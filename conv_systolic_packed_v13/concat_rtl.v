
//------> /hd/cad/mentor/2016.9/Mgc_home/pkgs/siflibs/mgc_in_wire_wait_v1.v 
//------------------------------------------------------------------------------
// Catapult Synthesis - Sample I/O Port Library
//
// Copyright (c) 2003-2015 Mentor Graphics Corp.
//       All Rights Reserved
//
// This document may be used and distributed without restriction provided that
// this copyright statement is not removed from the file and that any derivative
// work contains this copyright notice.
//
// The design information contained in this file is intended to be an example
// of the functionality which the end user may study in preparation for creating
// their own custom interfaces. This design does not necessarily present a 
// complete implementation of the named protocol or standard.
//
//------------------------------------------------------------------------------


module mgc_in_wire_wait_v1 (ld, vd, d, lz, vz, z);

  parameter integer rscid = 1;
  parameter integer width = 8;

  input              ld;
  output             vd;
  output [width-1:0] d;
  output             lz;
  input              vz;
  input  [width-1:0] z;

  wire               vd;
  wire   [width-1:0] d;
  wire               lz;

  assign d = z;
  assign lz = ld;
  assign vd = vz;

endmodule


//------> /hd/cad/mentor/2016.9/Mgc_home/pkgs/siflibs/mgc_out_stdreg_wait_v1.v 
//------------------------------------------------------------------------------
// Catapult Synthesis - Sample I/O Port Library
//
// Copyright (c) 2003-2015 Mentor Graphics Corp.
//       All Rights Reserved
//
// This document may be used and distributed without restriction provided that
// this copyright statement is not removed from the file and that any derivative
// work contains this copyright notice.
//
// The design information contained in this file is intended to be an example
// of the functionality which the end user may study in preparation for creating
// their own custom interfaces. This design does not necessarily present a 
// complete implementation of the named protocol or standard.
//
//------------------------------------------------------------------------------


module mgc_out_stdreg_wait_v1 (ld, vd, d, lz, vz, z);

  parameter integer rscid = 1;
  parameter integer width = 8;

  input              ld;
  output             vd;
  input  [width-1:0] d;
  output             lz;
  input              vz;
  output [width-1:0] z;

  wire               vd;
  wire               lz;
  wire   [width-1:0] z;

  assign z = d;
  assign lz = ld;
  assign vd = vz;

endmodule



//------> /hd/cad/mentor/2016.9/Mgc_home/pkgs/siflibs/mgc_shift_r_beh_v4.v 
module mgc_shift_r_v4(a,s,z);
   parameter    width_a = 4;
   parameter    signd_a = 1;
   parameter    width_s = 2;
   parameter    width_z = 8;

   input [width_a-1:0] a;
   input [width_s-1:0] s;
   output [width_z -1:0] z;

   generate
     if (signd_a)
     begin: SIGNED
       assign z = fshr_u(a,s,a[width_a-1]);
     end
     else
     begin: UNSIGNED
       assign z = fshr_u(a,s,1'b0);
     end
   endgenerate

   //Shift right - unsigned shift argument
   function [width_z-1:0] fshr_u;
      input [width_a-1:0] arg1;
      input [width_s-1:0] arg2;
      input sbit;
      parameter olen = width_z;
      parameter ilen = signd_a ? width_a : width_a+1;
      parameter len = (ilen >= olen) ? ilen : olen;
      reg signed [len-1:0] result;
      reg signed [len-1:0] result_t;
      begin
        result_t = $signed( {(len){sbit}} );
        result_t[width_a-1:0] = arg1;
        result = result_t >>> arg2;
        fshr_u =  result[olen-1:0];
      end
   endfunction // fshl_u

endmodule

//------> /hd/cad/mentor/2016.9/Mgc_home/pkgs/siflibs/ram_sync_dualRW_be_generic.v 
//------------------------------------------------------------------------------
// Catapult Synthesis - Sample I/O Port Library
//
// Copyright (c) 2003-2015 Mentor Graphics Corp.
//       All Rights Reserved
//
// This document may be used and distributed without restriction provided that
// this copyright statement is not removed from the file and that any derivative
// work contains this copyright notice.
//
// The design information contained in this file is intended to be an example
// of the functionality which the end user may study in preparation for creating
// their own custom interfaces. This design does not necessarily present a 
// complete implementation of the named protocol or standard.
//
//------------------------------------------------------------------------------

module ram_sync_dualRW_be ( data_in, addr, re, we, data_out, clk, a_rst, s_rst, en);

  parameter ram_id = 1;
  parameter words = 'd16;
  parameter width = 'd16;
  parameter addr_width = 4;
  parameter [0:0] a_reset_active = 1;
  parameter [0:0] s_reset_active = 1;
  parameter [0:0] enable_active = 1;
  parameter [0:0] re_active = 1;
  parameter [0:0] we_active = 1;
  parameter num_byte_enables = 1;
  parameter [0:0] clock_edge = 1;
  parameter no_of_RAM_dualRW_readwrite_port = 2;

  localparam byte_width = width / num_byte_enables;

  input [(width*no_of_RAM_dualRW_readwrite_port)-1:0] data_in;
  input [(addr_width*no_of_RAM_dualRW_readwrite_port)-1:0] addr;
  input [(num_byte_enables*no_of_RAM_dualRW_readwrite_port)-1:0] re;
  input [(num_byte_enables*no_of_RAM_dualRW_readwrite_port)-1:0] we;
  output [(width*no_of_RAM_dualRW_readwrite_port)-1:0] data_out;
  input clk;
  input a_rst;
  input s_rst;
  input en;

  // synopsys translate_off
  reg  [width-1:0] mem [words-1:0];
  
  wire [num_byte_enables-1:0] reA;
  wire [num_byte_enables-1:0] reB;
  wire [num_byte_enables-1:0] weA;
  wire [num_byte_enables-1:0] weB;

  wire [width-1:0] data_inA;
  wire [width-1:0] data_inB;
  reg [width-1:0] data_outA;
  reg [width-1:0] data_outB;
  wire [addr_width-1:0] addrA;
  wire [addr_width-1:0] addrB;

  integer count;
  initial
  begin
    for (count = 0; count < words; count = count + 1) 
      mem[count] = 0;
  end

  integer i;
  generate
    if ( clock_edge == 1'b1 )
    begin: POSEDGE_BLK
      always @(posedge clk)
      begin
        if ( en == enable_active )
        begin
          for (i = 0; i < num_byte_enables; i = i + 1)
          begin
            if ( reA[i] == re_active )
              data_outA[i*byte_width+: byte_width] <= mem[addrA][i*byte_width+: byte_width];
            else
              data_outA[i*byte_width+: byte_width] <= {(byte_width){1'bX}};
            if ( reB[i] == re_active )
              data_outB[i*byte_width+: byte_width] <= mem[addrB][i*byte_width+: byte_width];
            else
              data_outB[i*byte_width+: byte_width] <= {(byte_width){1'bX}};
            if (weA[i] == we_active)
              mem[addrA][i*byte_width+:byte_width] <= data_inA[i*byte_width+:byte_width];
            if (weB[i] == we_active)
              mem[addrB][i*byte_width+:byte_width] <= data_inB[i*byte_width+:byte_width];
          end
        end
      end
    end else
    begin: NEGEDGE_BLK
      always @(negedge clk)
      begin
        if ( en == enable_active )
        begin
          for (i = 0; i < num_byte_enables; i = i + 1)
          begin
            if ( reA[i] == re_active )
              data_outA[i*byte_width+: byte_width] <= mem[addrA][i*byte_width+: byte_width];
            else
              data_outA[i*byte_width+: byte_width] <= {(byte_width){1'bX}};
            if ( reB[i] == re_active )
              data_outB[i*byte_width+: byte_width] <= mem[addrB][i*byte_width+: byte_width];
            else
              data_outB[i*byte_width+: byte_width] <= {(byte_width){1'bX}};
            if (weA[i] == we_active)
              mem[addrA][i*byte_width+:byte_width] <= data_inA[i*byte_width+:byte_width];
            if (weB[i] == we_active)
              mem[addrB][i*byte_width+:byte_width] <= data_inB[i*byte_width+:byte_width];
          end
        end
      end
    end
  endgenerate

  assign reA = re[1*num_byte_enables-1:0*num_byte_enables];
  assign reB = re[2*num_byte_enables-1:1*num_byte_enables];
  assign weA = we[1*num_byte_enables-1:0*num_byte_enables];
  assign weB = we[2*num_byte_enables-1:1*num_byte_enables];

  assign addrA = addr[addr_width-1:0];
  assign addrB = addr[(2*addr_width)-1:addr_width];
  assign data_inA = data_in[width-1:0];
  assign data_inB = data_in[(2*width)-1:width];

  assign data_out = {data_outB,data_outA};

  // synopsys translate_on
endmodule

module ram_sync_dualRW_be_port ( data_in_d, addr_d, re_d, we_d, data_out_d, data_in, addr, re, we, data_out, clk, a_rst, s_rst, en);

  parameter ram_id = 1;
  parameter words = 16;
  parameter width = 16;
  parameter addr_width = 4;
  parameter [0:0] a_reset_active = 1;
  parameter [0:0] s_reset_active = 1;
  parameter [0:0] enable_active = 1;
  parameter [0:0] re_active = 1;
  parameter [0:0] we_active = 1;
  parameter num_byte_enables = 1;
  parameter [0:0] clock_edge = 1;
  parameter no_of_RAM_dualRW_readwrite_port = 2;

  input [(width*no_of_RAM_dualRW_readwrite_port)-1:0] data_in_d;
  input [(addr_width*no_of_RAM_dualRW_readwrite_port)-1:0] addr_d;
  input [(num_byte_enables*no_of_RAM_dualRW_readwrite_port)-1:0] re_d;
  input [(num_byte_enables*no_of_RAM_dualRW_readwrite_port)-1:0] we_d;
  output [(width*no_of_RAM_dualRW_readwrite_port)-1:0] data_out_d;

  output [(width*no_of_RAM_dualRW_readwrite_port)-1:0] data_in;
  output [(addr_width*no_of_RAM_dualRW_readwrite_port)-1:0] addr;
  output [(num_byte_enables*no_of_RAM_dualRW_readwrite_port)-1:0] re;
  output [(num_byte_enables*no_of_RAM_dualRW_readwrite_port)-1:0] we;
  input [(width*no_of_RAM_dualRW_readwrite_port)-1:0] data_out;

  input clk;
  input a_rst;
  input s_rst;
  input en;

  assign data_in    = data_in_d;
  assign addr       = addr_d;
  assign re         = re_d;
  assign we         = we_d;
  assign data_out_d = data_out;

endmodule

//------> /hd/cad/mentor/2016.9/Mgc_home/pkgs/siflibs/mgc_io_sync_v1.v 
//------------------------------------------------------------------------------
// Catapult Synthesis - Sample I/O Port Library
//
// Copyright (c) 2003-2015 Mentor Graphics Corp.
//       All Rights Reserved
//
// This document may be used and distributed without restriction provided that
// this copyright statement is not removed from the file and that any derivative
// work contains this copyright notice.
//
// The design information contained in this file is intended to be an example
// of the functionality which the end user may study in preparation for creating
// their own custom interfaces. This design does not necessarily present a 
// complete implementation of the named protocol or standard.
//
//------------------------------------------------------------------------------


module mgc_io_sync_v1 (ld, lz);
    parameter valid = 0;

    input  ld;
    output lz;

    wire   lz;

    assign lz = ld;

endmodule


module mgc_in_sync_v1 (vd, vz);
    parameter valid = 1;

    output vd;
    input  vz;

    wire   vd;

    assign vd = vz;

endmodule



//------> /hd/cad/mentor/2016.9/Mgc_home/pkgs/siflibs/mgc_out_fifo_wait_core_v2001_v9.v 
//------------------------------------------------------------------------------
// Catapult Synthesis - Sample I/O Port Library
//
// Copyright (c) 2003-2015 Mentor Graphics Corp.
//       All Rights Reserved
//
// This document may be used and distributed without restriction provided that
// this copyright statement is not removed from the file and that any derivative
// work contains this copyright notice.
//
// The design information contained in this file is intended to be an example
// of the functionality which the end user may study in preparation for creating
// their own custom interfaces. This design does not necessarily present a 
// complete implementation of the named protocol or standard.
//
//------------------------------------------------------------------------------


module mgc_out_fifo_wait_core_v9 (clk, en, arst, srst, ld, vd, d, lz, vz,  z, sd);

    parameter integer rscid   = 0; // resource ID
    parameter integer width   = 8; // fifo width
    parameter integer sz_width = 8; // size of port for elements in fifo
    parameter integer fifo_sz = 8; // fifo depth
    parameter integer ph_clk  =  1; // clock polarity 1=rising edge, 0=falling edge
    parameter integer ph_en   =  1; // clock enable polarity
    parameter integer ph_arst =  1; // async reset polarity
    parameter integer ph_srst =  1; // sync reset polarity
    parameter integer ph_log2 = 3; // log2(fifo_sz)

   localparam integer  fifo_b = width * fifo_sz;

    input                 clk;
    input                 en;
    input                 arst;
    input                 srst;
    input                 ld;    // load data
    output                vd;    // fifo full active low
    input     [width-1:0] d;
    output                lz;    // fifo ready to send
    input                 vz;    // dest ready for data
    output    [width-1:0] z;
    output    [sz_width-1:0]      sd; 

    localparam integer fifo_mx = (fifo_sz > 0) ? (fifo_sz-1) : 0 ;
    localparam integer fifo_mx_over_8 = fifo_mx / 8 ;
    reg      [fifo_mx:0] stat_pre;
    reg      [fifo_mx:0] stat;
    reg      [( (fifo_b > 0) ? fifo_b : 1)-1:0] buff_pre;
    reg      [( (fifo_b > 0) ? fifo_b : 1)-1:0] buff;
    wire     [fifo_mx:0] en_l;
    wire     [fifo_mx_over_8:0] en_l_s;

    reg       [width-1:0] buff_nxt;

    reg                   stat_nxt;
    reg                   stat_before;
    reg                   stat_after;
    reg       [fifo_mx:0] en_l_var;

    integer               i;
    genvar                eni;

    wire [32:0]           size_t;
    reg [31:0]            count;
    reg [31:0]            count_t;
    reg [32:0]            n_elem;
    // synopsys translate_off
    reg [31:0]            peak = 32'b0;
    // synopsys translate_on
    wire                  active;

    assign active = ld | vz; // (ld & ~vd) | (vz & ~lz);

    genvar igen;

    generate
    if ( fifo_sz > 0 )
    begin: FIFO_REG
      wire [31:0]           delta;
      //  0 :  32'b0      if ld==0 and (vz & stat[fifo_sz-1])==0   
      //               or if ld==1 and (vz & stat[fifo_sz-1])==1
      // +1 :  32'b1      if ld==1 and (vz & stat[fifo_sz-1])==0
      // -1 : {32{1'b1}}  if ld==0 and (vz & stat[fifo_sz-1])==1
      assign delta   =  {{31{(~ld & (vz & stat[fifo_sz-1]))}} , (vz & stat[fifo_sz-1]) ^ ld};
      assign vd = vz | ~stat[0];
      assign lz = ld | stat[fifo_sz-1];
      assign size_t = count + delta;
      assign sd = size_t[sz_width-1:0];
      assign z = (stat[fifo_sz-1]) ? buff[fifo_b-1:width*(fifo_sz-1)] : d;

      always @(*)
      begin: FIFOPROC
        n_elem = 33'b0;
        for (i = fifo_sz-1; i >= 0; i = i - 1)
        begin
          stat_before = (i != 0) ? stat[i-1] : 1'b0;
          stat_after = (i != (fifo_sz-1)) ? stat[i+1] : 1'b1;
          stat_nxt = stat_after &
                    (stat_before | (stat[i] & (~vz)) | (stat[i] & ld) | (ld & (~vz)));
  
          stat_pre[i] = stat_nxt;
          if (vz & stat_before )
            begin
              buff_nxt[0+:width] = buff[width*(i-1)+:width];
              en_l_var[i] = 1'b1;
            end
          else if (ld & ~((~vz) & stat[i]))
            begin
              buff_nxt = d;
              en_l_var[i] = 1'b1;
            end
          else
            begin
              buff_nxt = d; // Don't care input to disabled flop
              en_l_var[i] = 1'b0;
            end
             
          buff_pre[width*i+:width] = buff_nxt[0+:width];
  
          if ((stat_after == 1'b1) & (stat[i] == 1'b0)) 
            n_elem = ($unsigned(fifo_sz) - 1) - $unsigned(i);
        end

        if ( stat[fifo_sz-1] == 1'b0 )
          count_t = 32'b0;
        else if ( stat[0] == 1'b1 )
          count_t = fifo_sz;
        else 
          count_t = n_elem[31:0];
        count = count_t;
        // synopsys translate_off
        if ( peak < count )
          peak = count;
        // synopsys translate_on
      end

      if (ph_en) begin: PH_EN_HI
        assign en_l_s[fifo_mx_over_8] = en & active;
        for (igen = 0 ; igen < fifo_sz ; igen = igen + 1) begin: NEED_A_LABEL
          assign en_l[igen] = en & en_l_var[igen];
        end
        for (igen = 1 ; igen <= fifo_mx_over_8 ; igen = igen + 1) begin: NEED_A_LABEL2
          assign  en_l_s[igen-1] = en & (stat[igen*8]) & (active);
        end
      end
      else begin: PH_EN_LO
        assign en_l_s[fifo_mx_over_8] = en | ~active;
        for (igen = 0 ; igen < fifo_sz ; igen = igen + 1) begin: NEED_A_LABEL3
          assign en_l[igen] = en | ~en_l_var[igen];
        end
        for (igen = 1 ; igen <= fifo_mx_over_8 ; igen = igen + 1) begin: NEED_A_LABEL2
          assign  en_l_s[igen-1] = en | (~stat[igen*8]) | (~active);
        end
      end

      // Output registers:
      for (eni = fifo_sz-1; eni >= 0; eni = eni - 1)
      begin: BUF_GEN
        if (ph_clk==1) begin: POS_BUF
          if (ph_arst==0) begin: LABEL1
            always @(posedge clk or negedge arst)
            if (arst == 1'b0) begin
              stat[eni] <= 1'b0;
            end
            else if (srst == ph_srst) begin
              stat[eni] <= 1'b0;
            end
            else if (en_l_s[eni/8] == ph_en) begin
              stat[eni] <= stat_pre[eni];
            end
          end
          else begin: LABEL2 // ph_arst==1
            always @(posedge clk or posedge arst)
            if (arst == 1'b1) begin
              stat[eni] <= 1'b0;
            end
            else if (srst == ph_srst) begin
              stat[eni] <= 1'b0;
            end
            else if (en_l_s[eni/8] == ph_en) begin
              stat[eni] <= stat_pre[eni];
            end
          end
        end
        else begin: NEG_BUF
          if (ph_arst==0) begin: LABEL3
            always @(negedge clk or negedge arst)
            if (arst == 1'b0) begin
              stat[eni] <= 1'b0;
            end
            else if (srst == ph_srst) begin
              stat[eni] <= 1'b0;
            end
            else if (en_l_s[eni/8] == ph_en) begin
              stat[eni] <= stat_pre[eni];
            end
          end
          else begin: LABEL4 // ph_arst==1
            always @(negedge clk or posedge arst)
            if (arst == 1'b1) begin
              stat[eni] <= 1'b0;
            end
            else if (srst == ph_srst) begin
              stat[eni] <= 1'b0;
            end
            else if (en_l_s[eni/8] == ph_en) begin
              stat[eni] <= stat_pre[eni];
            end
          end
        end
      end

      for (eni = fifo_sz-1; eni >= 0; eni = eni - 1)
      begin: STATGEN2
        if (ph_clk==1) begin: POS_STAT
          if (ph_arst==0) begin: LABEL5
            always @(posedge clk or negedge arst)
            if (arst == 1'b0) begin
              buff[width*eni+:width] <= {width{1'b0}};
            end
            else if (srst == ph_srst) begin
              buff[width*eni+:width] <= {width{1'b0}};
            end
            else if (en_l[eni] == ph_en) begin
              buff[width*eni+:width] <= buff_pre[width*eni+:width];
            end
          end
          else begin: LABEL6 // ph_arst==1
            always @(posedge clk or posedge arst)
            if (arst == 1'b1) begin
              buff[width*eni+:width] <= {width{1'b0}};
            end
            else if (srst == ph_srst) begin
              buff[width*eni+:width] <= {width{1'b0}};
            end
            else if (en_l[eni] == ph_en) begin
              buff[width*eni+:width] <= buff_pre[width*eni+:width];
            end
          end
        end
        else begin: NEG_STAT // ph_clk==0
          if (ph_arst==0) begin: LABEL7
            always @(negedge clk or negedge arst)
            if (arst == 1'b0) begin
              buff[width*eni+:width] <= {width{1'b0}};
            end
            else if (srst == ph_srst) begin
              buff[width*eni+:width] <= {width{1'b0}};
            end
            else if (en_l[eni] == ph_en) begin
              buff[width*eni+:width] <= buff_pre[width*eni+:width];
            end
          end
          else begin: LABEL8 // ph_arst==1
            always @(negedge clk or posedge arst)
            if (arst == 1'b1) begin
              buff[width*eni+:width] <= {width{1'b0}};
            end
            else if (srst == ph_srst) begin
              buff[width*eni+:width] <= {width{1'b0}};
            end
            else if (en_l[eni] == ph_en) begin
              buff[width*eni+:width] <= buff_pre[width*eni+:width];
            end
          end
        end
      end
    end
    else
    begin: FEED_THRU
      assign vd = vz;
      assign lz = ld;
      assign z = d;
      assign sd = ld & ~vz;
    end
    endgenerate

endmodule



//------> /hd/cad/mentor/2016.9/Mgc_home/pkgs/siflibs/mgc_pipe_v2001_v10.v 
//------------------------------------------------------------------------------
// Catapult Synthesis - Sample I/O Port Library
//
// Copyright (c) 2003-2015 Mentor Graphics Corp.
//       All Rights Reserved
//
// This document may be used and distributed without restriction provided that
// this copyright statement is not removed from the file and that any derivative
// work contains this copyright notice.
//
// The design information contained in this file is intended to be an example
// of the functionality which the end user may study in preparation for creating
// their own custom interfaces. This design does not necessarily present a 
// complete implementation of the named protocol or standard.
//
//------------------------------------------------------------------------------


/*
 *
 *             _______________________________________________
 * WRITER    |                                               |          READER
 *           |           MGC_PIPE                            |
 *           |           __________________________          |
 *        --<| vdout  --<| vd ---------------  vz<|-----ldin<|---
 *           |           |      FIFO              |          |
 *        ---|>ldout  ---|>ld ---------------- lz |> ---vdin |>--
 *        ---|>dout -----|>d  ---------------- dz |> ----din |>--
 *           |           |________________________|          |
 *           |_______________________________________________|
 *
 *    vdout - can be considered as a notFULL signal
 *    vdin  - can be considered as a notEMPTY signal
 *    write_stall - an internal debug signal formed from ldout & !vdout
 *    read_stall  - an internal debug signal formed from ldin & !vdin
 *
 */
// two clock pipe
module mgc_pipe_v10 (clk, en, arst, srst, ldin, vdin, din, ldout, vdout, dout, sd);

    parameter integer rscid   = 0; // resource ID
    parameter integer width   = 8; // fifo width
    parameter integer sz_width = 8; // width of size of elements in fifo
    parameter integer fifo_sz = 8; // fifo depth
    parameter integer log2_sz = 3; // log2(fifo_sz)
    parameter integer ph_clk  = 1;  // clock polarity 1=rising edge, 0=falling edge
    parameter integer ph_en   = 1;  // clock enable polarity
    parameter integer ph_arst = 1;  // async reset polarity
    parameter integer ph_srst = 1;  // sync reset polarity

    input              clk;
    input              en;
    input              arst;
    input              srst;
    input              ldin;
    output             vdin;
    output [width-1:0] din;
    input              ldout;
    output             vdout;
    input  [width-1:0] dout;
    output [sz_width-1:0]      sd;

    // synopsys translate_off
    wire               write_stall;
    wire               read_stall;
    assign write_stall = ldout & !vdout;
    assign read_stall = ldin & !vdin;
    // synopsys translate_on

    mgc_out_fifo_wait_core_v9
    #(
        .rscid    (rscid),
        .width    (width),
        .sz_width (sz_width),
        .fifo_sz  (fifo_sz),
        .ph_clk   (ph_clk),
        .ph_en    (ph_en),
        .ph_arst  (ph_arst),
        .ph_srst  (ph_srst),
        .ph_log2  (log2_sz)
    )
    FIFO
    (
        .clk     (clk),
        .en      (en),
        .arst    (arst),
        .srst    (srst),
        .ld      (ldout),
        .vd      (vdout),
        .d       (dout),
        .lz      (vdin),
        .vz      (ldin),
        .z       (din),
        .sd      (sd)
    );

endmodule


//------> ./rtl.v 
// ----------------------------------------------------------------------
//  HLS HDL:        Verilog Netlister
//  HLS Version:    10.0/263344 Production Release
//  HLS Date:       Sun Jul  3 19:13:39 PDT 2016
// 
//  Generated by:   xuany@kiwi
//  Generated date: Mon Mar 26 14:54:09 2018
// ----------------------------------------------------------------------

// 
// ------------------------------------------------------------------
//  Design Unit:    double_buffetmobz_3_cns_bctl
// ------------------------------------------------------------------


module double_buffetmobz_3_cns_bctl (
  clk, rst, dout_3_rsc_data_in_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst, dout_3_rsc_addr_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst,
      dout_3_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst, dout_3_rsc_req_vz_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst,
      dout_3_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz, din_3_rsc_addr_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst,
      din_3_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst, din_3_rsc_data_out_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst,
      din_3_rsc_req_vz_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst, din_3_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz,
      dout_3_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_bud, dout_3_rsc_rls_lz_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_bud,
      din_3_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_bud, din_3_rsc_rls_lz_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_bud,
      shr_mem_3_cns_S0, shr_mem_3_cns_R0, shr_mem_3_cns_S1, shr_mem_3_cns_R1, shr_mem_3_cns_data_in_shi0,
      shr_mem_3_cns_data_in_shi1, shr_mem_3_cns_addr_shi0, shr_mem_3_cns_addr_shi1,
      shr_mem_3_cns_re_shi0, shr_mem_3_cns_re_shi1, shr_mem_3_cns_we_shi0, shr_mem_3_cns_we_shi1,
      shr_mem_3_cns_data_out_sho0, shr_mem_3_cns_data_out_sho1, shr_mem_3_cns_S1_pff,
      din_3_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_pff, din_3_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_bud_pff,
      dout_3_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_pff, dout_3_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_bud_pff,
      shr_mem_3_cns_S0_pff
);
  input clk;
  input rst;
  input [31:0] dout_3_rsc_data_in_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst;
  input [13:0] dout_3_rsc_addr_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst;
  input [1:0] dout_3_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst;
  output dout_3_rsc_req_vz_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst;
  input [1:0] dout_3_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz;
  input [13:0] din_3_rsc_addr_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst;
  input [1:0] din_3_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst;
  output [31:0] din_3_rsc_data_out_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst;
  output din_3_rsc_req_vz_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst;
  input [1:0] din_3_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz;
  output [1:0] dout_3_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_bud;
  input dout_3_rsc_rls_lz_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_bud;
  output [1:0] din_3_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_bud;
  input din_3_rsc_rls_lz_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_bud;
  output shr_mem_3_cns_S0;
  input shr_mem_3_cns_R0;
  output shr_mem_3_cns_S1;
  input shr_mem_3_cns_R1;
  output [31:0] shr_mem_3_cns_data_in_shi0;
  output [31:0] shr_mem_3_cns_data_in_shi1;
  output [13:0] shr_mem_3_cns_addr_shi0;
  output [13:0] shr_mem_3_cns_addr_shi1;
  output [1:0] shr_mem_3_cns_re_shi0;
  output [1:0] shr_mem_3_cns_re_shi1;
  output [1:0] shr_mem_3_cns_we_shi0;
  output [1:0] shr_mem_3_cns_we_shi1;
  input [31:0] shr_mem_3_cns_data_out_sho0;
  input [31:0] shr_mem_3_cns_data_out_sho1;
  output shr_mem_3_cns_S1_pff;
  input [1:0] din_3_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_pff;
  output [1:0] din_3_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_bud_pff;
  input [1:0] dout_3_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_pff;
  output [1:0] dout_3_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_bud_pff;
  output shr_mem_3_cns_S0_pff;


  // Interconnect Declarations
  reg [1:0] dout_3_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buy;
  reg [1:0] din_3_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buy;
  wire shr_mem_3_cns_PC0;
  reg shr_mem_3_cns_ppidx;
  reg [1:0] shr_mem_3_cns_ppown;
  wire shr_mem_3_cns_PC1;
  reg shr_mem_3_cns_ppidx_1;
  reg [1:0] shr_mem_3_cns_ppown_1;
  wire shr_mem_3_and_5_cse_pff;
  wire [1:0] shr_mem_3_acc_1_rmff;
  wire [3:0] nl_shr_mem_3_acc_1_rmff;
  wire shr_mem_3_xor_1_rmff;
  wire [1:0] shr_mem_3_acc_rmff;
  wire [3:0] nl_shr_mem_3_acc_rmff;
  wire shr_mem_3_xor_rmff;
  wire shr_mem_3_and_7_cse_pff;

  wire[0:0] shr_mem_3_shr_mem_3_not_nl;
  wire[0:0] shr_mem_3_shr_mem_3_shr_mem_3_nand_1_nl;
  wire[0:0] shr_mem_3_shr_mem_3_not_1_nl;
  wire[0:0] shr_mem_3_shr_mem_3_shr_mem_3_nand_nl;

  // Interconnect Declarations for Component Instantiations 
  assign dout_3_rsc_req_vz_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst = shr_mem_3_cns_R0;
  assign din_3_rsc_req_vz_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst = shr_mem_3_cns_R1;
  assign shr_mem_3_xor_rmff = shr_mem_3_cns_ppidx ^ shr_mem_3_cns_PC0;
  assign nl_shr_mem_3_acc_rmff = shr_mem_3_cns_ppown + conv_u2u_1_2(shr_mem_3_cns_PC0)
      + conv_s2u_1_2(shr_mem_3_cns_PC1);
  assign shr_mem_3_acc_rmff = nl_shr_mem_3_acc_rmff[1:0];
  assign shr_mem_3_cns_PC0 = shr_mem_3_cns_S0 & dout_3_rsc_rls_lz_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_bud;
  assign shr_mem_3_xor_1_rmff = shr_mem_3_cns_ppidx_1 ^ shr_mem_3_cns_PC1;
  assign nl_shr_mem_3_acc_1_rmff = shr_mem_3_cns_ppown_1 + conv_u2u_1_2(shr_mem_3_cns_PC1)
      + conv_s2u_1_2(shr_mem_3_cns_PC0);
  assign shr_mem_3_acc_1_rmff = nl_shr_mem_3_acc_1_rmff[1:0];
  assign shr_mem_3_cns_PC1 = shr_mem_3_cns_S1 & din_3_rsc_rls_lz_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_bud;
  assign din_3_rsc_data_out_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst = MUX_v_32_2_2(shr_mem_3_cns_data_out_sho0,
      shr_mem_3_cns_data_out_sho1, shr_mem_3_cns_ppidx_1);
  assign shr_mem_3_cns_data_in_shi0 = dout_3_rsc_data_in_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst;
  assign shr_mem_3_cns_addr_shi0 = MUX_v_14_2_2(dout_3_rsc_addr_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst,
      din_3_rsc_addr_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst, shr_mem_3_and_5_cse_pff);
  assign shr_mem_3_cns_S1 = (shr_mem_3_cns_ppown_1!=2'b00);
  assign shr_mem_3_cns_S1_pff = (shr_mem_3_acc_1_rmff!=2'b00);
  assign shr_mem_3_and_5_cse_pff = shr_mem_3_cns_S1_pff & (~ shr_mem_3_xor_1_rmff);
  assign shr_mem_3_shr_mem_3_not_nl = ~ shr_mem_3_and_5_cse_pff;
  assign shr_mem_3_cns_re_shi0 = MUX_v_2_2_2(din_3_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_pff,
      2'b11, (shr_mem_3_shr_mem_3_not_nl));
  assign din_3_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_bud = ~ din_3_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buy;
  assign din_3_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_bud_pff = din_3_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst;
  assign shr_mem_3_shr_mem_3_shr_mem_3_nand_1_nl = ~(shr_mem_3_cns_S0_pff & (~ shr_mem_3_xor_rmff));
  assign shr_mem_3_cns_we_shi0 = MUX_v_2_2_2(dout_3_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_pff,
      2'b11, (shr_mem_3_shr_mem_3_shr_mem_3_nand_1_nl));
  assign dout_3_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_bud = ~ dout_3_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buy;
  assign dout_3_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_bud_pff = dout_3_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst;
  assign shr_mem_3_cns_S0 = ~((shr_mem_3_cns_ppown==2'b10));
  assign shr_mem_3_cns_S0_pff = ~((shr_mem_3_acc_rmff==2'b10));
  assign shr_mem_3_cns_data_in_shi1 = dout_3_rsc_data_in_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst;
  assign shr_mem_3_cns_addr_shi1 = MUX_v_14_2_2(dout_3_rsc_addr_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst,
      din_3_rsc_addr_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst, shr_mem_3_and_7_cse_pff);
  assign shr_mem_3_and_7_cse_pff = shr_mem_3_cns_S1_pff & shr_mem_3_xor_1_rmff;
  assign shr_mem_3_shr_mem_3_not_1_nl = ~ shr_mem_3_and_7_cse_pff;
  assign shr_mem_3_cns_re_shi1 = MUX_v_2_2_2(din_3_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_pff,
      2'b11, (shr_mem_3_shr_mem_3_not_1_nl));
  assign shr_mem_3_shr_mem_3_shr_mem_3_nand_nl = ~(shr_mem_3_cns_S0_pff & shr_mem_3_xor_rmff);
  assign shr_mem_3_cns_we_shi1 = MUX_v_2_2_2(dout_3_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_pff,
      2'b11, (shr_mem_3_shr_mem_3_shr_mem_3_nand_nl));
  always @(posedge clk) begin
    if ( rst ) begin
      dout_3_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buy <= 2'b0;
      din_3_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buy <= 2'b0;
      shr_mem_3_cns_ppidx <= 1'b0;
      shr_mem_3_cns_ppown <= 2'b0;
      shr_mem_3_cns_ppidx_1 <= 1'b0;
      shr_mem_3_cns_ppown_1 <= 2'b0;
    end
    else begin
      dout_3_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buy <= ~ dout_3_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst;
      din_3_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buy <= ~ din_3_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst;
      shr_mem_3_cns_ppidx <= shr_mem_3_xor_rmff;
      shr_mem_3_cns_ppown <= shr_mem_3_acc_rmff;
      shr_mem_3_cns_ppidx_1 <= shr_mem_3_xor_1_rmff;
      shr_mem_3_cns_ppown_1 <= shr_mem_3_acc_1_rmff;
    end
  end

  function [13:0] MUX_v_14_2_2;
    input [13:0] input_0;
    input [13:0] input_1;
    input [0:0] sel;
    reg [13:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_14_2_2 = result;
  end
  endfunction


  function [1:0] MUX_v_2_2_2;
    input [1:0] input_0;
    input [1:0] input_1;
    input [0:0] sel;
    reg [1:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_2_2_2 = result;
  end
  endfunction


  function [31:0] MUX_v_32_2_2;
    input [31:0] input_0;
    input [31:0] input_1;
    input [0:0] sel;
    reg [31:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_32_2_2 = result;
  end
  endfunction


  function  [1:0] conv_s2u_1_2 ;
    input [0:0]  vector ;
  begin
    conv_s2u_1_2 = {vector[0], vector};
  end
  endfunction


  function  [1:0] conv_u2u_1_2 ;
    input [0:0]  vector ;
  begin
    conv_u2u_1_2 = {1'b0, vector};
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    double_buffetmobz_2_cns_bctl
// ------------------------------------------------------------------


module double_buffetmobz_2_cns_bctl (
  clk, rst, dout_2_rsc_data_in_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst, dout_2_rsc_addr_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst,
      dout_2_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst, dout_2_rsc_req_vz_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst,
      dout_2_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz, din_2_rsc_addr_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst,
      din_2_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst, din_2_rsc_data_out_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst,
      din_2_rsc_req_vz_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst, din_2_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz,
      dout_2_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_bud, dout_2_rsc_rls_lz_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_bud,
      din_2_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_bud, din_2_rsc_rls_lz_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_bud,
      shr_mem_2_cns_S0, shr_mem_2_cns_R0, shr_mem_2_cns_S1, shr_mem_2_cns_R1, shr_mem_2_cns_data_in_shi0,
      shr_mem_2_cns_data_in_shi1, shr_mem_2_cns_addr_shi0, shr_mem_2_cns_addr_shi1,
      shr_mem_2_cns_re_shi0, shr_mem_2_cns_re_shi1, shr_mem_2_cns_we_shi0, shr_mem_2_cns_we_shi1,
      shr_mem_2_cns_data_out_sho0, shr_mem_2_cns_data_out_sho1, shr_mem_2_cns_S1_pff,
      din_2_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_pff, din_2_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_bud_pff,
      dout_2_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_pff, dout_2_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_bud_pff,
      shr_mem_2_cns_S0_pff
);
  input clk;
  input rst;
  input [31:0] dout_2_rsc_data_in_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst;
  input [13:0] dout_2_rsc_addr_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst;
  input [1:0] dout_2_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst;
  output dout_2_rsc_req_vz_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst;
  input [1:0] dout_2_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz;
  input [13:0] din_2_rsc_addr_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst;
  input [1:0] din_2_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst;
  output [31:0] din_2_rsc_data_out_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst;
  output din_2_rsc_req_vz_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst;
  input [1:0] din_2_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz;
  output [1:0] dout_2_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_bud;
  input dout_2_rsc_rls_lz_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_bud;
  output [1:0] din_2_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_bud;
  input din_2_rsc_rls_lz_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_bud;
  output shr_mem_2_cns_S0;
  input shr_mem_2_cns_R0;
  output shr_mem_2_cns_S1;
  input shr_mem_2_cns_R1;
  output [31:0] shr_mem_2_cns_data_in_shi0;
  output [31:0] shr_mem_2_cns_data_in_shi1;
  output [13:0] shr_mem_2_cns_addr_shi0;
  output [13:0] shr_mem_2_cns_addr_shi1;
  output [1:0] shr_mem_2_cns_re_shi0;
  output [1:0] shr_mem_2_cns_re_shi1;
  output [1:0] shr_mem_2_cns_we_shi0;
  output [1:0] shr_mem_2_cns_we_shi1;
  input [31:0] shr_mem_2_cns_data_out_sho0;
  input [31:0] shr_mem_2_cns_data_out_sho1;
  output shr_mem_2_cns_S1_pff;
  input [1:0] din_2_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_pff;
  output [1:0] din_2_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_bud_pff;
  input [1:0] dout_2_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_pff;
  output [1:0] dout_2_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_bud_pff;
  output shr_mem_2_cns_S0_pff;


  // Interconnect Declarations
  reg [1:0] dout_2_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buy;
  reg [1:0] din_2_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buy;
  wire shr_mem_2_cns_PC0;
  reg shr_mem_2_cns_ppidx;
  reg [1:0] shr_mem_2_cns_ppown;
  wire shr_mem_2_cns_PC1;
  reg shr_mem_2_cns_ppidx_1;
  reg [1:0] shr_mem_2_cns_ppown_1;
  wire shr_mem_2_and_5_cse_pff;
  wire [1:0] shr_mem_2_acc_1_rmff;
  wire [3:0] nl_shr_mem_2_acc_1_rmff;
  wire shr_mem_2_xor_1_rmff;
  wire [1:0] shr_mem_2_acc_rmff;
  wire [3:0] nl_shr_mem_2_acc_rmff;
  wire shr_mem_2_xor_rmff;
  wire shr_mem_2_and_7_cse_pff;

  wire[0:0] shr_mem_2_shr_mem_2_not_nl;
  wire[0:0] shr_mem_2_shr_mem_2_shr_mem_2_nand_1_nl;
  wire[0:0] shr_mem_2_shr_mem_2_not_1_nl;
  wire[0:0] shr_mem_2_shr_mem_2_shr_mem_2_nand_nl;

  // Interconnect Declarations for Component Instantiations 
  assign dout_2_rsc_req_vz_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst = shr_mem_2_cns_R0;
  assign din_2_rsc_req_vz_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst = shr_mem_2_cns_R1;
  assign shr_mem_2_xor_rmff = shr_mem_2_cns_ppidx ^ shr_mem_2_cns_PC0;
  assign nl_shr_mem_2_acc_rmff = shr_mem_2_cns_ppown + conv_u2u_1_2(shr_mem_2_cns_PC0)
      + conv_s2u_1_2(shr_mem_2_cns_PC1);
  assign shr_mem_2_acc_rmff = nl_shr_mem_2_acc_rmff[1:0];
  assign shr_mem_2_cns_PC0 = shr_mem_2_cns_S0 & dout_2_rsc_rls_lz_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_bud;
  assign shr_mem_2_xor_1_rmff = shr_mem_2_cns_ppidx_1 ^ shr_mem_2_cns_PC1;
  assign nl_shr_mem_2_acc_1_rmff = shr_mem_2_cns_ppown_1 + conv_u2u_1_2(shr_mem_2_cns_PC1)
      + conv_s2u_1_2(shr_mem_2_cns_PC0);
  assign shr_mem_2_acc_1_rmff = nl_shr_mem_2_acc_1_rmff[1:0];
  assign shr_mem_2_cns_PC1 = shr_mem_2_cns_S1 & din_2_rsc_rls_lz_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_bud;
  assign din_2_rsc_data_out_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst = MUX_v_32_2_2(shr_mem_2_cns_data_out_sho0,
      shr_mem_2_cns_data_out_sho1, shr_mem_2_cns_ppidx_1);
  assign shr_mem_2_cns_data_in_shi0 = dout_2_rsc_data_in_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst;
  assign shr_mem_2_cns_addr_shi0 = MUX_v_14_2_2(dout_2_rsc_addr_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst,
      din_2_rsc_addr_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst, shr_mem_2_and_5_cse_pff);
  assign shr_mem_2_cns_S1 = (shr_mem_2_cns_ppown_1!=2'b00);
  assign shr_mem_2_cns_S1_pff = (shr_mem_2_acc_1_rmff!=2'b00);
  assign shr_mem_2_and_5_cse_pff = shr_mem_2_cns_S1_pff & (~ shr_mem_2_xor_1_rmff);
  assign shr_mem_2_shr_mem_2_not_nl = ~ shr_mem_2_and_5_cse_pff;
  assign shr_mem_2_cns_re_shi0 = MUX_v_2_2_2(din_2_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_pff,
      2'b11, (shr_mem_2_shr_mem_2_not_nl));
  assign din_2_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_bud = ~ din_2_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buy;
  assign din_2_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_bud_pff = din_2_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst;
  assign shr_mem_2_shr_mem_2_shr_mem_2_nand_1_nl = ~(shr_mem_2_cns_S0_pff & (~ shr_mem_2_xor_rmff));
  assign shr_mem_2_cns_we_shi0 = MUX_v_2_2_2(dout_2_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_pff,
      2'b11, (shr_mem_2_shr_mem_2_shr_mem_2_nand_1_nl));
  assign dout_2_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_bud = ~ dout_2_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buy;
  assign dout_2_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_bud_pff = dout_2_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst;
  assign shr_mem_2_cns_S0 = ~((shr_mem_2_cns_ppown==2'b10));
  assign shr_mem_2_cns_S0_pff = ~((shr_mem_2_acc_rmff==2'b10));
  assign shr_mem_2_cns_data_in_shi1 = dout_2_rsc_data_in_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst;
  assign shr_mem_2_cns_addr_shi1 = MUX_v_14_2_2(dout_2_rsc_addr_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst,
      din_2_rsc_addr_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst, shr_mem_2_and_7_cse_pff);
  assign shr_mem_2_and_7_cse_pff = shr_mem_2_cns_S1_pff & shr_mem_2_xor_1_rmff;
  assign shr_mem_2_shr_mem_2_not_1_nl = ~ shr_mem_2_and_7_cse_pff;
  assign shr_mem_2_cns_re_shi1 = MUX_v_2_2_2(din_2_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_pff,
      2'b11, (shr_mem_2_shr_mem_2_not_1_nl));
  assign shr_mem_2_shr_mem_2_shr_mem_2_nand_nl = ~(shr_mem_2_cns_S0_pff & shr_mem_2_xor_rmff);
  assign shr_mem_2_cns_we_shi1 = MUX_v_2_2_2(dout_2_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_pff,
      2'b11, (shr_mem_2_shr_mem_2_shr_mem_2_nand_nl));
  always @(posedge clk) begin
    if ( rst ) begin
      dout_2_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buy <= 2'b0;
      din_2_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buy <= 2'b0;
      shr_mem_2_cns_ppidx <= 1'b0;
      shr_mem_2_cns_ppown <= 2'b0;
      shr_mem_2_cns_ppidx_1 <= 1'b0;
      shr_mem_2_cns_ppown_1 <= 2'b0;
    end
    else begin
      dout_2_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buy <= ~ dout_2_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst;
      din_2_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buy <= ~ din_2_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst;
      shr_mem_2_cns_ppidx <= shr_mem_2_xor_rmff;
      shr_mem_2_cns_ppown <= shr_mem_2_acc_rmff;
      shr_mem_2_cns_ppidx_1 <= shr_mem_2_xor_1_rmff;
      shr_mem_2_cns_ppown_1 <= shr_mem_2_acc_1_rmff;
    end
  end

  function [13:0] MUX_v_14_2_2;
    input [13:0] input_0;
    input [13:0] input_1;
    input [0:0] sel;
    reg [13:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_14_2_2 = result;
  end
  endfunction


  function [1:0] MUX_v_2_2_2;
    input [1:0] input_0;
    input [1:0] input_1;
    input [0:0] sel;
    reg [1:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_2_2_2 = result;
  end
  endfunction


  function [31:0] MUX_v_32_2_2;
    input [31:0] input_0;
    input [31:0] input_1;
    input [0:0] sel;
    reg [31:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_32_2_2 = result;
  end
  endfunction


  function  [1:0] conv_s2u_1_2 ;
    input [0:0]  vector ;
  begin
    conv_s2u_1_2 = {vector[0], vector};
  end
  endfunction


  function  [1:0] conv_u2u_1_2 ;
    input [0:0]  vector ;
  begin
    conv_u2u_1_2 = {1'b0, vector};
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    double_buffetmobz_1_cns_bctl
// ------------------------------------------------------------------


module double_buffetmobz_1_cns_bctl (
  clk, rst, dout_1_rsc_data_in_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst, dout_1_rsc_addr_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst,
      dout_1_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst, dout_1_rsc_req_vz_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst,
      dout_1_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz, din_1_rsc_addr_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst,
      din_1_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst, din_1_rsc_data_out_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst,
      din_1_rsc_req_vz_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst, din_1_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz,
      dout_1_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_bud, dout_1_rsc_rls_lz_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_bud,
      din_1_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_bud, din_1_rsc_rls_lz_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_bud,
      shr_mem_1_cns_S0, shr_mem_1_cns_R0, shr_mem_1_cns_S1, shr_mem_1_cns_R1, shr_mem_1_cns_data_in_shi0,
      shr_mem_1_cns_data_in_shi1, shr_mem_1_cns_addr_shi0, shr_mem_1_cns_addr_shi1,
      shr_mem_1_cns_re_shi0, shr_mem_1_cns_re_shi1, shr_mem_1_cns_we_shi0, shr_mem_1_cns_we_shi1,
      shr_mem_1_cns_data_out_sho0, shr_mem_1_cns_data_out_sho1, shr_mem_1_cns_S1_pff,
      din_1_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_pff, din_1_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_bud_pff,
      dout_1_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_pff, dout_1_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_bud_pff,
      shr_mem_1_cns_S0_pff
);
  input clk;
  input rst;
  input [31:0] dout_1_rsc_data_in_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst;
  input [13:0] dout_1_rsc_addr_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst;
  input [1:0] dout_1_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst;
  output dout_1_rsc_req_vz_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst;
  input [1:0] dout_1_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz;
  input [13:0] din_1_rsc_addr_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst;
  input [1:0] din_1_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst;
  output [31:0] din_1_rsc_data_out_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst;
  output din_1_rsc_req_vz_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst;
  input [1:0] din_1_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz;
  output [1:0] dout_1_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_bud;
  input dout_1_rsc_rls_lz_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_bud;
  output [1:0] din_1_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_bud;
  input din_1_rsc_rls_lz_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_bud;
  output shr_mem_1_cns_S0;
  input shr_mem_1_cns_R0;
  output shr_mem_1_cns_S1;
  input shr_mem_1_cns_R1;
  output [31:0] shr_mem_1_cns_data_in_shi0;
  output [31:0] shr_mem_1_cns_data_in_shi1;
  output [13:0] shr_mem_1_cns_addr_shi0;
  output [13:0] shr_mem_1_cns_addr_shi1;
  output [1:0] shr_mem_1_cns_re_shi0;
  output [1:0] shr_mem_1_cns_re_shi1;
  output [1:0] shr_mem_1_cns_we_shi0;
  output [1:0] shr_mem_1_cns_we_shi1;
  input [31:0] shr_mem_1_cns_data_out_sho0;
  input [31:0] shr_mem_1_cns_data_out_sho1;
  output shr_mem_1_cns_S1_pff;
  input [1:0] din_1_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_pff;
  output [1:0] din_1_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_bud_pff;
  input [1:0] dout_1_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_pff;
  output [1:0] dout_1_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_bud_pff;
  output shr_mem_1_cns_S0_pff;


  // Interconnect Declarations
  reg [1:0] dout_1_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buy;
  reg [1:0] din_1_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buy;
  wire shr_mem_1_cns_PC0;
  reg shr_mem_1_cns_ppidx;
  reg [1:0] shr_mem_1_cns_ppown;
  wire shr_mem_1_cns_PC1;
  reg shr_mem_1_cns_ppidx_1;
  reg [1:0] shr_mem_1_cns_ppown_1;
  wire shr_mem_1_and_5_cse_pff;
  wire [1:0] shr_mem_1_acc_1_rmff;
  wire [3:0] nl_shr_mem_1_acc_1_rmff;
  wire shr_mem_1_xor_1_rmff;
  wire [1:0] shr_mem_1_acc_rmff;
  wire [3:0] nl_shr_mem_1_acc_rmff;
  wire shr_mem_1_xor_rmff;
  wire shr_mem_1_and_7_cse_pff;

  wire[0:0] shr_mem_1_shr_mem_1_not_nl;
  wire[0:0] shr_mem_1_shr_mem_1_shr_mem_1_nand_1_nl;
  wire[0:0] shr_mem_1_shr_mem_1_not_1_nl;
  wire[0:0] shr_mem_1_shr_mem_1_shr_mem_1_nand_nl;

  // Interconnect Declarations for Component Instantiations 
  assign dout_1_rsc_req_vz_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst = shr_mem_1_cns_R0;
  assign din_1_rsc_req_vz_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst = shr_mem_1_cns_R1;
  assign shr_mem_1_xor_rmff = shr_mem_1_cns_ppidx ^ shr_mem_1_cns_PC0;
  assign nl_shr_mem_1_acc_rmff = shr_mem_1_cns_ppown + conv_u2u_1_2(shr_mem_1_cns_PC0)
      + conv_s2u_1_2(shr_mem_1_cns_PC1);
  assign shr_mem_1_acc_rmff = nl_shr_mem_1_acc_rmff[1:0];
  assign shr_mem_1_cns_PC0 = shr_mem_1_cns_S0 & dout_1_rsc_rls_lz_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_bud;
  assign shr_mem_1_xor_1_rmff = shr_mem_1_cns_ppidx_1 ^ shr_mem_1_cns_PC1;
  assign nl_shr_mem_1_acc_1_rmff = shr_mem_1_cns_ppown_1 + conv_u2u_1_2(shr_mem_1_cns_PC1)
      + conv_s2u_1_2(shr_mem_1_cns_PC0);
  assign shr_mem_1_acc_1_rmff = nl_shr_mem_1_acc_1_rmff[1:0];
  assign shr_mem_1_cns_PC1 = shr_mem_1_cns_S1 & din_1_rsc_rls_lz_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_bud;
  assign din_1_rsc_data_out_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst = MUX_v_32_2_2(shr_mem_1_cns_data_out_sho0,
      shr_mem_1_cns_data_out_sho1, shr_mem_1_cns_ppidx_1);
  assign shr_mem_1_cns_data_in_shi0 = dout_1_rsc_data_in_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst;
  assign shr_mem_1_cns_addr_shi0 = MUX_v_14_2_2(dout_1_rsc_addr_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst,
      din_1_rsc_addr_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst, shr_mem_1_and_5_cse_pff);
  assign shr_mem_1_cns_S1 = (shr_mem_1_cns_ppown_1!=2'b00);
  assign shr_mem_1_cns_S1_pff = (shr_mem_1_acc_1_rmff!=2'b00);
  assign shr_mem_1_and_5_cse_pff = shr_mem_1_cns_S1_pff & (~ shr_mem_1_xor_1_rmff);
  assign shr_mem_1_shr_mem_1_not_nl = ~ shr_mem_1_and_5_cse_pff;
  assign shr_mem_1_cns_re_shi0 = MUX_v_2_2_2(din_1_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_pff,
      2'b11, (shr_mem_1_shr_mem_1_not_nl));
  assign din_1_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_bud = ~ din_1_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buy;
  assign din_1_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_bud_pff = din_1_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst;
  assign shr_mem_1_shr_mem_1_shr_mem_1_nand_1_nl = ~(shr_mem_1_cns_S0_pff & (~ shr_mem_1_xor_rmff));
  assign shr_mem_1_cns_we_shi0 = MUX_v_2_2_2(dout_1_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_pff,
      2'b11, (shr_mem_1_shr_mem_1_shr_mem_1_nand_1_nl));
  assign dout_1_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_bud = ~ dout_1_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buy;
  assign dout_1_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_bud_pff = dout_1_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst;
  assign shr_mem_1_cns_S0 = ~((shr_mem_1_cns_ppown==2'b10));
  assign shr_mem_1_cns_S0_pff = ~((shr_mem_1_acc_rmff==2'b10));
  assign shr_mem_1_cns_data_in_shi1 = dout_1_rsc_data_in_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst;
  assign shr_mem_1_cns_addr_shi1 = MUX_v_14_2_2(dout_1_rsc_addr_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst,
      din_1_rsc_addr_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst, shr_mem_1_and_7_cse_pff);
  assign shr_mem_1_and_7_cse_pff = shr_mem_1_cns_S1_pff & shr_mem_1_xor_1_rmff;
  assign shr_mem_1_shr_mem_1_not_1_nl = ~ shr_mem_1_and_7_cse_pff;
  assign shr_mem_1_cns_re_shi1 = MUX_v_2_2_2(din_1_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_pff,
      2'b11, (shr_mem_1_shr_mem_1_not_1_nl));
  assign shr_mem_1_shr_mem_1_shr_mem_1_nand_nl = ~(shr_mem_1_cns_S0_pff & shr_mem_1_xor_rmff);
  assign shr_mem_1_cns_we_shi1 = MUX_v_2_2_2(dout_1_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_pff,
      2'b11, (shr_mem_1_shr_mem_1_shr_mem_1_nand_nl));
  always @(posedge clk) begin
    if ( rst ) begin
      dout_1_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buy <= 2'b0;
      din_1_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buy <= 2'b0;
      shr_mem_1_cns_ppidx <= 1'b0;
      shr_mem_1_cns_ppown <= 2'b0;
      shr_mem_1_cns_ppidx_1 <= 1'b0;
      shr_mem_1_cns_ppown_1 <= 2'b0;
    end
    else begin
      dout_1_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buy <= ~ dout_1_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst;
      din_1_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buy <= ~ din_1_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst;
      shr_mem_1_cns_ppidx <= shr_mem_1_xor_rmff;
      shr_mem_1_cns_ppown <= shr_mem_1_acc_rmff;
      shr_mem_1_cns_ppidx_1 <= shr_mem_1_xor_1_rmff;
      shr_mem_1_cns_ppown_1 <= shr_mem_1_acc_1_rmff;
    end
  end

  function [13:0] MUX_v_14_2_2;
    input [13:0] input_0;
    input [13:0] input_1;
    input [0:0] sel;
    reg [13:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_14_2_2 = result;
  end
  endfunction


  function [1:0] MUX_v_2_2_2;
    input [1:0] input_0;
    input [1:0] input_1;
    input [0:0] sel;
    reg [1:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_2_2_2 = result;
  end
  endfunction


  function [31:0] MUX_v_32_2_2;
    input [31:0] input_0;
    input [31:0] input_1;
    input [0:0] sel;
    reg [31:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_32_2_2 = result;
  end
  endfunction


  function  [1:0] conv_s2u_1_2 ;
    input [0:0]  vector ;
  begin
    conv_s2u_1_2 = {vector[0], vector};
  end
  endfunction


  function  [1:0] conv_u2u_1_2 ;
    input [0:0]  vector ;
  begin
    conv_u2u_1_2 = {1'b0, vector};
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    double_buffetmobz_0_cns_bctl
// ------------------------------------------------------------------


module double_buffetmobz_0_cns_bctl (
  clk, rst, din_rsc_lz_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst, dout_0_rsc_data_in_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst,
      dout_0_rsc_addr_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst, dout_0_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst,
      dout_0_rsc_req_vz_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst, dout_1_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz,
      dout_2_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz, dout_3_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz,
      din_0_rsc_addr_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst, din_0_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst,
      din_0_rsc_data_out_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst, din_0_rsc_req_vz_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst,
      dout_rsc_lz_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst, din_1_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz,
      din_2_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz, din_3_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz,
      din_rsc_lz_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_bud, dout_0_rsc_rls_lz_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_bud,
      din_0_rsc_rls_lz_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_bud, dout_1_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_bud,
      dout_1_rsc_rls_lz_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_bud, din_1_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_bud,
      din_1_rsc_rls_lz_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_bud, dout_2_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_bud,
      dout_2_rsc_rls_lz_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_bud, din_2_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_bud,
      din_2_rsc_rls_lz_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_bud, dout_3_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_bud,
      dout_3_rsc_rls_lz_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_bud, din_3_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_bud,
      din_3_rsc_rls_lz_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_bud, dout_rsc_lz_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_bud,
      shr_mem_0_cns_S0, shr_mem_0_cns_R0, shr_mem_0_cns_S1, shr_mem_0_cns_R1, shr_mem_0_cns_data_in_shi0,
      shr_mem_0_cns_data_in_shi1, shr_mem_0_cns_addr_shi0, shr_mem_0_cns_addr_shi1,
      shr_mem_0_cns_re_shi0, shr_mem_0_cns_re_shi1, shr_mem_0_cns_we_shi0, shr_mem_0_cns_we_shi1,
      shr_mem_0_cns_data_out_sho0, shr_mem_0_cns_data_out_sho1, shr_mem_0_cns_S1_pff,
      shr_mem_0_cns_S0_pff, din_1_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_pff,
      din_1_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_bud_pff, dout_1_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_pff,
      dout_1_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_bud_pff, din_2_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_pff,
      din_2_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_bud_pff, dout_2_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_pff,
      dout_2_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_bud_pff, din_3_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_pff,
      din_3_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_bud_pff, dout_3_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_pff,
      dout_3_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_bud_pff
);
  input clk;
  input rst;
  output din_rsc_lz_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst;
  input [31:0] dout_0_rsc_data_in_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst;
  input [13:0] dout_0_rsc_addr_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst;
  input [1:0] dout_0_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst;
  output dout_0_rsc_req_vz_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst;
  output [1:0] dout_1_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz;
  output [1:0] dout_2_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz;
  output [1:0] dout_3_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz;
  input [13:0] din_0_rsc_addr_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst;
  input [1:0] din_0_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst;
  output [31:0] din_0_rsc_data_out_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst;
  output din_0_rsc_req_vz_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst;
  output dout_rsc_lz_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst;
  output [1:0] din_1_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz;
  output [1:0] din_2_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz;
  output [1:0] din_3_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz;
  input din_rsc_lz_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_bud;
  input dout_0_rsc_rls_lz_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_bud;
  input din_0_rsc_rls_lz_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_bud;
  input [1:0] dout_1_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_bud;
  input dout_1_rsc_rls_lz_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_bud;
  input [1:0] din_1_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_bud;
  input din_1_rsc_rls_lz_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_bud;
  input [1:0] dout_2_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_bud;
  input dout_2_rsc_rls_lz_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_bud;
  input [1:0] din_2_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_bud;
  input din_2_rsc_rls_lz_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_bud;
  input [1:0] dout_3_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_bud;
  input dout_3_rsc_rls_lz_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_bud;
  input [1:0] din_3_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_bud;
  input din_3_rsc_rls_lz_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_bud;
  input dout_rsc_lz_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_bud;
  output shr_mem_0_cns_S0;
  input shr_mem_0_cns_R0;
  output shr_mem_0_cns_S1;
  input shr_mem_0_cns_R1;
  output [31:0] shr_mem_0_cns_data_in_shi0;
  output [31:0] shr_mem_0_cns_data_in_shi1;
  output [13:0] shr_mem_0_cns_addr_shi0;
  output [13:0] shr_mem_0_cns_addr_shi1;
  output [1:0] shr_mem_0_cns_re_shi0;
  output [1:0] shr_mem_0_cns_re_shi1;
  output [1:0] shr_mem_0_cns_we_shi0;
  output [1:0] shr_mem_0_cns_we_shi1;
  input [31:0] shr_mem_0_cns_data_out_sho0;
  input [31:0] shr_mem_0_cns_data_out_sho1;
  output shr_mem_0_cns_S1_pff;
  output shr_mem_0_cns_S0_pff;
  output [1:0] din_1_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_pff;
  input [1:0] din_1_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_bud_pff;
  output [1:0] dout_1_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_pff;
  input [1:0] dout_1_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_bud_pff;
  output [1:0] din_2_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_pff;
  input [1:0] din_2_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_bud_pff;
  output [1:0] dout_2_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_pff;
  input [1:0] dout_2_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_bud_pff;
  output [1:0] din_3_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_pff;
  input [1:0] din_3_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_bud_pff;
  output [1:0] dout_3_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_pff;
  input [1:0] dout_3_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_bud_pff;


  // Interconnect Declarations
  wire shr_mem_0_cns_PC0;
  reg shr_mem_0_cns_ppidx;
  reg [1:0] shr_mem_0_cns_ppown;
  wire shr_mem_0_cns_PC1;
  reg shr_mem_0_cns_ppidx_1;
  reg [1:0] shr_mem_0_cns_ppown_1;
  wire shr_mem_0_and_5_cse_pff;
  wire [1:0] shr_mem_0_acc_1_rmff;
  wire [3:0] nl_shr_mem_0_acc_1_rmff;
  wire shr_mem_0_xor_1_rmff;
  wire [1:0] shr_mem_0_acc_rmff;
  wire [3:0] nl_shr_mem_0_acc_rmff;
  wire shr_mem_0_xor_rmff;
  wire shr_mem_0_and_7_cse_pff;

  wire[1:0] din_0_not_5_nl;
  wire[0:0] shr_mem_0_nand_1_nl;
  wire[1:0] din_0_not_1_nl;
  wire[0:0] shr_mem_0_nand_nl;

  // Interconnect Declarations for Component Instantiations 
  assign din_rsc_lz_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst = din_rsc_lz_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_bud;
  assign dout_rsc_lz_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst = dout_rsc_lz_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_bud;
  assign dout_0_rsc_req_vz_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst = shr_mem_0_cns_R0;
  assign din_0_rsc_req_vz_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst = shr_mem_0_cns_R1;
  assign shr_mem_0_xor_rmff = shr_mem_0_cns_ppidx ^ shr_mem_0_cns_PC0;
  assign nl_shr_mem_0_acc_rmff = shr_mem_0_cns_ppown + conv_u2u_1_2(shr_mem_0_cns_PC0)
      + conv_s2u_1_2(shr_mem_0_cns_PC1);
  assign shr_mem_0_acc_rmff = nl_shr_mem_0_acc_rmff[1:0];
  assign shr_mem_0_cns_PC0 = shr_mem_0_cns_S0 & dout_0_rsc_rls_lz_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_bud;
  assign shr_mem_0_xor_1_rmff = shr_mem_0_cns_ppidx_1 ^ shr_mem_0_cns_PC1;
  assign nl_shr_mem_0_acc_1_rmff = shr_mem_0_cns_ppown_1 + conv_u2u_1_2(shr_mem_0_cns_PC1)
      + conv_s2u_1_2(shr_mem_0_cns_PC0);
  assign shr_mem_0_acc_1_rmff = nl_shr_mem_0_acc_1_rmff[1:0];
  assign shr_mem_0_cns_PC1 = shr_mem_0_cns_S1 & din_0_rsc_rls_lz_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_bud;
  assign din_0_rsc_data_out_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst = MUX_v_32_2_2(shr_mem_0_cns_data_out_sho0,
      shr_mem_0_cns_data_out_sho1, shr_mem_0_cns_ppidx_1);
  assign shr_mem_0_cns_data_in_shi0 = dout_0_rsc_data_in_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst;
  assign shr_mem_0_cns_addr_shi0 = MUX_v_14_2_2(dout_0_rsc_addr_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst,
      din_0_rsc_addr_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst, shr_mem_0_and_5_cse_pff);
  assign shr_mem_0_cns_S1 = (shr_mem_0_cns_ppown_1!=2'b00);
  assign shr_mem_0_cns_S1_pff = (shr_mem_0_acc_1_rmff!=2'b00);
  assign shr_mem_0_and_5_cse_pff = shr_mem_0_cns_S1_pff & (~ shr_mem_0_xor_1_rmff);
  assign din_0_not_5_nl = ~ din_0_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst;
  assign shr_mem_0_cns_re_shi0 = ~(MUX_v_2_2_2(2'b00, (din_0_not_5_nl), shr_mem_0_and_5_cse_pff));
  assign shr_mem_0_nand_1_nl = ~(shr_mem_0_cns_S0_pff & (~ shr_mem_0_xor_rmff));
  assign shr_mem_0_cns_we_shi0 = MUX_v_2_2_2(dout_0_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst,
      2'b11, (shr_mem_0_nand_1_nl));
  assign shr_mem_0_cns_S0 = ~((shr_mem_0_cns_ppown==2'b10));
  assign shr_mem_0_cns_S0_pff = ~((shr_mem_0_acc_rmff==2'b10));
  assign shr_mem_0_cns_data_in_shi1 = dout_0_rsc_data_in_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst;
  assign shr_mem_0_cns_addr_shi1 = MUX_v_14_2_2(dout_0_rsc_addr_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst,
      din_0_rsc_addr_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst, shr_mem_0_and_7_cse_pff);
  assign shr_mem_0_and_7_cse_pff = shr_mem_0_cns_S1_pff & shr_mem_0_xor_1_rmff;
  assign din_0_not_1_nl = ~ din_0_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst;
  assign shr_mem_0_cns_re_shi1 = ~(MUX_v_2_2_2(2'b00, (din_0_not_1_nl), shr_mem_0_and_7_cse_pff));
  assign shr_mem_0_nand_nl = ~(shr_mem_0_cns_S0_pff & shr_mem_0_xor_rmff);
  assign shr_mem_0_cns_we_shi1 = MUX_v_2_2_2(dout_0_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst,
      2'b11, (shr_mem_0_nand_nl));
  assign din_1_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz = din_1_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_bud;
  assign din_1_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_pff = din_1_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_bud_pff;
  assign dout_1_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz = dout_1_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_bud;
  assign dout_1_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_pff = dout_1_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_bud_pff;
  assign din_2_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz = din_2_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_bud;
  assign din_2_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_pff = din_2_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_bud_pff;
  assign dout_2_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz = dout_2_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_bud;
  assign dout_2_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_pff = dout_2_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_bud_pff;
  assign din_3_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz = din_3_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_bud;
  assign din_3_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_pff = din_3_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_bud_pff;
  assign dout_3_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz = dout_3_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_bud;
  assign dout_3_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_pff = dout_3_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_bud_pff;
  always @(posedge clk) begin
    if ( rst ) begin
      shr_mem_0_cns_ppidx <= 1'b0;
      shr_mem_0_cns_ppown <= 2'b0;
      shr_mem_0_cns_ppidx_1 <= 1'b0;
      shr_mem_0_cns_ppown_1 <= 2'b0;
    end
    else begin
      shr_mem_0_cns_ppidx <= shr_mem_0_xor_rmff;
      shr_mem_0_cns_ppown <= shr_mem_0_acc_rmff;
      shr_mem_0_cns_ppidx_1 <= shr_mem_0_xor_1_rmff;
      shr_mem_0_cns_ppown_1 <= shr_mem_0_acc_1_rmff;
    end
  end

  function [13:0] MUX_v_14_2_2;
    input [13:0] input_0;
    input [13:0] input_1;
    input [0:0] sel;
    reg [13:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_14_2_2 = result;
  end
  endfunction


  function [1:0] MUX_v_2_2_2;
    input [1:0] input_0;
    input [1:0] input_1;
    input [0:0] sel;
    reg [1:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_2_2_2 = result;
  end
  endfunction


  function [31:0] MUX_v_32_2_2;
    input [31:0] input_0;
    input [31:0] input_1;
    input [0:0] sel;
    reg [31:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_32_2_2 = result;
  end
  endfunction


  function  [1:0] conv_s2u_1_2 ;
    input [0:0]  vector ;
  begin
    conv_s2u_1_2 = {vector[0], vector};
  end
  endfunction


  function  [1:0] conv_u2u_1_2 ;
    input [0:0]  vector ;
  begin
    conv_u2u_1_2 = {1'b0, vector};
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    unreg_hier_15
// ------------------------------------------------------------------


module unreg_hier_15 (
  in_0, out_0
);
  input in_0;
  output out_0;



  // Interconnect Declarations for Component Instantiations 
  assign out_0 = in_0;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    ram_sample_065nm_dualport_beh_dc_RAM_dualRW_wport_5_72_16_7_0_1_0_0_0_1_1_16_72_2_gen
// ------------------------------------------------------------------


module ram_sample_065nm_dualport_beh_dc_RAM_dualRW_wport_5_72_16_7_0_1_0_0_0_1_1_16_72_2_gen
    (
  we, addr, data_in, data_in_d, addr_d, we_d
);
  output [1:0] we;
  output [13:0] addr;
  output [31:0] data_in;
  input [31:0] data_in_d;
  input [13:0] addr_d;
  input [1:0] we_d;



  // Interconnect Declarations for Component Instantiations 
  assign we = we_d;
  assign addr = addr_d;
  assign data_in = data_in_d;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    ram_sample_065nm_dualport_beh_dc_RAM_dualRW_wport_4_72_16_7_0_1_0_0_0_1_1_16_72_2_gen
// ------------------------------------------------------------------


module ram_sample_065nm_dualport_beh_dc_RAM_dualRW_wport_4_72_16_7_0_1_0_0_0_1_1_16_72_2_gen
    (
  we, addr, data_in, data_in_d, addr_d, we_d
);
  output [1:0] we;
  output [13:0] addr;
  output [31:0] data_in;
  input [31:0] data_in_d;
  input [13:0] addr_d;
  input [1:0] we_d;



  // Interconnect Declarations for Component Instantiations 
  assign we = we_d;
  assign addr = addr_d;
  assign data_in = data_in_d;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    ram_sample_065nm_dualport_beh_dc_RAM_dualRW_wport_3_72_16_7_0_1_0_0_0_1_1_16_72_2_gen
// ------------------------------------------------------------------


module ram_sample_065nm_dualport_beh_dc_RAM_dualRW_wport_3_72_16_7_0_1_0_0_0_1_1_16_72_2_gen
    (
  we, addr, data_in, data_in_d, addr_d, we_d
);
  output [1:0] we;
  output [13:0] addr;
  output [31:0] data_in;
  input [31:0] data_in_d;
  input [13:0] addr_d;
  input [1:0] we_d;



  // Interconnect Declarations for Component Instantiations 
  assign we = we_d;
  assign addr = addr_d;
  assign data_in = data_in_d;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    ram_sample_065nm_dualport_beh_dc_RAM_dualRW_wport_2_72_16_7_0_1_0_0_0_1_1_16_72_2_gen
// ------------------------------------------------------------------


module ram_sample_065nm_dualport_beh_dc_RAM_dualRW_wport_2_72_16_7_0_1_0_0_0_1_1_16_72_2_gen
    (
  we, addr, data_in, data_in_d, addr_d, we_d
);
  output [1:0] we;
  output [13:0] addr;
  output [31:0] data_in;
  input [31:0] data_in_d;
  input [13:0] addr_d;
  input [1:0] we_d;



  // Interconnect Declarations for Component Instantiations 
  assign we = we_d;
  assign addr = addr_d;
  assign data_in = data_in_d;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_core_fsm
//  FSM Module
// ------------------------------------------------------------------


module WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_core_fsm (
  clk, rst, core_wen, fsm_output
);
  input clk;
  input rst;
  input core_wen;
  output [1:0] fsm_output;
  reg [1:0] fsm_output;


  // FSM State Type Declaration for WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_core_fsm_1
  parameter
    core_rlp_C_0 = 1'd0,
    main_C_0 = 1'd1;

  reg [0:0] state_var;
  reg [0:0] state_var_NS;


  // Interconnect Declarations for Component Instantiations 
  always @(*)
  begin : WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_core_fsm_1
    case (state_var)
      main_C_0 : begin
        fsm_output = 2'b10;
        state_var_NS = main_C_0;
      end
      // core_rlp_C_0
      default : begin
        fsm_output = 2'b1;
        state_var_NS = main_C_0;
      end
    endcase
  end

  always @(posedge clk) begin
    if ( rst ) begin
      state_var <= core_rlp_C_0;
    end
    else if ( core_wen ) begin
      state_var <= state_var_NS;
    end
  end

endmodule

// ------------------------------------------------------------------
//  Design Unit:    WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_staller
// ------------------------------------------------------------------


module WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_staller (
  clk, rst, core_wen, din_rsci_wen_comp, core_wten, dout_3_rsc_req_obj_wen_comp,
      dout_2_rsc_req_obj_wen_comp, dout_1_rsc_req_obj_wen_comp, dout_0_rsc_req_obj_wen_comp
);
  input clk;
  input rst;
  output core_wen;
  input din_rsci_wen_comp;
  output core_wten;
  input dout_3_rsc_req_obj_wen_comp;
  input dout_2_rsc_req_obj_wen_comp;
  input dout_1_rsc_req_obj_wen_comp;
  input dout_0_rsc_req_obj_wen_comp;


  // Interconnect Declarations
  reg core_wten_reg;


  // Interconnect Declarations for Component Instantiations 
  assign core_wen = din_rsci_wen_comp & dout_3_rsc_req_obj_wen_comp & dout_2_rsc_req_obj_wen_comp
      & dout_1_rsc_req_obj_wen_comp & dout_0_rsc_req_obj_wen_comp;
  assign core_wten = core_wten_reg;
  always @(posedge clk) begin
    if ( rst ) begin
      core_wten_reg <= 1'b0;
    end
    else begin
      core_wten_reg <= ~ core_wen;
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_0_rsc_req_obj_dout_0_rsc_req_wait_dp
// ------------------------------------------------------------------


module WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_0_rsc_req_obj_dout_0_rsc_req_wait_dp
    (
  clk, rst, dout_0_rsc_req_obj_oswt, dout_0_rsc_req_obj_wen_comp, dout_0_rsc_req_obj_biwt,
      dout_0_rsc_req_obj_bdwt
);
  input clk;
  input rst;
  input dout_0_rsc_req_obj_oswt;
  output dout_0_rsc_req_obj_wen_comp;
  input dout_0_rsc_req_obj_biwt;
  input dout_0_rsc_req_obj_bdwt;


  // Interconnect Declarations
  reg dout_0_rsc_req_obj_bcwt;


  // Interconnect Declarations for Component Instantiations 
  assign dout_0_rsc_req_obj_wen_comp = (~ dout_0_rsc_req_obj_oswt) | dout_0_rsc_req_obj_biwt
      | dout_0_rsc_req_obj_bcwt;
  always @(posedge clk) begin
    if ( rst ) begin
      dout_0_rsc_req_obj_bcwt <= 1'b0;
    end
    else begin
      dout_0_rsc_req_obj_bcwt <= ~((~(dout_0_rsc_req_obj_bcwt | dout_0_rsc_req_obj_biwt))
          | dout_0_rsc_req_obj_bdwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_0_rsc_req_obj_dout_0_rsc_req_wait_ctrl
// ------------------------------------------------------------------


module WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_0_rsc_req_obj_dout_0_rsc_req_wait_ctrl
    (
  clk, rst, core_wen, core_wten, dout_0_rsc_req_obj_oswt, dout_0_rsc_req_obj_vd,
      dout_0_rsc_req_obj_biwt, dout_0_rsc_req_obj_bdwt
);
  input clk;
  input rst;
  input core_wen;
  input core_wten;
  input dout_0_rsc_req_obj_oswt;
  input dout_0_rsc_req_obj_vd;
  output dout_0_rsc_req_obj_biwt;
  output dout_0_rsc_req_obj_bdwt;


  // Interconnect Declarations
  wire dout_0_rsc_req_obj_pdswt0;
  reg dout_0_rsc_req_obj_icwt;


  // Interconnect Declarations for Component Instantiations 
  assign dout_0_rsc_req_obj_pdswt0 = (~ core_wten) & dout_0_rsc_req_obj_oswt;
  assign dout_0_rsc_req_obj_biwt = (dout_0_rsc_req_obj_pdswt0 | dout_0_rsc_req_obj_icwt)
      & dout_0_rsc_req_obj_vd;
  assign dout_0_rsc_req_obj_bdwt = dout_0_rsc_req_obj_oswt & core_wen;
  always @(posedge clk) begin
    if ( rst ) begin
      dout_0_rsc_req_obj_icwt <= 1'b0;
    end
    else begin
      dout_0_rsc_req_obj_icwt <= ~((~(dout_0_rsc_req_obj_icwt | dout_0_rsc_req_obj_pdswt0))
          | dout_0_rsc_req_obj_biwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_1_rsc_req_obj_dout_1_rsc_req_wait_dp
// ------------------------------------------------------------------


module WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_1_rsc_req_obj_dout_1_rsc_req_wait_dp
    (
  clk, rst, dout_1_rsc_req_obj_oswt, dout_1_rsc_req_obj_wen_comp, dout_1_rsc_req_obj_biwt,
      dout_1_rsc_req_obj_bdwt
);
  input clk;
  input rst;
  input dout_1_rsc_req_obj_oswt;
  output dout_1_rsc_req_obj_wen_comp;
  input dout_1_rsc_req_obj_biwt;
  input dout_1_rsc_req_obj_bdwt;


  // Interconnect Declarations
  reg dout_1_rsc_req_obj_bcwt;


  // Interconnect Declarations for Component Instantiations 
  assign dout_1_rsc_req_obj_wen_comp = (~ dout_1_rsc_req_obj_oswt) | dout_1_rsc_req_obj_biwt
      | dout_1_rsc_req_obj_bcwt;
  always @(posedge clk) begin
    if ( rst ) begin
      dout_1_rsc_req_obj_bcwt <= 1'b0;
    end
    else begin
      dout_1_rsc_req_obj_bcwt <= ~((~(dout_1_rsc_req_obj_bcwt | dout_1_rsc_req_obj_biwt))
          | dout_1_rsc_req_obj_bdwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_1_rsc_req_obj_dout_1_rsc_req_wait_ctrl
// ------------------------------------------------------------------


module WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_1_rsc_req_obj_dout_1_rsc_req_wait_ctrl
    (
  clk, rst, core_wen, core_wten, dout_1_rsc_req_obj_oswt, dout_1_rsc_req_obj_vd,
      dout_1_rsc_req_obj_biwt, dout_1_rsc_req_obj_bdwt
);
  input clk;
  input rst;
  input core_wen;
  input core_wten;
  input dout_1_rsc_req_obj_oswt;
  input dout_1_rsc_req_obj_vd;
  output dout_1_rsc_req_obj_biwt;
  output dout_1_rsc_req_obj_bdwt;


  // Interconnect Declarations
  wire dout_1_rsc_req_obj_pdswt0;
  reg dout_1_rsc_req_obj_icwt;


  // Interconnect Declarations for Component Instantiations 
  assign dout_1_rsc_req_obj_pdswt0 = (~ core_wten) & dout_1_rsc_req_obj_oswt;
  assign dout_1_rsc_req_obj_biwt = (dout_1_rsc_req_obj_pdswt0 | dout_1_rsc_req_obj_icwt)
      & dout_1_rsc_req_obj_vd;
  assign dout_1_rsc_req_obj_bdwt = dout_1_rsc_req_obj_oswt & core_wen;
  always @(posedge clk) begin
    if ( rst ) begin
      dout_1_rsc_req_obj_icwt <= 1'b0;
    end
    else begin
      dout_1_rsc_req_obj_icwt <= ~((~(dout_1_rsc_req_obj_icwt | dout_1_rsc_req_obj_pdswt0))
          | dout_1_rsc_req_obj_biwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_2_rsc_req_obj_dout_2_rsc_req_wait_dp
// ------------------------------------------------------------------


module WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_2_rsc_req_obj_dout_2_rsc_req_wait_dp
    (
  clk, rst, dout_2_rsc_req_obj_oswt, dout_2_rsc_req_obj_wen_comp, dout_2_rsc_req_obj_biwt,
      dout_2_rsc_req_obj_bdwt
);
  input clk;
  input rst;
  input dout_2_rsc_req_obj_oswt;
  output dout_2_rsc_req_obj_wen_comp;
  input dout_2_rsc_req_obj_biwt;
  input dout_2_rsc_req_obj_bdwt;


  // Interconnect Declarations
  reg dout_2_rsc_req_obj_bcwt;


  // Interconnect Declarations for Component Instantiations 
  assign dout_2_rsc_req_obj_wen_comp = (~ dout_2_rsc_req_obj_oswt) | dout_2_rsc_req_obj_biwt
      | dout_2_rsc_req_obj_bcwt;
  always @(posedge clk) begin
    if ( rst ) begin
      dout_2_rsc_req_obj_bcwt <= 1'b0;
    end
    else begin
      dout_2_rsc_req_obj_bcwt <= ~((~(dout_2_rsc_req_obj_bcwt | dout_2_rsc_req_obj_biwt))
          | dout_2_rsc_req_obj_bdwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_2_rsc_req_obj_dout_2_rsc_req_wait_ctrl
// ------------------------------------------------------------------


module WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_2_rsc_req_obj_dout_2_rsc_req_wait_ctrl
    (
  clk, rst, core_wen, core_wten, dout_2_rsc_req_obj_oswt, dout_2_rsc_req_obj_vd,
      dout_2_rsc_req_obj_biwt, dout_2_rsc_req_obj_bdwt
);
  input clk;
  input rst;
  input core_wen;
  input core_wten;
  input dout_2_rsc_req_obj_oswt;
  input dout_2_rsc_req_obj_vd;
  output dout_2_rsc_req_obj_biwt;
  output dout_2_rsc_req_obj_bdwt;


  // Interconnect Declarations
  wire dout_2_rsc_req_obj_pdswt0;
  reg dout_2_rsc_req_obj_icwt;


  // Interconnect Declarations for Component Instantiations 
  assign dout_2_rsc_req_obj_pdswt0 = (~ core_wten) & dout_2_rsc_req_obj_oswt;
  assign dout_2_rsc_req_obj_biwt = (dout_2_rsc_req_obj_pdswt0 | dout_2_rsc_req_obj_icwt)
      & dout_2_rsc_req_obj_vd;
  assign dout_2_rsc_req_obj_bdwt = dout_2_rsc_req_obj_oswt & core_wen;
  always @(posedge clk) begin
    if ( rst ) begin
      dout_2_rsc_req_obj_icwt <= 1'b0;
    end
    else begin
      dout_2_rsc_req_obj_icwt <= ~((~(dout_2_rsc_req_obj_icwt | dout_2_rsc_req_obj_pdswt0))
          | dout_2_rsc_req_obj_biwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_3_rsc_req_obj_dout_3_rsc_req_wait_dp
// ------------------------------------------------------------------


module WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_3_rsc_req_obj_dout_3_rsc_req_wait_dp
    (
  clk, rst, dout_3_rsc_req_obj_oswt, dout_3_rsc_req_obj_wen_comp, dout_3_rsc_req_obj_biwt,
      dout_3_rsc_req_obj_bdwt
);
  input clk;
  input rst;
  input dout_3_rsc_req_obj_oswt;
  output dout_3_rsc_req_obj_wen_comp;
  input dout_3_rsc_req_obj_biwt;
  input dout_3_rsc_req_obj_bdwt;


  // Interconnect Declarations
  reg dout_3_rsc_req_obj_bcwt;


  // Interconnect Declarations for Component Instantiations 
  assign dout_3_rsc_req_obj_wen_comp = (~ dout_3_rsc_req_obj_oswt) | dout_3_rsc_req_obj_biwt
      | dout_3_rsc_req_obj_bcwt;
  always @(posedge clk) begin
    if ( rst ) begin
      dout_3_rsc_req_obj_bcwt <= 1'b0;
    end
    else begin
      dout_3_rsc_req_obj_bcwt <= ~((~(dout_3_rsc_req_obj_bcwt | dout_3_rsc_req_obj_biwt))
          | dout_3_rsc_req_obj_bdwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_3_rsc_req_obj_dout_3_rsc_req_wait_ctrl
// ------------------------------------------------------------------


module WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_3_rsc_req_obj_dout_3_rsc_req_wait_ctrl
    (
  clk, rst, core_wen, core_wten, dout_3_rsc_req_obj_oswt, dout_3_rsc_req_obj_vd,
      dout_3_rsc_req_obj_biwt, dout_3_rsc_req_obj_bdwt
);
  input clk;
  input rst;
  input core_wen;
  input core_wten;
  input dout_3_rsc_req_obj_oswt;
  input dout_3_rsc_req_obj_vd;
  output dout_3_rsc_req_obj_biwt;
  output dout_3_rsc_req_obj_bdwt;


  // Interconnect Declarations
  wire dout_3_rsc_req_obj_pdswt0;
  reg dout_3_rsc_req_obj_icwt;


  // Interconnect Declarations for Component Instantiations 
  assign dout_3_rsc_req_obj_pdswt0 = (~ core_wten) & dout_3_rsc_req_obj_oswt;
  assign dout_3_rsc_req_obj_biwt = (dout_3_rsc_req_obj_pdswt0 | dout_3_rsc_req_obj_icwt)
      & dout_3_rsc_req_obj_vd;
  assign dout_3_rsc_req_obj_bdwt = dout_3_rsc_req_obj_oswt & core_wen;
  always @(posedge clk) begin
    if ( rst ) begin
      dout_3_rsc_req_obj_icwt <= 1'b0;
    end
    else begin
      dout_3_rsc_req_obj_icwt <= ~((~(dout_3_rsc_req_obj_icwt | dout_3_rsc_req_obj_pdswt0))
          | dout_3_rsc_req_obj_biwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_0_rsc_rls_obj_dout_0_rsc_rls_wait_ctrl
// ------------------------------------------------------------------


module WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_0_rsc_rls_obj_dout_0_rsc_rls_wait_ctrl
    (
  core_wten, dout_0_rsc_rls_obj_iswt0, dout_0_rsc_rls_obj_ld_core_sct
);
  input core_wten;
  input dout_0_rsc_rls_obj_iswt0;
  output dout_0_rsc_rls_obj_ld_core_sct;



  // Interconnect Declarations for Component Instantiations 
  assign dout_0_rsc_rls_obj_ld_core_sct = dout_0_rsc_rls_obj_iswt0 & (~ core_wten);
endmodule

// ------------------------------------------------------------------
//  Design Unit:    WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_1_rsc_rls_obj_dout_1_rsc_rls_wait_ctrl
// ------------------------------------------------------------------


module WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_1_rsc_rls_obj_dout_1_rsc_rls_wait_ctrl
    (
  core_wten, dout_1_rsc_rls_obj_iswt0, dout_1_rsc_rls_obj_ld_core_sct
);
  input core_wten;
  input dout_1_rsc_rls_obj_iswt0;
  output dout_1_rsc_rls_obj_ld_core_sct;



  // Interconnect Declarations for Component Instantiations 
  assign dout_1_rsc_rls_obj_ld_core_sct = dout_1_rsc_rls_obj_iswt0 & (~ core_wten);
endmodule

// ------------------------------------------------------------------
//  Design Unit:    WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_2_rsc_rls_obj_dout_2_rsc_rls_wait_ctrl
// ------------------------------------------------------------------


module WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_2_rsc_rls_obj_dout_2_rsc_rls_wait_ctrl
    (
  core_wten, dout_2_rsc_rls_obj_iswt0, dout_2_rsc_rls_obj_ld_core_sct
);
  input core_wten;
  input dout_2_rsc_rls_obj_iswt0;
  output dout_2_rsc_rls_obj_ld_core_sct;



  // Interconnect Declarations for Component Instantiations 
  assign dout_2_rsc_rls_obj_ld_core_sct = dout_2_rsc_rls_obj_iswt0 & (~ core_wten);
endmodule

// ------------------------------------------------------------------
//  Design Unit:    WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_3_rsc_rls_obj_dout_3_rsc_rls_wait_ctrl
// ------------------------------------------------------------------


module WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_3_rsc_rls_obj_dout_3_rsc_rls_wait_ctrl
    (
  core_wten, dout_3_rsc_rls_obj_iswt0, dout_3_rsc_rls_obj_ld_core_sct
);
  input core_wten;
  input dout_3_rsc_rls_obj_iswt0;
  output dout_3_rsc_rls_obj_ld_core_sct;



  // Interconnect Declarations for Component Instantiations 
  assign dout_3_rsc_rls_obj_ld_core_sct = dout_3_rsc_rls_obj_iswt0 & (~ core_wten);
endmodule

// ------------------------------------------------------------------
//  Design Unit:    WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_3_rsci_1_dout_3_rsc_wait_ctrl
// ------------------------------------------------------------------


module WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_3_rsci_1_dout_3_rsc_wait_ctrl (
  core_wten, dout_3_rsci_iswt0, dout_3_rsci_we_d_core_psct, dout_3_rsci_we_d_core_sct
);
  input core_wten;
  input dout_3_rsci_iswt0;
  input [1:0] dout_3_rsci_we_d_core_psct;
  output [1:0] dout_3_rsci_we_d_core_sct;


  wire[0:0] dout_3_and_2_nl;

  // Interconnect Declarations for Component Instantiations 
  assign dout_3_and_2_nl = (dout_3_rsci_we_d_core_psct[0]) & (~ core_wten) & dout_3_rsci_iswt0;
  assign dout_3_rsci_we_d_core_sct = {1'b0 , (dout_3_and_2_nl)};
endmodule

// ------------------------------------------------------------------
//  Design Unit:    WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_2_rsci_1_dout_2_rsc_wait_ctrl
// ------------------------------------------------------------------


module WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_2_rsci_1_dout_2_rsc_wait_ctrl (
  core_wten, dout_2_rsci_iswt0, dout_2_rsci_we_d_core_psct, dout_2_rsci_we_d_core_sct
);
  input core_wten;
  input dout_2_rsci_iswt0;
  input [1:0] dout_2_rsci_we_d_core_psct;
  output [1:0] dout_2_rsci_we_d_core_sct;


  wire[0:0] dout_2_and_2_nl;

  // Interconnect Declarations for Component Instantiations 
  assign dout_2_and_2_nl = (dout_2_rsci_we_d_core_psct[0]) & (~ core_wten) & dout_2_rsci_iswt0;
  assign dout_2_rsci_we_d_core_sct = {1'b0 , (dout_2_and_2_nl)};
endmodule

// ------------------------------------------------------------------
//  Design Unit:    WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_1_rsci_1_dout_1_rsc_wait_ctrl
// ------------------------------------------------------------------


module WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_1_rsci_1_dout_1_rsc_wait_ctrl (
  core_wten, dout_1_rsci_iswt0, dout_1_rsci_we_d_core_psct, dout_1_rsci_we_d_core_sct
);
  input core_wten;
  input dout_1_rsci_iswt0;
  input [1:0] dout_1_rsci_we_d_core_psct;
  output [1:0] dout_1_rsci_we_d_core_sct;


  wire[0:0] dout_1_and_2_nl;

  // Interconnect Declarations for Component Instantiations 
  assign dout_1_and_2_nl = (dout_1_rsci_we_d_core_psct[0]) & (~ core_wten) & dout_1_rsci_iswt0;
  assign dout_1_rsci_we_d_core_sct = {1'b0 , (dout_1_and_2_nl)};
endmodule

// ------------------------------------------------------------------
//  Design Unit:    WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_0_rsci_1_dout_0_rsc_wait_ctrl
// ------------------------------------------------------------------


module WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_0_rsci_1_dout_0_rsc_wait_ctrl (
  core_wten, dout_0_rsci_iswt0, dout_0_rsci_we_d_core_psct, dout_0_rsci_we_d_core_sct
);
  input core_wten;
  input dout_0_rsci_iswt0;
  input [1:0] dout_0_rsci_we_d_core_psct;
  output [1:0] dout_0_rsci_we_d_core_sct;


  wire[0:0] dout_0_and_2_nl;

  // Interconnect Declarations for Component Instantiations 
  assign dout_0_and_2_nl = (dout_0_rsci_we_d_core_psct[0]) & (~ core_wten) & dout_0_rsci_iswt0;
  assign dout_0_rsci_we_d_core_sct = {1'b0 , (dout_0_and_2_nl)};
endmodule

// ------------------------------------------------------------------
//  Design Unit:    WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_din_rsci_din_wait_dp
// ------------------------------------------------------------------


module WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_din_rsci_din_wait_dp (
  clk, rst, din_rsci_oswt, din_rsci_wen_comp, din_rsci_d_mxwt, din_rsci_biwt, din_rsci_bdwt,
      din_rsci_d
);
  input clk;
  input rst;
  input din_rsci_oswt;
  output din_rsci_wen_comp;
  output [63:0] din_rsci_d_mxwt;
  input din_rsci_biwt;
  input din_rsci_bdwt;
  input [127:0] din_rsci_d;


  // Interconnect Declarations
  reg din_rsci_bcwt;
  reg [15:0] reg_din_rsci_d_bfwt_tmp;
  reg [15:0] reg_din_rsci_d_bfwt_tmp_17;
  reg [15:0] reg_din_rsci_d_bfwt_tmp_34;
  reg [15:0] reg_din_rsci_d_bfwt_tmp_51;
  wire [15:0] din_rsci_d_mxwt_opt_111_96;
  wire [15:0] din_rsci_d_mxwt_opt_79_64;
  wire [15:0] din_rsci_d_mxwt_opt_47_32;
  wire [15:0] din_rsci_d_mxwt_opt_15_0;


  // Interconnect Declarations for Component Instantiations 
  assign din_rsci_wen_comp = (~ din_rsci_oswt) | din_rsci_biwt | din_rsci_bcwt;
  assign din_rsci_d_mxwt_opt_111_96 = MUX_v_16_2_2((din_rsci_d[111:96]), reg_din_rsci_d_bfwt_tmp,
      din_rsci_bcwt);
  assign din_rsci_d_mxwt_opt_79_64 = MUX_v_16_2_2((din_rsci_d[79:64]), reg_din_rsci_d_bfwt_tmp_17,
      din_rsci_bcwt);
  assign din_rsci_d_mxwt_opt_47_32 = MUX_v_16_2_2((din_rsci_d[47:32]), reg_din_rsci_d_bfwt_tmp_34,
      din_rsci_bcwt);
  assign din_rsci_d_mxwt_opt_15_0 = MUX_v_16_2_2((din_rsci_d[15:0]), reg_din_rsci_d_bfwt_tmp_51,
      din_rsci_bcwt);
  assign din_rsci_d_mxwt = {din_rsci_d_mxwt_opt_111_96 , din_rsci_d_mxwt_opt_79_64
      , din_rsci_d_mxwt_opt_47_32 , din_rsci_d_mxwt_opt_15_0};
  always @(posedge clk) begin
    if ( rst ) begin
      din_rsci_bcwt <= 1'b0;
      reg_din_rsci_d_bfwt_tmp <= 16'b0;
      reg_din_rsci_d_bfwt_tmp_17 <= 16'b0;
      reg_din_rsci_d_bfwt_tmp_34 <= 16'b0;
      reg_din_rsci_d_bfwt_tmp_51 <= 16'b0;
    end
    else begin
      din_rsci_bcwt <= ~((~(din_rsci_bcwt | din_rsci_biwt)) | din_rsci_bdwt);
      reg_din_rsci_d_bfwt_tmp <= din_rsci_d_mxwt_opt_111_96;
      reg_din_rsci_d_bfwt_tmp_17 <= din_rsci_d_mxwt_opt_79_64;
      reg_din_rsci_d_bfwt_tmp_34 <= din_rsci_d_mxwt_opt_47_32;
      reg_din_rsci_d_bfwt_tmp_51 <= din_rsci_d_mxwt_opt_15_0;
    end
  end

  function [15:0] MUX_v_16_2_2;
    input [15:0] input_0;
    input [15:0] input_1;
    input [0:0] sel;
    reg [15:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_16_2_2 = result;
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_din_rsci_din_wait_ctrl
// ------------------------------------------------------------------


module WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_din_rsci_din_wait_ctrl (
  clk, rst, core_wen, din_rsci_oswt, core_wten, din_rsci_biwt, din_rsci_bdwt, din_rsci_ld_core_sct,
      din_rsci_vd
);
  input clk;
  input rst;
  input core_wen;
  input din_rsci_oswt;
  input core_wten;
  output din_rsci_biwt;
  output din_rsci_bdwt;
  output din_rsci_ld_core_sct;
  input din_rsci_vd;


  // Interconnect Declarations
  wire din_rsci_ogwt;
  wire din_rsci_pdswt0;
  reg din_rsci_icwt;


  // Interconnect Declarations for Component Instantiations 
  assign din_rsci_pdswt0 = (~ core_wten) & din_rsci_oswt;
  assign din_rsci_biwt = din_rsci_ogwt & din_rsci_vd;
  assign din_rsci_ogwt = din_rsci_pdswt0 | din_rsci_icwt;
  assign din_rsci_bdwt = din_rsci_oswt & core_wen;
  assign din_rsci_ld_core_sct = din_rsci_oswt & din_rsci_ogwt;
  always @(posedge clk) begin
    if ( rst ) begin
      din_rsci_icwt <= 1'b0;
    end
    else begin
      din_rsci_icwt <= ~((~(din_rsci_icwt | din_rsci_pdswt0)) | din_rsci_biwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    ram_sample_065nm_dualport_beh_dc_RAM_dualRW_rport_13_72_16_7_0_1_0_0_0_1_1_16_72_2_gen
// ------------------------------------------------------------------


module ram_sample_065nm_dualport_beh_dc_RAM_dualRW_rport_13_72_16_7_0_1_0_0_0_1_1_16_72_2_gen
    (
  data_out, re, addr, addr_d, re_d, data_out_d
);
  input [31:0] data_out;
  output [1:0] re;
  output [13:0] addr;
  input [13:0] addr_d;
  input [1:0] re_d;
  output [31:0] data_out_d;



  // Interconnect Declarations for Component Instantiations 
  assign data_out_d = data_out;
  assign re = re_d;
  assign addr = addr_d;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    ram_sample_065nm_dualport_beh_dc_RAM_dualRW_rport_12_72_16_7_0_1_0_0_0_1_1_16_72_2_gen
// ------------------------------------------------------------------


module ram_sample_065nm_dualport_beh_dc_RAM_dualRW_rport_12_72_16_7_0_1_0_0_0_1_1_16_72_2_gen
    (
  data_out, re, addr, addr_d, re_d, data_out_d
);
  input [31:0] data_out;
  output [1:0] re;
  output [13:0] addr;
  input [13:0] addr_d;
  input [1:0] re_d;
  output [31:0] data_out_d;



  // Interconnect Declarations for Component Instantiations 
  assign data_out_d = data_out;
  assign re = re_d;
  assign addr = addr_d;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    ram_sample_065nm_dualport_beh_dc_RAM_dualRW_rport_11_72_16_7_0_1_0_0_0_1_1_16_72_2_gen
// ------------------------------------------------------------------


module ram_sample_065nm_dualport_beh_dc_RAM_dualRW_rport_11_72_16_7_0_1_0_0_0_1_1_16_72_2_gen
    (
  data_out, re, addr, addr_d, re_d, data_out_d
);
  input [31:0] data_out;
  output [1:0] re;
  output [13:0] addr;
  input [13:0] addr_d;
  input [1:0] re_d;
  output [31:0] data_out_d;



  // Interconnect Declarations for Component Instantiations 
  assign data_out_d = data_out;
  assign re = re_d;
  assign addr = addr_d;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    ram_sample_065nm_dualport_beh_dc_RAM_dualRW_rport_10_72_16_7_0_1_0_0_0_1_1_16_72_2_gen
// ------------------------------------------------------------------


module ram_sample_065nm_dualport_beh_dc_RAM_dualRW_rport_10_72_16_7_0_1_0_0_0_1_1_16_72_2_gen
    (
  data_out, re, addr, addr_d, re_d, data_out_d
);
  input [31:0] data_out;
  output [1:0] re;
  output [13:0] addr;
  input [13:0] addr_d;
  input [1:0] re_d;
  output [31:0] data_out_d;



  // Interconnect Declarations for Component Instantiations 
  assign data_out_d = data_out;
  assign re = re_d;
  assign addr = addr_d;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_core_fsm
//  FSM Module
// ------------------------------------------------------------------


module READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_core_fsm (
  clk, rst, core_wen, fsm_output
);
  input clk;
  input rst;
  input core_wen;
  output [1:0] fsm_output;
  reg [1:0] fsm_output;


  // FSM State Type Declaration for READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_core_fsm_1
  parameter
    core_rlp_C_0 = 1'd0,
    main_C_0 = 1'd1;

  reg [0:0] state_var;
  reg [0:0] state_var_NS;


  // Interconnect Declarations for Component Instantiations 
  always @(*)
  begin : READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_core_fsm_1
    case (state_var)
      main_C_0 : begin
        fsm_output = 2'b10;
        state_var_NS = main_C_0;
      end
      // core_rlp_C_0
      default : begin
        fsm_output = 2'b1;
        state_var_NS = main_C_0;
      end
    endcase
  end

  always @(posedge clk) begin
    if ( rst ) begin
      state_var <= core_rlp_C_0;
    end
    else if ( core_wen ) begin
      state_var <= state_var_NS;
    end
  end

endmodule

// ------------------------------------------------------------------
//  Design Unit:    READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_staller
// ------------------------------------------------------------------


module READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_staller (
  clk, rst, core_wen, core_wten, dout_rsci_wen_comp, din_3_rsc_req_obj_wen_comp,
      din_2_rsc_req_obj_wen_comp, din_1_rsc_req_obj_wen_comp, din_0_rsc_req_obj_wen_comp
);
  input clk;
  input rst;
  output core_wen;
  output core_wten;
  input dout_rsci_wen_comp;
  input din_3_rsc_req_obj_wen_comp;
  input din_2_rsc_req_obj_wen_comp;
  input din_1_rsc_req_obj_wen_comp;
  input din_0_rsc_req_obj_wen_comp;


  // Interconnect Declarations
  reg core_wten_reg;


  // Interconnect Declarations for Component Instantiations 
  assign core_wen = dout_rsci_wen_comp & din_3_rsc_req_obj_wen_comp & din_2_rsc_req_obj_wen_comp
      & din_1_rsc_req_obj_wen_comp & din_0_rsc_req_obj_wen_comp;
  assign core_wten = core_wten_reg;
  always @(posedge clk) begin
    if ( rst ) begin
      core_wten_reg <= 1'b0;
    end
    else begin
      core_wten_reg <= ~ core_wen;
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_0_rsc_req_obj_din_0_rsc_req_wait_dp
// ------------------------------------------------------------------


module READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_0_rsc_req_obj_din_0_rsc_req_wait_dp
    (
  clk, rst, din_0_rsc_req_obj_oswt, din_0_rsc_req_obj_wen_comp, din_0_rsc_req_obj_biwt,
      din_0_rsc_req_obj_bdwt
);
  input clk;
  input rst;
  input din_0_rsc_req_obj_oswt;
  output din_0_rsc_req_obj_wen_comp;
  input din_0_rsc_req_obj_biwt;
  input din_0_rsc_req_obj_bdwt;


  // Interconnect Declarations
  reg din_0_rsc_req_obj_bcwt;


  // Interconnect Declarations for Component Instantiations 
  assign din_0_rsc_req_obj_wen_comp = (~ din_0_rsc_req_obj_oswt) | din_0_rsc_req_obj_biwt
      | din_0_rsc_req_obj_bcwt;
  always @(posedge clk) begin
    if ( rst ) begin
      din_0_rsc_req_obj_bcwt <= 1'b0;
    end
    else begin
      din_0_rsc_req_obj_bcwt <= ~((~(din_0_rsc_req_obj_bcwt | din_0_rsc_req_obj_biwt))
          | din_0_rsc_req_obj_bdwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_0_rsc_req_obj_din_0_rsc_req_wait_ctrl
// ------------------------------------------------------------------


module READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_0_rsc_req_obj_din_0_rsc_req_wait_ctrl
    (
  clk, rst, core_wen, core_wten, din_0_rsc_req_obj_oswt, din_0_rsc_req_obj_vd, din_0_rsc_req_obj_biwt,
      din_0_rsc_req_obj_bdwt
);
  input clk;
  input rst;
  input core_wen;
  input core_wten;
  input din_0_rsc_req_obj_oswt;
  input din_0_rsc_req_obj_vd;
  output din_0_rsc_req_obj_biwt;
  output din_0_rsc_req_obj_bdwt;


  // Interconnect Declarations
  wire din_0_rsc_req_obj_pdswt0;
  reg din_0_rsc_req_obj_icwt;


  // Interconnect Declarations for Component Instantiations 
  assign din_0_rsc_req_obj_pdswt0 = (~ core_wten) & din_0_rsc_req_obj_oswt;
  assign din_0_rsc_req_obj_biwt = (din_0_rsc_req_obj_pdswt0 | din_0_rsc_req_obj_icwt)
      & din_0_rsc_req_obj_vd;
  assign din_0_rsc_req_obj_bdwt = din_0_rsc_req_obj_oswt & core_wen;
  always @(posedge clk) begin
    if ( rst ) begin
      din_0_rsc_req_obj_icwt <= 1'b0;
    end
    else begin
      din_0_rsc_req_obj_icwt <= ~((~(din_0_rsc_req_obj_icwt | din_0_rsc_req_obj_pdswt0))
          | din_0_rsc_req_obj_biwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_1_rsc_req_obj_din_1_rsc_req_wait_dp
// ------------------------------------------------------------------


module READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_1_rsc_req_obj_din_1_rsc_req_wait_dp
    (
  clk, rst, din_1_rsc_req_obj_oswt, din_1_rsc_req_obj_wen_comp, din_1_rsc_req_obj_biwt,
      din_1_rsc_req_obj_bdwt
);
  input clk;
  input rst;
  input din_1_rsc_req_obj_oswt;
  output din_1_rsc_req_obj_wen_comp;
  input din_1_rsc_req_obj_biwt;
  input din_1_rsc_req_obj_bdwt;


  // Interconnect Declarations
  reg din_1_rsc_req_obj_bcwt;


  // Interconnect Declarations for Component Instantiations 
  assign din_1_rsc_req_obj_wen_comp = (~ din_1_rsc_req_obj_oswt) | din_1_rsc_req_obj_biwt
      | din_1_rsc_req_obj_bcwt;
  always @(posedge clk) begin
    if ( rst ) begin
      din_1_rsc_req_obj_bcwt <= 1'b0;
    end
    else begin
      din_1_rsc_req_obj_bcwt <= ~((~(din_1_rsc_req_obj_bcwt | din_1_rsc_req_obj_biwt))
          | din_1_rsc_req_obj_bdwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_1_rsc_req_obj_din_1_rsc_req_wait_ctrl
// ------------------------------------------------------------------


module READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_1_rsc_req_obj_din_1_rsc_req_wait_ctrl
    (
  clk, rst, core_wen, core_wten, din_1_rsc_req_obj_oswt, din_1_rsc_req_obj_vd, din_1_rsc_req_obj_biwt,
      din_1_rsc_req_obj_bdwt
);
  input clk;
  input rst;
  input core_wen;
  input core_wten;
  input din_1_rsc_req_obj_oswt;
  input din_1_rsc_req_obj_vd;
  output din_1_rsc_req_obj_biwt;
  output din_1_rsc_req_obj_bdwt;


  // Interconnect Declarations
  wire din_1_rsc_req_obj_pdswt0;
  reg din_1_rsc_req_obj_icwt;


  // Interconnect Declarations for Component Instantiations 
  assign din_1_rsc_req_obj_pdswt0 = (~ core_wten) & din_1_rsc_req_obj_oswt;
  assign din_1_rsc_req_obj_biwt = (din_1_rsc_req_obj_pdswt0 | din_1_rsc_req_obj_icwt)
      & din_1_rsc_req_obj_vd;
  assign din_1_rsc_req_obj_bdwt = din_1_rsc_req_obj_oswt & core_wen;
  always @(posedge clk) begin
    if ( rst ) begin
      din_1_rsc_req_obj_icwt <= 1'b0;
    end
    else begin
      din_1_rsc_req_obj_icwt <= ~((~(din_1_rsc_req_obj_icwt | din_1_rsc_req_obj_pdswt0))
          | din_1_rsc_req_obj_biwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_2_rsc_req_obj_din_2_rsc_req_wait_dp
// ------------------------------------------------------------------


module READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_2_rsc_req_obj_din_2_rsc_req_wait_dp
    (
  clk, rst, din_2_rsc_req_obj_oswt, din_2_rsc_req_obj_wen_comp, din_2_rsc_req_obj_biwt,
      din_2_rsc_req_obj_bdwt
);
  input clk;
  input rst;
  input din_2_rsc_req_obj_oswt;
  output din_2_rsc_req_obj_wen_comp;
  input din_2_rsc_req_obj_biwt;
  input din_2_rsc_req_obj_bdwt;


  // Interconnect Declarations
  reg din_2_rsc_req_obj_bcwt;


  // Interconnect Declarations for Component Instantiations 
  assign din_2_rsc_req_obj_wen_comp = (~ din_2_rsc_req_obj_oswt) | din_2_rsc_req_obj_biwt
      | din_2_rsc_req_obj_bcwt;
  always @(posedge clk) begin
    if ( rst ) begin
      din_2_rsc_req_obj_bcwt <= 1'b0;
    end
    else begin
      din_2_rsc_req_obj_bcwt <= ~((~(din_2_rsc_req_obj_bcwt | din_2_rsc_req_obj_biwt))
          | din_2_rsc_req_obj_bdwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_2_rsc_req_obj_din_2_rsc_req_wait_ctrl
// ------------------------------------------------------------------


module READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_2_rsc_req_obj_din_2_rsc_req_wait_ctrl
    (
  clk, rst, core_wen, core_wten, din_2_rsc_req_obj_oswt, din_2_rsc_req_obj_vd, din_2_rsc_req_obj_biwt,
      din_2_rsc_req_obj_bdwt
);
  input clk;
  input rst;
  input core_wen;
  input core_wten;
  input din_2_rsc_req_obj_oswt;
  input din_2_rsc_req_obj_vd;
  output din_2_rsc_req_obj_biwt;
  output din_2_rsc_req_obj_bdwt;


  // Interconnect Declarations
  wire din_2_rsc_req_obj_pdswt0;
  reg din_2_rsc_req_obj_icwt;


  // Interconnect Declarations for Component Instantiations 
  assign din_2_rsc_req_obj_pdswt0 = (~ core_wten) & din_2_rsc_req_obj_oswt;
  assign din_2_rsc_req_obj_biwt = (din_2_rsc_req_obj_pdswt0 | din_2_rsc_req_obj_icwt)
      & din_2_rsc_req_obj_vd;
  assign din_2_rsc_req_obj_bdwt = din_2_rsc_req_obj_oswt & core_wen;
  always @(posedge clk) begin
    if ( rst ) begin
      din_2_rsc_req_obj_icwt <= 1'b0;
    end
    else begin
      din_2_rsc_req_obj_icwt <= ~((~(din_2_rsc_req_obj_icwt | din_2_rsc_req_obj_pdswt0))
          | din_2_rsc_req_obj_biwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_3_rsc_req_obj_din_3_rsc_req_wait_dp
// ------------------------------------------------------------------


module READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_3_rsc_req_obj_din_3_rsc_req_wait_dp
    (
  clk, rst, din_3_rsc_req_obj_oswt, din_3_rsc_req_obj_wen_comp, din_3_rsc_req_obj_biwt,
      din_3_rsc_req_obj_bdwt
);
  input clk;
  input rst;
  input din_3_rsc_req_obj_oswt;
  output din_3_rsc_req_obj_wen_comp;
  input din_3_rsc_req_obj_biwt;
  input din_3_rsc_req_obj_bdwt;


  // Interconnect Declarations
  reg din_3_rsc_req_obj_bcwt;


  // Interconnect Declarations for Component Instantiations 
  assign din_3_rsc_req_obj_wen_comp = (~ din_3_rsc_req_obj_oswt) | din_3_rsc_req_obj_biwt
      | din_3_rsc_req_obj_bcwt;
  always @(posedge clk) begin
    if ( rst ) begin
      din_3_rsc_req_obj_bcwt <= 1'b0;
    end
    else begin
      din_3_rsc_req_obj_bcwt <= ~((~(din_3_rsc_req_obj_bcwt | din_3_rsc_req_obj_biwt))
          | din_3_rsc_req_obj_bdwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_3_rsc_req_obj_din_3_rsc_req_wait_ctrl
// ------------------------------------------------------------------


module READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_3_rsc_req_obj_din_3_rsc_req_wait_ctrl
    (
  clk, rst, core_wen, core_wten, din_3_rsc_req_obj_oswt, din_3_rsc_req_obj_vd, din_3_rsc_req_obj_biwt,
      din_3_rsc_req_obj_bdwt
);
  input clk;
  input rst;
  input core_wen;
  input core_wten;
  input din_3_rsc_req_obj_oswt;
  input din_3_rsc_req_obj_vd;
  output din_3_rsc_req_obj_biwt;
  output din_3_rsc_req_obj_bdwt;


  // Interconnect Declarations
  wire din_3_rsc_req_obj_pdswt0;
  reg din_3_rsc_req_obj_icwt;


  // Interconnect Declarations for Component Instantiations 
  assign din_3_rsc_req_obj_pdswt0 = (~ core_wten) & din_3_rsc_req_obj_oswt;
  assign din_3_rsc_req_obj_biwt = (din_3_rsc_req_obj_pdswt0 | din_3_rsc_req_obj_icwt)
      & din_3_rsc_req_obj_vd;
  assign din_3_rsc_req_obj_bdwt = din_3_rsc_req_obj_oswt & core_wen;
  always @(posedge clk) begin
    if ( rst ) begin
      din_3_rsc_req_obj_icwt <= 1'b0;
    end
    else begin
      din_3_rsc_req_obj_icwt <= ~((~(din_3_rsc_req_obj_icwt | din_3_rsc_req_obj_pdswt0))
          | din_3_rsc_req_obj_biwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_3_rsc_rls_obj_din_3_rsc_rls_wait_ctrl
// ------------------------------------------------------------------


module READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_3_rsc_rls_obj_din_3_rsc_rls_wait_ctrl
    (
  core_wten, din_3_rsc_rls_obj_iswt0, din_3_rsc_rls_obj_ld_core_sct
);
  input core_wten;
  input din_3_rsc_rls_obj_iswt0;
  output din_3_rsc_rls_obj_ld_core_sct;



  // Interconnect Declarations for Component Instantiations 
  assign din_3_rsc_rls_obj_ld_core_sct = din_3_rsc_rls_obj_iswt0 & (~ core_wten);
endmodule

// ------------------------------------------------------------------
//  Design Unit:    READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_2_rsc_rls_obj_din_2_rsc_rls_wait_ctrl
// ------------------------------------------------------------------


module READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_2_rsc_rls_obj_din_2_rsc_rls_wait_ctrl
    (
  core_wten, din_2_rsc_rls_obj_iswt0, din_2_rsc_rls_obj_ld_core_sct
);
  input core_wten;
  input din_2_rsc_rls_obj_iswt0;
  output din_2_rsc_rls_obj_ld_core_sct;



  // Interconnect Declarations for Component Instantiations 
  assign din_2_rsc_rls_obj_ld_core_sct = din_2_rsc_rls_obj_iswt0 & (~ core_wten);
endmodule

// ------------------------------------------------------------------
//  Design Unit:    READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_1_rsc_rls_obj_din_1_rsc_rls_wait_ctrl
// ------------------------------------------------------------------


module READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_1_rsc_rls_obj_din_1_rsc_rls_wait_ctrl
    (
  core_wten, din_1_rsc_rls_obj_iswt0, din_1_rsc_rls_obj_ld_core_sct
);
  input core_wten;
  input din_1_rsc_rls_obj_iswt0;
  output din_1_rsc_rls_obj_ld_core_sct;



  // Interconnect Declarations for Component Instantiations 
  assign din_1_rsc_rls_obj_ld_core_sct = din_1_rsc_rls_obj_iswt0 & (~ core_wten);
endmodule

// ------------------------------------------------------------------
//  Design Unit:    READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_0_rsc_rls_obj_din_0_rsc_rls_wait_ctrl
// ------------------------------------------------------------------


module READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_0_rsc_rls_obj_din_0_rsc_rls_wait_ctrl
    (
  core_wten, din_0_rsc_rls_obj_iswt0, din_0_rsc_rls_obj_ld_core_sct
);
  input core_wten;
  input din_0_rsc_rls_obj_iswt0;
  output din_0_rsc_rls_obj_ld_core_sct;



  // Interconnect Declarations for Component Instantiations 
  assign din_0_rsc_rls_obj_ld_core_sct = din_0_rsc_rls_obj_iswt0 & (~ core_wten);
endmodule

// ------------------------------------------------------------------
//  Design Unit:    READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_dout_rsci_dout_wait_dp
// ------------------------------------------------------------------


module READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_dout_rsci_dout_wait_dp (
  clk, rst, dout_rsci_oswt, dout_rsci_wen_comp, dout_rsci_biwt, dout_rsci_bdwt
);
  input clk;
  input rst;
  input dout_rsci_oswt;
  output dout_rsci_wen_comp;
  input dout_rsci_biwt;
  input dout_rsci_bdwt;


  // Interconnect Declarations
  reg dout_rsci_bcwt;


  // Interconnect Declarations for Component Instantiations 
  assign dout_rsci_wen_comp = (~ dout_rsci_oswt) | dout_rsci_biwt | dout_rsci_bcwt;
  always @(posedge clk) begin
    if ( rst ) begin
      dout_rsci_bcwt <= 1'b0;
    end
    else begin
      dout_rsci_bcwt <= ~((~(dout_rsci_bcwt | dout_rsci_biwt)) | dout_rsci_bdwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_dout_rsci_dout_wait_ctrl
// ------------------------------------------------------------------


module READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_dout_rsci_dout_wait_ctrl (
  clk, rst, core_wen, core_wten, dout_rsci_oswt, dout_rsci_biwt, dout_rsci_bdwt,
      dout_rsci_ld_core_sct, dout_rsci_vd
);
  input clk;
  input rst;
  input core_wen;
  input core_wten;
  input dout_rsci_oswt;
  output dout_rsci_biwt;
  output dout_rsci_bdwt;
  output dout_rsci_ld_core_sct;
  input dout_rsci_vd;


  // Interconnect Declarations
  wire dout_rsci_ogwt;
  wire dout_rsci_pdswt0;
  reg dout_rsci_icwt;


  // Interconnect Declarations for Component Instantiations 
  assign dout_rsci_pdswt0 = (~ core_wten) & dout_rsci_oswt;
  assign dout_rsci_biwt = dout_rsci_ogwt & dout_rsci_vd;
  assign dout_rsci_ogwt = dout_rsci_pdswt0 | dout_rsci_icwt;
  assign dout_rsci_bdwt = dout_rsci_oswt & core_wen;
  assign dout_rsci_ld_core_sct = dout_rsci_oswt & dout_rsci_ogwt;
  always @(posedge clk) begin
    if ( rst ) begin
      dout_rsci_icwt <= 1'b0;
    end
    else begin
      dout_rsci_icwt <= ~((~(dout_rsci_icwt | dout_rsci_pdswt0)) | dout_rsci_biwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_3_rsci_1_din_3_rsc_wait_dp
// ------------------------------------------------------------------


module READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_3_rsci_1_din_3_rsc_wait_dp (
  clk, rst, din_3_rsci_addr_d, din_3_rsci_re_d, din_3_rsci_data_out_d, din_3_rsci_addr_d_core,
      din_3_rsci_data_out_d_mxwt, din_3_rsci_biwt, din_3_rsci_bdwt, din_3_rsci_re_d_core_sct
);
  input clk;
  input rst;
  output [6:0] din_3_rsci_addr_d;
  output [1:0] din_3_rsci_re_d;
  input [31:0] din_3_rsci_data_out_d;
  input [13:0] din_3_rsci_addr_d_core;
  output [15:0] din_3_rsci_data_out_d_mxwt;
  input din_3_rsci_biwt;
  input din_3_rsci_bdwt;
  input [1:0] din_3_rsci_re_d_core_sct;


  // Interconnect Declarations
  reg din_3_rsci_bcwt;
  reg [15:0] din_3_rsci_data_out_d_bfwt_15_0;
  wire [15:0] din_3_rsci_data_out_d_mxwt_opt_15_0;


  // Interconnect Declarations for Component Instantiations 
  assign din_3_rsci_data_out_d_mxwt_opt_15_0 = MUX_v_16_2_2((din_3_rsci_data_out_d[15:0]),
      din_3_rsci_data_out_d_bfwt_15_0, din_3_rsci_bcwt);
  assign din_3_rsci_data_out_d_mxwt = din_3_rsci_data_out_d_mxwt_opt_15_0;
  assign din_3_rsci_re_d = ~ din_3_rsci_re_d_core_sct;
  assign din_3_rsci_addr_d = din_3_rsci_addr_d_core[6:0];
  always @(posedge clk) begin
    if ( rst ) begin
      din_3_rsci_bcwt <= 1'b0;
      din_3_rsci_data_out_d_bfwt_15_0 <= 16'b0;
    end
    else begin
      din_3_rsci_bcwt <= ~((~(din_3_rsci_bcwt | din_3_rsci_biwt)) | din_3_rsci_bdwt);
      din_3_rsci_data_out_d_bfwt_15_0 <= din_3_rsci_data_out_d_mxwt_opt_15_0;
    end
  end

  function [15:0] MUX_v_16_2_2;
    input [15:0] input_0;
    input [15:0] input_1;
    input [0:0] sel;
    reg [15:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_16_2_2 = result;
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_3_rsci_1_din_3_rsc_wait_ctrl
// ------------------------------------------------------------------


module READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_3_rsci_1_din_3_rsc_wait_ctrl (
  core_wen, core_wten, din_3_rsci_oswt, din_3_rsci_re_d_core_psct, din_3_rsci_biwt,
      din_3_rsci_bdwt, din_3_rsci_re_d_core_sct, din_3_rsci_oswt_pff
);
  input core_wen;
  input core_wten;
  input din_3_rsci_oswt;
  input [1:0] din_3_rsci_re_d_core_psct;
  output din_3_rsci_biwt;
  output din_3_rsci_bdwt;
  output [1:0] din_3_rsci_re_d_core_sct;
  input din_3_rsci_oswt_pff;


  wire[0:0] din_3_and_1_nl;

  // Interconnect Declarations for Component Instantiations 
  assign din_3_rsci_biwt = (~ core_wten) & din_3_rsci_oswt;
  assign din_3_rsci_bdwt = din_3_rsci_oswt & core_wen;
  assign din_3_and_1_nl = (din_3_rsci_re_d_core_psct[0]) & core_wen & din_3_rsci_oswt_pff;
  assign din_3_rsci_re_d_core_sct = {1'b0 , (din_3_and_1_nl)};
endmodule

// ------------------------------------------------------------------
//  Design Unit:    READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_2_rsci_1_din_2_rsc_wait_dp
// ------------------------------------------------------------------


module READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_2_rsci_1_din_2_rsc_wait_dp (
  clk, rst, din_2_rsci_addr_d, din_2_rsci_re_d, din_2_rsci_data_out_d, din_2_rsci_addr_d_core,
      din_2_rsci_data_out_d_mxwt, din_2_rsci_biwt, din_2_rsci_bdwt, din_2_rsci_re_d_core_sct
);
  input clk;
  input rst;
  output [6:0] din_2_rsci_addr_d;
  output [1:0] din_2_rsci_re_d;
  input [31:0] din_2_rsci_data_out_d;
  input [13:0] din_2_rsci_addr_d_core;
  output [15:0] din_2_rsci_data_out_d_mxwt;
  input din_2_rsci_biwt;
  input din_2_rsci_bdwt;
  input [1:0] din_2_rsci_re_d_core_sct;


  // Interconnect Declarations
  reg din_2_rsci_bcwt;
  reg [15:0] din_2_rsci_data_out_d_bfwt_15_0;
  wire [15:0] din_2_rsci_data_out_d_mxwt_opt_15_0;


  // Interconnect Declarations for Component Instantiations 
  assign din_2_rsci_data_out_d_mxwt_opt_15_0 = MUX_v_16_2_2((din_2_rsci_data_out_d[15:0]),
      din_2_rsci_data_out_d_bfwt_15_0, din_2_rsci_bcwt);
  assign din_2_rsci_data_out_d_mxwt = din_2_rsci_data_out_d_mxwt_opt_15_0;
  assign din_2_rsci_re_d = ~ din_2_rsci_re_d_core_sct;
  assign din_2_rsci_addr_d = din_2_rsci_addr_d_core[6:0];
  always @(posedge clk) begin
    if ( rst ) begin
      din_2_rsci_bcwt <= 1'b0;
      din_2_rsci_data_out_d_bfwt_15_0 <= 16'b0;
    end
    else begin
      din_2_rsci_bcwt <= ~((~(din_2_rsci_bcwt | din_2_rsci_biwt)) | din_2_rsci_bdwt);
      din_2_rsci_data_out_d_bfwt_15_0 <= din_2_rsci_data_out_d_mxwt_opt_15_0;
    end
  end

  function [15:0] MUX_v_16_2_2;
    input [15:0] input_0;
    input [15:0] input_1;
    input [0:0] sel;
    reg [15:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_16_2_2 = result;
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_2_rsci_1_din_2_rsc_wait_ctrl
// ------------------------------------------------------------------


module READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_2_rsci_1_din_2_rsc_wait_ctrl (
  core_wen, core_wten, din_2_rsci_oswt, din_2_rsci_re_d_core_psct, din_2_rsci_biwt,
      din_2_rsci_bdwt, din_2_rsci_re_d_core_sct, din_2_rsci_oswt_pff
);
  input core_wen;
  input core_wten;
  input din_2_rsci_oswt;
  input [1:0] din_2_rsci_re_d_core_psct;
  output din_2_rsci_biwt;
  output din_2_rsci_bdwt;
  output [1:0] din_2_rsci_re_d_core_sct;
  input din_2_rsci_oswt_pff;


  wire[0:0] din_2_and_1_nl;

  // Interconnect Declarations for Component Instantiations 
  assign din_2_rsci_biwt = (~ core_wten) & din_2_rsci_oswt;
  assign din_2_rsci_bdwt = din_2_rsci_oswt & core_wen;
  assign din_2_and_1_nl = (din_2_rsci_re_d_core_psct[0]) & core_wen & din_2_rsci_oswt_pff;
  assign din_2_rsci_re_d_core_sct = {1'b0 , (din_2_and_1_nl)};
endmodule

// ------------------------------------------------------------------
//  Design Unit:    READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_1_rsci_1_din_1_rsc_wait_dp
// ------------------------------------------------------------------


module READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_1_rsci_1_din_1_rsc_wait_dp (
  clk, rst, din_1_rsci_addr_d, din_1_rsci_re_d, din_1_rsci_data_out_d, din_1_rsci_addr_d_core,
      din_1_rsci_data_out_d_mxwt, din_1_rsci_biwt, din_1_rsci_bdwt, din_1_rsci_re_d_core_sct
);
  input clk;
  input rst;
  output [6:0] din_1_rsci_addr_d;
  output [1:0] din_1_rsci_re_d;
  input [31:0] din_1_rsci_data_out_d;
  input [13:0] din_1_rsci_addr_d_core;
  output [15:0] din_1_rsci_data_out_d_mxwt;
  input din_1_rsci_biwt;
  input din_1_rsci_bdwt;
  input [1:0] din_1_rsci_re_d_core_sct;


  // Interconnect Declarations
  reg din_1_rsci_bcwt;
  reg [15:0] din_1_rsci_data_out_d_bfwt_15_0;
  wire [15:0] din_1_rsci_data_out_d_mxwt_opt_15_0;


  // Interconnect Declarations for Component Instantiations 
  assign din_1_rsci_data_out_d_mxwt_opt_15_0 = MUX_v_16_2_2((din_1_rsci_data_out_d[15:0]),
      din_1_rsci_data_out_d_bfwt_15_0, din_1_rsci_bcwt);
  assign din_1_rsci_data_out_d_mxwt = din_1_rsci_data_out_d_mxwt_opt_15_0;
  assign din_1_rsci_re_d = ~ din_1_rsci_re_d_core_sct;
  assign din_1_rsci_addr_d = din_1_rsci_addr_d_core[6:0];
  always @(posedge clk) begin
    if ( rst ) begin
      din_1_rsci_bcwt <= 1'b0;
      din_1_rsci_data_out_d_bfwt_15_0 <= 16'b0;
    end
    else begin
      din_1_rsci_bcwt <= ~((~(din_1_rsci_bcwt | din_1_rsci_biwt)) | din_1_rsci_bdwt);
      din_1_rsci_data_out_d_bfwt_15_0 <= din_1_rsci_data_out_d_mxwt_opt_15_0;
    end
  end

  function [15:0] MUX_v_16_2_2;
    input [15:0] input_0;
    input [15:0] input_1;
    input [0:0] sel;
    reg [15:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_16_2_2 = result;
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_1_rsci_1_din_1_rsc_wait_ctrl
// ------------------------------------------------------------------


module READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_1_rsci_1_din_1_rsc_wait_ctrl (
  core_wen, core_wten, din_1_rsci_oswt, din_1_rsci_re_d_core_psct, din_1_rsci_biwt,
      din_1_rsci_bdwt, din_1_rsci_re_d_core_sct, din_1_rsci_oswt_pff
);
  input core_wen;
  input core_wten;
  input din_1_rsci_oswt;
  input [1:0] din_1_rsci_re_d_core_psct;
  output din_1_rsci_biwt;
  output din_1_rsci_bdwt;
  output [1:0] din_1_rsci_re_d_core_sct;
  input din_1_rsci_oswt_pff;


  wire[0:0] din_1_and_1_nl;

  // Interconnect Declarations for Component Instantiations 
  assign din_1_rsci_biwt = (~ core_wten) & din_1_rsci_oswt;
  assign din_1_rsci_bdwt = din_1_rsci_oswt & core_wen;
  assign din_1_and_1_nl = (din_1_rsci_re_d_core_psct[0]) & core_wen & din_1_rsci_oswt_pff;
  assign din_1_rsci_re_d_core_sct = {1'b0 , (din_1_and_1_nl)};
endmodule

// ------------------------------------------------------------------
//  Design Unit:    READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_0_rsci_1_din_0_rsc_wait_dp
// ------------------------------------------------------------------


module READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_0_rsci_1_din_0_rsc_wait_dp (
  clk, rst, din_0_rsci_addr_d, din_0_rsci_re_d, din_0_rsci_data_out_d, din_0_rsci_addr_d_core,
      din_0_rsci_data_out_d_mxwt, din_0_rsci_biwt, din_0_rsci_bdwt, din_0_rsci_re_d_core_sct
);
  input clk;
  input rst;
  output [6:0] din_0_rsci_addr_d;
  output [1:0] din_0_rsci_re_d;
  input [31:0] din_0_rsci_data_out_d;
  input [13:0] din_0_rsci_addr_d_core;
  output [15:0] din_0_rsci_data_out_d_mxwt;
  input din_0_rsci_biwt;
  input din_0_rsci_bdwt;
  input [1:0] din_0_rsci_re_d_core_sct;


  // Interconnect Declarations
  reg din_0_rsci_bcwt;
  reg [15:0] din_0_rsci_data_out_d_bfwt_15_0;
  wire [15:0] din_0_rsci_data_out_d_mxwt_opt_15_0;


  // Interconnect Declarations for Component Instantiations 
  assign din_0_rsci_data_out_d_mxwt_opt_15_0 = MUX_v_16_2_2((din_0_rsci_data_out_d[15:0]),
      din_0_rsci_data_out_d_bfwt_15_0, din_0_rsci_bcwt);
  assign din_0_rsci_data_out_d_mxwt = din_0_rsci_data_out_d_mxwt_opt_15_0;
  assign din_0_rsci_re_d = ~ din_0_rsci_re_d_core_sct;
  assign din_0_rsci_addr_d = din_0_rsci_addr_d_core[6:0];
  always @(posedge clk) begin
    if ( rst ) begin
      din_0_rsci_bcwt <= 1'b0;
      din_0_rsci_data_out_d_bfwt_15_0 <= 16'b0;
    end
    else begin
      din_0_rsci_bcwt <= ~((~(din_0_rsci_bcwt | din_0_rsci_biwt)) | din_0_rsci_bdwt);
      din_0_rsci_data_out_d_bfwt_15_0 <= din_0_rsci_data_out_d_mxwt_opt_15_0;
    end
  end

  function [15:0] MUX_v_16_2_2;
    input [15:0] input_0;
    input [15:0] input_1;
    input [0:0] sel;
    reg [15:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_16_2_2 = result;
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_0_rsci_1_din_0_rsc_wait_ctrl
// ------------------------------------------------------------------


module READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_0_rsci_1_din_0_rsc_wait_ctrl (
  core_wen, din_0_rsci_oswt, din_0_rsci_re_d_core_psct, core_wten, din_0_rsci_biwt,
      din_0_rsci_bdwt, din_0_rsci_re_d_core_sct, din_0_rsci_oswt_pff
);
  input core_wen;
  input din_0_rsci_oswt;
  input [1:0] din_0_rsci_re_d_core_psct;
  input core_wten;
  output din_0_rsci_biwt;
  output din_0_rsci_bdwt;
  output [1:0] din_0_rsci_re_d_core_sct;
  input din_0_rsci_oswt_pff;


  wire[0:0] din_0_and_1_nl;

  // Interconnect Declarations for Component Instantiations 
  assign din_0_rsci_biwt = (~ core_wten) & din_0_rsci_oswt;
  assign din_0_rsci_bdwt = din_0_rsci_oswt & core_wen;
  assign din_0_and_1_nl = (din_0_rsci_re_d_core_psct[0]) & core_wen & din_0_rsci_oswt_pff;
  assign din_0_rsci_re_d_core_sct = {1'b0 , (din_0_and_1_nl)};
endmodule

// ------------------------------------------------------------------
//  Design Unit:    double_buffeHLhBe_3_cns_bctl
// ------------------------------------------------------------------


module double_buffeHLhBe_3_cns_bctl (
  clk, rst, dout_3_rsc_data_in_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst, dout_3_rsc_addr_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst,
      dout_3_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst, dout_3_rsc_req_vz_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst,
      dout_3_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz, din_3_rsc_addr_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst,
      din_3_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst, din_3_rsc_data_out_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst,
      din_3_rsc_req_vz_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst, din_3_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz,
      dout_3_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_bud, dout_3_rsc_rls_lz_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_bud,
      din_3_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_bud, din_3_rsc_rls_lz_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_bud,
      shr_mem_3_cns_S0, shr_mem_3_cns_R0, shr_mem_3_cns_S1, shr_mem_3_cns_R1, shr_mem_3_cns_data_in_shi0,
      shr_mem_3_cns_data_in_shi1, shr_mem_3_cns_addr_shi0, shr_mem_3_cns_addr_shi1,
      shr_mem_3_cns_re_shi0, shr_mem_3_cns_re_shi1, shr_mem_3_cns_we_shi0, shr_mem_3_cns_we_shi1,
      shr_mem_3_cns_data_out_sho0, shr_mem_3_cns_data_out_sho1, shr_mem_3_cns_S1_pff,
      din_3_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_pff, din_3_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_bud_pff,
      dout_3_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_pff, dout_3_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_bud_pff,
      shr_mem_3_cns_S0_pff
);
  input clk;
  input rst;
  input [127:0] dout_3_rsc_data_in_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst;
  input [15:0] dout_3_rsc_addr_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst;
  input [1:0] dout_3_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst;
  output dout_3_rsc_req_vz_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst;
  input [1:0] dout_3_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz;
  input [15:0] din_3_rsc_addr_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst;
  input [1:0] din_3_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst;
  output [127:0] din_3_rsc_data_out_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst;
  output din_3_rsc_req_vz_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst;
  input [1:0] din_3_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz;
  output [1:0] dout_3_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_bud;
  input dout_3_rsc_rls_lz_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_bud;
  output [1:0] din_3_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_bud;
  input din_3_rsc_rls_lz_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_bud;
  output shr_mem_3_cns_S0;
  input shr_mem_3_cns_R0;
  output shr_mem_3_cns_S1;
  input shr_mem_3_cns_R1;
  output [127:0] shr_mem_3_cns_data_in_shi0;
  output [127:0] shr_mem_3_cns_data_in_shi1;
  output [15:0] shr_mem_3_cns_addr_shi0;
  output [15:0] shr_mem_3_cns_addr_shi1;
  output [1:0] shr_mem_3_cns_re_shi0;
  output [1:0] shr_mem_3_cns_re_shi1;
  output [1:0] shr_mem_3_cns_we_shi0;
  output [1:0] shr_mem_3_cns_we_shi1;
  input [127:0] shr_mem_3_cns_data_out_sho0;
  input [127:0] shr_mem_3_cns_data_out_sho1;
  output shr_mem_3_cns_S1_pff;
  input [1:0] din_3_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_pff;
  output [1:0] din_3_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_bud_pff;
  input [1:0] dout_3_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_pff;
  output [1:0] dout_3_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_bud_pff;
  output shr_mem_3_cns_S0_pff;


  // Interconnect Declarations
  reg [1:0] dout_3_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buy;
  reg [1:0] din_3_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buy;
  wire shr_mem_3_cns_PC0;
  reg shr_mem_3_cns_ppidx;
  reg [1:0] shr_mem_3_cns_ppown;
  wire shr_mem_3_cns_PC1;
  reg shr_mem_3_cns_ppidx_1;
  reg [1:0] shr_mem_3_cns_ppown_1;
  wire shr_mem_3_and_5_cse_pff;
  wire [1:0] shr_mem_3_acc_1_rmff;
  wire [3:0] nl_shr_mem_3_acc_1_rmff;
  wire shr_mem_3_xor_1_rmff;
  wire [1:0] shr_mem_3_acc_rmff;
  wire [3:0] nl_shr_mem_3_acc_rmff;
  wire shr_mem_3_xor_rmff;
  wire shr_mem_3_and_7_cse_pff;

  wire[0:0] shr_mem_3_shr_mem_3_not_nl;
  wire[0:0] shr_mem_3_shr_mem_3_shr_mem_3_nand_1_nl;
  wire[0:0] shr_mem_3_shr_mem_3_not_1_nl;
  wire[0:0] shr_mem_3_shr_mem_3_shr_mem_3_nand_nl;

  // Interconnect Declarations for Component Instantiations 
  assign dout_3_rsc_req_vz_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst = shr_mem_3_cns_R0;
  assign din_3_rsc_req_vz_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst = shr_mem_3_cns_R1;
  assign shr_mem_3_xor_rmff = shr_mem_3_cns_ppidx ^ shr_mem_3_cns_PC0;
  assign nl_shr_mem_3_acc_rmff = shr_mem_3_cns_ppown + conv_u2u_1_2(shr_mem_3_cns_PC0)
      + conv_s2u_1_2(shr_mem_3_cns_PC1);
  assign shr_mem_3_acc_rmff = nl_shr_mem_3_acc_rmff[1:0];
  assign shr_mem_3_cns_PC0 = shr_mem_3_cns_S0 & dout_3_rsc_rls_lz_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_bud;
  assign shr_mem_3_xor_1_rmff = shr_mem_3_cns_ppidx_1 ^ shr_mem_3_cns_PC1;
  assign nl_shr_mem_3_acc_1_rmff = shr_mem_3_cns_ppown_1 + conv_u2u_1_2(shr_mem_3_cns_PC1)
      + conv_s2u_1_2(shr_mem_3_cns_PC0);
  assign shr_mem_3_acc_1_rmff = nl_shr_mem_3_acc_1_rmff[1:0];
  assign shr_mem_3_cns_PC1 = shr_mem_3_cns_S1 & din_3_rsc_rls_lz_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_bud;
  assign din_3_rsc_data_out_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst = MUX_v_128_2_2(shr_mem_3_cns_data_out_sho0,
      shr_mem_3_cns_data_out_sho1, shr_mem_3_cns_ppidx_1);
  assign shr_mem_3_cns_data_in_shi0 = dout_3_rsc_data_in_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst;
  assign shr_mem_3_cns_addr_shi0 = MUX_v_16_2_2(dout_3_rsc_addr_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst,
      din_3_rsc_addr_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst, shr_mem_3_and_5_cse_pff);
  assign shr_mem_3_cns_S1 = (shr_mem_3_cns_ppown_1!=2'b00);
  assign shr_mem_3_cns_S1_pff = (shr_mem_3_acc_1_rmff!=2'b00);
  assign shr_mem_3_and_5_cse_pff = shr_mem_3_cns_S1_pff & (~ shr_mem_3_xor_1_rmff);
  assign shr_mem_3_shr_mem_3_not_nl = ~ shr_mem_3_and_5_cse_pff;
  assign shr_mem_3_cns_re_shi0 = MUX_v_2_2_2(din_3_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_pff,
      2'b11, (shr_mem_3_shr_mem_3_not_nl));
  assign din_3_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_bud = ~ din_3_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buy;
  assign din_3_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_bud_pff =
      din_3_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst;
  assign shr_mem_3_shr_mem_3_shr_mem_3_nand_1_nl = ~(shr_mem_3_cns_S0_pff & (~ shr_mem_3_xor_rmff));
  assign shr_mem_3_cns_we_shi0 = MUX_v_2_2_2(dout_3_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_pff,
      2'b11, (shr_mem_3_shr_mem_3_shr_mem_3_nand_1_nl));
  assign dout_3_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_bud = ~ dout_3_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buy;
  assign dout_3_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_bud_pff =
      dout_3_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst;
  assign shr_mem_3_cns_S0 = ~((shr_mem_3_cns_ppown==2'b10));
  assign shr_mem_3_cns_S0_pff = ~((shr_mem_3_acc_rmff==2'b10));
  assign shr_mem_3_cns_data_in_shi1 = dout_3_rsc_data_in_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst;
  assign shr_mem_3_cns_addr_shi1 = MUX_v_16_2_2(dout_3_rsc_addr_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst,
      din_3_rsc_addr_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst, shr_mem_3_and_7_cse_pff);
  assign shr_mem_3_and_7_cse_pff = shr_mem_3_cns_S1_pff & shr_mem_3_xor_1_rmff;
  assign shr_mem_3_shr_mem_3_not_1_nl = ~ shr_mem_3_and_7_cse_pff;
  assign shr_mem_3_cns_re_shi1 = MUX_v_2_2_2(din_3_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_pff,
      2'b11, (shr_mem_3_shr_mem_3_not_1_nl));
  assign shr_mem_3_shr_mem_3_shr_mem_3_nand_nl = ~(shr_mem_3_cns_S0_pff & shr_mem_3_xor_rmff);
  assign shr_mem_3_cns_we_shi1 = MUX_v_2_2_2(dout_3_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_pff,
      2'b11, (shr_mem_3_shr_mem_3_shr_mem_3_nand_nl));
  always @(posedge clk) begin
    if ( rst ) begin
      dout_3_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buy <= 2'b0;
      din_3_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buy <= 2'b0;
      shr_mem_3_cns_ppidx <= 1'b0;
      shr_mem_3_cns_ppown <= 2'b0;
      shr_mem_3_cns_ppidx_1 <= 1'b0;
      shr_mem_3_cns_ppown_1 <= 2'b0;
    end
    else begin
      dout_3_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buy <= ~ dout_3_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst;
      din_3_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buy <= ~ din_3_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst;
      shr_mem_3_cns_ppidx <= shr_mem_3_xor_rmff;
      shr_mem_3_cns_ppown <= shr_mem_3_acc_rmff;
      shr_mem_3_cns_ppidx_1 <= shr_mem_3_xor_1_rmff;
      shr_mem_3_cns_ppown_1 <= shr_mem_3_acc_1_rmff;
    end
  end

  function [127:0] MUX_v_128_2_2;
    input [127:0] input_0;
    input [127:0] input_1;
    input [0:0] sel;
    reg [127:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_128_2_2 = result;
  end
  endfunction


  function [15:0] MUX_v_16_2_2;
    input [15:0] input_0;
    input [15:0] input_1;
    input [0:0] sel;
    reg [15:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_16_2_2 = result;
  end
  endfunction


  function [1:0] MUX_v_2_2_2;
    input [1:0] input_0;
    input [1:0] input_1;
    input [0:0] sel;
    reg [1:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_2_2_2 = result;
  end
  endfunction


  function  [1:0] conv_s2u_1_2 ;
    input [0:0]  vector ;
  begin
    conv_s2u_1_2 = {vector[0], vector};
  end
  endfunction


  function  [1:0] conv_u2u_1_2 ;
    input [0:0]  vector ;
  begin
    conv_u2u_1_2 = {1'b0, vector};
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    double_buffeHLhBe_2_cns_bctl
// ------------------------------------------------------------------


module double_buffeHLhBe_2_cns_bctl (
  clk, rst, dout_2_rsc_data_in_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst, dout_2_rsc_addr_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst,
      dout_2_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst, dout_2_rsc_req_vz_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst,
      dout_2_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz, din_2_rsc_addr_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst,
      din_2_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst, din_2_rsc_data_out_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst,
      din_2_rsc_req_vz_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst, din_2_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz,
      dout_2_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_bud, dout_2_rsc_rls_lz_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_bud,
      din_2_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_bud, din_2_rsc_rls_lz_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_bud,
      shr_mem_2_cns_S0, shr_mem_2_cns_R0, shr_mem_2_cns_S1, shr_mem_2_cns_R1, shr_mem_2_cns_data_in_shi0,
      shr_mem_2_cns_data_in_shi1, shr_mem_2_cns_addr_shi0, shr_mem_2_cns_addr_shi1,
      shr_mem_2_cns_re_shi0, shr_mem_2_cns_re_shi1, shr_mem_2_cns_we_shi0, shr_mem_2_cns_we_shi1,
      shr_mem_2_cns_data_out_sho0, shr_mem_2_cns_data_out_sho1, shr_mem_2_cns_S1_pff,
      din_2_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_pff, din_2_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_bud_pff,
      dout_2_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_pff, dout_2_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_bud_pff,
      shr_mem_2_cns_S0_pff
);
  input clk;
  input rst;
  input [127:0] dout_2_rsc_data_in_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst;
  input [15:0] dout_2_rsc_addr_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst;
  input [1:0] dout_2_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst;
  output dout_2_rsc_req_vz_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst;
  input [1:0] dout_2_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz;
  input [15:0] din_2_rsc_addr_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst;
  input [1:0] din_2_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst;
  output [127:0] din_2_rsc_data_out_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst;
  output din_2_rsc_req_vz_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst;
  input [1:0] din_2_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz;
  output [1:0] dout_2_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_bud;
  input dout_2_rsc_rls_lz_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_bud;
  output [1:0] din_2_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_bud;
  input din_2_rsc_rls_lz_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_bud;
  output shr_mem_2_cns_S0;
  input shr_mem_2_cns_R0;
  output shr_mem_2_cns_S1;
  input shr_mem_2_cns_R1;
  output [127:0] shr_mem_2_cns_data_in_shi0;
  output [127:0] shr_mem_2_cns_data_in_shi1;
  output [15:0] shr_mem_2_cns_addr_shi0;
  output [15:0] shr_mem_2_cns_addr_shi1;
  output [1:0] shr_mem_2_cns_re_shi0;
  output [1:0] shr_mem_2_cns_re_shi1;
  output [1:0] shr_mem_2_cns_we_shi0;
  output [1:0] shr_mem_2_cns_we_shi1;
  input [127:0] shr_mem_2_cns_data_out_sho0;
  input [127:0] shr_mem_2_cns_data_out_sho1;
  output shr_mem_2_cns_S1_pff;
  input [1:0] din_2_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_pff;
  output [1:0] din_2_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_bud_pff;
  input [1:0] dout_2_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_pff;
  output [1:0] dout_2_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_bud_pff;
  output shr_mem_2_cns_S0_pff;


  // Interconnect Declarations
  reg [1:0] dout_2_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buy;
  reg [1:0] din_2_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buy;
  wire shr_mem_2_cns_PC0;
  reg shr_mem_2_cns_ppidx;
  reg [1:0] shr_mem_2_cns_ppown;
  wire shr_mem_2_cns_PC1;
  reg shr_mem_2_cns_ppidx_1;
  reg [1:0] shr_mem_2_cns_ppown_1;
  wire shr_mem_2_and_5_cse_pff;
  wire [1:0] shr_mem_2_acc_1_rmff;
  wire [3:0] nl_shr_mem_2_acc_1_rmff;
  wire shr_mem_2_xor_1_rmff;
  wire [1:0] shr_mem_2_acc_rmff;
  wire [3:0] nl_shr_mem_2_acc_rmff;
  wire shr_mem_2_xor_rmff;
  wire shr_mem_2_and_7_cse_pff;

  wire[0:0] shr_mem_2_shr_mem_2_not_nl;
  wire[0:0] shr_mem_2_shr_mem_2_shr_mem_2_nand_1_nl;
  wire[0:0] shr_mem_2_shr_mem_2_not_1_nl;
  wire[0:0] shr_mem_2_shr_mem_2_shr_mem_2_nand_nl;

  // Interconnect Declarations for Component Instantiations 
  assign dout_2_rsc_req_vz_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst = shr_mem_2_cns_R0;
  assign din_2_rsc_req_vz_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst = shr_mem_2_cns_R1;
  assign shr_mem_2_xor_rmff = shr_mem_2_cns_ppidx ^ shr_mem_2_cns_PC0;
  assign nl_shr_mem_2_acc_rmff = shr_mem_2_cns_ppown + conv_u2u_1_2(shr_mem_2_cns_PC0)
      + conv_s2u_1_2(shr_mem_2_cns_PC1);
  assign shr_mem_2_acc_rmff = nl_shr_mem_2_acc_rmff[1:0];
  assign shr_mem_2_cns_PC0 = shr_mem_2_cns_S0 & dout_2_rsc_rls_lz_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_bud;
  assign shr_mem_2_xor_1_rmff = shr_mem_2_cns_ppidx_1 ^ shr_mem_2_cns_PC1;
  assign nl_shr_mem_2_acc_1_rmff = shr_mem_2_cns_ppown_1 + conv_u2u_1_2(shr_mem_2_cns_PC1)
      + conv_s2u_1_2(shr_mem_2_cns_PC0);
  assign shr_mem_2_acc_1_rmff = nl_shr_mem_2_acc_1_rmff[1:0];
  assign shr_mem_2_cns_PC1 = shr_mem_2_cns_S1 & din_2_rsc_rls_lz_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_bud;
  assign din_2_rsc_data_out_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst = MUX_v_128_2_2(shr_mem_2_cns_data_out_sho0,
      shr_mem_2_cns_data_out_sho1, shr_mem_2_cns_ppidx_1);
  assign shr_mem_2_cns_data_in_shi0 = dout_2_rsc_data_in_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst;
  assign shr_mem_2_cns_addr_shi0 = MUX_v_16_2_2(dout_2_rsc_addr_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst,
      din_2_rsc_addr_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst, shr_mem_2_and_5_cse_pff);
  assign shr_mem_2_cns_S1 = (shr_mem_2_cns_ppown_1!=2'b00);
  assign shr_mem_2_cns_S1_pff = (shr_mem_2_acc_1_rmff!=2'b00);
  assign shr_mem_2_and_5_cse_pff = shr_mem_2_cns_S1_pff & (~ shr_mem_2_xor_1_rmff);
  assign shr_mem_2_shr_mem_2_not_nl = ~ shr_mem_2_and_5_cse_pff;
  assign shr_mem_2_cns_re_shi0 = MUX_v_2_2_2(din_2_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_pff,
      2'b11, (shr_mem_2_shr_mem_2_not_nl));
  assign din_2_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_bud = ~ din_2_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buy;
  assign din_2_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_bud_pff =
      din_2_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst;
  assign shr_mem_2_shr_mem_2_shr_mem_2_nand_1_nl = ~(shr_mem_2_cns_S0_pff & (~ shr_mem_2_xor_rmff));
  assign shr_mem_2_cns_we_shi0 = MUX_v_2_2_2(dout_2_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_pff,
      2'b11, (shr_mem_2_shr_mem_2_shr_mem_2_nand_1_nl));
  assign dout_2_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_bud = ~ dout_2_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buy;
  assign dout_2_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_bud_pff =
      dout_2_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst;
  assign shr_mem_2_cns_S0 = ~((shr_mem_2_cns_ppown==2'b10));
  assign shr_mem_2_cns_S0_pff = ~((shr_mem_2_acc_rmff==2'b10));
  assign shr_mem_2_cns_data_in_shi1 = dout_2_rsc_data_in_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst;
  assign shr_mem_2_cns_addr_shi1 = MUX_v_16_2_2(dout_2_rsc_addr_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst,
      din_2_rsc_addr_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst, shr_mem_2_and_7_cse_pff);
  assign shr_mem_2_and_7_cse_pff = shr_mem_2_cns_S1_pff & shr_mem_2_xor_1_rmff;
  assign shr_mem_2_shr_mem_2_not_1_nl = ~ shr_mem_2_and_7_cse_pff;
  assign shr_mem_2_cns_re_shi1 = MUX_v_2_2_2(din_2_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_pff,
      2'b11, (shr_mem_2_shr_mem_2_not_1_nl));
  assign shr_mem_2_shr_mem_2_shr_mem_2_nand_nl = ~(shr_mem_2_cns_S0_pff & shr_mem_2_xor_rmff);
  assign shr_mem_2_cns_we_shi1 = MUX_v_2_2_2(dout_2_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_pff,
      2'b11, (shr_mem_2_shr_mem_2_shr_mem_2_nand_nl));
  always @(posedge clk) begin
    if ( rst ) begin
      dout_2_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buy <= 2'b0;
      din_2_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buy <= 2'b0;
      shr_mem_2_cns_ppidx <= 1'b0;
      shr_mem_2_cns_ppown <= 2'b0;
      shr_mem_2_cns_ppidx_1 <= 1'b0;
      shr_mem_2_cns_ppown_1 <= 2'b0;
    end
    else begin
      dout_2_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buy <= ~ dout_2_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst;
      din_2_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buy <= ~ din_2_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst;
      shr_mem_2_cns_ppidx <= shr_mem_2_xor_rmff;
      shr_mem_2_cns_ppown <= shr_mem_2_acc_rmff;
      shr_mem_2_cns_ppidx_1 <= shr_mem_2_xor_1_rmff;
      shr_mem_2_cns_ppown_1 <= shr_mem_2_acc_1_rmff;
    end
  end

  function [127:0] MUX_v_128_2_2;
    input [127:0] input_0;
    input [127:0] input_1;
    input [0:0] sel;
    reg [127:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_128_2_2 = result;
  end
  endfunction


  function [15:0] MUX_v_16_2_2;
    input [15:0] input_0;
    input [15:0] input_1;
    input [0:0] sel;
    reg [15:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_16_2_2 = result;
  end
  endfunction


  function [1:0] MUX_v_2_2_2;
    input [1:0] input_0;
    input [1:0] input_1;
    input [0:0] sel;
    reg [1:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_2_2_2 = result;
  end
  endfunction


  function  [1:0] conv_s2u_1_2 ;
    input [0:0]  vector ;
  begin
    conv_s2u_1_2 = {vector[0], vector};
  end
  endfunction


  function  [1:0] conv_u2u_1_2 ;
    input [0:0]  vector ;
  begin
    conv_u2u_1_2 = {1'b0, vector};
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    double_buffeHLhBe_1_cns_bctl
// ------------------------------------------------------------------


module double_buffeHLhBe_1_cns_bctl (
  clk, rst, dout_1_rsc_data_in_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst, dout_1_rsc_addr_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst,
      dout_1_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst, dout_1_rsc_req_vz_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst,
      dout_1_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz, din_1_rsc_addr_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst,
      din_1_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst, din_1_rsc_data_out_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst,
      din_1_rsc_req_vz_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst, din_1_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz,
      dout_1_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_bud, dout_1_rsc_rls_lz_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_bud,
      din_1_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_bud, din_1_rsc_rls_lz_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_bud,
      shr_mem_1_cns_S0, shr_mem_1_cns_R0, shr_mem_1_cns_S1, shr_mem_1_cns_R1, shr_mem_1_cns_data_in_shi0,
      shr_mem_1_cns_data_in_shi1, shr_mem_1_cns_addr_shi0, shr_mem_1_cns_addr_shi1,
      shr_mem_1_cns_re_shi0, shr_mem_1_cns_re_shi1, shr_mem_1_cns_we_shi0, shr_mem_1_cns_we_shi1,
      shr_mem_1_cns_data_out_sho0, shr_mem_1_cns_data_out_sho1, shr_mem_1_cns_S1_pff,
      din_1_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_pff, din_1_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_bud_pff,
      dout_1_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_pff, dout_1_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_bud_pff,
      shr_mem_1_cns_S0_pff
);
  input clk;
  input rst;
  input [127:0] dout_1_rsc_data_in_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst;
  input [15:0] dout_1_rsc_addr_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst;
  input [1:0] dout_1_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst;
  output dout_1_rsc_req_vz_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst;
  input [1:0] dout_1_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz;
  input [15:0] din_1_rsc_addr_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst;
  input [1:0] din_1_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst;
  output [127:0] din_1_rsc_data_out_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst;
  output din_1_rsc_req_vz_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst;
  input [1:0] din_1_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz;
  output [1:0] dout_1_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_bud;
  input dout_1_rsc_rls_lz_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_bud;
  output [1:0] din_1_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_bud;
  input din_1_rsc_rls_lz_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_bud;
  output shr_mem_1_cns_S0;
  input shr_mem_1_cns_R0;
  output shr_mem_1_cns_S1;
  input shr_mem_1_cns_R1;
  output [127:0] shr_mem_1_cns_data_in_shi0;
  output [127:0] shr_mem_1_cns_data_in_shi1;
  output [15:0] shr_mem_1_cns_addr_shi0;
  output [15:0] shr_mem_1_cns_addr_shi1;
  output [1:0] shr_mem_1_cns_re_shi0;
  output [1:0] shr_mem_1_cns_re_shi1;
  output [1:0] shr_mem_1_cns_we_shi0;
  output [1:0] shr_mem_1_cns_we_shi1;
  input [127:0] shr_mem_1_cns_data_out_sho0;
  input [127:0] shr_mem_1_cns_data_out_sho1;
  output shr_mem_1_cns_S1_pff;
  input [1:0] din_1_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_pff;
  output [1:0] din_1_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_bud_pff;
  input [1:0] dout_1_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_pff;
  output [1:0] dout_1_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_bud_pff;
  output shr_mem_1_cns_S0_pff;


  // Interconnect Declarations
  reg [1:0] dout_1_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buy;
  reg [1:0] din_1_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buy;
  wire shr_mem_1_cns_PC0;
  reg shr_mem_1_cns_ppidx;
  reg [1:0] shr_mem_1_cns_ppown;
  wire shr_mem_1_cns_PC1;
  reg shr_mem_1_cns_ppidx_1;
  reg [1:0] shr_mem_1_cns_ppown_1;
  wire shr_mem_1_and_5_cse_pff;
  wire [1:0] shr_mem_1_acc_1_rmff;
  wire [3:0] nl_shr_mem_1_acc_1_rmff;
  wire shr_mem_1_xor_1_rmff;
  wire [1:0] shr_mem_1_acc_rmff;
  wire [3:0] nl_shr_mem_1_acc_rmff;
  wire shr_mem_1_xor_rmff;
  wire shr_mem_1_and_7_cse_pff;

  wire[0:0] shr_mem_1_shr_mem_1_not_nl;
  wire[0:0] shr_mem_1_shr_mem_1_shr_mem_1_nand_1_nl;
  wire[0:0] shr_mem_1_shr_mem_1_not_1_nl;
  wire[0:0] shr_mem_1_shr_mem_1_shr_mem_1_nand_nl;

  // Interconnect Declarations for Component Instantiations 
  assign dout_1_rsc_req_vz_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst = shr_mem_1_cns_R0;
  assign din_1_rsc_req_vz_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst = shr_mem_1_cns_R1;
  assign shr_mem_1_xor_rmff = shr_mem_1_cns_ppidx ^ shr_mem_1_cns_PC0;
  assign nl_shr_mem_1_acc_rmff = shr_mem_1_cns_ppown + conv_u2u_1_2(shr_mem_1_cns_PC0)
      + conv_s2u_1_2(shr_mem_1_cns_PC1);
  assign shr_mem_1_acc_rmff = nl_shr_mem_1_acc_rmff[1:0];
  assign shr_mem_1_cns_PC0 = shr_mem_1_cns_S0 & dout_1_rsc_rls_lz_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_bud;
  assign shr_mem_1_xor_1_rmff = shr_mem_1_cns_ppidx_1 ^ shr_mem_1_cns_PC1;
  assign nl_shr_mem_1_acc_1_rmff = shr_mem_1_cns_ppown_1 + conv_u2u_1_2(shr_mem_1_cns_PC1)
      + conv_s2u_1_2(shr_mem_1_cns_PC0);
  assign shr_mem_1_acc_1_rmff = nl_shr_mem_1_acc_1_rmff[1:0];
  assign shr_mem_1_cns_PC1 = shr_mem_1_cns_S1 & din_1_rsc_rls_lz_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_bud;
  assign din_1_rsc_data_out_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst = MUX_v_128_2_2(shr_mem_1_cns_data_out_sho0,
      shr_mem_1_cns_data_out_sho1, shr_mem_1_cns_ppidx_1);
  assign shr_mem_1_cns_data_in_shi0 = dout_1_rsc_data_in_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst;
  assign shr_mem_1_cns_addr_shi0 = MUX_v_16_2_2(dout_1_rsc_addr_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst,
      din_1_rsc_addr_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst, shr_mem_1_and_5_cse_pff);
  assign shr_mem_1_cns_S1 = (shr_mem_1_cns_ppown_1!=2'b00);
  assign shr_mem_1_cns_S1_pff = (shr_mem_1_acc_1_rmff!=2'b00);
  assign shr_mem_1_and_5_cse_pff = shr_mem_1_cns_S1_pff & (~ shr_mem_1_xor_1_rmff);
  assign shr_mem_1_shr_mem_1_not_nl = ~ shr_mem_1_and_5_cse_pff;
  assign shr_mem_1_cns_re_shi0 = MUX_v_2_2_2(din_1_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_pff,
      2'b11, (shr_mem_1_shr_mem_1_not_nl));
  assign din_1_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_bud = ~ din_1_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buy;
  assign din_1_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_bud_pff =
      din_1_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst;
  assign shr_mem_1_shr_mem_1_shr_mem_1_nand_1_nl = ~(shr_mem_1_cns_S0_pff & (~ shr_mem_1_xor_rmff));
  assign shr_mem_1_cns_we_shi0 = MUX_v_2_2_2(dout_1_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_pff,
      2'b11, (shr_mem_1_shr_mem_1_shr_mem_1_nand_1_nl));
  assign dout_1_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_bud = ~ dout_1_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buy;
  assign dout_1_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_bud_pff =
      dout_1_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst;
  assign shr_mem_1_cns_S0 = ~((shr_mem_1_cns_ppown==2'b10));
  assign shr_mem_1_cns_S0_pff = ~((shr_mem_1_acc_rmff==2'b10));
  assign shr_mem_1_cns_data_in_shi1 = dout_1_rsc_data_in_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst;
  assign shr_mem_1_cns_addr_shi1 = MUX_v_16_2_2(dout_1_rsc_addr_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst,
      din_1_rsc_addr_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst, shr_mem_1_and_7_cse_pff);
  assign shr_mem_1_and_7_cse_pff = shr_mem_1_cns_S1_pff & shr_mem_1_xor_1_rmff;
  assign shr_mem_1_shr_mem_1_not_1_nl = ~ shr_mem_1_and_7_cse_pff;
  assign shr_mem_1_cns_re_shi1 = MUX_v_2_2_2(din_1_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_pff,
      2'b11, (shr_mem_1_shr_mem_1_not_1_nl));
  assign shr_mem_1_shr_mem_1_shr_mem_1_nand_nl = ~(shr_mem_1_cns_S0_pff & shr_mem_1_xor_rmff);
  assign shr_mem_1_cns_we_shi1 = MUX_v_2_2_2(dout_1_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_pff,
      2'b11, (shr_mem_1_shr_mem_1_shr_mem_1_nand_nl));
  always @(posedge clk) begin
    if ( rst ) begin
      dout_1_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buy <= 2'b0;
      din_1_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buy <= 2'b0;
      shr_mem_1_cns_ppidx <= 1'b0;
      shr_mem_1_cns_ppown <= 2'b0;
      shr_mem_1_cns_ppidx_1 <= 1'b0;
      shr_mem_1_cns_ppown_1 <= 2'b0;
    end
    else begin
      dout_1_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buy <= ~ dout_1_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst;
      din_1_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buy <= ~ din_1_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst;
      shr_mem_1_cns_ppidx <= shr_mem_1_xor_rmff;
      shr_mem_1_cns_ppown <= shr_mem_1_acc_rmff;
      shr_mem_1_cns_ppidx_1 <= shr_mem_1_xor_1_rmff;
      shr_mem_1_cns_ppown_1 <= shr_mem_1_acc_1_rmff;
    end
  end

  function [127:0] MUX_v_128_2_2;
    input [127:0] input_0;
    input [127:0] input_1;
    input [0:0] sel;
    reg [127:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_128_2_2 = result;
  end
  endfunction


  function [15:0] MUX_v_16_2_2;
    input [15:0] input_0;
    input [15:0] input_1;
    input [0:0] sel;
    reg [15:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_16_2_2 = result;
  end
  endfunction


  function [1:0] MUX_v_2_2_2;
    input [1:0] input_0;
    input [1:0] input_1;
    input [0:0] sel;
    reg [1:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_2_2_2 = result;
  end
  endfunction


  function  [1:0] conv_s2u_1_2 ;
    input [0:0]  vector ;
  begin
    conv_s2u_1_2 = {vector[0], vector};
  end
  endfunction


  function  [1:0] conv_u2u_1_2 ;
    input [0:0]  vector ;
  begin
    conv_u2u_1_2 = {1'b0, vector};
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    double_buffeHLhBe_0_cns_bctl
// ------------------------------------------------------------------


module double_buffeHLhBe_0_cns_bctl (
  clk, rst, din_rsc_lz_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst, dout_0_rsc_data_in_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst,
      dout_0_rsc_addr_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst, dout_0_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst,
      dout_0_rsc_req_vz_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst, dout_1_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz,
      dout_2_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz, dout_3_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz,
      din_0_rsc_addr_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst, din_0_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst,
      din_0_rsc_data_out_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst, din_0_rsc_req_vz_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst,
      dout_rsc_lz_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst, din_1_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz,
      din_2_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz, din_3_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz,
      din_rsc_lz_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_bud, dout_0_rsc_rls_lz_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_bud,
      din_0_rsc_rls_lz_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_bud, dout_1_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_bud,
      dout_1_rsc_rls_lz_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_bud, din_1_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_bud,
      din_1_rsc_rls_lz_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_bud, dout_2_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_bud,
      dout_2_rsc_rls_lz_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_bud, din_2_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_bud,
      din_2_rsc_rls_lz_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_bud, dout_3_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_bud,
      dout_3_rsc_rls_lz_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_bud, din_3_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_bud,
      din_3_rsc_rls_lz_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_bud, dout_rsc_lz_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_bud,
      shr_mem_0_cns_S0, shr_mem_0_cns_R0, shr_mem_0_cns_S1, shr_mem_0_cns_R1, shr_mem_0_cns_data_in_shi0,
      shr_mem_0_cns_data_in_shi1, shr_mem_0_cns_addr_shi0, shr_mem_0_cns_addr_shi1,
      shr_mem_0_cns_re_shi0, shr_mem_0_cns_re_shi1, shr_mem_0_cns_we_shi0, shr_mem_0_cns_we_shi1,
      shr_mem_0_cns_data_out_sho0, shr_mem_0_cns_data_out_sho1, shr_mem_0_cns_S1_pff,
      shr_mem_0_cns_S0_pff, din_1_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_pff,
      din_1_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_bud_pff, dout_1_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_pff,
      dout_1_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_bud_pff, din_2_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_pff,
      din_2_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_bud_pff, dout_2_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_pff,
      dout_2_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_bud_pff, din_3_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_pff,
      din_3_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_bud_pff, dout_3_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_pff,
      dout_3_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_bud_pff
);
  input clk;
  input rst;
  output din_rsc_lz_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst;
  input [127:0] dout_0_rsc_data_in_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst;
  input [15:0] dout_0_rsc_addr_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst;
  input [1:0] dout_0_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst;
  output dout_0_rsc_req_vz_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst;
  output [1:0] dout_1_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz;
  output [1:0] dout_2_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz;
  output [1:0] dout_3_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz;
  input [15:0] din_0_rsc_addr_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst;
  input [1:0] din_0_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst;
  output [127:0] din_0_rsc_data_out_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst;
  output din_0_rsc_req_vz_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst;
  output dout_rsc_lz_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst;
  output [1:0] din_1_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz;
  output [1:0] din_2_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz;
  output [1:0] din_3_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz;
  input din_rsc_lz_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_bud;
  input dout_0_rsc_rls_lz_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_bud;
  input din_0_rsc_rls_lz_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_bud;
  input [1:0] dout_1_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_bud;
  input dout_1_rsc_rls_lz_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_bud;
  input [1:0] din_1_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_bud;
  input din_1_rsc_rls_lz_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_bud;
  input [1:0] dout_2_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_bud;
  input dout_2_rsc_rls_lz_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_bud;
  input [1:0] din_2_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_bud;
  input din_2_rsc_rls_lz_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_bud;
  input [1:0] dout_3_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_bud;
  input dout_3_rsc_rls_lz_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_bud;
  input [1:0] din_3_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_bud;
  input din_3_rsc_rls_lz_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_bud;
  input dout_rsc_lz_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_bud;
  output shr_mem_0_cns_S0;
  input shr_mem_0_cns_R0;
  output shr_mem_0_cns_S1;
  input shr_mem_0_cns_R1;
  output [127:0] shr_mem_0_cns_data_in_shi0;
  output [127:0] shr_mem_0_cns_data_in_shi1;
  output [15:0] shr_mem_0_cns_addr_shi0;
  output [15:0] shr_mem_0_cns_addr_shi1;
  output [1:0] shr_mem_0_cns_re_shi0;
  output [1:0] shr_mem_0_cns_re_shi1;
  output [1:0] shr_mem_0_cns_we_shi0;
  output [1:0] shr_mem_0_cns_we_shi1;
  input [127:0] shr_mem_0_cns_data_out_sho0;
  input [127:0] shr_mem_0_cns_data_out_sho1;
  output shr_mem_0_cns_S1_pff;
  output shr_mem_0_cns_S0_pff;
  output [1:0] din_1_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_pff;
  input [1:0] din_1_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_bud_pff;
  output [1:0] dout_1_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_pff;
  input [1:0] dout_1_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_bud_pff;
  output [1:0] din_2_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_pff;
  input [1:0] din_2_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_bud_pff;
  output [1:0] dout_2_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_pff;
  input [1:0] dout_2_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_bud_pff;
  output [1:0] din_3_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_pff;
  input [1:0] din_3_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_bud_pff;
  output [1:0] dout_3_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_pff;
  input [1:0] dout_3_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_bud_pff;


  // Interconnect Declarations
  wire shr_mem_0_cns_PC0;
  reg shr_mem_0_cns_ppidx;
  reg [1:0] shr_mem_0_cns_ppown;
  wire shr_mem_0_cns_PC1;
  reg shr_mem_0_cns_ppidx_1;
  reg [1:0] shr_mem_0_cns_ppown_1;
  wire shr_mem_0_and_5_cse_pff;
  wire [1:0] shr_mem_0_acc_1_rmff;
  wire [3:0] nl_shr_mem_0_acc_1_rmff;
  wire shr_mem_0_xor_1_rmff;
  wire [1:0] shr_mem_0_acc_rmff;
  wire [3:0] nl_shr_mem_0_acc_rmff;
  wire shr_mem_0_xor_rmff;
  wire shr_mem_0_and_7_cse_pff;

  wire[1:0] din_0_not_5_nl;
  wire[0:0] shr_mem_0_nand_1_nl;
  wire[1:0] din_0_not_1_nl;
  wire[0:0] shr_mem_0_nand_nl;

  // Interconnect Declarations for Component Instantiations 
  assign din_rsc_lz_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst = din_rsc_lz_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_bud;
  assign dout_rsc_lz_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst = dout_rsc_lz_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_bud;
  assign dout_0_rsc_req_vz_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst = shr_mem_0_cns_R0;
  assign din_0_rsc_req_vz_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst = shr_mem_0_cns_R1;
  assign shr_mem_0_xor_rmff = shr_mem_0_cns_ppidx ^ shr_mem_0_cns_PC0;
  assign nl_shr_mem_0_acc_rmff = shr_mem_0_cns_ppown + conv_u2u_1_2(shr_mem_0_cns_PC0)
      + conv_s2u_1_2(shr_mem_0_cns_PC1);
  assign shr_mem_0_acc_rmff = nl_shr_mem_0_acc_rmff[1:0];
  assign shr_mem_0_cns_PC0 = shr_mem_0_cns_S0 & dout_0_rsc_rls_lz_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_bud;
  assign shr_mem_0_xor_1_rmff = shr_mem_0_cns_ppidx_1 ^ shr_mem_0_cns_PC1;
  assign nl_shr_mem_0_acc_1_rmff = shr_mem_0_cns_ppown_1 + conv_u2u_1_2(shr_mem_0_cns_PC1)
      + conv_s2u_1_2(shr_mem_0_cns_PC0);
  assign shr_mem_0_acc_1_rmff = nl_shr_mem_0_acc_1_rmff[1:0];
  assign shr_mem_0_cns_PC1 = shr_mem_0_cns_S1 & din_0_rsc_rls_lz_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_bud;
  assign din_0_rsc_data_out_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst = MUX_v_128_2_2(shr_mem_0_cns_data_out_sho0,
      shr_mem_0_cns_data_out_sho1, shr_mem_0_cns_ppidx_1);
  assign shr_mem_0_cns_data_in_shi0 = dout_0_rsc_data_in_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst;
  assign shr_mem_0_cns_addr_shi0 = MUX_v_16_2_2(dout_0_rsc_addr_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst,
      din_0_rsc_addr_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst, shr_mem_0_and_5_cse_pff);
  assign shr_mem_0_cns_S1 = (shr_mem_0_cns_ppown_1!=2'b00);
  assign shr_mem_0_cns_S1_pff = (shr_mem_0_acc_1_rmff!=2'b00);
  assign shr_mem_0_and_5_cse_pff = shr_mem_0_cns_S1_pff & (~ shr_mem_0_xor_1_rmff);
  assign din_0_not_5_nl = ~ din_0_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst;
  assign shr_mem_0_cns_re_shi0 = ~(MUX_v_2_2_2(2'b00, (din_0_not_5_nl), shr_mem_0_and_5_cse_pff));
  assign shr_mem_0_nand_1_nl = ~(shr_mem_0_cns_S0_pff & (~ shr_mem_0_xor_rmff));
  assign shr_mem_0_cns_we_shi0 = MUX_v_2_2_2(dout_0_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst,
      2'b11, (shr_mem_0_nand_1_nl));
  assign shr_mem_0_cns_S0 = ~((shr_mem_0_cns_ppown==2'b10));
  assign shr_mem_0_cns_S0_pff = ~((shr_mem_0_acc_rmff==2'b10));
  assign shr_mem_0_cns_data_in_shi1 = dout_0_rsc_data_in_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst;
  assign shr_mem_0_cns_addr_shi1 = MUX_v_16_2_2(dout_0_rsc_addr_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst,
      din_0_rsc_addr_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst, shr_mem_0_and_7_cse_pff);
  assign shr_mem_0_and_7_cse_pff = shr_mem_0_cns_S1_pff & shr_mem_0_xor_1_rmff;
  assign din_0_not_1_nl = ~ din_0_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst;
  assign shr_mem_0_cns_re_shi1 = ~(MUX_v_2_2_2(2'b00, (din_0_not_1_nl), shr_mem_0_and_7_cse_pff));
  assign shr_mem_0_nand_nl = ~(shr_mem_0_cns_S0_pff & shr_mem_0_xor_rmff);
  assign shr_mem_0_cns_we_shi1 = MUX_v_2_2_2(dout_0_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst,
      2'b11, (shr_mem_0_nand_nl));
  assign din_1_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz = din_1_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_bud;
  assign din_1_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_pff = din_1_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_bud_pff;
  assign dout_1_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz = dout_1_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_bud;
  assign dout_1_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_pff = dout_1_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_bud_pff;
  assign din_2_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz = din_2_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_bud;
  assign din_2_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_pff = din_2_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_bud_pff;
  assign dout_2_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz = dout_2_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_bud;
  assign dout_2_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_pff = dout_2_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_bud_pff;
  assign din_3_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz = din_3_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_bud;
  assign din_3_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_pff = din_3_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_bud_pff;
  assign dout_3_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz = dout_3_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_bud;
  assign dout_3_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_pff = dout_3_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_bud_pff;
  always @(posedge clk) begin
    if ( rst ) begin
      shr_mem_0_cns_ppidx <= 1'b0;
      shr_mem_0_cns_ppown <= 2'b0;
      shr_mem_0_cns_ppidx_1 <= 1'b0;
      shr_mem_0_cns_ppown_1 <= 2'b0;
    end
    else begin
      shr_mem_0_cns_ppidx <= shr_mem_0_xor_rmff;
      shr_mem_0_cns_ppown <= shr_mem_0_acc_rmff;
      shr_mem_0_cns_ppidx_1 <= shr_mem_0_xor_1_rmff;
      shr_mem_0_cns_ppown_1 <= shr_mem_0_acc_1_rmff;
    end
  end

  function [127:0] MUX_v_128_2_2;
    input [127:0] input_0;
    input [127:0] input_1;
    input [0:0] sel;
    reg [127:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_128_2_2 = result;
  end
  endfunction


  function [15:0] MUX_v_16_2_2;
    input [15:0] input_0;
    input [15:0] input_1;
    input [0:0] sel;
    reg [15:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_16_2_2 = result;
  end
  endfunction


  function [1:0] MUX_v_2_2_2;
    input [1:0] input_0;
    input [1:0] input_1;
    input [0:0] sel;
    reg [1:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_2_2_2 = result;
  end
  endfunction


  function  [1:0] conv_s2u_1_2 ;
    input [0:0]  vector ;
  begin
    conv_s2u_1_2 = {vector[0], vector};
  end
  endfunction


  function  [1:0] conv_u2u_1_2 ;
    input [0:0]  vector ;
  begin
    conv_u2u_1_2 = {1'b0, vector};
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    unreg_hier_7
// ------------------------------------------------------------------


module unreg_hier_7 (
  in_0, out_0
);
  input in_0;
  output out_0;



  // Interconnect Declarations for Component Instantiations 
  assign out_0 = in_0;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    ram_sample_065nm_dualport_beh_dc_RAM_dualRW_wport_29_144_64_8_0_1_0_0_0_1_1_64_144_2_gen
// ------------------------------------------------------------------


module ram_sample_065nm_dualport_beh_dc_RAM_dualRW_wport_29_144_64_8_0_1_0_0_0_1_1_64_144_2_gen
    (
  we, addr, data_in, data_in_d, addr_d, we_d
);
  output [1:0] we;
  output [15:0] addr;
  output [127:0] data_in;
  input [127:0] data_in_d;
  input [15:0] addr_d;
  input [1:0] we_d;



  // Interconnect Declarations for Component Instantiations 
  assign we = we_d;
  assign addr = addr_d;
  assign data_in = data_in_d;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    ram_sample_065nm_dualport_beh_dc_RAM_dualRW_wport_28_144_64_8_0_1_0_0_0_1_1_64_144_2_gen
// ------------------------------------------------------------------


module ram_sample_065nm_dualport_beh_dc_RAM_dualRW_wport_28_144_64_8_0_1_0_0_0_1_1_64_144_2_gen
    (
  we, addr, data_in, data_in_d, addr_d, we_d
);
  output [1:0] we;
  output [15:0] addr;
  output [127:0] data_in;
  input [127:0] data_in_d;
  input [15:0] addr_d;
  input [1:0] we_d;



  // Interconnect Declarations for Component Instantiations 
  assign we = we_d;
  assign addr = addr_d;
  assign data_in = data_in_d;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    ram_sample_065nm_dualport_beh_dc_RAM_dualRW_wport_27_144_64_8_0_1_0_0_0_1_1_64_144_2_gen
// ------------------------------------------------------------------


module ram_sample_065nm_dualport_beh_dc_RAM_dualRW_wport_27_144_64_8_0_1_0_0_0_1_1_64_144_2_gen
    (
  we, addr, data_in, data_in_d, addr_d, we_d
);
  output [1:0] we;
  output [15:0] addr;
  output [127:0] data_in;
  input [127:0] data_in_d;
  input [15:0] addr_d;
  input [1:0] we_d;



  // Interconnect Declarations for Component Instantiations 
  assign we = we_d;
  assign addr = addr_d;
  assign data_in = data_in_d;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    ram_sample_065nm_dualport_beh_dc_RAM_dualRW_wport_26_144_64_8_0_1_0_0_0_1_1_64_144_2_gen
// ------------------------------------------------------------------


module ram_sample_065nm_dualport_beh_dc_RAM_dualRW_wport_26_144_64_8_0_1_0_0_0_1_1_64_144_2_gen
    (
  we, addr, data_in, data_in_d, addr_d, we_d
);
  output [1:0] we;
  output [15:0] addr;
  output [127:0] data_in;
  input [127:0] data_in_d;
  input [15:0] addr_d;
  input [1:0] we_d;



  // Interconnect Declarations for Component Instantiations 
  assign we = we_d;
  assign addr = addr_d;
  assign data_in = data_in_d;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_core_fsm
//  FSM Module
// ------------------------------------------------------------------


module WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_core_fsm (
  clk, rst, core_wen, fsm_output
);
  input clk;
  input rst;
  input core_wen;
  output [1:0] fsm_output;
  reg [1:0] fsm_output;


  // FSM State Type Declaration for WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_core_fsm_1
  parameter
    core_rlp_C_0 = 1'd0,
    main_C_0 = 1'd1;

  reg [0:0] state_var;
  reg [0:0] state_var_NS;


  // Interconnect Declarations for Component Instantiations 
  always @(*)
  begin : WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_core_fsm_1
    case (state_var)
      main_C_0 : begin
        fsm_output = 2'b10;
        state_var_NS = main_C_0;
      end
      // core_rlp_C_0
      default : begin
        fsm_output = 2'b1;
        state_var_NS = main_C_0;
      end
    endcase
  end

  always @(posedge clk) begin
    if ( rst ) begin
      state_var <= core_rlp_C_0;
    end
    else if ( core_wen ) begin
      state_var <= state_var_NS;
    end
  end

endmodule

// ------------------------------------------------------------------
//  Design Unit:    WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_staller
// ------------------------------------------------------------------


module WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_staller (
  clk, rst, core_wen, din_rsci_wen_comp, core_wten, dout_3_rsc_req_obj_wen_comp,
      dout_2_rsc_req_obj_wen_comp, dout_1_rsc_req_obj_wen_comp, dout_0_rsc_req_obj_wen_comp
);
  input clk;
  input rst;
  output core_wen;
  input din_rsci_wen_comp;
  output core_wten;
  input dout_3_rsc_req_obj_wen_comp;
  input dout_2_rsc_req_obj_wen_comp;
  input dout_1_rsc_req_obj_wen_comp;
  input dout_0_rsc_req_obj_wen_comp;


  // Interconnect Declarations
  reg core_wten_reg;


  // Interconnect Declarations for Component Instantiations 
  assign core_wen = din_rsci_wen_comp & dout_3_rsc_req_obj_wen_comp & dout_2_rsc_req_obj_wen_comp
      & dout_1_rsc_req_obj_wen_comp & dout_0_rsc_req_obj_wen_comp;
  assign core_wten = core_wten_reg;
  always @(posedge clk) begin
    if ( rst ) begin
      core_wten_reg <= 1'b0;
    end
    else begin
      core_wten_reg <= ~ core_wen;
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_0_rsc_req_obj_dout_0_rsc_req_wait_dp
// ------------------------------------------------------------------


module WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_0_rsc_req_obj_dout_0_rsc_req_wait_dp
    (
  clk, rst, dout_0_rsc_req_obj_oswt, dout_0_rsc_req_obj_wen_comp, dout_0_rsc_req_obj_biwt,
      dout_0_rsc_req_obj_bdwt
);
  input clk;
  input rst;
  input dout_0_rsc_req_obj_oswt;
  output dout_0_rsc_req_obj_wen_comp;
  input dout_0_rsc_req_obj_biwt;
  input dout_0_rsc_req_obj_bdwt;


  // Interconnect Declarations
  reg dout_0_rsc_req_obj_bcwt;


  // Interconnect Declarations for Component Instantiations 
  assign dout_0_rsc_req_obj_wen_comp = (~ dout_0_rsc_req_obj_oswt) | dout_0_rsc_req_obj_biwt
      | dout_0_rsc_req_obj_bcwt;
  always @(posedge clk) begin
    if ( rst ) begin
      dout_0_rsc_req_obj_bcwt <= 1'b0;
    end
    else begin
      dout_0_rsc_req_obj_bcwt <= ~((~(dout_0_rsc_req_obj_bcwt | dout_0_rsc_req_obj_biwt))
          | dout_0_rsc_req_obj_bdwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_0_rsc_req_obj_dout_0_rsc_req_wait_ctrl
// ------------------------------------------------------------------


module WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_0_rsc_req_obj_dout_0_rsc_req_wait_ctrl
    (
  clk, rst, core_wen, core_wten, dout_0_rsc_req_obj_oswt, dout_0_rsc_req_obj_vd,
      dout_0_rsc_req_obj_biwt, dout_0_rsc_req_obj_bdwt
);
  input clk;
  input rst;
  input core_wen;
  input core_wten;
  input dout_0_rsc_req_obj_oswt;
  input dout_0_rsc_req_obj_vd;
  output dout_0_rsc_req_obj_biwt;
  output dout_0_rsc_req_obj_bdwt;


  // Interconnect Declarations
  wire dout_0_rsc_req_obj_pdswt0;
  reg dout_0_rsc_req_obj_icwt;


  // Interconnect Declarations for Component Instantiations 
  assign dout_0_rsc_req_obj_pdswt0 = (~ core_wten) & dout_0_rsc_req_obj_oswt;
  assign dout_0_rsc_req_obj_biwt = (dout_0_rsc_req_obj_pdswt0 | dout_0_rsc_req_obj_icwt)
      & dout_0_rsc_req_obj_vd;
  assign dout_0_rsc_req_obj_bdwt = dout_0_rsc_req_obj_oswt & core_wen;
  always @(posedge clk) begin
    if ( rst ) begin
      dout_0_rsc_req_obj_icwt <= 1'b0;
    end
    else begin
      dout_0_rsc_req_obj_icwt <= ~((~(dout_0_rsc_req_obj_icwt | dout_0_rsc_req_obj_pdswt0))
          | dout_0_rsc_req_obj_biwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_1_rsc_req_obj_dout_1_rsc_req_wait_dp
// ------------------------------------------------------------------


module WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_1_rsc_req_obj_dout_1_rsc_req_wait_dp
    (
  clk, rst, dout_1_rsc_req_obj_oswt, dout_1_rsc_req_obj_wen_comp, dout_1_rsc_req_obj_biwt,
      dout_1_rsc_req_obj_bdwt
);
  input clk;
  input rst;
  input dout_1_rsc_req_obj_oswt;
  output dout_1_rsc_req_obj_wen_comp;
  input dout_1_rsc_req_obj_biwt;
  input dout_1_rsc_req_obj_bdwt;


  // Interconnect Declarations
  reg dout_1_rsc_req_obj_bcwt;


  // Interconnect Declarations for Component Instantiations 
  assign dout_1_rsc_req_obj_wen_comp = (~ dout_1_rsc_req_obj_oswt) | dout_1_rsc_req_obj_biwt
      | dout_1_rsc_req_obj_bcwt;
  always @(posedge clk) begin
    if ( rst ) begin
      dout_1_rsc_req_obj_bcwt <= 1'b0;
    end
    else begin
      dout_1_rsc_req_obj_bcwt <= ~((~(dout_1_rsc_req_obj_bcwt | dout_1_rsc_req_obj_biwt))
          | dout_1_rsc_req_obj_bdwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_1_rsc_req_obj_dout_1_rsc_req_wait_ctrl
// ------------------------------------------------------------------


module WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_1_rsc_req_obj_dout_1_rsc_req_wait_ctrl
    (
  clk, rst, core_wen, core_wten, dout_1_rsc_req_obj_oswt, dout_1_rsc_req_obj_vd,
      dout_1_rsc_req_obj_biwt, dout_1_rsc_req_obj_bdwt
);
  input clk;
  input rst;
  input core_wen;
  input core_wten;
  input dout_1_rsc_req_obj_oswt;
  input dout_1_rsc_req_obj_vd;
  output dout_1_rsc_req_obj_biwt;
  output dout_1_rsc_req_obj_bdwt;


  // Interconnect Declarations
  wire dout_1_rsc_req_obj_pdswt0;
  reg dout_1_rsc_req_obj_icwt;


  // Interconnect Declarations for Component Instantiations 
  assign dout_1_rsc_req_obj_pdswt0 = (~ core_wten) & dout_1_rsc_req_obj_oswt;
  assign dout_1_rsc_req_obj_biwt = (dout_1_rsc_req_obj_pdswt0 | dout_1_rsc_req_obj_icwt)
      & dout_1_rsc_req_obj_vd;
  assign dout_1_rsc_req_obj_bdwt = dout_1_rsc_req_obj_oswt & core_wen;
  always @(posedge clk) begin
    if ( rst ) begin
      dout_1_rsc_req_obj_icwt <= 1'b0;
    end
    else begin
      dout_1_rsc_req_obj_icwt <= ~((~(dout_1_rsc_req_obj_icwt | dout_1_rsc_req_obj_pdswt0))
          | dout_1_rsc_req_obj_biwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_2_rsc_req_obj_dout_2_rsc_req_wait_dp
// ------------------------------------------------------------------


module WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_2_rsc_req_obj_dout_2_rsc_req_wait_dp
    (
  clk, rst, dout_2_rsc_req_obj_oswt, dout_2_rsc_req_obj_wen_comp, dout_2_rsc_req_obj_biwt,
      dout_2_rsc_req_obj_bdwt
);
  input clk;
  input rst;
  input dout_2_rsc_req_obj_oswt;
  output dout_2_rsc_req_obj_wen_comp;
  input dout_2_rsc_req_obj_biwt;
  input dout_2_rsc_req_obj_bdwt;


  // Interconnect Declarations
  reg dout_2_rsc_req_obj_bcwt;


  // Interconnect Declarations for Component Instantiations 
  assign dout_2_rsc_req_obj_wen_comp = (~ dout_2_rsc_req_obj_oswt) | dout_2_rsc_req_obj_biwt
      | dout_2_rsc_req_obj_bcwt;
  always @(posedge clk) begin
    if ( rst ) begin
      dout_2_rsc_req_obj_bcwt <= 1'b0;
    end
    else begin
      dout_2_rsc_req_obj_bcwt <= ~((~(dout_2_rsc_req_obj_bcwt | dout_2_rsc_req_obj_biwt))
          | dout_2_rsc_req_obj_bdwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_2_rsc_req_obj_dout_2_rsc_req_wait_ctrl
// ------------------------------------------------------------------


module WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_2_rsc_req_obj_dout_2_rsc_req_wait_ctrl
    (
  clk, rst, core_wen, core_wten, dout_2_rsc_req_obj_oswt, dout_2_rsc_req_obj_vd,
      dout_2_rsc_req_obj_biwt, dout_2_rsc_req_obj_bdwt
);
  input clk;
  input rst;
  input core_wen;
  input core_wten;
  input dout_2_rsc_req_obj_oswt;
  input dout_2_rsc_req_obj_vd;
  output dout_2_rsc_req_obj_biwt;
  output dout_2_rsc_req_obj_bdwt;


  // Interconnect Declarations
  wire dout_2_rsc_req_obj_pdswt0;
  reg dout_2_rsc_req_obj_icwt;


  // Interconnect Declarations for Component Instantiations 
  assign dout_2_rsc_req_obj_pdswt0 = (~ core_wten) & dout_2_rsc_req_obj_oswt;
  assign dout_2_rsc_req_obj_biwt = (dout_2_rsc_req_obj_pdswt0 | dout_2_rsc_req_obj_icwt)
      & dout_2_rsc_req_obj_vd;
  assign dout_2_rsc_req_obj_bdwt = dout_2_rsc_req_obj_oswt & core_wen;
  always @(posedge clk) begin
    if ( rst ) begin
      dout_2_rsc_req_obj_icwt <= 1'b0;
    end
    else begin
      dout_2_rsc_req_obj_icwt <= ~((~(dout_2_rsc_req_obj_icwt | dout_2_rsc_req_obj_pdswt0))
          | dout_2_rsc_req_obj_biwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_3_rsc_req_obj_dout_3_rsc_req_wait_dp
// ------------------------------------------------------------------


module WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_3_rsc_req_obj_dout_3_rsc_req_wait_dp
    (
  clk, rst, dout_3_rsc_req_obj_oswt, dout_3_rsc_req_obj_wen_comp, dout_3_rsc_req_obj_biwt,
      dout_3_rsc_req_obj_bdwt
);
  input clk;
  input rst;
  input dout_3_rsc_req_obj_oswt;
  output dout_3_rsc_req_obj_wen_comp;
  input dout_3_rsc_req_obj_biwt;
  input dout_3_rsc_req_obj_bdwt;


  // Interconnect Declarations
  reg dout_3_rsc_req_obj_bcwt;


  // Interconnect Declarations for Component Instantiations 
  assign dout_3_rsc_req_obj_wen_comp = (~ dout_3_rsc_req_obj_oswt) | dout_3_rsc_req_obj_biwt
      | dout_3_rsc_req_obj_bcwt;
  always @(posedge clk) begin
    if ( rst ) begin
      dout_3_rsc_req_obj_bcwt <= 1'b0;
    end
    else begin
      dout_3_rsc_req_obj_bcwt <= ~((~(dout_3_rsc_req_obj_bcwt | dout_3_rsc_req_obj_biwt))
          | dout_3_rsc_req_obj_bdwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_3_rsc_req_obj_dout_3_rsc_req_wait_ctrl
// ------------------------------------------------------------------


module WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_3_rsc_req_obj_dout_3_rsc_req_wait_ctrl
    (
  clk, rst, core_wen, core_wten, dout_3_rsc_req_obj_oswt, dout_3_rsc_req_obj_vd,
      dout_3_rsc_req_obj_biwt, dout_3_rsc_req_obj_bdwt
);
  input clk;
  input rst;
  input core_wen;
  input core_wten;
  input dout_3_rsc_req_obj_oswt;
  input dout_3_rsc_req_obj_vd;
  output dout_3_rsc_req_obj_biwt;
  output dout_3_rsc_req_obj_bdwt;


  // Interconnect Declarations
  wire dout_3_rsc_req_obj_pdswt0;
  reg dout_3_rsc_req_obj_icwt;


  // Interconnect Declarations for Component Instantiations 
  assign dout_3_rsc_req_obj_pdswt0 = (~ core_wten) & dout_3_rsc_req_obj_oswt;
  assign dout_3_rsc_req_obj_biwt = (dout_3_rsc_req_obj_pdswt0 | dout_3_rsc_req_obj_icwt)
      & dout_3_rsc_req_obj_vd;
  assign dout_3_rsc_req_obj_bdwt = dout_3_rsc_req_obj_oswt & core_wen;
  always @(posedge clk) begin
    if ( rst ) begin
      dout_3_rsc_req_obj_icwt <= 1'b0;
    end
    else begin
      dout_3_rsc_req_obj_icwt <= ~((~(dout_3_rsc_req_obj_icwt | dout_3_rsc_req_obj_pdswt0))
          | dout_3_rsc_req_obj_biwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_0_rsc_rls_obj_dout_0_rsc_rls_wait_ctrl
// ------------------------------------------------------------------


module WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_0_rsc_rls_obj_dout_0_rsc_rls_wait_ctrl
    (
  core_wten, dout_0_rsc_rls_obj_iswt0, dout_0_rsc_rls_obj_ld_core_sct
);
  input core_wten;
  input dout_0_rsc_rls_obj_iswt0;
  output dout_0_rsc_rls_obj_ld_core_sct;



  // Interconnect Declarations for Component Instantiations 
  assign dout_0_rsc_rls_obj_ld_core_sct = dout_0_rsc_rls_obj_iswt0 & (~ core_wten);
endmodule

// ------------------------------------------------------------------
//  Design Unit:    WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_1_rsc_rls_obj_dout_1_rsc_rls_wait_ctrl
// ------------------------------------------------------------------


module WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_1_rsc_rls_obj_dout_1_rsc_rls_wait_ctrl
    (
  core_wten, dout_1_rsc_rls_obj_iswt0, dout_1_rsc_rls_obj_ld_core_sct
);
  input core_wten;
  input dout_1_rsc_rls_obj_iswt0;
  output dout_1_rsc_rls_obj_ld_core_sct;



  // Interconnect Declarations for Component Instantiations 
  assign dout_1_rsc_rls_obj_ld_core_sct = dout_1_rsc_rls_obj_iswt0 & (~ core_wten);
endmodule

// ------------------------------------------------------------------
//  Design Unit:    WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_2_rsc_rls_obj_dout_2_rsc_rls_wait_ctrl
// ------------------------------------------------------------------


module WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_2_rsc_rls_obj_dout_2_rsc_rls_wait_ctrl
    (
  core_wten, dout_2_rsc_rls_obj_iswt0, dout_2_rsc_rls_obj_ld_core_sct
);
  input core_wten;
  input dout_2_rsc_rls_obj_iswt0;
  output dout_2_rsc_rls_obj_ld_core_sct;



  // Interconnect Declarations for Component Instantiations 
  assign dout_2_rsc_rls_obj_ld_core_sct = dout_2_rsc_rls_obj_iswt0 & (~ core_wten);
endmodule

// ------------------------------------------------------------------
//  Design Unit:    WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_3_rsc_rls_obj_dout_3_rsc_rls_wait_ctrl
// ------------------------------------------------------------------


module WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_3_rsc_rls_obj_dout_3_rsc_rls_wait_ctrl
    (
  core_wten, dout_3_rsc_rls_obj_iswt0, dout_3_rsc_rls_obj_ld_core_sct
);
  input core_wten;
  input dout_3_rsc_rls_obj_iswt0;
  output dout_3_rsc_rls_obj_ld_core_sct;



  // Interconnect Declarations for Component Instantiations 
  assign dout_3_rsc_rls_obj_ld_core_sct = dout_3_rsc_rls_obj_iswt0 & (~ core_wten);
endmodule

// ------------------------------------------------------------------
//  Design Unit:    WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_3_rsci_1_dout_3_rsc_wait_ctrl
// ------------------------------------------------------------------


module WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_3_rsci_1_dout_3_rsc_wait_ctrl
    (
  core_wten, dout_3_rsci_iswt0, dout_3_rsci_we_d_core_psct, dout_3_rsci_we_d_core_sct
);
  input core_wten;
  input dout_3_rsci_iswt0;
  input [1:0] dout_3_rsci_we_d_core_psct;
  output [1:0] dout_3_rsci_we_d_core_sct;


  wire[0:0] dout_3_and_2_nl;

  // Interconnect Declarations for Component Instantiations 
  assign dout_3_and_2_nl = (dout_3_rsci_we_d_core_psct[0]) & (~ core_wten) & dout_3_rsci_iswt0;
  assign dout_3_rsci_we_d_core_sct = {1'b0 , (dout_3_and_2_nl)};
endmodule

// ------------------------------------------------------------------
//  Design Unit:    WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_2_rsci_1_dout_2_rsc_wait_ctrl
// ------------------------------------------------------------------


module WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_2_rsci_1_dout_2_rsc_wait_ctrl
    (
  core_wten, dout_2_rsci_iswt0, dout_2_rsci_we_d_core_psct, dout_2_rsci_we_d_core_sct
);
  input core_wten;
  input dout_2_rsci_iswt0;
  input [1:0] dout_2_rsci_we_d_core_psct;
  output [1:0] dout_2_rsci_we_d_core_sct;


  wire[0:0] dout_2_and_2_nl;

  // Interconnect Declarations for Component Instantiations 
  assign dout_2_and_2_nl = (dout_2_rsci_we_d_core_psct[0]) & (~ core_wten) & dout_2_rsci_iswt0;
  assign dout_2_rsci_we_d_core_sct = {1'b0 , (dout_2_and_2_nl)};
endmodule

// ------------------------------------------------------------------
//  Design Unit:    WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_1_rsci_1_dout_1_rsc_wait_ctrl
// ------------------------------------------------------------------


module WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_1_rsci_1_dout_1_rsc_wait_ctrl
    (
  core_wten, dout_1_rsci_iswt0, dout_1_rsci_we_d_core_psct, dout_1_rsci_we_d_core_sct
);
  input core_wten;
  input dout_1_rsci_iswt0;
  input [1:0] dout_1_rsci_we_d_core_psct;
  output [1:0] dout_1_rsci_we_d_core_sct;


  wire[0:0] dout_1_and_2_nl;

  // Interconnect Declarations for Component Instantiations 
  assign dout_1_and_2_nl = (dout_1_rsci_we_d_core_psct[0]) & (~ core_wten) & dout_1_rsci_iswt0;
  assign dout_1_rsci_we_d_core_sct = {1'b0 , (dout_1_and_2_nl)};
endmodule

// ------------------------------------------------------------------
//  Design Unit:    WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_0_rsci_1_dout_0_rsc_wait_ctrl
// ------------------------------------------------------------------


module WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_0_rsci_1_dout_0_rsc_wait_ctrl
    (
  core_wten, dout_0_rsci_iswt0, dout_0_rsci_we_d_core_psct, dout_0_rsci_we_d_core_sct
);
  input core_wten;
  input dout_0_rsci_iswt0;
  input [1:0] dout_0_rsci_we_d_core_psct;
  output [1:0] dout_0_rsci_we_d_core_sct;


  wire[0:0] dout_0_and_2_nl;

  // Interconnect Declarations for Component Instantiations 
  assign dout_0_and_2_nl = (dout_0_rsci_we_d_core_psct[0]) & (~ core_wten) & dout_0_rsci_iswt0;
  assign dout_0_rsci_we_d_core_sct = {1'b0 , (dout_0_and_2_nl)};
endmodule

// ------------------------------------------------------------------
//  Design Unit:    WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_din_rsci_din_wait_dp
// ------------------------------------------------------------------


module WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_din_rsci_din_wait_dp (
  clk, rst, din_rsci_oswt, din_rsci_wen_comp, din_rsci_d_mxwt, din_rsci_biwt, din_rsci_bdwt,
      din_rsci_d
);
  input clk;
  input rst;
  input din_rsci_oswt;
  output din_rsci_wen_comp;
  output [255:0] din_rsci_d_mxwt;
  input din_rsci_biwt;
  input din_rsci_bdwt;
  input [255:0] din_rsci_d;


  // Interconnect Declarations
  reg din_rsci_bcwt;
  reg [255:0] din_rsci_d_bfwt;


  // Interconnect Declarations for Component Instantiations 
  assign din_rsci_wen_comp = (~ din_rsci_oswt) | din_rsci_biwt | din_rsci_bcwt;
  assign din_rsci_d_mxwt = MUX_v_256_2_2(din_rsci_d, din_rsci_d_bfwt, din_rsci_bcwt);
  always @(posedge clk) begin
    if ( rst ) begin
      din_rsci_bcwt <= 1'b0;
      din_rsci_d_bfwt <= 256'b0;
    end
    else begin
      din_rsci_bcwt <= ~((~(din_rsci_bcwt | din_rsci_biwt)) | din_rsci_bdwt);
      din_rsci_d_bfwt <= din_rsci_d_mxwt;
    end
  end

  function [255:0] MUX_v_256_2_2;
    input [255:0] input_0;
    input [255:0] input_1;
    input [0:0] sel;
    reg [255:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_256_2_2 = result;
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_din_rsci_din_wait_ctrl
// ------------------------------------------------------------------


module WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_din_rsci_din_wait_ctrl (
  clk, rst, core_wen, din_rsci_oswt, core_wten, din_rsci_biwt, din_rsci_bdwt, din_rsci_ld_core_sct,
      din_rsci_vd
);
  input clk;
  input rst;
  input core_wen;
  input din_rsci_oswt;
  input core_wten;
  output din_rsci_biwt;
  output din_rsci_bdwt;
  output din_rsci_ld_core_sct;
  input din_rsci_vd;


  // Interconnect Declarations
  wire din_rsci_ogwt;
  wire din_rsci_pdswt0;
  reg din_rsci_icwt;


  // Interconnect Declarations for Component Instantiations 
  assign din_rsci_pdswt0 = (~ core_wten) & din_rsci_oswt;
  assign din_rsci_biwt = din_rsci_ogwt & din_rsci_vd;
  assign din_rsci_ogwt = din_rsci_pdswt0 | din_rsci_icwt;
  assign din_rsci_bdwt = din_rsci_oswt & core_wen;
  assign din_rsci_ld_core_sct = din_rsci_oswt & din_rsci_ogwt;
  always @(posedge clk) begin
    if ( rst ) begin
      din_rsci_icwt <= 1'b0;
    end
    else begin
      din_rsci_icwt <= ~((~(din_rsci_icwt | din_rsci_pdswt0)) | din_rsci_biwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    ram_sample_065nm_dualport_beh_dc_RAM_dualRW_rport_37_144_64_8_0_1_0_0_0_1_1_64_144_2_gen
// ------------------------------------------------------------------


module ram_sample_065nm_dualport_beh_dc_RAM_dualRW_rport_37_144_64_8_0_1_0_0_0_1_1_64_144_2_gen
    (
  data_out, re, addr, addr_d, re_d, data_out_d
);
  input [127:0] data_out;
  output [1:0] re;
  output [15:0] addr;
  input [15:0] addr_d;
  input [1:0] re_d;
  output [127:0] data_out_d;



  // Interconnect Declarations for Component Instantiations 
  assign data_out_d = data_out;
  assign re = re_d;
  assign addr = addr_d;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    ram_sample_065nm_dualport_beh_dc_RAM_dualRW_rport_36_144_64_8_0_1_0_0_0_1_1_64_144_2_gen
// ------------------------------------------------------------------


module ram_sample_065nm_dualport_beh_dc_RAM_dualRW_rport_36_144_64_8_0_1_0_0_0_1_1_64_144_2_gen
    (
  data_out, re, addr, addr_d, re_d, data_out_d
);
  input [127:0] data_out;
  output [1:0] re;
  output [15:0] addr;
  input [15:0] addr_d;
  input [1:0] re_d;
  output [127:0] data_out_d;



  // Interconnect Declarations for Component Instantiations 
  assign data_out_d = data_out;
  assign re = re_d;
  assign addr = addr_d;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    ram_sample_065nm_dualport_beh_dc_RAM_dualRW_rport_35_144_64_8_0_1_0_0_0_1_1_64_144_2_gen
// ------------------------------------------------------------------


module ram_sample_065nm_dualport_beh_dc_RAM_dualRW_rport_35_144_64_8_0_1_0_0_0_1_1_64_144_2_gen
    (
  data_out, re, addr, addr_d, re_d, data_out_d
);
  input [127:0] data_out;
  output [1:0] re;
  output [15:0] addr;
  input [15:0] addr_d;
  input [1:0] re_d;
  output [127:0] data_out_d;



  // Interconnect Declarations for Component Instantiations 
  assign data_out_d = data_out;
  assign re = re_d;
  assign addr = addr_d;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    ram_sample_065nm_dualport_beh_dc_RAM_dualRW_rport_34_144_64_8_0_1_0_0_0_1_1_64_144_2_gen
// ------------------------------------------------------------------


module ram_sample_065nm_dualport_beh_dc_RAM_dualRW_rport_34_144_64_8_0_1_0_0_0_1_1_64_144_2_gen
    (
  data_out, re, addr, addr_d, re_d, data_out_d
);
  input [127:0] data_out;
  output [1:0] re;
  output [15:0] addr;
  input [15:0] addr_d;
  input [1:0] re_d;
  output [127:0] data_out_d;



  // Interconnect Declarations for Component Instantiations 
  assign data_out_d = data_out;
  assign re = re_d;
  assign addr = addr_d;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_core_fsm
//  FSM Module
// ------------------------------------------------------------------


module READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_core_fsm (
  clk, rst, core_wen, fsm_output
);
  input clk;
  input rst;
  input core_wen;
  output [1:0] fsm_output;
  reg [1:0] fsm_output;


  // FSM State Type Declaration for READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_core_fsm_1
  parameter
    core_rlp_C_0 = 1'd0,
    main_C_0 = 1'd1;

  reg [0:0] state_var;
  reg [0:0] state_var_NS;


  // Interconnect Declarations for Component Instantiations 
  always @(*)
  begin : READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_core_fsm_1
    case (state_var)
      main_C_0 : begin
        fsm_output = 2'b10;
        state_var_NS = main_C_0;
      end
      // core_rlp_C_0
      default : begin
        fsm_output = 2'b1;
        state_var_NS = main_C_0;
      end
    endcase
  end

  always @(posedge clk) begin
    if ( rst ) begin
      state_var <= core_rlp_C_0;
    end
    else if ( core_wen ) begin
      state_var <= state_var_NS;
    end
  end

endmodule

// ------------------------------------------------------------------
//  Design Unit:    READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_staller
// ------------------------------------------------------------------


module READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_staller (
  clk, rst, core_wen, core_wten, dout_rsci_wen_comp, din_3_rsc_req_obj_wen_comp,
      din_2_rsc_req_obj_wen_comp, din_1_rsc_req_obj_wen_comp, din_0_rsc_req_obj_wen_comp
);
  input clk;
  input rst;
  output core_wen;
  output core_wten;
  input dout_rsci_wen_comp;
  input din_3_rsc_req_obj_wen_comp;
  input din_2_rsc_req_obj_wen_comp;
  input din_1_rsc_req_obj_wen_comp;
  input din_0_rsc_req_obj_wen_comp;


  // Interconnect Declarations
  reg core_wten_reg;


  // Interconnect Declarations for Component Instantiations 
  assign core_wen = dout_rsci_wen_comp & din_3_rsc_req_obj_wen_comp & din_2_rsc_req_obj_wen_comp
      & din_1_rsc_req_obj_wen_comp & din_0_rsc_req_obj_wen_comp;
  assign core_wten = core_wten_reg;
  always @(posedge clk) begin
    if ( rst ) begin
      core_wten_reg <= 1'b0;
    end
    else begin
      core_wten_reg <= ~ core_wen;
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_0_rsc_req_obj_din_0_rsc_req_wait_dp
// ------------------------------------------------------------------


module READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_0_rsc_req_obj_din_0_rsc_req_wait_dp
    (
  clk, rst, din_0_rsc_req_obj_oswt, din_0_rsc_req_obj_wen_comp, din_0_rsc_req_obj_biwt,
      din_0_rsc_req_obj_bdwt
);
  input clk;
  input rst;
  input din_0_rsc_req_obj_oswt;
  output din_0_rsc_req_obj_wen_comp;
  input din_0_rsc_req_obj_biwt;
  input din_0_rsc_req_obj_bdwt;


  // Interconnect Declarations
  reg din_0_rsc_req_obj_bcwt;


  // Interconnect Declarations for Component Instantiations 
  assign din_0_rsc_req_obj_wen_comp = (~ din_0_rsc_req_obj_oswt) | din_0_rsc_req_obj_biwt
      | din_0_rsc_req_obj_bcwt;
  always @(posedge clk) begin
    if ( rst ) begin
      din_0_rsc_req_obj_bcwt <= 1'b0;
    end
    else begin
      din_0_rsc_req_obj_bcwt <= ~((~(din_0_rsc_req_obj_bcwt | din_0_rsc_req_obj_biwt))
          | din_0_rsc_req_obj_bdwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_0_rsc_req_obj_din_0_rsc_req_wait_ctrl
// ------------------------------------------------------------------


module READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_0_rsc_req_obj_din_0_rsc_req_wait_ctrl
    (
  clk, rst, core_wen, core_wten, din_0_rsc_req_obj_oswt, din_0_rsc_req_obj_vd, din_0_rsc_req_obj_biwt,
      din_0_rsc_req_obj_bdwt
);
  input clk;
  input rst;
  input core_wen;
  input core_wten;
  input din_0_rsc_req_obj_oswt;
  input din_0_rsc_req_obj_vd;
  output din_0_rsc_req_obj_biwt;
  output din_0_rsc_req_obj_bdwt;


  // Interconnect Declarations
  wire din_0_rsc_req_obj_pdswt0;
  reg din_0_rsc_req_obj_icwt;


  // Interconnect Declarations for Component Instantiations 
  assign din_0_rsc_req_obj_pdswt0 = (~ core_wten) & din_0_rsc_req_obj_oswt;
  assign din_0_rsc_req_obj_biwt = (din_0_rsc_req_obj_pdswt0 | din_0_rsc_req_obj_icwt)
      & din_0_rsc_req_obj_vd;
  assign din_0_rsc_req_obj_bdwt = din_0_rsc_req_obj_oswt & core_wen;
  always @(posedge clk) begin
    if ( rst ) begin
      din_0_rsc_req_obj_icwt <= 1'b0;
    end
    else begin
      din_0_rsc_req_obj_icwt <= ~((~(din_0_rsc_req_obj_icwt | din_0_rsc_req_obj_pdswt0))
          | din_0_rsc_req_obj_biwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_1_rsc_req_obj_din_1_rsc_req_wait_dp
// ------------------------------------------------------------------


module READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_1_rsc_req_obj_din_1_rsc_req_wait_dp
    (
  clk, rst, din_1_rsc_req_obj_oswt, din_1_rsc_req_obj_wen_comp, din_1_rsc_req_obj_biwt,
      din_1_rsc_req_obj_bdwt
);
  input clk;
  input rst;
  input din_1_rsc_req_obj_oswt;
  output din_1_rsc_req_obj_wen_comp;
  input din_1_rsc_req_obj_biwt;
  input din_1_rsc_req_obj_bdwt;


  // Interconnect Declarations
  reg din_1_rsc_req_obj_bcwt;


  // Interconnect Declarations for Component Instantiations 
  assign din_1_rsc_req_obj_wen_comp = (~ din_1_rsc_req_obj_oswt) | din_1_rsc_req_obj_biwt
      | din_1_rsc_req_obj_bcwt;
  always @(posedge clk) begin
    if ( rst ) begin
      din_1_rsc_req_obj_bcwt <= 1'b0;
    end
    else begin
      din_1_rsc_req_obj_bcwt <= ~((~(din_1_rsc_req_obj_bcwt | din_1_rsc_req_obj_biwt))
          | din_1_rsc_req_obj_bdwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_1_rsc_req_obj_din_1_rsc_req_wait_ctrl
// ------------------------------------------------------------------


module READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_1_rsc_req_obj_din_1_rsc_req_wait_ctrl
    (
  clk, rst, core_wen, core_wten, din_1_rsc_req_obj_oswt, din_1_rsc_req_obj_vd, din_1_rsc_req_obj_biwt,
      din_1_rsc_req_obj_bdwt
);
  input clk;
  input rst;
  input core_wen;
  input core_wten;
  input din_1_rsc_req_obj_oswt;
  input din_1_rsc_req_obj_vd;
  output din_1_rsc_req_obj_biwt;
  output din_1_rsc_req_obj_bdwt;


  // Interconnect Declarations
  wire din_1_rsc_req_obj_pdswt0;
  reg din_1_rsc_req_obj_icwt;


  // Interconnect Declarations for Component Instantiations 
  assign din_1_rsc_req_obj_pdswt0 = (~ core_wten) & din_1_rsc_req_obj_oswt;
  assign din_1_rsc_req_obj_biwt = (din_1_rsc_req_obj_pdswt0 | din_1_rsc_req_obj_icwt)
      & din_1_rsc_req_obj_vd;
  assign din_1_rsc_req_obj_bdwt = din_1_rsc_req_obj_oswt & core_wen;
  always @(posedge clk) begin
    if ( rst ) begin
      din_1_rsc_req_obj_icwt <= 1'b0;
    end
    else begin
      din_1_rsc_req_obj_icwt <= ~((~(din_1_rsc_req_obj_icwt | din_1_rsc_req_obj_pdswt0))
          | din_1_rsc_req_obj_biwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_2_rsc_req_obj_din_2_rsc_req_wait_dp
// ------------------------------------------------------------------


module READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_2_rsc_req_obj_din_2_rsc_req_wait_dp
    (
  clk, rst, din_2_rsc_req_obj_oswt, din_2_rsc_req_obj_wen_comp, din_2_rsc_req_obj_biwt,
      din_2_rsc_req_obj_bdwt
);
  input clk;
  input rst;
  input din_2_rsc_req_obj_oswt;
  output din_2_rsc_req_obj_wen_comp;
  input din_2_rsc_req_obj_biwt;
  input din_2_rsc_req_obj_bdwt;


  // Interconnect Declarations
  reg din_2_rsc_req_obj_bcwt;


  // Interconnect Declarations for Component Instantiations 
  assign din_2_rsc_req_obj_wen_comp = (~ din_2_rsc_req_obj_oswt) | din_2_rsc_req_obj_biwt
      | din_2_rsc_req_obj_bcwt;
  always @(posedge clk) begin
    if ( rst ) begin
      din_2_rsc_req_obj_bcwt <= 1'b0;
    end
    else begin
      din_2_rsc_req_obj_bcwt <= ~((~(din_2_rsc_req_obj_bcwt | din_2_rsc_req_obj_biwt))
          | din_2_rsc_req_obj_bdwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_2_rsc_req_obj_din_2_rsc_req_wait_ctrl
// ------------------------------------------------------------------


module READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_2_rsc_req_obj_din_2_rsc_req_wait_ctrl
    (
  clk, rst, core_wen, core_wten, din_2_rsc_req_obj_oswt, din_2_rsc_req_obj_vd, din_2_rsc_req_obj_biwt,
      din_2_rsc_req_obj_bdwt
);
  input clk;
  input rst;
  input core_wen;
  input core_wten;
  input din_2_rsc_req_obj_oswt;
  input din_2_rsc_req_obj_vd;
  output din_2_rsc_req_obj_biwt;
  output din_2_rsc_req_obj_bdwt;


  // Interconnect Declarations
  wire din_2_rsc_req_obj_pdswt0;
  reg din_2_rsc_req_obj_icwt;


  // Interconnect Declarations for Component Instantiations 
  assign din_2_rsc_req_obj_pdswt0 = (~ core_wten) & din_2_rsc_req_obj_oswt;
  assign din_2_rsc_req_obj_biwt = (din_2_rsc_req_obj_pdswt0 | din_2_rsc_req_obj_icwt)
      & din_2_rsc_req_obj_vd;
  assign din_2_rsc_req_obj_bdwt = din_2_rsc_req_obj_oswt & core_wen;
  always @(posedge clk) begin
    if ( rst ) begin
      din_2_rsc_req_obj_icwt <= 1'b0;
    end
    else begin
      din_2_rsc_req_obj_icwt <= ~((~(din_2_rsc_req_obj_icwt | din_2_rsc_req_obj_pdswt0))
          | din_2_rsc_req_obj_biwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_3_rsc_req_obj_din_3_rsc_req_wait_dp
// ------------------------------------------------------------------


module READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_3_rsc_req_obj_din_3_rsc_req_wait_dp
    (
  clk, rst, din_3_rsc_req_obj_oswt, din_3_rsc_req_obj_wen_comp, din_3_rsc_req_obj_biwt,
      din_3_rsc_req_obj_bdwt
);
  input clk;
  input rst;
  input din_3_rsc_req_obj_oswt;
  output din_3_rsc_req_obj_wen_comp;
  input din_3_rsc_req_obj_biwt;
  input din_3_rsc_req_obj_bdwt;


  // Interconnect Declarations
  reg din_3_rsc_req_obj_bcwt;


  // Interconnect Declarations for Component Instantiations 
  assign din_3_rsc_req_obj_wen_comp = (~ din_3_rsc_req_obj_oswt) | din_3_rsc_req_obj_biwt
      | din_3_rsc_req_obj_bcwt;
  always @(posedge clk) begin
    if ( rst ) begin
      din_3_rsc_req_obj_bcwt <= 1'b0;
    end
    else begin
      din_3_rsc_req_obj_bcwt <= ~((~(din_3_rsc_req_obj_bcwt | din_3_rsc_req_obj_biwt))
          | din_3_rsc_req_obj_bdwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_3_rsc_req_obj_din_3_rsc_req_wait_ctrl
// ------------------------------------------------------------------


module READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_3_rsc_req_obj_din_3_rsc_req_wait_ctrl
    (
  clk, rst, core_wen, core_wten, din_3_rsc_req_obj_oswt, din_3_rsc_req_obj_vd, din_3_rsc_req_obj_biwt,
      din_3_rsc_req_obj_bdwt
);
  input clk;
  input rst;
  input core_wen;
  input core_wten;
  input din_3_rsc_req_obj_oswt;
  input din_3_rsc_req_obj_vd;
  output din_3_rsc_req_obj_biwt;
  output din_3_rsc_req_obj_bdwt;


  // Interconnect Declarations
  wire din_3_rsc_req_obj_pdswt0;
  reg din_3_rsc_req_obj_icwt;


  // Interconnect Declarations for Component Instantiations 
  assign din_3_rsc_req_obj_pdswt0 = (~ core_wten) & din_3_rsc_req_obj_oswt;
  assign din_3_rsc_req_obj_biwt = (din_3_rsc_req_obj_pdswt0 | din_3_rsc_req_obj_icwt)
      & din_3_rsc_req_obj_vd;
  assign din_3_rsc_req_obj_bdwt = din_3_rsc_req_obj_oswt & core_wen;
  always @(posedge clk) begin
    if ( rst ) begin
      din_3_rsc_req_obj_icwt <= 1'b0;
    end
    else begin
      din_3_rsc_req_obj_icwt <= ~((~(din_3_rsc_req_obj_icwt | din_3_rsc_req_obj_pdswt0))
          | din_3_rsc_req_obj_biwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_3_rsc_rls_obj_din_3_rsc_rls_wait_ctrl
// ------------------------------------------------------------------


module READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_3_rsc_rls_obj_din_3_rsc_rls_wait_ctrl
    (
  core_wten, din_3_rsc_rls_obj_iswt0, din_3_rsc_rls_obj_ld_core_sct
);
  input core_wten;
  input din_3_rsc_rls_obj_iswt0;
  output din_3_rsc_rls_obj_ld_core_sct;



  // Interconnect Declarations for Component Instantiations 
  assign din_3_rsc_rls_obj_ld_core_sct = din_3_rsc_rls_obj_iswt0 & (~ core_wten);
endmodule

// ------------------------------------------------------------------
//  Design Unit:    READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_2_rsc_rls_obj_din_2_rsc_rls_wait_ctrl
// ------------------------------------------------------------------


module READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_2_rsc_rls_obj_din_2_rsc_rls_wait_ctrl
    (
  core_wten, din_2_rsc_rls_obj_iswt0, din_2_rsc_rls_obj_ld_core_sct
);
  input core_wten;
  input din_2_rsc_rls_obj_iswt0;
  output din_2_rsc_rls_obj_ld_core_sct;



  // Interconnect Declarations for Component Instantiations 
  assign din_2_rsc_rls_obj_ld_core_sct = din_2_rsc_rls_obj_iswt0 & (~ core_wten);
endmodule

// ------------------------------------------------------------------
//  Design Unit:    READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_1_rsc_rls_obj_din_1_rsc_rls_wait_ctrl
// ------------------------------------------------------------------


module READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_1_rsc_rls_obj_din_1_rsc_rls_wait_ctrl
    (
  core_wten, din_1_rsc_rls_obj_iswt0, din_1_rsc_rls_obj_ld_core_sct
);
  input core_wten;
  input din_1_rsc_rls_obj_iswt0;
  output din_1_rsc_rls_obj_ld_core_sct;



  // Interconnect Declarations for Component Instantiations 
  assign din_1_rsc_rls_obj_ld_core_sct = din_1_rsc_rls_obj_iswt0 & (~ core_wten);
endmodule

// ------------------------------------------------------------------
//  Design Unit:    READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_0_rsc_rls_obj_din_0_rsc_rls_wait_ctrl
// ------------------------------------------------------------------


module READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_0_rsc_rls_obj_din_0_rsc_rls_wait_ctrl
    (
  core_wten, din_0_rsc_rls_obj_iswt0, din_0_rsc_rls_obj_ld_core_sct
);
  input core_wten;
  input din_0_rsc_rls_obj_iswt0;
  output din_0_rsc_rls_obj_ld_core_sct;



  // Interconnect Declarations for Component Instantiations 
  assign din_0_rsc_rls_obj_ld_core_sct = din_0_rsc_rls_obj_iswt0 & (~ core_wten);
endmodule

// ------------------------------------------------------------------
//  Design Unit:    READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_dout_rsci_dout_wait_dp
// ------------------------------------------------------------------


module READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_dout_rsci_dout_wait_dp (
  clk, rst, dout_rsci_oswt, dout_rsci_wen_comp, dout_rsci_biwt, dout_rsci_bdwt
);
  input clk;
  input rst;
  input dout_rsci_oswt;
  output dout_rsci_wen_comp;
  input dout_rsci_biwt;
  input dout_rsci_bdwt;


  // Interconnect Declarations
  reg dout_rsci_bcwt;


  // Interconnect Declarations for Component Instantiations 
  assign dout_rsci_wen_comp = (~ dout_rsci_oswt) | dout_rsci_biwt | dout_rsci_bcwt;
  always @(posedge clk) begin
    if ( rst ) begin
      dout_rsci_bcwt <= 1'b0;
    end
    else begin
      dout_rsci_bcwt <= ~((~(dout_rsci_bcwt | dout_rsci_biwt)) | dout_rsci_bdwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_dout_rsci_dout_wait_ctrl
// ------------------------------------------------------------------


module READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_dout_rsci_dout_wait_ctrl (
  clk, rst, core_wen, core_wten, dout_rsci_oswt, dout_rsci_biwt, dout_rsci_bdwt,
      dout_rsci_ld_core_sct, dout_rsci_vd
);
  input clk;
  input rst;
  input core_wen;
  input core_wten;
  input dout_rsci_oswt;
  output dout_rsci_biwt;
  output dout_rsci_bdwt;
  output dout_rsci_ld_core_sct;
  input dout_rsci_vd;


  // Interconnect Declarations
  wire dout_rsci_ogwt;
  wire dout_rsci_pdswt0;
  reg dout_rsci_icwt;


  // Interconnect Declarations for Component Instantiations 
  assign dout_rsci_pdswt0 = (~ core_wten) & dout_rsci_oswt;
  assign dout_rsci_biwt = dout_rsci_ogwt & dout_rsci_vd;
  assign dout_rsci_ogwt = dout_rsci_pdswt0 | dout_rsci_icwt;
  assign dout_rsci_bdwt = dout_rsci_oswt & core_wen;
  assign dout_rsci_ld_core_sct = dout_rsci_oswt & dout_rsci_ogwt;
  always @(posedge clk) begin
    if ( rst ) begin
      dout_rsci_icwt <= 1'b0;
    end
    else begin
      dout_rsci_icwt <= ~((~(dout_rsci_icwt | dout_rsci_pdswt0)) | dout_rsci_biwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_3_rsci_1_din_3_rsc_wait_dp
// ------------------------------------------------------------------


module READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_3_rsci_1_din_3_rsc_wait_dp
    (
  clk, rst, din_3_rsci_addr_d, din_3_rsci_re_d, din_3_rsci_data_out_d, din_3_rsci_addr_d_core,
      din_3_rsci_data_out_d_mxwt, din_3_rsci_biwt, din_3_rsci_bdwt, din_3_rsci_re_d_core_sct
);
  input clk;
  input rst;
  output [7:0] din_3_rsci_addr_d;
  output [1:0] din_3_rsci_re_d;
  input [127:0] din_3_rsci_data_out_d;
  input [15:0] din_3_rsci_addr_d_core;
  output [63:0] din_3_rsci_data_out_d_mxwt;
  input din_3_rsci_biwt;
  input din_3_rsci_bdwt;
  input [1:0] din_3_rsci_re_d_core_sct;


  // Interconnect Declarations
  reg din_3_rsci_bcwt;
  reg [63:0] din_3_rsci_data_out_d_bfwt_63_0;
  wire [63:0] din_3_rsci_data_out_d_mxwt_opt_63_0;


  // Interconnect Declarations for Component Instantiations 
  assign din_3_rsci_data_out_d_mxwt_opt_63_0 = MUX_v_64_2_2((din_3_rsci_data_out_d[63:0]),
      din_3_rsci_data_out_d_bfwt_63_0, din_3_rsci_bcwt);
  assign din_3_rsci_data_out_d_mxwt = din_3_rsci_data_out_d_mxwt_opt_63_0;
  assign din_3_rsci_re_d = ~ din_3_rsci_re_d_core_sct;
  assign din_3_rsci_addr_d = din_3_rsci_addr_d_core[7:0];
  always @(posedge clk) begin
    if ( rst ) begin
      din_3_rsci_bcwt <= 1'b0;
      din_3_rsci_data_out_d_bfwt_63_0 <= 64'b0;
    end
    else begin
      din_3_rsci_bcwt <= ~((~(din_3_rsci_bcwt | din_3_rsci_biwt)) | din_3_rsci_bdwt);
      din_3_rsci_data_out_d_bfwt_63_0 <= din_3_rsci_data_out_d_mxwt_opt_63_0;
    end
  end

  function [63:0] MUX_v_64_2_2;
    input [63:0] input_0;
    input [63:0] input_1;
    input [0:0] sel;
    reg [63:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_64_2_2 = result;
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_3_rsci_1_din_3_rsc_wait_ctrl
// ------------------------------------------------------------------


module READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_3_rsci_1_din_3_rsc_wait_ctrl
    (
  core_wen, core_wten, din_3_rsci_oswt, din_3_rsci_re_d_core_psct, din_3_rsci_biwt,
      din_3_rsci_bdwt, din_3_rsci_re_d_core_sct, din_3_rsci_oswt_pff
);
  input core_wen;
  input core_wten;
  input din_3_rsci_oswt;
  input [1:0] din_3_rsci_re_d_core_psct;
  output din_3_rsci_biwt;
  output din_3_rsci_bdwt;
  output [1:0] din_3_rsci_re_d_core_sct;
  input din_3_rsci_oswt_pff;


  wire[0:0] din_3_and_1_nl;

  // Interconnect Declarations for Component Instantiations 
  assign din_3_rsci_biwt = (~ core_wten) & din_3_rsci_oswt;
  assign din_3_rsci_bdwt = din_3_rsci_oswt & core_wen;
  assign din_3_and_1_nl = (din_3_rsci_re_d_core_psct[0]) & core_wen & din_3_rsci_oswt_pff;
  assign din_3_rsci_re_d_core_sct = {1'b0 , (din_3_and_1_nl)};
endmodule

// ------------------------------------------------------------------
//  Design Unit:    READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_2_rsci_1_din_2_rsc_wait_dp
// ------------------------------------------------------------------


module READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_2_rsci_1_din_2_rsc_wait_dp
    (
  clk, rst, din_2_rsci_addr_d, din_2_rsci_re_d, din_2_rsci_data_out_d, din_2_rsci_addr_d_core,
      din_2_rsci_data_out_d_mxwt, din_2_rsci_biwt, din_2_rsci_bdwt, din_2_rsci_re_d_core_sct
);
  input clk;
  input rst;
  output [7:0] din_2_rsci_addr_d;
  output [1:0] din_2_rsci_re_d;
  input [127:0] din_2_rsci_data_out_d;
  input [15:0] din_2_rsci_addr_d_core;
  output [63:0] din_2_rsci_data_out_d_mxwt;
  input din_2_rsci_biwt;
  input din_2_rsci_bdwt;
  input [1:0] din_2_rsci_re_d_core_sct;


  // Interconnect Declarations
  reg din_2_rsci_bcwt;
  reg [63:0] din_2_rsci_data_out_d_bfwt_63_0;
  wire [63:0] din_2_rsci_data_out_d_mxwt_opt_63_0;


  // Interconnect Declarations for Component Instantiations 
  assign din_2_rsci_data_out_d_mxwt_opt_63_0 = MUX_v_64_2_2((din_2_rsci_data_out_d[63:0]),
      din_2_rsci_data_out_d_bfwt_63_0, din_2_rsci_bcwt);
  assign din_2_rsci_data_out_d_mxwt = din_2_rsci_data_out_d_mxwt_opt_63_0;
  assign din_2_rsci_re_d = ~ din_2_rsci_re_d_core_sct;
  assign din_2_rsci_addr_d = din_2_rsci_addr_d_core[7:0];
  always @(posedge clk) begin
    if ( rst ) begin
      din_2_rsci_bcwt <= 1'b0;
      din_2_rsci_data_out_d_bfwt_63_0 <= 64'b0;
    end
    else begin
      din_2_rsci_bcwt <= ~((~(din_2_rsci_bcwt | din_2_rsci_biwt)) | din_2_rsci_bdwt);
      din_2_rsci_data_out_d_bfwt_63_0 <= din_2_rsci_data_out_d_mxwt_opt_63_0;
    end
  end

  function [63:0] MUX_v_64_2_2;
    input [63:0] input_0;
    input [63:0] input_1;
    input [0:0] sel;
    reg [63:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_64_2_2 = result;
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_2_rsci_1_din_2_rsc_wait_ctrl
// ------------------------------------------------------------------


module READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_2_rsci_1_din_2_rsc_wait_ctrl
    (
  core_wen, core_wten, din_2_rsci_oswt, din_2_rsci_re_d_core_psct, din_2_rsci_biwt,
      din_2_rsci_bdwt, din_2_rsci_re_d_core_sct, din_2_rsci_oswt_pff
);
  input core_wen;
  input core_wten;
  input din_2_rsci_oswt;
  input [1:0] din_2_rsci_re_d_core_psct;
  output din_2_rsci_biwt;
  output din_2_rsci_bdwt;
  output [1:0] din_2_rsci_re_d_core_sct;
  input din_2_rsci_oswt_pff;


  wire[0:0] din_2_and_1_nl;

  // Interconnect Declarations for Component Instantiations 
  assign din_2_rsci_biwt = (~ core_wten) & din_2_rsci_oswt;
  assign din_2_rsci_bdwt = din_2_rsci_oswt & core_wen;
  assign din_2_and_1_nl = (din_2_rsci_re_d_core_psct[0]) & core_wen & din_2_rsci_oswt_pff;
  assign din_2_rsci_re_d_core_sct = {1'b0 , (din_2_and_1_nl)};
endmodule

// ------------------------------------------------------------------
//  Design Unit:    READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_1_rsci_1_din_1_rsc_wait_dp
// ------------------------------------------------------------------


module READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_1_rsci_1_din_1_rsc_wait_dp
    (
  clk, rst, din_1_rsci_addr_d, din_1_rsci_re_d, din_1_rsci_data_out_d, din_1_rsci_addr_d_core,
      din_1_rsci_data_out_d_mxwt, din_1_rsci_biwt, din_1_rsci_bdwt, din_1_rsci_re_d_core_sct
);
  input clk;
  input rst;
  output [7:0] din_1_rsci_addr_d;
  output [1:0] din_1_rsci_re_d;
  input [127:0] din_1_rsci_data_out_d;
  input [15:0] din_1_rsci_addr_d_core;
  output [63:0] din_1_rsci_data_out_d_mxwt;
  input din_1_rsci_biwt;
  input din_1_rsci_bdwt;
  input [1:0] din_1_rsci_re_d_core_sct;


  // Interconnect Declarations
  reg din_1_rsci_bcwt;
  reg [63:0] din_1_rsci_data_out_d_bfwt_63_0;
  wire [63:0] din_1_rsci_data_out_d_mxwt_opt_63_0;


  // Interconnect Declarations for Component Instantiations 
  assign din_1_rsci_data_out_d_mxwt_opt_63_0 = MUX_v_64_2_2((din_1_rsci_data_out_d[63:0]),
      din_1_rsci_data_out_d_bfwt_63_0, din_1_rsci_bcwt);
  assign din_1_rsci_data_out_d_mxwt = din_1_rsci_data_out_d_mxwt_opt_63_0;
  assign din_1_rsci_re_d = ~ din_1_rsci_re_d_core_sct;
  assign din_1_rsci_addr_d = din_1_rsci_addr_d_core[7:0];
  always @(posedge clk) begin
    if ( rst ) begin
      din_1_rsci_bcwt <= 1'b0;
      din_1_rsci_data_out_d_bfwt_63_0 <= 64'b0;
    end
    else begin
      din_1_rsci_bcwt <= ~((~(din_1_rsci_bcwt | din_1_rsci_biwt)) | din_1_rsci_bdwt);
      din_1_rsci_data_out_d_bfwt_63_0 <= din_1_rsci_data_out_d_mxwt_opt_63_0;
    end
  end

  function [63:0] MUX_v_64_2_2;
    input [63:0] input_0;
    input [63:0] input_1;
    input [0:0] sel;
    reg [63:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_64_2_2 = result;
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_1_rsci_1_din_1_rsc_wait_ctrl
// ------------------------------------------------------------------


module READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_1_rsci_1_din_1_rsc_wait_ctrl
    (
  core_wen, core_wten, din_1_rsci_oswt, din_1_rsci_re_d_core_psct, din_1_rsci_biwt,
      din_1_rsci_bdwt, din_1_rsci_re_d_core_sct, din_1_rsci_oswt_pff
);
  input core_wen;
  input core_wten;
  input din_1_rsci_oswt;
  input [1:0] din_1_rsci_re_d_core_psct;
  output din_1_rsci_biwt;
  output din_1_rsci_bdwt;
  output [1:0] din_1_rsci_re_d_core_sct;
  input din_1_rsci_oswt_pff;


  wire[0:0] din_1_and_1_nl;

  // Interconnect Declarations for Component Instantiations 
  assign din_1_rsci_biwt = (~ core_wten) & din_1_rsci_oswt;
  assign din_1_rsci_bdwt = din_1_rsci_oswt & core_wen;
  assign din_1_and_1_nl = (din_1_rsci_re_d_core_psct[0]) & core_wen & din_1_rsci_oswt_pff;
  assign din_1_rsci_re_d_core_sct = {1'b0 , (din_1_and_1_nl)};
endmodule

// ------------------------------------------------------------------
//  Design Unit:    READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_0_rsci_1_din_0_rsc_wait_dp
// ------------------------------------------------------------------


module READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_0_rsci_1_din_0_rsc_wait_dp
    (
  clk, rst, din_0_rsci_addr_d, din_0_rsci_re_d, din_0_rsci_data_out_d, din_0_rsci_addr_d_core,
      din_0_rsci_data_out_d_mxwt, din_0_rsci_biwt, din_0_rsci_bdwt, din_0_rsci_re_d_core_sct
);
  input clk;
  input rst;
  output [7:0] din_0_rsci_addr_d;
  output [1:0] din_0_rsci_re_d;
  input [127:0] din_0_rsci_data_out_d;
  input [15:0] din_0_rsci_addr_d_core;
  output [63:0] din_0_rsci_data_out_d_mxwt;
  input din_0_rsci_biwt;
  input din_0_rsci_bdwt;
  input [1:0] din_0_rsci_re_d_core_sct;


  // Interconnect Declarations
  reg din_0_rsci_bcwt;
  reg [63:0] din_0_rsci_data_out_d_bfwt_63_0;
  wire [63:0] din_0_rsci_data_out_d_mxwt_opt_63_0;


  // Interconnect Declarations for Component Instantiations 
  assign din_0_rsci_data_out_d_mxwt_opt_63_0 = MUX_v_64_2_2((din_0_rsci_data_out_d[63:0]),
      din_0_rsci_data_out_d_bfwt_63_0, din_0_rsci_bcwt);
  assign din_0_rsci_data_out_d_mxwt = din_0_rsci_data_out_d_mxwt_opt_63_0;
  assign din_0_rsci_re_d = ~ din_0_rsci_re_d_core_sct;
  assign din_0_rsci_addr_d = din_0_rsci_addr_d_core[7:0];
  always @(posedge clk) begin
    if ( rst ) begin
      din_0_rsci_bcwt <= 1'b0;
      din_0_rsci_data_out_d_bfwt_63_0 <= 64'b0;
    end
    else begin
      din_0_rsci_bcwt <= ~((~(din_0_rsci_bcwt | din_0_rsci_biwt)) | din_0_rsci_bdwt);
      din_0_rsci_data_out_d_bfwt_63_0 <= din_0_rsci_data_out_d_mxwt_opt_63_0;
    end
  end

  function [63:0] MUX_v_64_2_2;
    input [63:0] input_0;
    input [63:0] input_1;
    input [0:0] sel;
    reg [63:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_64_2_2 = result;
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_0_rsci_1_din_0_rsc_wait_ctrl
// ------------------------------------------------------------------


module READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_0_rsci_1_din_0_rsc_wait_ctrl
    (
  core_wen, din_0_rsci_oswt, din_0_rsci_re_d_core_psct, core_wten, din_0_rsci_biwt,
      din_0_rsci_bdwt, din_0_rsci_re_d_core_sct, din_0_rsci_oswt_pff
);
  input core_wen;
  input din_0_rsci_oswt;
  input [1:0] din_0_rsci_re_d_core_psct;
  input core_wten;
  output din_0_rsci_biwt;
  output din_0_rsci_bdwt;
  output [1:0] din_0_rsci_re_d_core_sct;
  input din_0_rsci_oswt_pff;


  wire[0:0] din_0_and_1_nl;

  // Interconnect Declarations for Component Instantiations 
  assign din_0_rsci_biwt = (~ core_wten) & din_0_rsci_oswt;
  assign din_0_rsci_bdwt = din_0_rsci_oswt & core_wen;
  assign din_0_and_1_nl = (din_0_rsci_re_d_core_psct[0]) & core_wen & din_0_rsci_oswt_pff;
  assign din_0_rsci_re_d_core_sct = {1'b0 , (din_0_and_1_nl)};
endmodule

// ------------------------------------------------------------------
//  Design Unit:    ram_sample_065nm_dualport_beh_dc_RAM_dualRW_rwport_en_57_32_64_5_0_1_0_0_0_1_1_64_32_2_gen
// ------------------------------------------------------------------


module ram_sample_065nm_dualport_beh_dc_RAM_dualRW_rwport_en_57_32_64_5_0_1_0_0_0_1_1_64_32_2_gen
    (
  en, data_out, we, re, addr, data_in, data_in_d, addr_d, re_d, we_d, data_out_d,
      en_d
);
  output en;
  input [127:0] data_out;
  output [1:0] we;
  output [1:0] re;
  output [9:0] addr;
  output [127:0] data_in;
  input [127:0] data_in_d;
  input [9:0] addr_d;
  input [1:0] re_d;
  input [1:0] we_d;
  output [127:0] data_out_d;
  input en_d;



  // Interconnect Declarations for Component Instantiations 
  assign en = en_d;
  assign data_out_d = data_out;
  assign we = we_d;
  assign re = re_d;
  assign addr = addr_d;
  assign data_in = data_in_d;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    ram_sample_065nm_dualport_beh_dc_RAM_dualRW_rwport_en_56_32_64_5_0_1_0_0_0_1_1_64_32_2_gen
// ------------------------------------------------------------------


module ram_sample_065nm_dualport_beh_dc_RAM_dualRW_rwport_en_56_32_64_5_0_1_0_0_0_1_1_64_32_2_gen
    (
  en, data_out, we, re, addr, data_in, data_in_d, addr_d, re_d, we_d, data_out_d,
      en_d
);
  output en;
  input [127:0] data_out;
  output [1:0] we;
  output [1:0] re;
  output [9:0] addr;
  output [127:0] data_in;
  input [127:0] data_in_d;
  input [9:0] addr_d;
  input [1:0] re_d;
  input [1:0] we_d;
  output [127:0] data_out_d;
  input en_d;



  // Interconnect Declarations for Component Instantiations 
  assign en = en_d;
  assign data_out_d = data_out;
  assign we = we_d;
  assign re = re_d;
  assign addr = addr_d;
  assign data_in = data_in_d;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    ram_sample_065nm_dualport_beh_dc_RAM_dualRW_rwport_en_55_32_64_5_0_1_0_0_0_1_1_64_32_2_gen
// ------------------------------------------------------------------


module ram_sample_065nm_dualport_beh_dc_RAM_dualRW_rwport_en_55_32_64_5_0_1_0_0_0_1_1_64_32_2_gen
    (
  en, data_out, we, re, addr, data_in, data_in_d, addr_d, re_d, we_d, data_out_d,
      en_d
);
  output en;
  input [127:0] data_out;
  output [1:0] we;
  output [1:0] re;
  output [9:0] addr;
  output [127:0] data_in;
  input [127:0] data_in_d;
  input [9:0] addr_d;
  input [1:0] re_d;
  input [1:0] we_d;
  output [127:0] data_out_d;
  input en_d;



  // Interconnect Declarations for Component Instantiations 
  assign en = en_d;
  assign data_out_d = data_out;
  assign we = we_d;
  assign re = re_d;
  assign addr = addr_d;
  assign data_in = data_in_d;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    ram_sample_065nm_dualport_beh_dc_RAM_dualRW_rwport_en_54_32_64_5_0_1_0_0_0_1_1_64_32_2_gen
// ------------------------------------------------------------------


module ram_sample_065nm_dualport_beh_dc_RAM_dualRW_rwport_en_54_32_64_5_0_1_0_0_0_1_1_64_32_2_gen
    (
  en, data_out, we, re, addr, data_in, data_in_d, addr_d, re_d, we_d, data_out_d,
      en_d
);
  output en;
  input [127:0] data_out;
  output [1:0] we;
  output [1:0] re;
  output [9:0] addr;
  output [127:0] data_in;
  input [127:0] data_in_d;
  input [9:0] addr_d;
  input [1:0] re_d;
  input [1:0] we_d;
  output [127:0] data_out_d;
  input en_d;



  // Interconnect Declarations for Component Instantiations 
  assign en = en_d;
  assign data_out_d = data_out;
  assign we = we_d;
  assign re = re_d;
  assign addr = addr_d;
  assign data_in = data_in_d;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    systolic_array_DTYPE_2_4_16_4_2_2_3_core_core_fsm
//  FSM Module
// ------------------------------------------------------------------


module systolic_array_DTYPE_2_4_16_4_2_2_3_core_core_fsm (
  clk, rst, core_wen, fsm_output
);
  input clk;
  input rst;
  input core_wen;
  output [1:0] fsm_output;
  reg [1:0] fsm_output;


  // FSM State Type Declaration for systolic_array_DTYPE_2_4_16_4_2_2_3_core_core_fsm_1
  parameter
    core_rlp_C_0 = 1'd0,
    main_C_0 = 1'd1;

  reg [0:0] state_var;
  reg [0:0] state_var_NS;


  // Interconnect Declarations for Component Instantiations 
  always @(*)
  begin : systolic_array_DTYPE_2_4_16_4_2_2_3_core_core_fsm_1
    case (state_var)
      main_C_0 : begin
        fsm_output = 2'b10;
        state_var_NS = main_C_0;
      end
      // core_rlp_C_0
      default : begin
        fsm_output = 2'b1;
        state_var_NS = main_C_0;
      end
    endcase
  end

  always @(posedge clk) begin
    if ( rst ) begin
      state_var <= core_rlp_C_0;
    end
    else if ( core_wen ) begin
      state_var <= state_var_NS;
    end
  end

endmodule

// ------------------------------------------------------------------
//  Design Unit:    systolic_array_DTYPE_2_4_16_4_2_2_3_core_staller
// ------------------------------------------------------------------


module systolic_array_DTYPE_2_4_16_4_2_2_3_core_staller (
  clk, rst, core_wen, input_rsci_wen_comp, core_wten, weight_rsci_wen_comp, output_rsci_wen_comp
);
  input clk;
  input rst;
  output core_wen;
  input input_rsci_wen_comp;
  output core_wten;
  reg core_wten;
  input weight_rsci_wen_comp;
  input output_rsci_wen_comp;



  // Interconnect Declarations for Component Instantiations 
  assign core_wen = input_rsci_wen_comp & weight_rsci_wen_comp & output_rsci_wen_comp;
  always @(posedge clk) begin
    if ( rst ) begin
      core_wten <= 1'b0;
    end
    else begin
      core_wten <= ~ core_wen;
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    systolic_array_DTYPE_2_4_16_4_2_2_3_core_wait_dp
// ------------------------------------------------------------------


module systolic_array_DTYPE_2_4_16_4_2_2_3_core_wait_dp (
  out_tile_0_value_rsc_cgo_iro, out_tile_0_value_rsc_cge, core_wen, out_tile_0_value_rsc_cgo
);
  input out_tile_0_value_rsc_cgo_iro;
  output out_tile_0_value_rsc_cge;
  input core_wen;
  input out_tile_0_value_rsc_cgo;



  // Interconnect Declarations for Component Instantiations 
  assign out_tile_0_value_rsc_cge = core_wen & (out_tile_0_value_rsc_cgo | out_tile_0_value_rsc_cgo_iro);
endmodule

// ------------------------------------------------------------------
//  Design Unit:    CGHpart
// ------------------------------------------------------------------


module CGHpart (
  CGHpart_isig
);
  input CGHpart_isig;



  // Interconnect Declarations for Component Instantiations 
endmodule

// ------------------------------------------------------------------
//  Design Unit:    systolic_array_DTYPE_2_4_16_4_2_2_3_core_output_rsci_output_wait_dp
// ------------------------------------------------------------------


module systolic_array_DTYPE_2_4_16_4_2_2_3_core_output_rsci_output_wait_dp (
  clk, rst, output_rsci_oswt, output_rsci_wen_comp, output_rsci_biwt, output_rsci_bdwt
);
  input clk;
  input rst;
  input output_rsci_oswt;
  output output_rsci_wen_comp;
  input output_rsci_biwt;
  input output_rsci_bdwt;


  // Interconnect Declarations
  reg output_rsci_bcwt;


  // Interconnect Declarations for Component Instantiations 
  assign output_rsci_wen_comp = (~ output_rsci_oswt) | output_rsci_biwt | output_rsci_bcwt;
  always @(posedge clk) begin
    if ( rst ) begin
      output_rsci_bcwt <= 1'b0;
    end
    else begin
      output_rsci_bcwt <= ~((~(output_rsci_bcwt | output_rsci_biwt)) | output_rsci_bdwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    systolic_array_DTYPE_2_4_16_4_2_2_3_core_output_rsci_output_wait_ctrl
// ------------------------------------------------------------------


module systolic_array_DTYPE_2_4_16_4_2_2_3_core_output_rsci_output_wait_ctrl (
  clk, rst, core_wen, core_wten, output_rsci_oswt, output_rsci_biwt, output_rsci_bdwt,
      output_rsci_ld_core_sct, output_rsci_vd
);
  input clk;
  input rst;
  input core_wen;
  input core_wten;
  input output_rsci_oswt;
  output output_rsci_biwt;
  output output_rsci_bdwt;
  output output_rsci_ld_core_sct;
  input output_rsci_vd;


  // Interconnect Declarations
  wire output_rsci_ogwt;
  wire output_rsci_pdswt0;
  reg output_rsci_icwt;


  // Interconnect Declarations for Component Instantiations 
  assign output_rsci_pdswt0 = (~ core_wten) & output_rsci_oswt;
  assign output_rsci_biwt = output_rsci_ogwt & output_rsci_vd;
  assign output_rsci_ogwt = output_rsci_pdswt0 | output_rsci_icwt;
  assign output_rsci_bdwt = output_rsci_oswt & core_wen;
  assign output_rsci_ld_core_sct = output_rsci_oswt & output_rsci_ogwt;
  always @(posedge clk) begin
    if ( rst ) begin
      output_rsci_icwt <= 1'b0;
    end
    else begin
      output_rsci_icwt <= ~((~(output_rsci_icwt | output_rsci_pdswt0)) | output_rsci_biwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    systolic_array_DTYPE_2_4_16_4_2_2_3_core_weight_rsci_weight_wait_dp
// ------------------------------------------------------------------


module systolic_array_DTYPE_2_4_16_4_2_2_3_core_weight_rsci_weight_wait_dp (
  clk, rst, weight_rsci_oswt, weight_rsci_wen_comp, weight_rsci_d_mxwt, weight_rsci_biwt,
      weight_rsci_bdwt, weight_rsci_d
);
  input clk;
  input rst;
  input weight_rsci_oswt;
  output weight_rsci_wen_comp;
  output [127:0] weight_rsci_d_mxwt;
  input weight_rsci_biwt;
  input weight_rsci_bdwt;
  input [255:0] weight_rsci_d;


  // Interconnect Declarations
  reg weight_rsci_bcwt;
  reg [15:0] reg_weight_rsci_d_bfwt_tmp;
  reg [15:0] reg_weight_rsci_d_bfwt_tmp_17;
  reg [15:0] reg_weight_rsci_d_bfwt_tmp_34;
  reg [15:0] reg_weight_rsci_d_bfwt_tmp_51;
  reg [15:0] reg_weight_rsci_d_bfwt_tmp_68;
  reg [15:0] reg_weight_rsci_d_bfwt_tmp_85;
  reg [15:0] reg_weight_rsci_d_bfwt_tmp_102;
  reg [15:0] reg_weight_rsci_d_bfwt_tmp_119;
  wire [15:0] weight_rsci_d_mxwt_opt_239_224;
  wire [15:0] weight_rsci_d_mxwt_opt_207_192;
  wire [15:0] weight_rsci_d_mxwt_opt_175_160;
  wire [15:0] weight_rsci_d_mxwt_opt_143_128;
  wire [15:0] weight_rsci_d_mxwt_opt_111_96;
  wire [15:0] weight_rsci_d_mxwt_opt_79_64;
  wire [15:0] weight_rsci_d_mxwt_opt_47_32;
  wire [15:0] weight_rsci_d_mxwt_opt_15_0;


  // Interconnect Declarations for Component Instantiations 
  assign weight_rsci_wen_comp = (~ weight_rsci_oswt) | weight_rsci_biwt | weight_rsci_bcwt;
  assign weight_rsci_d_mxwt_opt_239_224 = MUX_v_16_2_2((weight_rsci_d[239:224]),
      reg_weight_rsci_d_bfwt_tmp, weight_rsci_bcwt);
  assign weight_rsci_d_mxwt_opt_207_192 = MUX_v_16_2_2((weight_rsci_d[207:192]),
      reg_weight_rsci_d_bfwt_tmp_17, weight_rsci_bcwt);
  assign weight_rsci_d_mxwt_opt_175_160 = MUX_v_16_2_2((weight_rsci_d[175:160]),
      reg_weight_rsci_d_bfwt_tmp_34, weight_rsci_bcwt);
  assign weight_rsci_d_mxwt_opt_143_128 = MUX_v_16_2_2((weight_rsci_d[143:128]),
      reg_weight_rsci_d_bfwt_tmp_51, weight_rsci_bcwt);
  assign weight_rsci_d_mxwt_opt_111_96 = MUX_v_16_2_2((weight_rsci_d[111:96]), reg_weight_rsci_d_bfwt_tmp_68,
      weight_rsci_bcwt);
  assign weight_rsci_d_mxwt_opt_79_64 = MUX_v_16_2_2((weight_rsci_d[79:64]), reg_weight_rsci_d_bfwt_tmp_85,
      weight_rsci_bcwt);
  assign weight_rsci_d_mxwt_opt_47_32 = MUX_v_16_2_2((weight_rsci_d[47:32]), reg_weight_rsci_d_bfwt_tmp_102,
      weight_rsci_bcwt);
  assign weight_rsci_d_mxwt_opt_15_0 = MUX_v_16_2_2((weight_rsci_d[15:0]), reg_weight_rsci_d_bfwt_tmp_119,
      weight_rsci_bcwt);
  assign weight_rsci_d_mxwt = {weight_rsci_d_mxwt_opt_239_224 , weight_rsci_d_mxwt_opt_207_192
      , weight_rsci_d_mxwt_opt_175_160 , weight_rsci_d_mxwt_opt_143_128 , weight_rsci_d_mxwt_opt_111_96
      , weight_rsci_d_mxwt_opt_79_64 , weight_rsci_d_mxwt_opt_47_32 , weight_rsci_d_mxwt_opt_15_0};
  always @(posedge clk) begin
    if ( rst ) begin
      weight_rsci_bcwt <= 1'b0;
      reg_weight_rsci_d_bfwt_tmp <= 16'b0;
      reg_weight_rsci_d_bfwt_tmp_17 <= 16'b0;
      reg_weight_rsci_d_bfwt_tmp_34 <= 16'b0;
      reg_weight_rsci_d_bfwt_tmp_51 <= 16'b0;
      reg_weight_rsci_d_bfwt_tmp_68 <= 16'b0;
      reg_weight_rsci_d_bfwt_tmp_85 <= 16'b0;
      reg_weight_rsci_d_bfwt_tmp_102 <= 16'b0;
      reg_weight_rsci_d_bfwt_tmp_119 <= 16'b0;
    end
    else begin
      weight_rsci_bcwt <= ~((~(weight_rsci_bcwt | weight_rsci_biwt)) | weight_rsci_bdwt);
      reg_weight_rsci_d_bfwt_tmp <= weight_rsci_d_mxwt_opt_239_224;
      reg_weight_rsci_d_bfwt_tmp_17 <= weight_rsci_d_mxwt_opt_207_192;
      reg_weight_rsci_d_bfwt_tmp_34 <= weight_rsci_d_mxwt_opt_175_160;
      reg_weight_rsci_d_bfwt_tmp_51 <= weight_rsci_d_mxwt_opt_143_128;
      reg_weight_rsci_d_bfwt_tmp_68 <= weight_rsci_d_mxwt_opt_111_96;
      reg_weight_rsci_d_bfwt_tmp_85 <= weight_rsci_d_mxwt_opt_79_64;
      reg_weight_rsci_d_bfwt_tmp_102 <= weight_rsci_d_mxwt_opt_47_32;
      reg_weight_rsci_d_bfwt_tmp_119 <= weight_rsci_d_mxwt_opt_15_0;
    end
  end

  function [15:0] MUX_v_16_2_2;
    input [15:0] input_0;
    input [15:0] input_1;
    input [0:0] sel;
    reg [15:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_16_2_2 = result;
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    systolic_array_DTYPE_2_4_16_4_2_2_3_core_weight_rsci_weight_wait_ctrl
// ------------------------------------------------------------------


module systolic_array_DTYPE_2_4_16_4_2_2_3_core_weight_rsci_weight_wait_ctrl (
  clk, rst, core_wen, core_wten, weight_rsci_oswt, weight_rsci_biwt, weight_rsci_bdwt,
      weight_rsci_ld_core_sct, weight_rsci_vd
);
  input clk;
  input rst;
  input core_wen;
  input core_wten;
  input weight_rsci_oswt;
  output weight_rsci_biwt;
  output weight_rsci_bdwt;
  output weight_rsci_ld_core_sct;
  input weight_rsci_vd;


  // Interconnect Declarations
  wire weight_rsci_ogwt;
  wire weight_rsci_pdswt0;
  reg weight_rsci_icwt;


  // Interconnect Declarations for Component Instantiations 
  assign weight_rsci_pdswt0 = (~ core_wten) & weight_rsci_oswt;
  assign weight_rsci_biwt = weight_rsci_ogwt & weight_rsci_vd;
  assign weight_rsci_ogwt = weight_rsci_pdswt0 | weight_rsci_icwt;
  assign weight_rsci_bdwt = weight_rsci_oswt & core_wen;
  assign weight_rsci_ld_core_sct = weight_rsci_oswt & weight_rsci_ogwt;
  always @(posedge clk) begin
    if ( rst ) begin
      weight_rsci_icwt <= 1'b0;
    end
    else begin
      weight_rsci_icwt <= ~((~(weight_rsci_icwt | weight_rsci_pdswt0)) | weight_rsci_biwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    systolic_array_DTYPE_2_4_16_4_2_2_3_core_input_rsci_input_wait_dp
// ------------------------------------------------------------------


module systolic_array_DTYPE_2_4_16_4_2_2_3_core_input_rsci_input_wait_dp (
  clk, rst, input_rsci_oswt, input_rsci_wen_comp, input_rsci_d_mxwt, input_rsci_biwt,
      input_rsci_bdwt, input_rsci_d
);
  input clk;
  input rst;
  input input_rsci_oswt;
  output input_rsci_wen_comp;
  output [63:0] input_rsci_d_mxwt;
  input input_rsci_biwt;
  input input_rsci_bdwt;
  input [127:0] input_rsci_d;


  // Interconnect Declarations
  reg input_rsci_bcwt;
  reg [15:0] reg_input_rsci_d_bfwt_tmp;
  reg [15:0] reg_input_rsci_d_bfwt_tmp_17;
  reg [15:0] reg_input_rsci_d_bfwt_tmp_34;
  reg [15:0] reg_input_rsci_d_bfwt_tmp_51;
  wire [15:0] input_rsci_d_mxwt_opt_111_96;
  wire [15:0] input_rsci_d_mxwt_opt_79_64;
  wire [15:0] input_rsci_d_mxwt_opt_47_32;
  wire [15:0] input_rsci_d_mxwt_opt_15_0;


  // Interconnect Declarations for Component Instantiations 
  assign input_rsci_wen_comp = (~ input_rsci_oswt) | input_rsci_biwt | input_rsci_bcwt;
  assign input_rsci_d_mxwt_opt_111_96 = MUX_v_16_2_2((input_rsci_d[111:96]), reg_input_rsci_d_bfwt_tmp,
      input_rsci_bcwt);
  assign input_rsci_d_mxwt_opt_79_64 = MUX_v_16_2_2((input_rsci_d[79:64]), reg_input_rsci_d_bfwt_tmp_17,
      input_rsci_bcwt);
  assign input_rsci_d_mxwt_opt_47_32 = MUX_v_16_2_2((input_rsci_d[47:32]), reg_input_rsci_d_bfwt_tmp_34,
      input_rsci_bcwt);
  assign input_rsci_d_mxwt_opt_15_0 = MUX_v_16_2_2((input_rsci_d[15:0]), reg_input_rsci_d_bfwt_tmp_51,
      input_rsci_bcwt);
  assign input_rsci_d_mxwt = {input_rsci_d_mxwt_opt_111_96 , input_rsci_d_mxwt_opt_79_64
      , input_rsci_d_mxwt_opt_47_32 , input_rsci_d_mxwt_opt_15_0};
  always @(posedge clk) begin
    if ( rst ) begin
      input_rsci_bcwt <= 1'b0;
      reg_input_rsci_d_bfwt_tmp <= 16'b0;
      reg_input_rsci_d_bfwt_tmp_17 <= 16'b0;
      reg_input_rsci_d_bfwt_tmp_34 <= 16'b0;
      reg_input_rsci_d_bfwt_tmp_51 <= 16'b0;
    end
    else begin
      input_rsci_bcwt <= ~((~(input_rsci_bcwt | input_rsci_biwt)) | input_rsci_bdwt);
      reg_input_rsci_d_bfwt_tmp <= input_rsci_d_mxwt_opt_111_96;
      reg_input_rsci_d_bfwt_tmp_17 <= input_rsci_d_mxwt_opt_79_64;
      reg_input_rsci_d_bfwt_tmp_34 <= input_rsci_d_mxwt_opt_47_32;
      reg_input_rsci_d_bfwt_tmp_51 <= input_rsci_d_mxwt_opt_15_0;
    end
  end

  function [15:0] MUX_v_16_2_2;
    input [15:0] input_0;
    input [15:0] input_1;
    input [0:0] sel;
    reg [15:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_16_2_2 = result;
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    systolic_array_DTYPE_2_4_16_4_2_2_3_core_input_rsci_input_wait_ctrl
// ------------------------------------------------------------------


module systolic_array_DTYPE_2_4_16_4_2_2_3_core_input_rsci_input_wait_ctrl (
  clk, rst, core_wen, input_rsci_oswt, core_wten, input_rsci_biwt, input_rsci_bdwt,
      input_rsci_ld_core_sct, input_rsci_vd
);
  input clk;
  input rst;
  input core_wen;
  input input_rsci_oswt;
  input core_wten;
  output input_rsci_biwt;
  output input_rsci_bdwt;
  output input_rsci_ld_core_sct;
  input input_rsci_vd;


  // Interconnect Declarations
  wire input_rsci_ogwt;
  wire input_rsci_pdswt0;
  reg input_rsci_icwt;


  // Interconnect Declarations for Component Instantiations 
  assign input_rsci_pdswt0 = (~ core_wten) & input_rsci_oswt;
  assign input_rsci_biwt = input_rsci_ogwt & input_rsci_vd;
  assign input_rsci_ogwt = input_rsci_pdswt0 | input_rsci_icwt;
  assign input_rsci_bdwt = input_rsci_oswt & core_wen;
  assign input_rsci_ld_core_sct = input_rsci_oswt & input_rsci_ogwt;
  always @(posedge clk) begin
    if ( rst ) begin
      input_rsci_icwt <= 1'b0;
    end
    else begin
      input_rsci_icwt <= ~((~(input_rsci_icwt | input_rsci_pdswt0)) | input_rsci_biwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_0_rsc_req_obj
// ------------------------------------------------------------------


module WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_0_rsc_req_obj (
  clk, rst, dout_0_rsc_req_vz, core_wen, core_wten, dout_0_rsc_req_obj_oswt, dout_0_rsc_req_obj_wen_comp
);
  input clk;
  input rst;
  input dout_0_rsc_req_vz;
  input core_wen;
  input core_wten;
  input dout_0_rsc_req_obj_oswt;
  output dout_0_rsc_req_obj_wen_comp;


  // Interconnect Declarations
  wire dout_0_rsc_req_obj_vd;
  wire dout_0_rsc_req_obj_biwt;
  wire dout_0_rsc_req_obj_bdwt;


  // Interconnect Declarations for Component Instantiations 
  mgc_in_sync_v1 #(.valid(32'sd1)) dout_0_rsc_req_obj (
      .vd(dout_0_rsc_req_obj_vd),
      .vz(dout_0_rsc_req_vz)
    );
  WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_0_rsc_req_obj_dout_0_rsc_req_wait_ctrl
      WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_0_rsc_req_obj_dout_0_rsc_req_wait_ctrl_inst
      (
      .clk(clk),
      .rst(rst),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .dout_0_rsc_req_obj_oswt(dout_0_rsc_req_obj_oswt),
      .dout_0_rsc_req_obj_vd(dout_0_rsc_req_obj_vd),
      .dout_0_rsc_req_obj_biwt(dout_0_rsc_req_obj_biwt),
      .dout_0_rsc_req_obj_bdwt(dout_0_rsc_req_obj_bdwt)
    );
  WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_0_rsc_req_obj_dout_0_rsc_req_wait_dp
      WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_0_rsc_req_obj_dout_0_rsc_req_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .dout_0_rsc_req_obj_oswt(dout_0_rsc_req_obj_oswt),
      .dout_0_rsc_req_obj_wen_comp(dout_0_rsc_req_obj_wen_comp),
      .dout_0_rsc_req_obj_biwt(dout_0_rsc_req_obj_biwt),
      .dout_0_rsc_req_obj_bdwt(dout_0_rsc_req_obj_bdwt)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_1_rsc_req_obj
// ------------------------------------------------------------------


module WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_1_rsc_req_obj (
  clk, rst, dout_1_rsc_req_vz, core_wen, core_wten, dout_1_rsc_req_obj_oswt, dout_1_rsc_req_obj_wen_comp
);
  input clk;
  input rst;
  input dout_1_rsc_req_vz;
  input core_wen;
  input core_wten;
  input dout_1_rsc_req_obj_oswt;
  output dout_1_rsc_req_obj_wen_comp;


  // Interconnect Declarations
  wire dout_1_rsc_req_obj_vd;
  wire dout_1_rsc_req_obj_biwt;
  wire dout_1_rsc_req_obj_bdwt;


  // Interconnect Declarations for Component Instantiations 
  mgc_in_sync_v1 #(.valid(32'sd1)) dout_1_rsc_req_obj (
      .vd(dout_1_rsc_req_obj_vd),
      .vz(dout_1_rsc_req_vz)
    );
  WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_1_rsc_req_obj_dout_1_rsc_req_wait_ctrl
      WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_1_rsc_req_obj_dout_1_rsc_req_wait_ctrl_inst
      (
      .clk(clk),
      .rst(rst),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .dout_1_rsc_req_obj_oswt(dout_1_rsc_req_obj_oswt),
      .dout_1_rsc_req_obj_vd(dout_1_rsc_req_obj_vd),
      .dout_1_rsc_req_obj_biwt(dout_1_rsc_req_obj_biwt),
      .dout_1_rsc_req_obj_bdwt(dout_1_rsc_req_obj_bdwt)
    );
  WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_1_rsc_req_obj_dout_1_rsc_req_wait_dp
      WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_1_rsc_req_obj_dout_1_rsc_req_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .dout_1_rsc_req_obj_oswt(dout_1_rsc_req_obj_oswt),
      .dout_1_rsc_req_obj_wen_comp(dout_1_rsc_req_obj_wen_comp),
      .dout_1_rsc_req_obj_biwt(dout_1_rsc_req_obj_biwt),
      .dout_1_rsc_req_obj_bdwt(dout_1_rsc_req_obj_bdwt)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_2_rsc_req_obj
// ------------------------------------------------------------------


module WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_2_rsc_req_obj (
  clk, rst, dout_2_rsc_req_vz, core_wen, core_wten, dout_2_rsc_req_obj_oswt, dout_2_rsc_req_obj_wen_comp
);
  input clk;
  input rst;
  input dout_2_rsc_req_vz;
  input core_wen;
  input core_wten;
  input dout_2_rsc_req_obj_oswt;
  output dout_2_rsc_req_obj_wen_comp;


  // Interconnect Declarations
  wire dout_2_rsc_req_obj_vd;
  wire dout_2_rsc_req_obj_biwt;
  wire dout_2_rsc_req_obj_bdwt;


  // Interconnect Declarations for Component Instantiations 
  mgc_in_sync_v1 #(.valid(32'sd1)) dout_2_rsc_req_obj (
      .vd(dout_2_rsc_req_obj_vd),
      .vz(dout_2_rsc_req_vz)
    );
  WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_2_rsc_req_obj_dout_2_rsc_req_wait_ctrl
      WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_2_rsc_req_obj_dout_2_rsc_req_wait_ctrl_inst
      (
      .clk(clk),
      .rst(rst),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .dout_2_rsc_req_obj_oswt(dout_2_rsc_req_obj_oswt),
      .dout_2_rsc_req_obj_vd(dout_2_rsc_req_obj_vd),
      .dout_2_rsc_req_obj_biwt(dout_2_rsc_req_obj_biwt),
      .dout_2_rsc_req_obj_bdwt(dout_2_rsc_req_obj_bdwt)
    );
  WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_2_rsc_req_obj_dout_2_rsc_req_wait_dp
      WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_2_rsc_req_obj_dout_2_rsc_req_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .dout_2_rsc_req_obj_oswt(dout_2_rsc_req_obj_oswt),
      .dout_2_rsc_req_obj_wen_comp(dout_2_rsc_req_obj_wen_comp),
      .dout_2_rsc_req_obj_biwt(dout_2_rsc_req_obj_biwt),
      .dout_2_rsc_req_obj_bdwt(dout_2_rsc_req_obj_bdwt)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_3_rsc_req_obj
// ------------------------------------------------------------------


module WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_3_rsc_req_obj (
  clk, rst, dout_3_rsc_req_vz, core_wen, core_wten, dout_3_rsc_req_obj_oswt, dout_3_rsc_req_obj_wen_comp
);
  input clk;
  input rst;
  input dout_3_rsc_req_vz;
  input core_wen;
  input core_wten;
  input dout_3_rsc_req_obj_oswt;
  output dout_3_rsc_req_obj_wen_comp;


  // Interconnect Declarations
  wire dout_3_rsc_req_obj_vd;
  wire dout_3_rsc_req_obj_biwt;
  wire dout_3_rsc_req_obj_bdwt;


  // Interconnect Declarations for Component Instantiations 
  mgc_in_sync_v1 #(.valid(32'sd1)) dout_3_rsc_req_obj (
      .vd(dout_3_rsc_req_obj_vd),
      .vz(dout_3_rsc_req_vz)
    );
  WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_3_rsc_req_obj_dout_3_rsc_req_wait_ctrl
      WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_3_rsc_req_obj_dout_3_rsc_req_wait_ctrl_inst
      (
      .clk(clk),
      .rst(rst),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .dout_3_rsc_req_obj_oswt(dout_3_rsc_req_obj_oswt),
      .dout_3_rsc_req_obj_vd(dout_3_rsc_req_obj_vd),
      .dout_3_rsc_req_obj_biwt(dout_3_rsc_req_obj_biwt),
      .dout_3_rsc_req_obj_bdwt(dout_3_rsc_req_obj_bdwt)
    );
  WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_3_rsc_req_obj_dout_3_rsc_req_wait_dp
      WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_3_rsc_req_obj_dout_3_rsc_req_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .dout_3_rsc_req_obj_oswt(dout_3_rsc_req_obj_oswt),
      .dout_3_rsc_req_obj_wen_comp(dout_3_rsc_req_obj_wen_comp),
      .dout_3_rsc_req_obj_biwt(dout_3_rsc_req_obj_biwt),
      .dout_3_rsc_req_obj_bdwt(dout_3_rsc_req_obj_bdwt)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_0_rsc_rls_obj
// ------------------------------------------------------------------


module WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_0_rsc_rls_obj (
  dout_0_rsc_rls_lz, core_wten, dout_0_rsc_rls_obj_iswt0
);
  output dout_0_rsc_rls_lz;
  input core_wten;
  input dout_0_rsc_rls_obj_iswt0;


  // Interconnect Declarations
  wire dout_0_rsc_rls_obj_ld_core_sct;


  // Interconnect Declarations for Component Instantiations 
  mgc_io_sync_v1 #(.valid(32'sd0)) dout_0_rsc_rls_obj (
      .ld(dout_0_rsc_rls_obj_ld_core_sct),
      .lz(dout_0_rsc_rls_lz)
    );
  WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_0_rsc_rls_obj_dout_0_rsc_rls_wait_ctrl
      WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_0_rsc_rls_obj_dout_0_rsc_rls_wait_ctrl_inst
      (
      .core_wten(core_wten),
      .dout_0_rsc_rls_obj_iswt0(dout_0_rsc_rls_obj_iswt0),
      .dout_0_rsc_rls_obj_ld_core_sct(dout_0_rsc_rls_obj_ld_core_sct)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_1_rsc_rls_obj
// ------------------------------------------------------------------


module WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_1_rsc_rls_obj (
  dout_1_rsc_rls_lz, core_wten, dout_1_rsc_rls_obj_iswt0
);
  output dout_1_rsc_rls_lz;
  input core_wten;
  input dout_1_rsc_rls_obj_iswt0;


  // Interconnect Declarations
  wire dout_1_rsc_rls_obj_ld_core_sct;


  // Interconnect Declarations for Component Instantiations 
  mgc_io_sync_v1 #(.valid(32'sd0)) dout_1_rsc_rls_obj (
      .ld(dout_1_rsc_rls_obj_ld_core_sct),
      .lz(dout_1_rsc_rls_lz)
    );
  WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_1_rsc_rls_obj_dout_1_rsc_rls_wait_ctrl
      WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_1_rsc_rls_obj_dout_1_rsc_rls_wait_ctrl_inst
      (
      .core_wten(core_wten),
      .dout_1_rsc_rls_obj_iswt0(dout_1_rsc_rls_obj_iswt0),
      .dout_1_rsc_rls_obj_ld_core_sct(dout_1_rsc_rls_obj_ld_core_sct)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_2_rsc_rls_obj
// ------------------------------------------------------------------


module WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_2_rsc_rls_obj (
  dout_2_rsc_rls_lz, core_wten, dout_2_rsc_rls_obj_iswt0
);
  output dout_2_rsc_rls_lz;
  input core_wten;
  input dout_2_rsc_rls_obj_iswt0;


  // Interconnect Declarations
  wire dout_2_rsc_rls_obj_ld_core_sct;


  // Interconnect Declarations for Component Instantiations 
  mgc_io_sync_v1 #(.valid(32'sd0)) dout_2_rsc_rls_obj (
      .ld(dout_2_rsc_rls_obj_ld_core_sct),
      .lz(dout_2_rsc_rls_lz)
    );
  WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_2_rsc_rls_obj_dout_2_rsc_rls_wait_ctrl
      WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_2_rsc_rls_obj_dout_2_rsc_rls_wait_ctrl_inst
      (
      .core_wten(core_wten),
      .dout_2_rsc_rls_obj_iswt0(dout_2_rsc_rls_obj_iswt0),
      .dout_2_rsc_rls_obj_ld_core_sct(dout_2_rsc_rls_obj_ld_core_sct)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_3_rsc_rls_obj
// ------------------------------------------------------------------


module WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_3_rsc_rls_obj (
  dout_3_rsc_rls_lz, core_wten, dout_3_rsc_rls_obj_iswt0
);
  output dout_3_rsc_rls_lz;
  input core_wten;
  input dout_3_rsc_rls_obj_iswt0;


  // Interconnect Declarations
  wire dout_3_rsc_rls_obj_ld_core_sct;


  // Interconnect Declarations for Component Instantiations 
  mgc_io_sync_v1 #(.valid(32'sd0)) dout_3_rsc_rls_obj (
      .ld(dout_3_rsc_rls_obj_ld_core_sct),
      .lz(dout_3_rsc_rls_lz)
    );
  WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_3_rsc_rls_obj_dout_3_rsc_rls_wait_ctrl
      WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_3_rsc_rls_obj_dout_3_rsc_rls_wait_ctrl_inst
      (
      .core_wten(core_wten),
      .dout_3_rsc_rls_obj_iswt0(dout_3_rsc_rls_obj_iswt0),
      .dout_3_rsc_rls_obj_ld_core_sct(dout_3_rsc_rls_obj_ld_core_sct)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_3_rsci_1
// ------------------------------------------------------------------


module WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_3_rsci_1 (
  dout_3_rsci_data_in_d, dout_3_rsci_addr_d, dout_3_rsci_we_d, core_wten, dout_3_rsci_iswt0,
      dout_3_rsci_data_in_d_core, dout_3_rsci_addr_d_core, dout_3_rsci_we_d_core_psct
);
  output [15:0] dout_3_rsci_data_in_d;
  output [6:0] dout_3_rsci_addr_d;
  output [1:0] dout_3_rsci_we_d;
  input core_wten;
  input dout_3_rsci_iswt0;
  input [31:0] dout_3_rsci_data_in_d_core;
  input [13:0] dout_3_rsci_addr_d_core;
  input [1:0] dout_3_rsci_we_d_core_psct;


  // Interconnect Declarations
  wire [1:0] dout_3_rsci_we_d_core_sct;


  // Interconnect Declarations for Component Instantiations 
  wire [1:0] nl_WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_3_rsci_1_dout_3_rsc_wait_ctrl_inst_dout_3_rsci_we_d_core_psct;
  assign nl_WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_3_rsci_1_dout_3_rsc_wait_ctrl_inst_dout_3_rsci_we_d_core_psct
      = {1'b0 , (dout_3_rsci_we_d_core_psct[0])};
  WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_3_rsci_1_dout_3_rsc_wait_ctrl WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_3_rsci_1_dout_3_rsc_wait_ctrl_inst
      (
      .core_wten(core_wten),
      .dout_3_rsci_iswt0(dout_3_rsci_iswt0),
      .dout_3_rsci_we_d_core_psct(nl_WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_3_rsci_1_dout_3_rsc_wait_ctrl_inst_dout_3_rsci_we_d_core_psct[1:0]),
      .dout_3_rsci_we_d_core_sct(dout_3_rsci_we_d_core_sct)
    );
  assign dout_3_rsci_we_d = ~ dout_3_rsci_we_d_core_sct;
  assign dout_3_rsci_data_in_d = dout_3_rsci_data_in_d_core[15:0];
  assign dout_3_rsci_addr_d = dout_3_rsci_addr_d_core[6:0];
endmodule

// ------------------------------------------------------------------
//  Design Unit:    WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_2_rsci_1
// ------------------------------------------------------------------


module WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_2_rsci_1 (
  dout_2_rsci_data_in_d, dout_2_rsci_addr_d, dout_2_rsci_we_d, core_wten, dout_2_rsci_iswt0,
      dout_2_rsci_data_in_d_core, dout_2_rsci_addr_d_core, dout_2_rsci_we_d_core_psct
);
  output [15:0] dout_2_rsci_data_in_d;
  output [6:0] dout_2_rsci_addr_d;
  output [1:0] dout_2_rsci_we_d;
  input core_wten;
  input dout_2_rsci_iswt0;
  input [31:0] dout_2_rsci_data_in_d_core;
  input [13:0] dout_2_rsci_addr_d_core;
  input [1:0] dout_2_rsci_we_d_core_psct;


  // Interconnect Declarations
  wire [1:0] dout_2_rsci_we_d_core_sct;


  // Interconnect Declarations for Component Instantiations 
  wire [1:0] nl_WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_2_rsci_1_dout_2_rsc_wait_ctrl_inst_dout_2_rsci_we_d_core_psct;
  assign nl_WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_2_rsci_1_dout_2_rsc_wait_ctrl_inst_dout_2_rsci_we_d_core_psct
      = {1'b0 , (dout_2_rsci_we_d_core_psct[0])};
  WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_2_rsci_1_dout_2_rsc_wait_ctrl WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_2_rsci_1_dout_2_rsc_wait_ctrl_inst
      (
      .core_wten(core_wten),
      .dout_2_rsci_iswt0(dout_2_rsci_iswt0),
      .dout_2_rsci_we_d_core_psct(nl_WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_2_rsci_1_dout_2_rsc_wait_ctrl_inst_dout_2_rsci_we_d_core_psct[1:0]),
      .dout_2_rsci_we_d_core_sct(dout_2_rsci_we_d_core_sct)
    );
  assign dout_2_rsci_we_d = ~ dout_2_rsci_we_d_core_sct;
  assign dout_2_rsci_data_in_d = dout_2_rsci_data_in_d_core[15:0];
  assign dout_2_rsci_addr_d = dout_2_rsci_addr_d_core[6:0];
endmodule

// ------------------------------------------------------------------
//  Design Unit:    WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_1_rsci_1
// ------------------------------------------------------------------


module WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_1_rsci_1 (
  dout_1_rsci_data_in_d, dout_1_rsci_addr_d, dout_1_rsci_we_d, core_wten, dout_1_rsci_iswt0,
      dout_1_rsci_data_in_d_core, dout_1_rsci_addr_d_core, dout_1_rsci_we_d_core_psct
);
  output [15:0] dout_1_rsci_data_in_d;
  output [6:0] dout_1_rsci_addr_d;
  output [1:0] dout_1_rsci_we_d;
  input core_wten;
  input dout_1_rsci_iswt0;
  input [31:0] dout_1_rsci_data_in_d_core;
  input [13:0] dout_1_rsci_addr_d_core;
  input [1:0] dout_1_rsci_we_d_core_psct;


  // Interconnect Declarations
  wire [1:0] dout_1_rsci_we_d_core_sct;


  // Interconnect Declarations for Component Instantiations 
  wire [1:0] nl_WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_1_rsci_1_dout_1_rsc_wait_ctrl_inst_dout_1_rsci_we_d_core_psct;
  assign nl_WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_1_rsci_1_dout_1_rsc_wait_ctrl_inst_dout_1_rsci_we_d_core_psct
      = {1'b0 , (dout_1_rsci_we_d_core_psct[0])};
  WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_1_rsci_1_dout_1_rsc_wait_ctrl WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_1_rsci_1_dout_1_rsc_wait_ctrl_inst
      (
      .core_wten(core_wten),
      .dout_1_rsci_iswt0(dout_1_rsci_iswt0),
      .dout_1_rsci_we_d_core_psct(nl_WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_1_rsci_1_dout_1_rsc_wait_ctrl_inst_dout_1_rsci_we_d_core_psct[1:0]),
      .dout_1_rsci_we_d_core_sct(dout_1_rsci_we_d_core_sct)
    );
  assign dout_1_rsci_we_d = ~ dout_1_rsci_we_d_core_sct;
  assign dout_1_rsci_data_in_d = dout_1_rsci_data_in_d_core[15:0];
  assign dout_1_rsci_addr_d = dout_1_rsci_addr_d_core[6:0];
endmodule

// ------------------------------------------------------------------
//  Design Unit:    WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_0_rsci_1
// ------------------------------------------------------------------


module WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_0_rsci_1 (
  dout_0_rsci_data_in_d, dout_0_rsci_addr_d, dout_0_rsci_we_d, core_wten, dout_0_rsci_iswt0,
      dout_0_rsci_data_in_d_core, dout_0_rsci_addr_d_core, dout_0_rsci_we_d_core_psct
);
  output [15:0] dout_0_rsci_data_in_d;
  output [6:0] dout_0_rsci_addr_d;
  output [1:0] dout_0_rsci_we_d;
  input core_wten;
  input dout_0_rsci_iswt0;
  input [31:0] dout_0_rsci_data_in_d_core;
  input [13:0] dout_0_rsci_addr_d_core;
  input [1:0] dout_0_rsci_we_d_core_psct;


  // Interconnect Declarations
  wire [1:0] dout_0_rsci_we_d_core_sct;


  // Interconnect Declarations for Component Instantiations 
  wire [1:0] nl_WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_0_rsci_1_dout_0_rsc_wait_ctrl_inst_dout_0_rsci_we_d_core_psct;
  assign nl_WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_0_rsci_1_dout_0_rsc_wait_ctrl_inst_dout_0_rsci_we_d_core_psct
      = {1'b0 , (dout_0_rsci_we_d_core_psct[0])};
  WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_0_rsci_1_dout_0_rsc_wait_ctrl WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_0_rsci_1_dout_0_rsc_wait_ctrl_inst
      (
      .core_wten(core_wten),
      .dout_0_rsci_iswt0(dout_0_rsci_iswt0),
      .dout_0_rsci_we_d_core_psct(nl_WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_0_rsci_1_dout_0_rsc_wait_ctrl_inst_dout_0_rsci_we_d_core_psct[1:0]),
      .dout_0_rsci_we_d_core_sct(dout_0_rsci_we_d_core_sct)
    );
  assign dout_0_rsci_we_d = ~ dout_0_rsci_we_d_core_sct;
  assign dout_0_rsci_data_in_d = dout_0_rsci_data_in_d_core[15:0];
  assign dout_0_rsci_addr_d = dout_0_rsci_addr_d_core[6:0];
endmodule

// ------------------------------------------------------------------
//  Design Unit:    WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_din_rsci
// ------------------------------------------------------------------


module WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_din_rsci (
  clk, rst, din_rsc_z, din_rsc_vz, din_rsc_lz, core_wen, din_rsci_oswt, din_rsci_wen_comp,
      din_rsci_d_mxwt, core_wten
);
  input clk;
  input rst;
  input [127:0] din_rsc_z;
  input din_rsc_vz;
  output din_rsc_lz;
  input core_wen;
  input din_rsci_oswt;
  output din_rsci_wen_comp;
  output [63:0] din_rsci_d_mxwt;
  input core_wten;


  // Interconnect Declarations
  wire din_rsci_biwt;
  wire din_rsci_bdwt;
  wire din_rsci_ld_core_sct;
  wire din_rsci_vd;
  wire [127:0] din_rsci_d;
  wire [63:0] din_rsci_d_mxwt_pconst;


  // Interconnect Declarations for Component Instantiations 
  mgc_in_wire_wait_v1 #(.rscid(32'sd1),
  .width(32'sd128)) din_rsci (
      .ld(din_rsci_ld_core_sct),
      .vd(din_rsci_vd),
      .d(din_rsci_d),
      .lz(din_rsc_lz),
      .vz(din_rsc_vz),
      .z(din_rsc_z)
    );
  WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_din_rsci_din_wait_ctrl WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_din_rsci_din_wait_ctrl_inst
      (
      .clk(clk),
      .rst(rst),
      .core_wen(core_wen),
      .din_rsci_oswt(din_rsci_oswt),
      .core_wten(core_wten),
      .din_rsci_biwt(din_rsci_biwt),
      .din_rsci_bdwt(din_rsci_bdwt),
      .din_rsci_ld_core_sct(din_rsci_ld_core_sct),
      .din_rsci_vd(din_rsci_vd)
    );
  WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_din_rsci_din_wait_dp WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_din_rsci_din_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .din_rsci_oswt(din_rsci_oswt),
      .din_rsci_wen_comp(din_rsci_wen_comp),
      .din_rsci_d_mxwt(din_rsci_d_mxwt_pconst),
      .din_rsci_biwt(din_rsci_biwt),
      .din_rsci_bdwt(din_rsci_bdwt),
      .din_rsci_d(din_rsci_d)
    );
  assign din_rsci_d_mxwt = din_rsci_d_mxwt_pconst;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_0_rsc_req_obj
// ------------------------------------------------------------------


module READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_0_rsc_req_obj (
  clk, rst, din_0_rsc_req_vz, core_wen, core_wten, din_0_rsc_req_obj_oswt, din_0_rsc_req_obj_wen_comp
);
  input clk;
  input rst;
  input din_0_rsc_req_vz;
  input core_wen;
  input core_wten;
  input din_0_rsc_req_obj_oswt;
  output din_0_rsc_req_obj_wen_comp;


  // Interconnect Declarations
  wire din_0_rsc_req_obj_vd;
  wire din_0_rsc_req_obj_biwt;
  wire din_0_rsc_req_obj_bdwt;


  // Interconnect Declarations for Component Instantiations 
  mgc_in_sync_v1 #(.valid(32'sd1)) din_0_rsc_req_obj (
      .vd(din_0_rsc_req_obj_vd),
      .vz(din_0_rsc_req_vz)
    );
  READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_0_rsc_req_obj_din_0_rsc_req_wait_ctrl
      READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_0_rsc_req_obj_din_0_rsc_req_wait_ctrl_inst
      (
      .clk(clk),
      .rst(rst),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .din_0_rsc_req_obj_oswt(din_0_rsc_req_obj_oswt),
      .din_0_rsc_req_obj_vd(din_0_rsc_req_obj_vd),
      .din_0_rsc_req_obj_biwt(din_0_rsc_req_obj_biwt),
      .din_0_rsc_req_obj_bdwt(din_0_rsc_req_obj_bdwt)
    );
  READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_0_rsc_req_obj_din_0_rsc_req_wait_dp
      READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_0_rsc_req_obj_din_0_rsc_req_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .din_0_rsc_req_obj_oswt(din_0_rsc_req_obj_oswt),
      .din_0_rsc_req_obj_wen_comp(din_0_rsc_req_obj_wen_comp),
      .din_0_rsc_req_obj_biwt(din_0_rsc_req_obj_biwt),
      .din_0_rsc_req_obj_bdwt(din_0_rsc_req_obj_bdwt)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_1_rsc_req_obj
// ------------------------------------------------------------------


module READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_1_rsc_req_obj (
  clk, rst, din_1_rsc_req_vz, core_wen, core_wten, din_1_rsc_req_obj_oswt, din_1_rsc_req_obj_wen_comp
);
  input clk;
  input rst;
  input din_1_rsc_req_vz;
  input core_wen;
  input core_wten;
  input din_1_rsc_req_obj_oswt;
  output din_1_rsc_req_obj_wen_comp;


  // Interconnect Declarations
  wire din_1_rsc_req_obj_vd;
  wire din_1_rsc_req_obj_biwt;
  wire din_1_rsc_req_obj_bdwt;


  // Interconnect Declarations for Component Instantiations 
  mgc_in_sync_v1 #(.valid(32'sd1)) din_1_rsc_req_obj (
      .vd(din_1_rsc_req_obj_vd),
      .vz(din_1_rsc_req_vz)
    );
  READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_1_rsc_req_obj_din_1_rsc_req_wait_ctrl
      READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_1_rsc_req_obj_din_1_rsc_req_wait_ctrl_inst
      (
      .clk(clk),
      .rst(rst),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .din_1_rsc_req_obj_oswt(din_1_rsc_req_obj_oswt),
      .din_1_rsc_req_obj_vd(din_1_rsc_req_obj_vd),
      .din_1_rsc_req_obj_biwt(din_1_rsc_req_obj_biwt),
      .din_1_rsc_req_obj_bdwt(din_1_rsc_req_obj_bdwt)
    );
  READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_1_rsc_req_obj_din_1_rsc_req_wait_dp
      READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_1_rsc_req_obj_din_1_rsc_req_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .din_1_rsc_req_obj_oswt(din_1_rsc_req_obj_oswt),
      .din_1_rsc_req_obj_wen_comp(din_1_rsc_req_obj_wen_comp),
      .din_1_rsc_req_obj_biwt(din_1_rsc_req_obj_biwt),
      .din_1_rsc_req_obj_bdwt(din_1_rsc_req_obj_bdwt)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_2_rsc_req_obj
// ------------------------------------------------------------------


module READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_2_rsc_req_obj (
  clk, rst, din_2_rsc_req_vz, core_wen, core_wten, din_2_rsc_req_obj_oswt, din_2_rsc_req_obj_wen_comp
);
  input clk;
  input rst;
  input din_2_rsc_req_vz;
  input core_wen;
  input core_wten;
  input din_2_rsc_req_obj_oswt;
  output din_2_rsc_req_obj_wen_comp;


  // Interconnect Declarations
  wire din_2_rsc_req_obj_vd;
  wire din_2_rsc_req_obj_biwt;
  wire din_2_rsc_req_obj_bdwt;


  // Interconnect Declarations for Component Instantiations 
  mgc_in_sync_v1 #(.valid(32'sd1)) din_2_rsc_req_obj (
      .vd(din_2_rsc_req_obj_vd),
      .vz(din_2_rsc_req_vz)
    );
  READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_2_rsc_req_obj_din_2_rsc_req_wait_ctrl
      READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_2_rsc_req_obj_din_2_rsc_req_wait_ctrl_inst
      (
      .clk(clk),
      .rst(rst),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .din_2_rsc_req_obj_oswt(din_2_rsc_req_obj_oswt),
      .din_2_rsc_req_obj_vd(din_2_rsc_req_obj_vd),
      .din_2_rsc_req_obj_biwt(din_2_rsc_req_obj_biwt),
      .din_2_rsc_req_obj_bdwt(din_2_rsc_req_obj_bdwt)
    );
  READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_2_rsc_req_obj_din_2_rsc_req_wait_dp
      READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_2_rsc_req_obj_din_2_rsc_req_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .din_2_rsc_req_obj_oswt(din_2_rsc_req_obj_oswt),
      .din_2_rsc_req_obj_wen_comp(din_2_rsc_req_obj_wen_comp),
      .din_2_rsc_req_obj_biwt(din_2_rsc_req_obj_biwt),
      .din_2_rsc_req_obj_bdwt(din_2_rsc_req_obj_bdwt)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_3_rsc_req_obj
// ------------------------------------------------------------------


module READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_3_rsc_req_obj (
  clk, rst, din_3_rsc_req_vz, core_wen, core_wten, din_3_rsc_req_obj_oswt, din_3_rsc_req_obj_wen_comp
);
  input clk;
  input rst;
  input din_3_rsc_req_vz;
  input core_wen;
  input core_wten;
  input din_3_rsc_req_obj_oswt;
  output din_3_rsc_req_obj_wen_comp;


  // Interconnect Declarations
  wire din_3_rsc_req_obj_vd;
  wire din_3_rsc_req_obj_biwt;
  wire din_3_rsc_req_obj_bdwt;


  // Interconnect Declarations for Component Instantiations 
  mgc_in_sync_v1 #(.valid(32'sd1)) din_3_rsc_req_obj (
      .vd(din_3_rsc_req_obj_vd),
      .vz(din_3_rsc_req_vz)
    );
  READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_3_rsc_req_obj_din_3_rsc_req_wait_ctrl
      READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_3_rsc_req_obj_din_3_rsc_req_wait_ctrl_inst
      (
      .clk(clk),
      .rst(rst),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .din_3_rsc_req_obj_oswt(din_3_rsc_req_obj_oswt),
      .din_3_rsc_req_obj_vd(din_3_rsc_req_obj_vd),
      .din_3_rsc_req_obj_biwt(din_3_rsc_req_obj_biwt),
      .din_3_rsc_req_obj_bdwt(din_3_rsc_req_obj_bdwt)
    );
  READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_3_rsc_req_obj_din_3_rsc_req_wait_dp
      READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_3_rsc_req_obj_din_3_rsc_req_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .din_3_rsc_req_obj_oswt(din_3_rsc_req_obj_oswt),
      .din_3_rsc_req_obj_wen_comp(din_3_rsc_req_obj_wen_comp),
      .din_3_rsc_req_obj_biwt(din_3_rsc_req_obj_biwt),
      .din_3_rsc_req_obj_bdwt(din_3_rsc_req_obj_bdwt)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_3_rsc_rls_obj
// ------------------------------------------------------------------


module READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_3_rsc_rls_obj (
  din_3_rsc_rls_lz, core_wten, din_3_rsc_rls_obj_iswt0
);
  output din_3_rsc_rls_lz;
  input core_wten;
  input din_3_rsc_rls_obj_iswt0;


  // Interconnect Declarations
  wire din_3_rsc_rls_obj_ld_core_sct;


  // Interconnect Declarations for Component Instantiations 
  mgc_io_sync_v1 #(.valid(32'sd0)) din_3_rsc_rls_obj (
      .ld(din_3_rsc_rls_obj_ld_core_sct),
      .lz(din_3_rsc_rls_lz)
    );
  READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_3_rsc_rls_obj_din_3_rsc_rls_wait_ctrl
      READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_3_rsc_rls_obj_din_3_rsc_rls_wait_ctrl_inst
      (
      .core_wten(core_wten),
      .din_3_rsc_rls_obj_iswt0(din_3_rsc_rls_obj_iswt0),
      .din_3_rsc_rls_obj_ld_core_sct(din_3_rsc_rls_obj_ld_core_sct)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_2_rsc_rls_obj
// ------------------------------------------------------------------


module READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_2_rsc_rls_obj (
  din_2_rsc_rls_lz, core_wten, din_2_rsc_rls_obj_iswt0
);
  output din_2_rsc_rls_lz;
  input core_wten;
  input din_2_rsc_rls_obj_iswt0;


  // Interconnect Declarations
  wire din_2_rsc_rls_obj_ld_core_sct;


  // Interconnect Declarations for Component Instantiations 
  mgc_io_sync_v1 #(.valid(32'sd0)) din_2_rsc_rls_obj (
      .ld(din_2_rsc_rls_obj_ld_core_sct),
      .lz(din_2_rsc_rls_lz)
    );
  READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_2_rsc_rls_obj_din_2_rsc_rls_wait_ctrl
      READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_2_rsc_rls_obj_din_2_rsc_rls_wait_ctrl_inst
      (
      .core_wten(core_wten),
      .din_2_rsc_rls_obj_iswt0(din_2_rsc_rls_obj_iswt0),
      .din_2_rsc_rls_obj_ld_core_sct(din_2_rsc_rls_obj_ld_core_sct)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_1_rsc_rls_obj
// ------------------------------------------------------------------


module READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_1_rsc_rls_obj (
  din_1_rsc_rls_lz, core_wten, din_1_rsc_rls_obj_iswt0
);
  output din_1_rsc_rls_lz;
  input core_wten;
  input din_1_rsc_rls_obj_iswt0;


  // Interconnect Declarations
  wire din_1_rsc_rls_obj_ld_core_sct;


  // Interconnect Declarations for Component Instantiations 
  mgc_io_sync_v1 #(.valid(32'sd0)) din_1_rsc_rls_obj (
      .ld(din_1_rsc_rls_obj_ld_core_sct),
      .lz(din_1_rsc_rls_lz)
    );
  READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_1_rsc_rls_obj_din_1_rsc_rls_wait_ctrl
      READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_1_rsc_rls_obj_din_1_rsc_rls_wait_ctrl_inst
      (
      .core_wten(core_wten),
      .din_1_rsc_rls_obj_iswt0(din_1_rsc_rls_obj_iswt0),
      .din_1_rsc_rls_obj_ld_core_sct(din_1_rsc_rls_obj_ld_core_sct)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_0_rsc_rls_obj
// ------------------------------------------------------------------


module READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_0_rsc_rls_obj (
  din_0_rsc_rls_lz, core_wten, din_0_rsc_rls_obj_iswt0
);
  output din_0_rsc_rls_lz;
  input core_wten;
  input din_0_rsc_rls_obj_iswt0;


  // Interconnect Declarations
  wire din_0_rsc_rls_obj_ld_core_sct;


  // Interconnect Declarations for Component Instantiations 
  mgc_io_sync_v1 #(.valid(32'sd0)) din_0_rsc_rls_obj (
      .ld(din_0_rsc_rls_obj_ld_core_sct),
      .lz(din_0_rsc_rls_lz)
    );
  READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_0_rsc_rls_obj_din_0_rsc_rls_wait_ctrl
      READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_0_rsc_rls_obj_din_0_rsc_rls_wait_ctrl_inst
      (
      .core_wten(core_wten),
      .din_0_rsc_rls_obj_iswt0(din_0_rsc_rls_obj_iswt0),
      .din_0_rsc_rls_obj_ld_core_sct(din_0_rsc_rls_obj_ld_core_sct)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_dout_rsci
// ------------------------------------------------------------------


module READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_dout_rsci (
  clk, rst, dout_rsc_z, dout_rsc_vz, dout_rsc_lz, core_wen, core_wten, dout_rsci_oswt,
      dout_rsci_wen_comp, dout_rsci_d
);
  input clk;
  input rst;
  output [127:0] dout_rsc_z;
  input dout_rsc_vz;
  output dout_rsc_lz;
  input core_wen;
  input core_wten;
  input dout_rsci_oswt;
  output dout_rsci_wen_comp;
  input [127:0] dout_rsci_d;


  // Interconnect Declarations
  wire dout_rsci_biwt;
  wire dout_rsci_bdwt;
  wire dout_rsci_ld_core_sct;
  wire dout_rsci_vd;


  // Interconnect Declarations for Component Instantiations 
  mgc_out_stdreg_wait_v1 #(.rscid(32'sd14),
  .width(32'sd128)) dout_rsci (
      .ld(dout_rsci_ld_core_sct),
      .vd(dout_rsci_vd),
      .d(dout_rsci_d),
      .lz(dout_rsc_lz),
      .vz(dout_rsc_vz),
      .z(dout_rsc_z)
    );
  READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_dout_rsci_dout_wait_ctrl READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_dout_rsci_dout_wait_ctrl_inst
      (
      .clk(clk),
      .rst(rst),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .dout_rsci_oswt(dout_rsci_oswt),
      .dout_rsci_biwt(dout_rsci_biwt),
      .dout_rsci_bdwt(dout_rsci_bdwt),
      .dout_rsci_ld_core_sct(dout_rsci_ld_core_sct),
      .dout_rsci_vd(dout_rsci_vd)
    );
  READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_dout_rsci_dout_wait_dp READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_dout_rsci_dout_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .dout_rsci_oswt(dout_rsci_oswt),
      .dout_rsci_wen_comp(dout_rsci_wen_comp),
      .dout_rsci_biwt(dout_rsci_biwt),
      .dout_rsci_bdwt(dout_rsci_bdwt)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_3_rsci_1
// ------------------------------------------------------------------


module READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_3_rsci_1 (
  clk, rst, din_3_rsci_addr_d, din_3_rsci_re_d, din_3_rsci_data_out_d, core_wen,
      core_wten, din_3_rsci_oswt, din_3_rsci_addr_d_core, din_3_rsci_re_d_core_psct,
      din_3_rsci_data_out_d_mxwt, din_3_rsci_oswt_pff
);
  input clk;
  input rst;
  output [6:0] din_3_rsci_addr_d;
  output [1:0] din_3_rsci_re_d;
  input [31:0] din_3_rsci_data_out_d;
  input core_wen;
  input core_wten;
  input din_3_rsci_oswt;
  input [13:0] din_3_rsci_addr_d_core;
  input [1:0] din_3_rsci_re_d_core_psct;
  output [15:0] din_3_rsci_data_out_d_mxwt;
  input din_3_rsci_oswt_pff;


  // Interconnect Declarations
  wire din_3_rsci_biwt;
  wire din_3_rsci_bdwt;
  wire [1:0] din_3_rsci_re_d_core_sct;
  wire [15:0] din_3_rsci_data_out_d_mxwt_pconst;
  wire [6:0] din_3_rsci_addr_d_reg;
  wire [1:0] din_3_rsci_re_d_reg;


  // Interconnect Declarations for Component Instantiations 
  wire [1:0] nl_READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_3_rsci_1_din_3_rsc_wait_ctrl_inst_din_3_rsci_re_d_core_psct;
  assign nl_READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_3_rsci_1_din_3_rsc_wait_ctrl_inst_din_3_rsci_re_d_core_psct
      = {1'b0 , (din_3_rsci_re_d_core_psct[0])};
  wire [13:0] nl_READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_3_rsci_1_din_3_rsc_wait_dp_inst_din_3_rsci_addr_d_core;
  assign nl_READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_3_rsci_1_din_3_rsc_wait_dp_inst_din_3_rsci_addr_d_core
      = {7'b0 , (din_3_rsci_addr_d_core[6:0])};
  READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_3_rsci_1_din_3_rsc_wait_ctrl READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_3_rsci_1_din_3_rsc_wait_ctrl_inst
      (
      .core_wen(core_wen),
      .core_wten(core_wten),
      .din_3_rsci_oswt(din_3_rsci_oswt),
      .din_3_rsci_re_d_core_psct(nl_READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_3_rsci_1_din_3_rsc_wait_ctrl_inst_din_3_rsci_re_d_core_psct[1:0]),
      .din_3_rsci_biwt(din_3_rsci_biwt),
      .din_3_rsci_bdwt(din_3_rsci_bdwt),
      .din_3_rsci_re_d_core_sct(din_3_rsci_re_d_core_sct),
      .din_3_rsci_oswt_pff(din_3_rsci_oswt_pff)
    );
  READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_3_rsci_1_din_3_rsc_wait_dp READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_3_rsci_1_din_3_rsc_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .din_3_rsci_addr_d(din_3_rsci_addr_d_reg),
      .din_3_rsci_re_d(din_3_rsci_re_d_reg),
      .din_3_rsci_data_out_d(din_3_rsci_data_out_d),
      .din_3_rsci_addr_d_core(nl_READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_3_rsci_1_din_3_rsc_wait_dp_inst_din_3_rsci_addr_d_core[13:0]),
      .din_3_rsci_data_out_d_mxwt(din_3_rsci_data_out_d_mxwt_pconst),
      .din_3_rsci_biwt(din_3_rsci_biwt),
      .din_3_rsci_bdwt(din_3_rsci_bdwt),
      .din_3_rsci_re_d_core_sct(din_3_rsci_re_d_core_sct)
    );
  assign din_3_rsci_data_out_d_mxwt = din_3_rsci_data_out_d_mxwt_pconst;
  assign din_3_rsci_re_d = din_3_rsci_re_d_reg;
  assign din_3_rsci_addr_d = din_3_rsci_addr_d_reg;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_2_rsci_1
// ------------------------------------------------------------------


module READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_2_rsci_1 (
  clk, rst, din_2_rsci_addr_d, din_2_rsci_re_d, din_2_rsci_data_out_d, core_wen,
      core_wten, din_2_rsci_oswt, din_2_rsci_addr_d_core, din_2_rsci_re_d_core_psct,
      din_2_rsci_data_out_d_mxwt, din_2_rsci_oswt_pff
);
  input clk;
  input rst;
  output [6:0] din_2_rsci_addr_d;
  output [1:0] din_2_rsci_re_d;
  input [31:0] din_2_rsci_data_out_d;
  input core_wen;
  input core_wten;
  input din_2_rsci_oswt;
  input [13:0] din_2_rsci_addr_d_core;
  input [1:0] din_2_rsci_re_d_core_psct;
  output [15:0] din_2_rsci_data_out_d_mxwt;
  input din_2_rsci_oswt_pff;


  // Interconnect Declarations
  wire din_2_rsci_biwt;
  wire din_2_rsci_bdwt;
  wire [1:0] din_2_rsci_re_d_core_sct;
  wire [15:0] din_2_rsci_data_out_d_mxwt_pconst;
  wire [6:0] din_2_rsci_addr_d_reg;
  wire [1:0] din_2_rsci_re_d_reg;


  // Interconnect Declarations for Component Instantiations 
  wire [1:0] nl_READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_2_rsci_1_din_2_rsc_wait_ctrl_inst_din_2_rsci_re_d_core_psct;
  assign nl_READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_2_rsci_1_din_2_rsc_wait_ctrl_inst_din_2_rsci_re_d_core_psct
      = {1'b0 , (din_2_rsci_re_d_core_psct[0])};
  wire [13:0] nl_READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_2_rsci_1_din_2_rsc_wait_dp_inst_din_2_rsci_addr_d_core;
  assign nl_READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_2_rsci_1_din_2_rsc_wait_dp_inst_din_2_rsci_addr_d_core
      = {7'b0 , (din_2_rsci_addr_d_core[6:0])};
  READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_2_rsci_1_din_2_rsc_wait_ctrl READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_2_rsci_1_din_2_rsc_wait_ctrl_inst
      (
      .core_wen(core_wen),
      .core_wten(core_wten),
      .din_2_rsci_oswt(din_2_rsci_oswt),
      .din_2_rsci_re_d_core_psct(nl_READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_2_rsci_1_din_2_rsc_wait_ctrl_inst_din_2_rsci_re_d_core_psct[1:0]),
      .din_2_rsci_biwt(din_2_rsci_biwt),
      .din_2_rsci_bdwt(din_2_rsci_bdwt),
      .din_2_rsci_re_d_core_sct(din_2_rsci_re_d_core_sct),
      .din_2_rsci_oswt_pff(din_2_rsci_oswt_pff)
    );
  READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_2_rsci_1_din_2_rsc_wait_dp READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_2_rsci_1_din_2_rsc_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .din_2_rsci_addr_d(din_2_rsci_addr_d_reg),
      .din_2_rsci_re_d(din_2_rsci_re_d_reg),
      .din_2_rsci_data_out_d(din_2_rsci_data_out_d),
      .din_2_rsci_addr_d_core(nl_READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_2_rsci_1_din_2_rsc_wait_dp_inst_din_2_rsci_addr_d_core[13:0]),
      .din_2_rsci_data_out_d_mxwt(din_2_rsci_data_out_d_mxwt_pconst),
      .din_2_rsci_biwt(din_2_rsci_biwt),
      .din_2_rsci_bdwt(din_2_rsci_bdwt),
      .din_2_rsci_re_d_core_sct(din_2_rsci_re_d_core_sct)
    );
  assign din_2_rsci_data_out_d_mxwt = din_2_rsci_data_out_d_mxwt_pconst;
  assign din_2_rsci_re_d = din_2_rsci_re_d_reg;
  assign din_2_rsci_addr_d = din_2_rsci_addr_d_reg;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_1_rsci_1
// ------------------------------------------------------------------


module READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_1_rsci_1 (
  clk, rst, din_1_rsci_addr_d, din_1_rsci_re_d, din_1_rsci_data_out_d, core_wen,
      core_wten, din_1_rsci_oswt, din_1_rsci_addr_d_core, din_1_rsci_re_d_core_psct,
      din_1_rsci_data_out_d_mxwt, din_1_rsci_oswt_pff
);
  input clk;
  input rst;
  output [6:0] din_1_rsci_addr_d;
  output [1:0] din_1_rsci_re_d;
  input [31:0] din_1_rsci_data_out_d;
  input core_wen;
  input core_wten;
  input din_1_rsci_oswt;
  input [13:0] din_1_rsci_addr_d_core;
  input [1:0] din_1_rsci_re_d_core_psct;
  output [15:0] din_1_rsci_data_out_d_mxwt;
  input din_1_rsci_oswt_pff;


  // Interconnect Declarations
  wire din_1_rsci_biwt;
  wire din_1_rsci_bdwt;
  wire [1:0] din_1_rsci_re_d_core_sct;
  wire [15:0] din_1_rsci_data_out_d_mxwt_pconst;
  wire [6:0] din_1_rsci_addr_d_reg;
  wire [1:0] din_1_rsci_re_d_reg;


  // Interconnect Declarations for Component Instantiations 
  wire [1:0] nl_READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_1_rsci_1_din_1_rsc_wait_ctrl_inst_din_1_rsci_re_d_core_psct;
  assign nl_READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_1_rsci_1_din_1_rsc_wait_ctrl_inst_din_1_rsci_re_d_core_psct
      = {1'b0 , (din_1_rsci_re_d_core_psct[0])};
  wire [13:0] nl_READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_1_rsci_1_din_1_rsc_wait_dp_inst_din_1_rsci_addr_d_core;
  assign nl_READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_1_rsci_1_din_1_rsc_wait_dp_inst_din_1_rsci_addr_d_core
      = {7'b0 , (din_1_rsci_addr_d_core[6:0])};
  READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_1_rsci_1_din_1_rsc_wait_ctrl READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_1_rsci_1_din_1_rsc_wait_ctrl_inst
      (
      .core_wen(core_wen),
      .core_wten(core_wten),
      .din_1_rsci_oswt(din_1_rsci_oswt),
      .din_1_rsci_re_d_core_psct(nl_READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_1_rsci_1_din_1_rsc_wait_ctrl_inst_din_1_rsci_re_d_core_psct[1:0]),
      .din_1_rsci_biwt(din_1_rsci_biwt),
      .din_1_rsci_bdwt(din_1_rsci_bdwt),
      .din_1_rsci_re_d_core_sct(din_1_rsci_re_d_core_sct),
      .din_1_rsci_oswt_pff(din_1_rsci_oswt_pff)
    );
  READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_1_rsci_1_din_1_rsc_wait_dp READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_1_rsci_1_din_1_rsc_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .din_1_rsci_addr_d(din_1_rsci_addr_d_reg),
      .din_1_rsci_re_d(din_1_rsci_re_d_reg),
      .din_1_rsci_data_out_d(din_1_rsci_data_out_d),
      .din_1_rsci_addr_d_core(nl_READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_1_rsci_1_din_1_rsc_wait_dp_inst_din_1_rsci_addr_d_core[13:0]),
      .din_1_rsci_data_out_d_mxwt(din_1_rsci_data_out_d_mxwt_pconst),
      .din_1_rsci_biwt(din_1_rsci_biwt),
      .din_1_rsci_bdwt(din_1_rsci_bdwt),
      .din_1_rsci_re_d_core_sct(din_1_rsci_re_d_core_sct)
    );
  assign din_1_rsci_data_out_d_mxwt = din_1_rsci_data_out_d_mxwt_pconst;
  assign din_1_rsci_re_d = din_1_rsci_re_d_reg;
  assign din_1_rsci_addr_d = din_1_rsci_addr_d_reg;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_0_rsci_1
// ------------------------------------------------------------------


module READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_0_rsci_1 (
  clk, rst, din_0_rsci_addr_d, din_0_rsci_re_d, din_0_rsci_data_out_d, core_wen,
      din_0_rsci_oswt, din_0_rsci_addr_d_core, din_0_rsci_re_d_core_psct, din_0_rsci_data_out_d_mxwt,
      core_wten, din_0_rsci_oswt_pff
);
  input clk;
  input rst;
  output [6:0] din_0_rsci_addr_d;
  output [1:0] din_0_rsci_re_d;
  input [31:0] din_0_rsci_data_out_d;
  input core_wen;
  input din_0_rsci_oswt;
  input [13:0] din_0_rsci_addr_d_core;
  input [1:0] din_0_rsci_re_d_core_psct;
  output [15:0] din_0_rsci_data_out_d_mxwt;
  input core_wten;
  input din_0_rsci_oswt_pff;


  // Interconnect Declarations
  wire din_0_rsci_biwt;
  wire din_0_rsci_bdwt;
  wire [1:0] din_0_rsci_re_d_core_sct;
  wire [15:0] din_0_rsci_data_out_d_mxwt_pconst;
  wire [6:0] din_0_rsci_addr_d_reg;
  wire [1:0] din_0_rsci_re_d_reg;


  // Interconnect Declarations for Component Instantiations 
  wire [1:0] nl_READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_0_rsci_1_din_0_rsc_wait_ctrl_inst_din_0_rsci_re_d_core_psct;
  assign nl_READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_0_rsci_1_din_0_rsc_wait_ctrl_inst_din_0_rsci_re_d_core_psct
      = {1'b0 , (din_0_rsci_re_d_core_psct[0])};
  wire [13:0] nl_READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_0_rsci_1_din_0_rsc_wait_dp_inst_din_0_rsci_addr_d_core;
  assign nl_READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_0_rsci_1_din_0_rsc_wait_dp_inst_din_0_rsci_addr_d_core
      = {7'b0 , (din_0_rsci_addr_d_core[6:0])};
  READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_0_rsci_1_din_0_rsc_wait_ctrl READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_0_rsci_1_din_0_rsc_wait_ctrl_inst
      (
      .core_wen(core_wen),
      .din_0_rsci_oswt(din_0_rsci_oswt),
      .din_0_rsci_re_d_core_psct(nl_READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_0_rsci_1_din_0_rsc_wait_ctrl_inst_din_0_rsci_re_d_core_psct[1:0]),
      .core_wten(core_wten),
      .din_0_rsci_biwt(din_0_rsci_biwt),
      .din_0_rsci_bdwt(din_0_rsci_bdwt),
      .din_0_rsci_re_d_core_sct(din_0_rsci_re_d_core_sct),
      .din_0_rsci_oswt_pff(din_0_rsci_oswt_pff)
    );
  READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_0_rsci_1_din_0_rsc_wait_dp READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_0_rsci_1_din_0_rsc_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .din_0_rsci_addr_d(din_0_rsci_addr_d_reg),
      .din_0_rsci_re_d(din_0_rsci_re_d_reg),
      .din_0_rsci_data_out_d(din_0_rsci_data_out_d),
      .din_0_rsci_addr_d_core(nl_READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_0_rsci_1_din_0_rsc_wait_dp_inst_din_0_rsci_addr_d_core[13:0]),
      .din_0_rsci_data_out_d_mxwt(din_0_rsci_data_out_d_mxwt_pconst),
      .din_0_rsci_biwt(din_0_rsci_biwt),
      .din_0_rsci_bdwt(din_0_rsci_bdwt),
      .din_0_rsci_re_d_core_sct(din_0_rsci_re_d_core_sct)
    );
  assign din_0_rsci_data_out_d_mxwt = din_0_rsci_data_out_d_mxwt_pconst;
  assign din_0_rsci_re_d = din_0_rsci_re_d_reg;
  assign din_0_rsci_addr_d = din_0_rsci_addr_d_reg;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_0_rsc_req_obj
// ------------------------------------------------------------------


module WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_0_rsc_req_obj (
  clk, rst, dout_0_rsc_req_vz, core_wen, core_wten, dout_0_rsc_req_obj_oswt, dout_0_rsc_req_obj_wen_comp
);
  input clk;
  input rst;
  input dout_0_rsc_req_vz;
  input core_wen;
  input core_wten;
  input dout_0_rsc_req_obj_oswt;
  output dout_0_rsc_req_obj_wen_comp;


  // Interconnect Declarations
  wire dout_0_rsc_req_obj_vd;
  wire dout_0_rsc_req_obj_biwt;
  wire dout_0_rsc_req_obj_bdwt;


  // Interconnect Declarations for Component Instantiations 
  mgc_in_sync_v1 #(.valid(32'sd1)) dout_0_rsc_req_obj (
      .vd(dout_0_rsc_req_obj_vd),
      .vz(dout_0_rsc_req_vz)
    );
  WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_0_rsc_req_obj_dout_0_rsc_req_wait_ctrl
      WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_0_rsc_req_obj_dout_0_rsc_req_wait_ctrl_inst
      (
      .clk(clk),
      .rst(rst),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .dout_0_rsc_req_obj_oswt(dout_0_rsc_req_obj_oswt),
      .dout_0_rsc_req_obj_vd(dout_0_rsc_req_obj_vd),
      .dout_0_rsc_req_obj_biwt(dout_0_rsc_req_obj_biwt),
      .dout_0_rsc_req_obj_bdwt(dout_0_rsc_req_obj_bdwt)
    );
  WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_0_rsc_req_obj_dout_0_rsc_req_wait_dp
      WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_0_rsc_req_obj_dout_0_rsc_req_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .dout_0_rsc_req_obj_oswt(dout_0_rsc_req_obj_oswt),
      .dout_0_rsc_req_obj_wen_comp(dout_0_rsc_req_obj_wen_comp),
      .dout_0_rsc_req_obj_biwt(dout_0_rsc_req_obj_biwt),
      .dout_0_rsc_req_obj_bdwt(dout_0_rsc_req_obj_bdwt)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_1_rsc_req_obj
// ------------------------------------------------------------------


module WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_1_rsc_req_obj (
  clk, rst, dout_1_rsc_req_vz, core_wen, core_wten, dout_1_rsc_req_obj_oswt, dout_1_rsc_req_obj_wen_comp
);
  input clk;
  input rst;
  input dout_1_rsc_req_vz;
  input core_wen;
  input core_wten;
  input dout_1_rsc_req_obj_oswt;
  output dout_1_rsc_req_obj_wen_comp;


  // Interconnect Declarations
  wire dout_1_rsc_req_obj_vd;
  wire dout_1_rsc_req_obj_biwt;
  wire dout_1_rsc_req_obj_bdwt;


  // Interconnect Declarations for Component Instantiations 
  mgc_in_sync_v1 #(.valid(32'sd1)) dout_1_rsc_req_obj (
      .vd(dout_1_rsc_req_obj_vd),
      .vz(dout_1_rsc_req_vz)
    );
  WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_1_rsc_req_obj_dout_1_rsc_req_wait_ctrl
      WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_1_rsc_req_obj_dout_1_rsc_req_wait_ctrl_inst
      (
      .clk(clk),
      .rst(rst),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .dout_1_rsc_req_obj_oswt(dout_1_rsc_req_obj_oswt),
      .dout_1_rsc_req_obj_vd(dout_1_rsc_req_obj_vd),
      .dout_1_rsc_req_obj_biwt(dout_1_rsc_req_obj_biwt),
      .dout_1_rsc_req_obj_bdwt(dout_1_rsc_req_obj_bdwt)
    );
  WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_1_rsc_req_obj_dout_1_rsc_req_wait_dp
      WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_1_rsc_req_obj_dout_1_rsc_req_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .dout_1_rsc_req_obj_oswt(dout_1_rsc_req_obj_oswt),
      .dout_1_rsc_req_obj_wen_comp(dout_1_rsc_req_obj_wen_comp),
      .dout_1_rsc_req_obj_biwt(dout_1_rsc_req_obj_biwt),
      .dout_1_rsc_req_obj_bdwt(dout_1_rsc_req_obj_bdwt)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_2_rsc_req_obj
// ------------------------------------------------------------------


module WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_2_rsc_req_obj (
  clk, rst, dout_2_rsc_req_vz, core_wen, core_wten, dout_2_rsc_req_obj_oswt, dout_2_rsc_req_obj_wen_comp
);
  input clk;
  input rst;
  input dout_2_rsc_req_vz;
  input core_wen;
  input core_wten;
  input dout_2_rsc_req_obj_oswt;
  output dout_2_rsc_req_obj_wen_comp;


  // Interconnect Declarations
  wire dout_2_rsc_req_obj_vd;
  wire dout_2_rsc_req_obj_biwt;
  wire dout_2_rsc_req_obj_bdwt;


  // Interconnect Declarations for Component Instantiations 
  mgc_in_sync_v1 #(.valid(32'sd1)) dout_2_rsc_req_obj (
      .vd(dout_2_rsc_req_obj_vd),
      .vz(dout_2_rsc_req_vz)
    );
  WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_2_rsc_req_obj_dout_2_rsc_req_wait_ctrl
      WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_2_rsc_req_obj_dout_2_rsc_req_wait_ctrl_inst
      (
      .clk(clk),
      .rst(rst),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .dout_2_rsc_req_obj_oswt(dout_2_rsc_req_obj_oswt),
      .dout_2_rsc_req_obj_vd(dout_2_rsc_req_obj_vd),
      .dout_2_rsc_req_obj_biwt(dout_2_rsc_req_obj_biwt),
      .dout_2_rsc_req_obj_bdwt(dout_2_rsc_req_obj_bdwt)
    );
  WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_2_rsc_req_obj_dout_2_rsc_req_wait_dp
      WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_2_rsc_req_obj_dout_2_rsc_req_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .dout_2_rsc_req_obj_oswt(dout_2_rsc_req_obj_oswt),
      .dout_2_rsc_req_obj_wen_comp(dout_2_rsc_req_obj_wen_comp),
      .dout_2_rsc_req_obj_biwt(dout_2_rsc_req_obj_biwt),
      .dout_2_rsc_req_obj_bdwt(dout_2_rsc_req_obj_bdwt)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_3_rsc_req_obj
// ------------------------------------------------------------------


module WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_3_rsc_req_obj (
  clk, rst, dout_3_rsc_req_vz, core_wen, core_wten, dout_3_rsc_req_obj_oswt, dout_3_rsc_req_obj_wen_comp
);
  input clk;
  input rst;
  input dout_3_rsc_req_vz;
  input core_wen;
  input core_wten;
  input dout_3_rsc_req_obj_oswt;
  output dout_3_rsc_req_obj_wen_comp;


  // Interconnect Declarations
  wire dout_3_rsc_req_obj_vd;
  wire dout_3_rsc_req_obj_biwt;
  wire dout_3_rsc_req_obj_bdwt;


  // Interconnect Declarations for Component Instantiations 
  mgc_in_sync_v1 #(.valid(32'sd1)) dout_3_rsc_req_obj (
      .vd(dout_3_rsc_req_obj_vd),
      .vz(dout_3_rsc_req_vz)
    );
  WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_3_rsc_req_obj_dout_3_rsc_req_wait_ctrl
      WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_3_rsc_req_obj_dout_3_rsc_req_wait_ctrl_inst
      (
      .clk(clk),
      .rst(rst),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .dout_3_rsc_req_obj_oswt(dout_3_rsc_req_obj_oswt),
      .dout_3_rsc_req_obj_vd(dout_3_rsc_req_obj_vd),
      .dout_3_rsc_req_obj_biwt(dout_3_rsc_req_obj_biwt),
      .dout_3_rsc_req_obj_bdwt(dout_3_rsc_req_obj_bdwt)
    );
  WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_3_rsc_req_obj_dout_3_rsc_req_wait_dp
      WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_3_rsc_req_obj_dout_3_rsc_req_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .dout_3_rsc_req_obj_oswt(dout_3_rsc_req_obj_oswt),
      .dout_3_rsc_req_obj_wen_comp(dout_3_rsc_req_obj_wen_comp),
      .dout_3_rsc_req_obj_biwt(dout_3_rsc_req_obj_biwt),
      .dout_3_rsc_req_obj_bdwt(dout_3_rsc_req_obj_bdwt)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_0_rsc_rls_obj
// ------------------------------------------------------------------


module WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_0_rsc_rls_obj (
  dout_0_rsc_rls_lz, core_wten, dout_0_rsc_rls_obj_iswt0
);
  output dout_0_rsc_rls_lz;
  input core_wten;
  input dout_0_rsc_rls_obj_iswt0;


  // Interconnect Declarations
  wire dout_0_rsc_rls_obj_ld_core_sct;


  // Interconnect Declarations for Component Instantiations 
  mgc_io_sync_v1 #(.valid(32'sd0)) dout_0_rsc_rls_obj (
      .ld(dout_0_rsc_rls_obj_ld_core_sct),
      .lz(dout_0_rsc_rls_lz)
    );
  WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_0_rsc_rls_obj_dout_0_rsc_rls_wait_ctrl
      WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_0_rsc_rls_obj_dout_0_rsc_rls_wait_ctrl_inst
      (
      .core_wten(core_wten),
      .dout_0_rsc_rls_obj_iswt0(dout_0_rsc_rls_obj_iswt0),
      .dout_0_rsc_rls_obj_ld_core_sct(dout_0_rsc_rls_obj_ld_core_sct)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_1_rsc_rls_obj
// ------------------------------------------------------------------


module WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_1_rsc_rls_obj (
  dout_1_rsc_rls_lz, core_wten, dout_1_rsc_rls_obj_iswt0
);
  output dout_1_rsc_rls_lz;
  input core_wten;
  input dout_1_rsc_rls_obj_iswt0;


  // Interconnect Declarations
  wire dout_1_rsc_rls_obj_ld_core_sct;


  // Interconnect Declarations for Component Instantiations 
  mgc_io_sync_v1 #(.valid(32'sd0)) dout_1_rsc_rls_obj (
      .ld(dout_1_rsc_rls_obj_ld_core_sct),
      .lz(dout_1_rsc_rls_lz)
    );
  WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_1_rsc_rls_obj_dout_1_rsc_rls_wait_ctrl
      WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_1_rsc_rls_obj_dout_1_rsc_rls_wait_ctrl_inst
      (
      .core_wten(core_wten),
      .dout_1_rsc_rls_obj_iswt0(dout_1_rsc_rls_obj_iswt0),
      .dout_1_rsc_rls_obj_ld_core_sct(dout_1_rsc_rls_obj_ld_core_sct)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_2_rsc_rls_obj
// ------------------------------------------------------------------


module WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_2_rsc_rls_obj (
  dout_2_rsc_rls_lz, core_wten, dout_2_rsc_rls_obj_iswt0
);
  output dout_2_rsc_rls_lz;
  input core_wten;
  input dout_2_rsc_rls_obj_iswt0;


  // Interconnect Declarations
  wire dout_2_rsc_rls_obj_ld_core_sct;


  // Interconnect Declarations for Component Instantiations 
  mgc_io_sync_v1 #(.valid(32'sd0)) dout_2_rsc_rls_obj (
      .ld(dout_2_rsc_rls_obj_ld_core_sct),
      .lz(dout_2_rsc_rls_lz)
    );
  WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_2_rsc_rls_obj_dout_2_rsc_rls_wait_ctrl
      WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_2_rsc_rls_obj_dout_2_rsc_rls_wait_ctrl_inst
      (
      .core_wten(core_wten),
      .dout_2_rsc_rls_obj_iswt0(dout_2_rsc_rls_obj_iswt0),
      .dout_2_rsc_rls_obj_ld_core_sct(dout_2_rsc_rls_obj_ld_core_sct)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_3_rsc_rls_obj
// ------------------------------------------------------------------


module WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_3_rsc_rls_obj (
  dout_3_rsc_rls_lz, core_wten, dout_3_rsc_rls_obj_iswt0
);
  output dout_3_rsc_rls_lz;
  input core_wten;
  input dout_3_rsc_rls_obj_iswt0;


  // Interconnect Declarations
  wire dout_3_rsc_rls_obj_ld_core_sct;


  // Interconnect Declarations for Component Instantiations 
  mgc_io_sync_v1 #(.valid(32'sd0)) dout_3_rsc_rls_obj (
      .ld(dout_3_rsc_rls_obj_ld_core_sct),
      .lz(dout_3_rsc_rls_lz)
    );
  WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_3_rsc_rls_obj_dout_3_rsc_rls_wait_ctrl
      WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_3_rsc_rls_obj_dout_3_rsc_rls_wait_ctrl_inst
      (
      .core_wten(core_wten),
      .dout_3_rsc_rls_obj_iswt0(dout_3_rsc_rls_obj_iswt0),
      .dout_3_rsc_rls_obj_ld_core_sct(dout_3_rsc_rls_obj_ld_core_sct)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_3_rsci_1
// ------------------------------------------------------------------


module WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_3_rsci_1 (
  dout_3_rsci_data_in_d, dout_3_rsci_addr_d, dout_3_rsci_we_d, core_wten, dout_3_rsci_iswt0,
      dout_3_rsci_data_in_d_core, dout_3_rsci_addr_d_core, dout_3_rsci_we_d_core_psct
);
  output [63:0] dout_3_rsci_data_in_d;
  output [7:0] dout_3_rsci_addr_d;
  output [1:0] dout_3_rsci_we_d;
  input core_wten;
  input dout_3_rsci_iswt0;
  input [127:0] dout_3_rsci_data_in_d_core;
  input [15:0] dout_3_rsci_addr_d_core;
  input [1:0] dout_3_rsci_we_d_core_psct;


  // Interconnect Declarations
  wire [1:0] dout_3_rsci_we_d_core_sct;


  // Interconnect Declarations for Component Instantiations 
  wire [1:0] nl_WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_3_rsci_1_dout_3_rsc_wait_ctrl_inst_dout_3_rsci_we_d_core_psct;
  assign nl_WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_3_rsci_1_dout_3_rsc_wait_ctrl_inst_dout_3_rsci_we_d_core_psct
      = {1'b0 , (dout_3_rsci_we_d_core_psct[0])};
  WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_3_rsci_1_dout_3_rsc_wait_ctrl WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_3_rsci_1_dout_3_rsc_wait_ctrl_inst
      (
      .core_wten(core_wten),
      .dout_3_rsci_iswt0(dout_3_rsci_iswt0),
      .dout_3_rsci_we_d_core_psct(nl_WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_3_rsci_1_dout_3_rsc_wait_ctrl_inst_dout_3_rsci_we_d_core_psct[1:0]),
      .dout_3_rsci_we_d_core_sct(dout_3_rsci_we_d_core_sct)
    );
  assign dout_3_rsci_we_d = ~ dout_3_rsci_we_d_core_sct;
  assign dout_3_rsci_data_in_d = dout_3_rsci_data_in_d_core[63:0];
  assign dout_3_rsci_addr_d = dout_3_rsci_addr_d_core[7:0];
endmodule

// ------------------------------------------------------------------
//  Design Unit:    WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_2_rsci_1
// ------------------------------------------------------------------


module WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_2_rsci_1 (
  dout_2_rsci_data_in_d, dout_2_rsci_addr_d, dout_2_rsci_we_d, core_wten, dout_2_rsci_iswt0,
      dout_2_rsci_data_in_d_core, dout_2_rsci_addr_d_core, dout_2_rsci_we_d_core_psct
);
  output [63:0] dout_2_rsci_data_in_d;
  output [7:0] dout_2_rsci_addr_d;
  output [1:0] dout_2_rsci_we_d;
  input core_wten;
  input dout_2_rsci_iswt0;
  input [127:0] dout_2_rsci_data_in_d_core;
  input [15:0] dout_2_rsci_addr_d_core;
  input [1:0] dout_2_rsci_we_d_core_psct;


  // Interconnect Declarations
  wire [1:0] dout_2_rsci_we_d_core_sct;


  // Interconnect Declarations for Component Instantiations 
  wire [1:0] nl_WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_2_rsci_1_dout_2_rsc_wait_ctrl_inst_dout_2_rsci_we_d_core_psct;
  assign nl_WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_2_rsci_1_dout_2_rsc_wait_ctrl_inst_dout_2_rsci_we_d_core_psct
      = {1'b0 , (dout_2_rsci_we_d_core_psct[0])};
  WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_2_rsci_1_dout_2_rsc_wait_ctrl WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_2_rsci_1_dout_2_rsc_wait_ctrl_inst
      (
      .core_wten(core_wten),
      .dout_2_rsci_iswt0(dout_2_rsci_iswt0),
      .dout_2_rsci_we_d_core_psct(nl_WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_2_rsci_1_dout_2_rsc_wait_ctrl_inst_dout_2_rsci_we_d_core_psct[1:0]),
      .dout_2_rsci_we_d_core_sct(dout_2_rsci_we_d_core_sct)
    );
  assign dout_2_rsci_we_d = ~ dout_2_rsci_we_d_core_sct;
  assign dout_2_rsci_data_in_d = dout_2_rsci_data_in_d_core[63:0];
  assign dout_2_rsci_addr_d = dout_2_rsci_addr_d_core[7:0];
endmodule

// ------------------------------------------------------------------
//  Design Unit:    WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_1_rsci_1
// ------------------------------------------------------------------


module WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_1_rsci_1 (
  dout_1_rsci_data_in_d, dout_1_rsci_addr_d, dout_1_rsci_we_d, core_wten, dout_1_rsci_iswt0,
      dout_1_rsci_data_in_d_core, dout_1_rsci_addr_d_core, dout_1_rsci_we_d_core_psct
);
  output [63:0] dout_1_rsci_data_in_d;
  output [7:0] dout_1_rsci_addr_d;
  output [1:0] dout_1_rsci_we_d;
  input core_wten;
  input dout_1_rsci_iswt0;
  input [127:0] dout_1_rsci_data_in_d_core;
  input [15:0] dout_1_rsci_addr_d_core;
  input [1:0] dout_1_rsci_we_d_core_psct;


  // Interconnect Declarations
  wire [1:0] dout_1_rsci_we_d_core_sct;


  // Interconnect Declarations for Component Instantiations 
  wire [1:0] nl_WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_1_rsci_1_dout_1_rsc_wait_ctrl_inst_dout_1_rsci_we_d_core_psct;
  assign nl_WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_1_rsci_1_dout_1_rsc_wait_ctrl_inst_dout_1_rsci_we_d_core_psct
      = {1'b0 , (dout_1_rsci_we_d_core_psct[0])};
  WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_1_rsci_1_dout_1_rsc_wait_ctrl WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_1_rsci_1_dout_1_rsc_wait_ctrl_inst
      (
      .core_wten(core_wten),
      .dout_1_rsci_iswt0(dout_1_rsci_iswt0),
      .dout_1_rsci_we_d_core_psct(nl_WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_1_rsci_1_dout_1_rsc_wait_ctrl_inst_dout_1_rsci_we_d_core_psct[1:0]),
      .dout_1_rsci_we_d_core_sct(dout_1_rsci_we_d_core_sct)
    );
  assign dout_1_rsci_we_d = ~ dout_1_rsci_we_d_core_sct;
  assign dout_1_rsci_data_in_d = dout_1_rsci_data_in_d_core[63:0];
  assign dout_1_rsci_addr_d = dout_1_rsci_addr_d_core[7:0];
endmodule

// ------------------------------------------------------------------
//  Design Unit:    WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_0_rsci_1
// ------------------------------------------------------------------


module WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_0_rsci_1 (
  dout_0_rsci_data_in_d, dout_0_rsci_addr_d, dout_0_rsci_we_d, core_wten, dout_0_rsci_iswt0,
      dout_0_rsci_data_in_d_core, dout_0_rsci_addr_d_core, dout_0_rsci_we_d_core_psct
);
  output [63:0] dout_0_rsci_data_in_d;
  output [7:0] dout_0_rsci_addr_d;
  output [1:0] dout_0_rsci_we_d;
  input core_wten;
  input dout_0_rsci_iswt0;
  input [127:0] dout_0_rsci_data_in_d_core;
  input [15:0] dout_0_rsci_addr_d_core;
  input [1:0] dout_0_rsci_we_d_core_psct;


  // Interconnect Declarations
  wire [1:0] dout_0_rsci_we_d_core_sct;


  // Interconnect Declarations for Component Instantiations 
  wire [1:0] nl_WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_0_rsci_1_dout_0_rsc_wait_ctrl_inst_dout_0_rsci_we_d_core_psct;
  assign nl_WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_0_rsci_1_dout_0_rsc_wait_ctrl_inst_dout_0_rsci_we_d_core_psct
      = {1'b0 , (dout_0_rsci_we_d_core_psct[0])};
  WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_0_rsci_1_dout_0_rsc_wait_ctrl WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_0_rsci_1_dout_0_rsc_wait_ctrl_inst
      (
      .core_wten(core_wten),
      .dout_0_rsci_iswt0(dout_0_rsci_iswt0),
      .dout_0_rsci_we_d_core_psct(nl_WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_0_rsci_1_dout_0_rsc_wait_ctrl_inst_dout_0_rsci_we_d_core_psct[1:0]),
      .dout_0_rsci_we_d_core_sct(dout_0_rsci_we_d_core_sct)
    );
  assign dout_0_rsci_we_d = ~ dout_0_rsci_we_d_core_sct;
  assign dout_0_rsci_data_in_d = dout_0_rsci_data_in_d_core[63:0];
  assign dout_0_rsci_addr_d = dout_0_rsci_addr_d_core[7:0];
endmodule

// ------------------------------------------------------------------
//  Design Unit:    WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_din_rsci
// ------------------------------------------------------------------


module WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_din_rsci (
  clk, rst, din_rsc_z, din_rsc_vz, din_rsc_lz, core_wen, din_rsci_oswt, din_rsci_wen_comp,
      din_rsci_d_mxwt, core_wten
);
  input clk;
  input rst;
  input [255:0] din_rsc_z;
  input din_rsc_vz;
  output din_rsc_lz;
  input core_wen;
  input din_rsci_oswt;
  output din_rsci_wen_comp;
  output [255:0] din_rsci_d_mxwt;
  input core_wten;


  // Interconnect Declarations
  wire din_rsci_biwt;
  wire din_rsci_bdwt;
  wire din_rsci_ld_core_sct;
  wire din_rsci_vd;
  wire [255:0] din_rsci_d;


  // Interconnect Declarations for Component Instantiations 
  mgc_in_wire_wait_v1 #(.rscid(32'sd25),
  .width(32'sd256)) din_rsci (
      .ld(din_rsci_ld_core_sct),
      .vd(din_rsci_vd),
      .d(din_rsci_d),
      .lz(din_rsc_lz),
      .vz(din_rsc_vz),
      .z(din_rsc_z)
    );
  WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_din_rsci_din_wait_ctrl WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_din_rsci_din_wait_ctrl_inst
      (
      .clk(clk),
      .rst(rst),
      .core_wen(core_wen),
      .din_rsci_oswt(din_rsci_oswt),
      .core_wten(core_wten),
      .din_rsci_biwt(din_rsci_biwt),
      .din_rsci_bdwt(din_rsci_bdwt),
      .din_rsci_ld_core_sct(din_rsci_ld_core_sct),
      .din_rsci_vd(din_rsci_vd)
    );
  WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_din_rsci_din_wait_dp WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_din_rsci_din_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .din_rsci_oswt(din_rsci_oswt),
      .din_rsci_wen_comp(din_rsci_wen_comp),
      .din_rsci_d_mxwt(din_rsci_d_mxwt),
      .din_rsci_biwt(din_rsci_biwt),
      .din_rsci_bdwt(din_rsci_bdwt),
      .din_rsci_d(din_rsci_d)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_0_rsc_req_obj
// ------------------------------------------------------------------


module READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_0_rsc_req_obj (
  clk, rst, din_0_rsc_req_vz, core_wen, core_wten, din_0_rsc_req_obj_oswt, din_0_rsc_req_obj_wen_comp
);
  input clk;
  input rst;
  input din_0_rsc_req_vz;
  input core_wen;
  input core_wten;
  input din_0_rsc_req_obj_oswt;
  output din_0_rsc_req_obj_wen_comp;


  // Interconnect Declarations
  wire din_0_rsc_req_obj_vd;
  wire din_0_rsc_req_obj_biwt;
  wire din_0_rsc_req_obj_bdwt;


  // Interconnect Declarations for Component Instantiations 
  mgc_in_sync_v1 #(.valid(32'sd1)) din_0_rsc_req_obj (
      .vd(din_0_rsc_req_obj_vd),
      .vz(din_0_rsc_req_vz)
    );
  READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_0_rsc_req_obj_din_0_rsc_req_wait_ctrl
      READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_0_rsc_req_obj_din_0_rsc_req_wait_ctrl_inst
      (
      .clk(clk),
      .rst(rst),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .din_0_rsc_req_obj_oswt(din_0_rsc_req_obj_oswt),
      .din_0_rsc_req_obj_vd(din_0_rsc_req_obj_vd),
      .din_0_rsc_req_obj_biwt(din_0_rsc_req_obj_biwt),
      .din_0_rsc_req_obj_bdwt(din_0_rsc_req_obj_bdwt)
    );
  READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_0_rsc_req_obj_din_0_rsc_req_wait_dp
      READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_0_rsc_req_obj_din_0_rsc_req_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .din_0_rsc_req_obj_oswt(din_0_rsc_req_obj_oswt),
      .din_0_rsc_req_obj_wen_comp(din_0_rsc_req_obj_wen_comp),
      .din_0_rsc_req_obj_biwt(din_0_rsc_req_obj_biwt),
      .din_0_rsc_req_obj_bdwt(din_0_rsc_req_obj_bdwt)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_1_rsc_req_obj
// ------------------------------------------------------------------


module READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_1_rsc_req_obj (
  clk, rst, din_1_rsc_req_vz, core_wen, core_wten, din_1_rsc_req_obj_oswt, din_1_rsc_req_obj_wen_comp
);
  input clk;
  input rst;
  input din_1_rsc_req_vz;
  input core_wen;
  input core_wten;
  input din_1_rsc_req_obj_oswt;
  output din_1_rsc_req_obj_wen_comp;


  // Interconnect Declarations
  wire din_1_rsc_req_obj_vd;
  wire din_1_rsc_req_obj_biwt;
  wire din_1_rsc_req_obj_bdwt;


  // Interconnect Declarations for Component Instantiations 
  mgc_in_sync_v1 #(.valid(32'sd1)) din_1_rsc_req_obj (
      .vd(din_1_rsc_req_obj_vd),
      .vz(din_1_rsc_req_vz)
    );
  READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_1_rsc_req_obj_din_1_rsc_req_wait_ctrl
      READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_1_rsc_req_obj_din_1_rsc_req_wait_ctrl_inst
      (
      .clk(clk),
      .rst(rst),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .din_1_rsc_req_obj_oswt(din_1_rsc_req_obj_oswt),
      .din_1_rsc_req_obj_vd(din_1_rsc_req_obj_vd),
      .din_1_rsc_req_obj_biwt(din_1_rsc_req_obj_biwt),
      .din_1_rsc_req_obj_bdwt(din_1_rsc_req_obj_bdwt)
    );
  READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_1_rsc_req_obj_din_1_rsc_req_wait_dp
      READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_1_rsc_req_obj_din_1_rsc_req_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .din_1_rsc_req_obj_oswt(din_1_rsc_req_obj_oswt),
      .din_1_rsc_req_obj_wen_comp(din_1_rsc_req_obj_wen_comp),
      .din_1_rsc_req_obj_biwt(din_1_rsc_req_obj_biwt),
      .din_1_rsc_req_obj_bdwt(din_1_rsc_req_obj_bdwt)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_2_rsc_req_obj
// ------------------------------------------------------------------


module READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_2_rsc_req_obj (
  clk, rst, din_2_rsc_req_vz, core_wen, core_wten, din_2_rsc_req_obj_oswt, din_2_rsc_req_obj_wen_comp
);
  input clk;
  input rst;
  input din_2_rsc_req_vz;
  input core_wen;
  input core_wten;
  input din_2_rsc_req_obj_oswt;
  output din_2_rsc_req_obj_wen_comp;


  // Interconnect Declarations
  wire din_2_rsc_req_obj_vd;
  wire din_2_rsc_req_obj_biwt;
  wire din_2_rsc_req_obj_bdwt;


  // Interconnect Declarations for Component Instantiations 
  mgc_in_sync_v1 #(.valid(32'sd1)) din_2_rsc_req_obj (
      .vd(din_2_rsc_req_obj_vd),
      .vz(din_2_rsc_req_vz)
    );
  READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_2_rsc_req_obj_din_2_rsc_req_wait_ctrl
      READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_2_rsc_req_obj_din_2_rsc_req_wait_ctrl_inst
      (
      .clk(clk),
      .rst(rst),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .din_2_rsc_req_obj_oswt(din_2_rsc_req_obj_oswt),
      .din_2_rsc_req_obj_vd(din_2_rsc_req_obj_vd),
      .din_2_rsc_req_obj_biwt(din_2_rsc_req_obj_biwt),
      .din_2_rsc_req_obj_bdwt(din_2_rsc_req_obj_bdwt)
    );
  READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_2_rsc_req_obj_din_2_rsc_req_wait_dp
      READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_2_rsc_req_obj_din_2_rsc_req_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .din_2_rsc_req_obj_oswt(din_2_rsc_req_obj_oswt),
      .din_2_rsc_req_obj_wen_comp(din_2_rsc_req_obj_wen_comp),
      .din_2_rsc_req_obj_biwt(din_2_rsc_req_obj_biwt),
      .din_2_rsc_req_obj_bdwt(din_2_rsc_req_obj_bdwt)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_3_rsc_req_obj
// ------------------------------------------------------------------


module READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_3_rsc_req_obj (
  clk, rst, din_3_rsc_req_vz, core_wen, core_wten, din_3_rsc_req_obj_oswt, din_3_rsc_req_obj_wen_comp
);
  input clk;
  input rst;
  input din_3_rsc_req_vz;
  input core_wen;
  input core_wten;
  input din_3_rsc_req_obj_oswt;
  output din_3_rsc_req_obj_wen_comp;


  // Interconnect Declarations
  wire din_3_rsc_req_obj_vd;
  wire din_3_rsc_req_obj_biwt;
  wire din_3_rsc_req_obj_bdwt;


  // Interconnect Declarations for Component Instantiations 
  mgc_in_sync_v1 #(.valid(32'sd1)) din_3_rsc_req_obj (
      .vd(din_3_rsc_req_obj_vd),
      .vz(din_3_rsc_req_vz)
    );
  READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_3_rsc_req_obj_din_3_rsc_req_wait_ctrl
      READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_3_rsc_req_obj_din_3_rsc_req_wait_ctrl_inst
      (
      .clk(clk),
      .rst(rst),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .din_3_rsc_req_obj_oswt(din_3_rsc_req_obj_oswt),
      .din_3_rsc_req_obj_vd(din_3_rsc_req_obj_vd),
      .din_3_rsc_req_obj_biwt(din_3_rsc_req_obj_biwt),
      .din_3_rsc_req_obj_bdwt(din_3_rsc_req_obj_bdwt)
    );
  READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_3_rsc_req_obj_din_3_rsc_req_wait_dp
      READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_3_rsc_req_obj_din_3_rsc_req_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .din_3_rsc_req_obj_oswt(din_3_rsc_req_obj_oswt),
      .din_3_rsc_req_obj_wen_comp(din_3_rsc_req_obj_wen_comp),
      .din_3_rsc_req_obj_biwt(din_3_rsc_req_obj_biwt),
      .din_3_rsc_req_obj_bdwt(din_3_rsc_req_obj_bdwt)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_3_rsc_rls_obj
// ------------------------------------------------------------------


module READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_3_rsc_rls_obj (
  din_3_rsc_rls_lz, core_wten, din_3_rsc_rls_obj_iswt0
);
  output din_3_rsc_rls_lz;
  input core_wten;
  input din_3_rsc_rls_obj_iswt0;


  // Interconnect Declarations
  wire din_3_rsc_rls_obj_ld_core_sct;


  // Interconnect Declarations for Component Instantiations 
  mgc_io_sync_v1 #(.valid(32'sd0)) din_3_rsc_rls_obj (
      .ld(din_3_rsc_rls_obj_ld_core_sct),
      .lz(din_3_rsc_rls_lz)
    );
  READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_3_rsc_rls_obj_din_3_rsc_rls_wait_ctrl
      READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_3_rsc_rls_obj_din_3_rsc_rls_wait_ctrl_inst
      (
      .core_wten(core_wten),
      .din_3_rsc_rls_obj_iswt0(din_3_rsc_rls_obj_iswt0),
      .din_3_rsc_rls_obj_ld_core_sct(din_3_rsc_rls_obj_ld_core_sct)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_2_rsc_rls_obj
// ------------------------------------------------------------------


module READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_2_rsc_rls_obj (
  din_2_rsc_rls_lz, core_wten, din_2_rsc_rls_obj_iswt0
);
  output din_2_rsc_rls_lz;
  input core_wten;
  input din_2_rsc_rls_obj_iswt0;


  // Interconnect Declarations
  wire din_2_rsc_rls_obj_ld_core_sct;


  // Interconnect Declarations for Component Instantiations 
  mgc_io_sync_v1 #(.valid(32'sd0)) din_2_rsc_rls_obj (
      .ld(din_2_rsc_rls_obj_ld_core_sct),
      .lz(din_2_rsc_rls_lz)
    );
  READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_2_rsc_rls_obj_din_2_rsc_rls_wait_ctrl
      READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_2_rsc_rls_obj_din_2_rsc_rls_wait_ctrl_inst
      (
      .core_wten(core_wten),
      .din_2_rsc_rls_obj_iswt0(din_2_rsc_rls_obj_iswt0),
      .din_2_rsc_rls_obj_ld_core_sct(din_2_rsc_rls_obj_ld_core_sct)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_1_rsc_rls_obj
// ------------------------------------------------------------------


module READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_1_rsc_rls_obj (
  din_1_rsc_rls_lz, core_wten, din_1_rsc_rls_obj_iswt0
);
  output din_1_rsc_rls_lz;
  input core_wten;
  input din_1_rsc_rls_obj_iswt0;


  // Interconnect Declarations
  wire din_1_rsc_rls_obj_ld_core_sct;


  // Interconnect Declarations for Component Instantiations 
  mgc_io_sync_v1 #(.valid(32'sd0)) din_1_rsc_rls_obj (
      .ld(din_1_rsc_rls_obj_ld_core_sct),
      .lz(din_1_rsc_rls_lz)
    );
  READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_1_rsc_rls_obj_din_1_rsc_rls_wait_ctrl
      READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_1_rsc_rls_obj_din_1_rsc_rls_wait_ctrl_inst
      (
      .core_wten(core_wten),
      .din_1_rsc_rls_obj_iswt0(din_1_rsc_rls_obj_iswt0),
      .din_1_rsc_rls_obj_ld_core_sct(din_1_rsc_rls_obj_ld_core_sct)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_0_rsc_rls_obj
// ------------------------------------------------------------------


module READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_0_rsc_rls_obj (
  din_0_rsc_rls_lz, core_wten, din_0_rsc_rls_obj_iswt0
);
  output din_0_rsc_rls_lz;
  input core_wten;
  input din_0_rsc_rls_obj_iswt0;


  // Interconnect Declarations
  wire din_0_rsc_rls_obj_ld_core_sct;


  // Interconnect Declarations for Component Instantiations 
  mgc_io_sync_v1 #(.valid(32'sd0)) din_0_rsc_rls_obj (
      .ld(din_0_rsc_rls_obj_ld_core_sct),
      .lz(din_0_rsc_rls_lz)
    );
  READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_0_rsc_rls_obj_din_0_rsc_rls_wait_ctrl
      READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_0_rsc_rls_obj_din_0_rsc_rls_wait_ctrl_inst
      (
      .core_wten(core_wten),
      .din_0_rsc_rls_obj_iswt0(din_0_rsc_rls_obj_iswt0),
      .din_0_rsc_rls_obj_ld_core_sct(din_0_rsc_rls_obj_ld_core_sct)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_dout_rsci
// ------------------------------------------------------------------


module READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_dout_rsci (
  clk, rst, dout_rsc_z, dout_rsc_vz, dout_rsc_lz, core_wen, core_wten, dout_rsci_oswt,
      dout_rsci_wen_comp, dout_rsci_d
);
  input clk;
  input rst;
  output [255:0] dout_rsc_z;
  input dout_rsc_vz;
  output dout_rsc_lz;
  input core_wen;
  input core_wten;
  input dout_rsci_oswt;
  output dout_rsci_wen_comp;
  input [255:0] dout_rsci_d;


  // Interconnect Declarations
  wire dout_rsci_biwt;
  wire dout_rsci_bdwt;
  wire dout_rsci_ld_core_sct;
  wire dout_rsci_vd;


  // Interconnect Declarations for Component Instantiations 
  mgc_out_stdreg_wait_v1 #(.rscid(32'sd38),
  .width(32'sd256)) dout_rsci (
      .ld(dout_rsci_ld_core_sct),
      .vd(dout_rsci_vd),
      .d(dout_rsci_d),
      .lz(dout_rsc_lz),
      .vz(dout_rsc_vz),
      .z(dout_rsc_z)
    );
  READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_dout_rsci_dout_wait_ctrl READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_dout_rsci_dout_wait_ctrl_inst
      (
      .clk(clk),
      .rst(rst),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .dout_rsci_oswt(dout_rsci_oswt),
      .dout_rsci_biwt(dout_rsci_biwt),
      .dout_rsci_bdwt(dout_rsci_bdwt),
      .dout_rsci_ld_core_sct(dout_rsci_ld_core_sct),
      .dout_rsci_vd(dout_rsci_vd)
    );
  READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_dout_rsci_dout_wait_dp READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_dout_rsci_dout_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .dout_rsci_oswt(dout_rsci_oswt),
      .dout_rsci_wen_comp(dout_rsci_wen_comp),
      .dout_rsci_biwt(dout_rsci_biwt),
      .dout_rsci_bdwt(dout_rsci_bdwt)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_3_rsci_1
// ------------------------------------------------------------------


module READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_3_rsci_1 (
  clk, rst, din_3_rsci_addr_d, din_3_rsci_re_d, din_3_rsci_data_out_d, core_wen,
      core_wten, din_3_rsci_oswt, din_3_rsci_addr_d_core, din_3_rsci_re_d_core_psct,
      din_3_rsci_data_out_d_mxwt, din_3_rsci_oswt_pff
);
  input clk;
  input rst;
  output [7:0] din_3_rsci_addr_d;
  output [1:0] din_3_rsci_re_d;
  input [127:0] din_3_rsci_data_out_d;
  input core_wen;
  input core_wten;
  input din_3_rsci_oswt;
  input [15:0] din_3_rsci_addr_d_core;
  input [1:0] din_3_rsci_re_d_core_psct;
  output [63:0] din_3_rsci_data_out_d_mxwt;
  input din_3_rsci_oswt_pff;


  // Interconnect Declarations
  wire din_3_rsci_biwt;
  wire din_3_rsci_bdwt;
  wire [1:0] din_3_rsci_re_d_core_sct;
  wire [63:0] din_3_rsci_data_out_d_mxwt_pconst;
  wire [7:0] din_3_rsci_addr_d_reg;
  wire [1:0] din_3_rsci_re_d_reg;


  // Interconnect Declarations for Component Instantiations 
  wire [1:0] nl_READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_3_rsci_1_din_3_rsc_wait_ctrl_inst_din_3_rsci_re_d_core_psct;
  assign nl_READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_3_rsci_1_din_3_rsc_wait_ctrl_inst_din_3_rsci_re_d_core_psct
      = {1'b0 , (din_3_rsci_re_d_core_psct[0])};
  wire [15:0] nl_READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_3_rsci_1_din_3_rsc_wait_dp_inst_din_3_rsci_addr_d_core;
  assign nl_READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_3_rsci_1_din_3_rsc_wait_dp_inst_din_3_rsci_addr_d_core
      = {8'b0 , (din_3_rsci_addr_d_core[7:0])};
  READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_3_rsci_1_din_3_rsc_wait_ctrl READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_3_rsci_1_din_3_rsc_wait_ctrl_inst
      (
      .core_wen(core_wen),
      .core_wten(core_wten),
      .din_3_rsci_oswt(din_3_rsci_oswt),
      .din_3_rsci_re_d_core_psct(nl_READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_3_rsci_1_din_3_rsc_wait_ctrl_inst_din_3_rsci_re_d_core_psct[1:0]),
      .din_3_rsci_biwt(din_3_rsci_biwt),
      .din_3_rsci_bdwt(din_3_rsci_bdwt),
      .din_3_rsci_re_d_core_sct(din_3_rsci_re_d_core_sct),
      .din_3_rsci_oswt_pff(din_3_rsci_oswt_pff)
    );
  READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_3_rsci_1_din_3_rsc_wait_dp READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_3_rsci_1_din_3_rsc_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .din_3_rsci_addr_d(din_3_rsci_addr_d_reg),
      .din_3_rsci_re_d(din_3_rsci_re_d_reg),
      .din_3_rsci_data_out_d(din_3_rsci_data_out_d),
      .din_3_rsci_addr_d_core(nl_READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_3_rsci_1_din_3_rsc_wait_dp_inst_din_3_rsci_addr_d_core[15:0]),
      .din_3_rsci_data_out_d_mxwt(din_3_rsci_data_out_d_mxwt_pconst),
      .din_3_rsci_biwt(din_3_rsci_biwt),
      .din_3_rsci_bdwt(din_3_rsci_bdwt),
      .din_3_rsci_re_d_core_sct(din_3_rsci_re_d_core_sct)
    );
  assign din_3_rsci_data_out_d_mxwt = din_3_rsci_data_out_d_mxwt_pconst;
  assign din_3_rsci_re_d = din_3_rsci_re_d_reg;
  assign din_3_rsci_addr_d = din_3_rsci_addr_d_reg;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_2_rsci_1
// ------------------------------------------------------------------


module READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_2_rsci_1 (
  clk, rst, din_2_rsci_addr_d, din_2_rsci_re_d, din_2_rsci_data_out_d, core_wen,
      core_wten, din_2_rsci_oswt, din_2_rsci_addr_d_core, din_2_rsci_re_d_core_psct,
      din_2_rsci_data_out_d_mxwt, din_2_rsci_oswt_pff
);
  input clk;
  input rst;
  output [7:0] din_2_rsci_addr_d;
  output [1:0] din_2_rsci_re_d;
  input [127:0] din_2_rsci_data_out_d;
  input core_wen;
  input core_wten;
  input din_2_rsci_oswt;
  input [15:0] din_2_rsci_addr_d_core;
  input [1:0] din_2_rsci_re_d_core_psct;
  output [63:0] din_2_rsci_data_out_d_mxwt;
  input din_2_rsci_oswt_pff;


  // Interconnect Declarations
  wire din_2_rsci_biwt;
  wire din_2_rsci_bdwt;
  wire [1:0] din_2_rsci_re_d_core_sct;
  wire [63:0] din_2_rsci_data_out_d_mxwt_pconst;
  wire [7:0] din_2_rsci_addr_d_reg;
  wire [1:0] din_2_rsci_re_d_reg;


  // Interconnect Declarations for Component Instantiations 
  wire [1:0] nl_READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_2_rsci_1_din_2_rsc_wait_ctrl_inst_din_2_rsci_re_d_core_psct;
  assign nl_READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_2_rsci_1_din_2_rsc_wait_ctrl_inst_din_2_rsci_re_d_core_psct
      = {1'b0 , (din_2_rsci_re_d_core_psct[0])};
  wire [15:0] nl_READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_2_rsci_1_din_2_rsc_wait_dp_inst_din_2_rsci_addr_d_core;
  assign nl_READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_2_rsci_1_din_2_rsc_wait_dp_inst_din_2_rsci_addr_d_core
      = {8'b0 , (din_2_rsci_addr_d_core[7:0])};
  READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_2_rsci_1_din_2_rsc_wait_ctrl READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_2_rsci_1_din_2_rsc_wait_ctrl_inst
      (
      .core_wen(core_wen),
      .core_wten(core_wten),
      .din_2_rsci_oswt(din_2_rsci_oswt),
      .din_2_rsci_re_d_core_psct(nl_READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_2_rsci_1_din_2_rsc_wait_ctrl_inst_din_2_rsci_re_d_core_psct[1:0]),
      .din_2_rsci_biwt(din_2_rsci_biwt),
      .din_2_rsci_bdwt(din_2_rsci_bdwt),
      .din_2_rsci_re_d_core_sct(din_2_rsci_re_d_core_sct),
      .din_2_rsci_oswt_pff(din_2_rsci_oswt_pff)
    );
  READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_2_rsci_1_din_2_rsc_wait_dp READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_2_rsci_1_din_2_rsc_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .din_2_rsci_addr_d(din_2_rsci_addr_d_reg),
      .din_2_rsci_re_d(din_2_rsci_re_d_reg),
      .din_2_rsci_data_out_d(din_2_rsci_data_out_d),
      .din_2_rsci_addr_d_core(nl_READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_2_rsci_1_din_2_rsc_wait_dp_inst_din_2_rsci_addr_d_core[15:0]),
      .din_2_rsci_data_out_d_mxwt(din_2_rsci_data_out_d_mxwt_pconst),
      .din_2_rsci_biwt(din_2_rsci_biwt),
      .din_2_rsci_bdwt(din_2_rsci_bdwt),
      .din_2_rsci_re_d_core_sct(din_2_rsci_re_d_core_sct)
    );
  assign din_2_rsci_data_out_d_mxwt = din_2_rsci_data_out_d_mxwt_pconst;
  assign din_2_rsci_re_d = din_2_rsci_re_d_reg;
  assign din_2_rsci_addr_d = din_2_rsci_addr_d_reg;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_1_rsci_1
// ------------------------------------------------------------------


module READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_1_rsci_1 (
  clk, rst, din_1_rsci_addr_d, din_1_rsci_re_d, din_1_rsci_data_out_d, core_wen,
      core_wten, din_1_rsci_oswt, din_1_rsci_addr_d_core, din_1_rsci_re_d_core_psct,
      din_1_rsci_data_out_d_mxwt, din_1_rsci_oswt_pff
);
  input clk;
  input rst;
  output [7:0] din_1_rsci_addr_d;
  output [1:0] din_1_rsci_re_d;
  input [127:0] din_1_rsci_data_out_d;
  input core_wen;
  input core_wten;
  input din_1_rsci_oswt;
  input [15:0] din_1_rsci_addr_d_core;
  input [1:0] din_1_rsci_re_d_core_psct;
  output [63:0] din_1_rsci_data_out_d_mxwt;
  input din_1_rsci_oswt_pff;


  // Interconnect Declarations
  wire din_1_rsci_biwt;
  wire din_1_rsci_bdwt;
  wire [1:0] din_1_rsci_re_d_core_sct;
  wire [63:0] din_1_rsci_data_out_d_mxwt_pconst;
  wire [7:0] din_1_rsci_addr_d_reg;
  wire [1:0] din_1_rsci_re_d_reg;


  // Interconnect Declarations for Component Instantiations 
  wire [1:0] nl_READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_1_rsci_1_din_1_rsc_wait_ctrl_inst_din_1_rsci_re_d_core_psct;
  assign nl_READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_1_rsci_1_din_1_rsc_wait_ctrl_inst_din_1_rsci_re_d_core_psct
      = {1'b0 , (din_1_rsci_re_d_core_psct[0])};
  wire [15:0] nl_READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_1_rsci_1_din_1_rsc_wait_dp_inst_din_1_rsci_addr_d_core;
  assign nl_READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_1_rsci_1_din_1_rsc_wait_dp_inst_din_1_rsci_addr_d_core
      = {8'b0 , (din_1_rsci_addr_d_core[7:0])};
  READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_1_rsci_1_din_1_rsc_wait_ctrl READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_1_rsci_1_din_1_rsc_wait_ctrl_inst
      (
      .core_wen(core_wen),
      .core_wten(core_wten),
      .din_1_rsci_oswt(din_1_rsci_oswt),
      .din_1_rsci_re_d_core_psct(nl_READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_1_rsci_1_din_1_rsc_wait_ctrl_inst_din_1_rsci_re_d_core_psct[1:0]),
      .din_1_rsci_biwt(din_1_rsci_biwt),
      .din_1_rsci_bdwt(din_1_rsci_bdwt),
      .din_1_rsci_re_d_core_sct(din_1_rsci_re_d_core_sct),
      .din_1_rsci_oswt_pff(din_1_rsci_oswt_pff)
    );
  READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_1_rsci_1_din_1_rsc_wait_dp READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_1_rsci_1_din_1_rsc_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .din_1_rsci_addr_d(din_1_rsci_addr_d_reg),
      .din_1_rsci_re_d(din_1_rsci_re_d_reg),
      .din_1_rsci_data_out_d(din_1_rsci_data_out_d),
      .din_1_rsci_addr_d_core(nl_READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_1_rsci_1_din_1_rsc_wait_dp_inst_din_1_rsci_addr_d_core[15:0]),
      .din_1_rsci_data_out_d_mxwt(din_1_rsci_data_out_d_mxwt_pconst),
      .din_1_rsci_biwt(din_1_rsci_biwt),
      .din_1_rsci_bdwt(din_1_rsci_bdwt),
      .din_1_rsci_re_d_core_sct(din_1_rsci_re_d_core_sct)
    );
  assign din_1_rsci_data_out_d_mxwt = din_1_rsci_data_out_d_mxwt_pconst;
  assign din_1_rsci_re_d = din_1_rsci_re_d_reg;
  assign din_1_rsci_addr_d = din_1_rsci_addr_d_reg;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_0_rsci_1
// ------------------------------------------------------------------


module READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_0_rsci_1 (
  clk, rst, din_0_rsci_addr_d, din_0_rsci_re_d, din_0_rsci_data_out_d, core_wen,
      din_0_rsci_oswt, din_0_rsci_addr_d_core, din_0_rsci_re_d_core_psct, din_0_rsci_data_out_d_mxwt,
      core_wten, din_0_rsci_oswt_pff
);
  input clk;
  input rst;
  output [7:0] din_0_rsci_addr_d;
  output [1:0] din_0_rsci_re_d;
  input [127:0] din_0_rsci_data_out_d;
  input core_wen;
  input din_0_rsci_oswt;
  input [15:0] din_0_rsci_addr_d_core;
  input [1:0] din_0_rsci_re_d_core_psct;
  output [63:0] din_0_rsci_data_out_d_mxwt;
  input core_wten;
  input din_0_rsci_oswt_pff;


  // Interconnect Declarations
  wire din_0_rsci_biwt;
  wire din_0_rsci_bdwt;
  wire [1:0] din_0_rsci_re_d_core_sct;
  wire [63:0] din_0_rsci_data_out_d_mxwt_pconst;
  wire [7:0] din_0_rsci_addr_d_reg;
  wire [1:0] din_0_rsci_re_d_reg;


  // Interconnect Declarations for Component Instantiations 
  wire [1:0] nl_READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_0_rsci_1_din_0_rsc_wait_ctrl_inst_din_0_rsci_re_d_core_psct;
  assign nl_READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_0_rsci_1_din_0_rsc_wait_ctrl_inst_din_0_rsci_re_d_core_psct
      = {1'b0 , (din_0_rsci_re_d_core_psct[0])};
  wire [15:0] nl_READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_0_rsci_1_din_0_rsc_wait_dp_inst_din_0_rsci_addr_d_core;
  assign nl_READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_0_rsci_1_din_0_rsc_wait_dp_inst_din_0_rsci_addr_d_core
      = {8'b0 , (din_0_rsci_addr_d_core[7:0])};
  READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_0_rsci_1_din_0_rsc_wait_ctrl READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_0_rsci_1_din_0_rsc_wait_ctrl_inst
      (
      .core_wen(core_wen),
      .din_0_rsci_oswt(din_0_rsci_oswt),
      .din_0_rsci_re_d_core_psct(nl_READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_0_rsci_1_din_0_rsc_wait_ctrl_inst_din_0_rsci_re_d_core_psct[1:0]),
      .core_wten(core_wten),
      .din_0_rsci_biwt(din_0_rsci_biwt),
      .din_0_rsci_bdwt(din_0_rsci_bdwt),
      .din_0_rsci_re_d_core_sct(din_0_rsci_re_d_core_sct),
      .din_0_rsci_oswt_pff(din_0_rsci_oswt_pff)
    );
  READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_0_rsci_1_din_0_rsc_wait_dp READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_0_rsci_1_din_0_rsc_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .din_0_rsci_addr_d(din_0_rsci_addr_d_reg),
      .din_0_rsci_re_d(din_0_rsci_re_d_reg),
      .din_0_rsci_data_out_d(din_0_rsci_data_out_d),
      .din_0_rsci_addr_d_core(nl_READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_0_rsci_1_din_0_rsc_wait_dp_inst_din_0_rsci_addr_d_core[15:0]),
      .din_0_rsci_data_out_d_mxwt(din_0_rsci_data_out_d_mxwt_pconst),
      .din_0_rsci_biwt(din_0_rsci_biwt),
      .din_0_rsci_bdwt(din_0_rsci_bdwt),
      .din_0_rsci_re_d_core_sct(din_0_rsci_re_d_core_sct)
    );
  assign din_0_rsci_data_out_d_mxwt = din_0_rsci_data_out_d_mxwt_pconst;
  assign din_0_rsci_re_d = din_0_rsci_re_d_reg;
  assign din_0_rsci_addr_d = din_0_rsci_addr_d_reg;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    systolic_array_DTYPE_2_4_16_4_2_2_3_core_output_rsci
// ------------------------------------------------------------------


module systolic_array_DTYPE_2_4_16_4_2_2_3_core_output_rsci (
  clk, rst, output_rsc_z, output_rsc_vz, output_rsc_lz, core_wen, core_wten, output_rsci_oswt,
      output_rsci_wen_comp, output_rsci_d
);
  input clk;
  input rst;
  output [255:0] output_rsc_z;
  input output_rsc_vz;
  output output_rsc_lz;
  input core_wen;
  input core_wten;
  input output_rsci_oswt;
  output output_rsci_wen_comp;
  input [255:0] output_rsci_d;


  // Interconnect Declarations
  wire output_rsci_biwt;
  wire output_rsci_bdwt;
  wire output_rsci_ld_core_sct;
  wire output_rsci_vd;


  // Interconnect Declarations for Component Instantiations 
  mgc_out_stdreg_wait_v1 #(.rscid(32'sd51),
  .width(32'sd256)) output_rsci (
      .ld(output_rsci_ld_core_sct),
      .vd(output_rsci_vd),
      .d(output_rsci_d),
      .lz(output_rsc_lz),
      .vz(output_rsc_vz),
      .z(output_rsc_z)
    );
  systolic_array_DTYPE_2_4_16_4_2_2_3_core_output_rsci_output_wait_ctrl systolic_array_DTYPE_2_4_16_4_2_2_3_core_output_rsci_output_wait_ctrl_inst
      (
      .clk(clk),
      .rst(rst),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .output_rsci_oswt(output_rsci_oswt),
      .output_rsci_biwt(output_rsci_biwt),
      .output_rsci_bdwt(output_rsci_bdwt),
      .output_rsci_ld_core_sct(output_rsci_ld_core_sct),
      .output_rsci_vd(output_rsci_vd)
    );
  systolic_array_DTYPE_2_4_16_4_2_2_3_core_output_rsci_output_wait_dp systolic_array_DTYPE_2_4_16_4_2_2_3_core_output_rsci_output_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .output_rsci_oswt(output_rsci_oswt),
      .output_rsci_wen_comp(output_rsci_wen_comp),
      .output_rsci_biwt(output_rsci_biwt),
      .output_rsci_bdwt(output_rsci_bdwt)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    systolic_array_DTYPE_2_4_16_4_2_2_3_core_weight_rsci
// ------------------------------------------------------------------


module systolic_array_DTYPE_2_4_16_4_2_2_3_core_weight_rsci (
  clk, rst, weight_rsc_z, weight_rsc_vz, weight_rsc_lz, core_wen, core_wten, weight_rsci_oswt,
      weight_rsci_wen_comp, weight_rsci_d_mxwt
);
  input clk;
  input rst;
  input [255:0] weight_rsc_z;
  input weight_rsc_vz;
  output weight_rsc_lz;
  input core_wen;
  input core_wten;
  input weight_rsci_oswt;
  output weight_rsci_wen_comp;
  output [127:0] weight_rsci_d_mxwt;


  // Interconnect Declarations
  wire weight_rsci_biwt;
  wire weight_rsci_bdwt;
  wire weight_rsci_ld_core_sct;
  wire weight_rsci_vd;
  wire [255:0] weight_rsci_d;
  wire [127:0] weight_rsci_d_mxwt_pconst;


  // Interconnect Declarations for Component Instantiations 
  mgc_in_wire_wait_v1 #(.rscid(32'sd50),
  .width(32'sd256)) weight_rsci (
      .ld(weight_rsci_ld_core_sct),
      .vd(weight_rsci_vd),
      .d(weight_rsci_d),
      .lz(weight_rsc_lz),
      .vz(weight_rsc_vz),
      .z(weight_rsc_z)
    );
  systolic_array_DTYPE_2_4_16_4_2_2_3_core_weight_rsci_weight_wait_ctrl systolic_array_DTYPE_2_4_16_4_2_2_3_core_weight_rsci_weight_wait_ctrl_inst
      (
      .clk(clk),
      .rst(rst),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .weight_rsci_oswt(weight_rsci_oswt),
      .weight_rsci_biwt(weight_rsci_biwt),
      .weight_rsci_bdwt(weight_rsci_bdwt),
      .weight_rsci_ld_core_sct(weight_rsci_ld_core_sct),
      .weight_rsci_vd(weight_rsci_vd)
    );
  systolic_array_DTYPE_2_4_16_4_2_2_3_core_weight_rsci_weight_wait_dp systolic_array_DTYPE_2_4_16_4_2_2_3_core_weight_rsci_weight_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .weight_rsci_oswt(weight_rsci_oswt),
      .weight_rsci_wen_comp(weight_rsci_wen_comp),
      .weight_rsci_d_mxwt(weight_rsci_d_mxwt_pconst),
      .weight_rsci_biwt(weight_rsci_biwt),
      .weight_rsci_bdwt(weight_rsci_bdwt),
      .weight_rsci_d(weight_rsci_d)
    );
  assign weight_rsci_d_mxwt = weight_rsci_d_mxwt_pconst;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    systolic_array_DTYPE_2_4_16_4_2_2_3_core_input_rsci
// ------------------------------------------------------------------


module systolic_array_DTYPE_2_4_16_4_2_2_3_core_input_rsci (
  clk, rst, input_rsc_z, input_rsc_vz, input_rsc_lz, core_wen, input_rsci_oswt, input_rsci_wen_comp,
      input_rsci_d_mxwt, core_wten
);
  input clk;
  input rst;
  input [127:0] input_rsc_z;
  input input_rsc_vz;
  output input_rsc_lz;
  input core_wen;
  input input_rsci_oswt;
  output input_rsci_wen_comp;
  output [63:0] input_rsci_d_mxwt;
  input core_wten;


  // Interconnect Declarations
  wire input_rsci_biwt;
  wire input_rsci_bdwt;
  wire input_rsci_ld_core_sct;
  wire input_rsci_vd;
  wire [127:0] input_rsci_d;
  wire [63:0] input_rsci_d_mxwt_pconst;


  // Interconnect Declarations for Component Instantiations 
  mgc_in_wire_wait_v1 #(.rscid(32'sd49),
  .width(32'sd128)) input_rsci (
      .ld(input_rsci_ld_core_sct),
      .vd(input_rsci_vd),
      .d(input_rsci_d),
      .lz(input_rsc_lz),
      .vz(input_rsc_vz),
      .z(input_rsc_z)
    );
  systolic_array_DTYPE_2_4_16_4_2_2_3_core_input_rsci_input_wait_ctrl systolic_array_DTYPE_2_4_16_4_2_2_3_core_input_rsci_input_wait_ctrl_inst
      (
      .clk(clk),
      .rst(rst),
      .core_wen(core_wen),
      .input_rsci_oswt(input_rsci_oswt),
      .core_wten(core_wten),
      .input_rsci_biwt(input_rsci_biwt),
      .input_rsci_bdwt(input_rsci_bdwt),
      .input_rsci_ld_core_sct(input_rsci_ld_core_sct),
      .input_rsci_vd(input_rsci_vd)
    );
  systolic_array_DTYPE_2_4_16_4_2_2_3_core_input_rsci_input_wait_dp systolic_array_DTYPE_2_4_16_4_2_2_3_core_input_rsci_input_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .input_rsci_oswt(input_rsci_oswt),
      .input_rsci_wen_comp(input_rsci_wen_comp),
      .input_rsci_d_mxwt(input_rsci_d_mxwt_pconst),
      .input_rsci_biwt(input_rsci_biwt),
      .input_rsci_bdwt(input_rsci_bdwt),
      .input_rsci_d(input_rsci_d)
    );
  assign input_rsci_d_mxwt = input_rsci_d_mxwt_pconst;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core
// ------------------------------------------------------------------


module WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core (
  clk, rst, din_rsc_z, din_rsc_vz, din_rsc_lz, dout_0_rsc_req_vz, dout_0_rsc_rls_lz,
      dout_1_rsc_req_vz, dout_1_rsc_rls_lz, dout_2_rsc_req_vz, dout_2_rsc_rls_lz,
      dout_3_rsc_req_vz, dout_3_rsc_rls_lz, dout_0_rsci_data_in_d, dout_0_rsci_addr_d,
      dout_0_rsci_we_d, dout_1_rsci_data_in_d, dout_1_rsci_addr_d, dout_1_rsci_we_d,
      dout_2_rsci_data_in_d, dout_2_rsci_addr_d, dout_2_rsci_we_d, dout_3_rsci_data_in_d,
      dout_3_rsci_addr_d, dout_3_rsci_we_d
);
  input clk;
  input rst;
  input [127:0] din_rsc_z;
  input din_rsc_vz;
  output din_rsc_lz;
  input dout_0_rsc_req_vz;
  output dout_0_rsc_rls_lz;
  input dout_1_rsc_req_vz;
  output dout_1_rsc_rls_lz;
  input dout_2_rsc_req_vz;
  output dout_2_rsc_rls_lz;
  input dout_3_rsc_req_vz;
  output dout_3_rsc_rls_lz;
  output [15:0] dout_0_rsci_data_in_d;
  output [6:0] dout_0_rsci_addr_d;
  output [1:0] dout_0_rsci_we_d;
  output [15:0] dout_1_rsci_data_in_d;
  output [6:0] dout_1_rsci_addr_d;
  output [1:0] dout_1_rsci_we_d;
  output [15:0] dout_2_rsci_data_in_d;
  output [6:0] dout_2_rsci_addr_d;
  output [1:0] dout_2_rsci_we_d;
  output [15:0] dout_3_rsci_data_in_d;
  output [6:0] dout_3_rsci_addr_d;
  output [1:0] dout_3_rsci_we_d;


  // Interconnect Declarations
  wire core_wen;
  wire din_rsci_wen_comp;
  wire [63:0] din_rsci_d_mxwt;
  wire core_wten;
  wire dout_3_rsc_req_obj_wen_comp;
  wire dout_2_rsc_req_obj_wen_comp;
  wire dout_1_rsc_req_obj_wen_comp;
  wire dout_0_rsc_req_obj_wen_comp;
  wire [1:0] fsm_output;
  reg exitL_exit_for_sva;
  reg [5:0] WRITE_y_idx_5_0_lpi_1_dfm_4;
  reg for_c_idx_0_lpi_1_dfm_2;
  reg exit_for_lpi_1_dfm_2;
  wire for_c_idx_0_lpi_1_dfm;
  reg reg_dout_3_rsc_req_obj_oswt_cse;
  reg reg_dout_0_rsc_rls_obj_ld_core_psct_cse;
  reg reg_din_rsci_ld_core_psct_cse;
  wire for_and_cse;
  wire or_1_cse;
  wire [15:0] dout_0_rsci_data_in_d_reg;
  wire [6:0] dout_0_rsci_addr_d_reg;
  wire [4:0] WRITE_acc_6_rmff;
  wire [6:0] nl_WRITE_acc_6_rmff;
  wire [1:0] dout_0_rsci_we_d_reg;
  wire [15:0] dout_1_rsci_data_in_d_reg;
  wire [6:0] dout_1_rsci_addr_d_reg;
  wire [1:0] dout_1_rsci_we_d_reg;
  wire [15:0] dout_2_rsci_data_in_d_reg;
  wire [6:0] dout_2_rsci_addr_d_reg;
  wire [1:0] dout_2_rsci_we_d_reg;
  wire [15:0] dout_3_rsci_data_in_d_reg;
  wire [6:0] dout_3_rsci_addr_d_reg;
  wire [1:0] dout_3_rsci_we_d_reg;
  wire [5:0] WRITE_y_idx_5_0_lpi_1_dfm;
  wire exit_for_lpi_1_dfm_2_mx0w0;
  wire for_c_idx_0_lpi_1_dfm_1_mx0c1;
  wire [5:0] WRITE_y_idx_5_0_sva_1;
  wire [6:0] nl_WRITE_y_idx_5_0_sva_1;
  wire WRITE_acc_itm_4_1;

  wire[4:0] WRITE_acc_nl;
  wire[5:0] nl_WRITE_acc_nl;
  wire[0:0] nor_nl;

  // Interconnect Declarations for Component Instantiations 
  wire [0:0] nl_WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_0_rsci_1_inst_core_wten;
  assign nl_WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_0_rsci_1_inst_core_wten =
      ~ core_wen;
  wire [0:0] nl_WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_0_rsci_1_inst_dout_0_rsci_iswt0;
  assign nl_WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_0_rsci_1_inst_dout_0_rsci_iswt0
      = fsm_output[1];
  wire [31:0] nl_WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_0_rsci_1_inst_dout_0_rsci_data_in_d_core;
  assign nl_WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_0_rsci_1_inst_dout_0_rsci_data_in_d_core
      = {16'b0 , (din_rsci_d_mxwt[15:0])};
  wire [13:0] nl_WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_0_rsci_1_inst_dout_0_rsci_addr_d_core;
  assign nl_WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_0_rsci_1_inst_dout_0_rsci_addr_d_core
      = {7'b0 , WRITE_acc_6_rmff , (WRITE_y_idx_5_0_lpi_1_dfm[1:0])};
  wire [1:0] nl_WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_0_rsci_1_inst_dout_0_rsci_we_d_core_psct;
  assign nl_WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_0_rsci_1_inst_dout_0_rsci_we_d_core_psct
      = {1'b0 , (fsm_output[1])};
  wire [0:0] nl_WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_1_rsci_1_inst_core_wten;
  assign nl_WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_1_rsci_1_inst_core_wten =
      ~ core_wen;
  wire [0:0] nl_WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_1_rsci_1_inst_dout_1_rsci_iswt0;
  assign nl_WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_1_rsci_1_inst_dout_1_rsci_iswt0
      = fsm_output[1];
  wire [31:0] nl_WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_1_rsci_1_inst_dout_1_rsci_data_in_d_core;
  assign nl_WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_1_rsci_1_inst_dout_1_rsci_data_in_d_core
      = {16'b0 , (din_rsci_d_mxwt[31:16])};
  wire [13:0] nl_WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_1_rsci_1_inst_dout_1_rsci_addr_d_core;
  assign nl_WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_1_rsci_1_inst_dout_1_rsci_addr_d_core
      = {7'b0 , WRITE_acc_6_rmff , (WRITE_y_idx_5_0_lpi_1_dfm[1:0])};
  wire [1:0] nl_WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_1_rsci_1_inst_dout_1_rsci_we_d_core_psct;
  assign nl_WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_1_rsci_1_inst_dout_1_rsci_we_d_core_psct
      = {1'b0 , (fsm_output[1])};
  wire [0:0] nl_WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_2_rsci_1_inst_core_wten;
  assign nl_WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_2_rsci_1_inst_core_wten =
      ~ core_wen;
  wire [0:0] nl_WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_2_rsci_1_inst_dout_2_rsci_iswt0;
  assign nl_WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_2_rsci_1_inst_dout_2_rsci_iswt0
      = fsm_output[1];
  wire [31:0] nl_WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_2_rsci_1_inst_dout_2_rsci_data_in_d_core;
  assign nl_WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_2_rsci_1_inst_dout_2_rsci_data_in_d_core
      = {16'b0 , (din_rsci_d_mxwt[47:32])};
  wire [13:0] nl_WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_2_rsci_1_inst_dout_2_rsci_addr_d_core;
  assign nl_WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_2_rsci_1_inst_dout_2_rsci_addr_d_core
      = {7'b0 , WRITE_acc_6_rmff , (WRITE_y_idx_5_0_lpi_1_dfm[1:0])};
  wire [1:0] nl_WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_2_rsci_1_inst_dout_2_rsci_we_d_core_psct;
  assign nl_WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_2_rsci_1_inst_dout_2_rsci_we_d_core_psct
      = {1'b0 , (fsm_output[1])};
  wire [0:0] nl_WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_3_rsci_1_inst_core_wten;
  assign nl_WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_3_rsci_1_inst_core_wten =
      ~ core_wen;
  wire [0:0] nl_WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_3_rsci_1_inst_dout_3_rsci_iswt0;
  assign nl_WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_3_rsci_1_inst_dout_3_rsci_iswt0
      = fsm_output[1];
  wire [31:0] nl_WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_3_rsci_1_inst_dout_3_rsci_data_in_d_core;
  assign nl_WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_3_rsci_1_inst_dout_3_rsci_data_in_d_core
      = {16'b0 , (din_rsci_d_mxwt[63:48])};
  wire [13:0] nl_WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_3_rsci_1_inst_dout_3_rsci_addr_d_core;
  assign nl_WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_3_rsci_1_inst_dout_3_rsci_addr_d_core
      = {7'b0 , WRITE_acc_6_rmff , (WRITE_y_idx_5_0_lpi_1_dfm[1:0])};
  wire [1:0] nl_WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_3_rsci_1_inst_dout_3_rsci_we_d_core_psct;
  assign nl_WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_3_rsci_1_inst_dout_3_rsci_we_d_core_psct
      = {1'b0 , (fsm_output[1])};
  WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_din_rsci WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_din_rsci_inst
      (
      .clk(clk),
      .rst(rst),
      .din_rsc_z(din_rsc_z),
      .din_rsc_vz(din_rsc_vz),
      .din_rsc_lz(din_rsc_lz),
      .core_wen(core_wen),
      .din_rsci_oswt(reg_din_rsci_ld_core_psct_cse),
      .din_rsci_wen_comp(din_rsci_wen_comp),
      .din_rsci_d_mxwt(din_rsci_d_mxwt),
      .core_wten(core_wten)
    );
  WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_0_rsci_1 WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_0_rsci_1_inst
      (
      .dout_0_rsci_data_in_d(dout_0_rsci_data_in_d_reg),
      .dout_0_rsci_addr_d(dout_0_rsci_addr_d_reg),
      .dout_0_rsci_we_d(dout_0_rsci_we_d_reg),
      .core_wten(nl_WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_0_rsci_1_inst_core_wten[0:0]),
      .dout_0_rsci_iswt0(nl_WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_0_rsci_1_inst_dout_0_rsci_iswt0[0:0]),
      .dout_0_rsci_data_in_d_core(nl_WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_0_rsci_1_inst_dout_0_rsci_data_in_d_core[31:0]),
      .dout_0_rsci_addr_d_core(nl_WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_0_rsci_1_inst_dout_0_rsci_addr_d_core[13:0]),
      .dout_0_rsci_we_d_core_psct(nl_WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_0_rsci_1_inst_dout_0_rsci_we_d_core_psct[1:0])
    );
  WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_1_rsci_1 WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_1_rsci_1_inst
      (
      .dout_1_rsci_data_in_d(dout_1_rsci_data_in_d_reg),
      .dout_1_rsci_addr_d(dout_1_rsci_addr_d_reg),
      .dout_1_rsci_we_d(dout_1_rsci_we_d_reg),
      .core_wten(nl_WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_1_rsci_1_inst_core_wten[0:0]),
      .dout_1_rsci_iswt0(nl_WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_1_rsci_1_inst_dout_1_rsci_iswt0[0:0]),
      .dout_1_rsci_data_in_d_core(nl_WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_1_rsci_1_inst_dout_1_rsci_data_in_d_core[31:0]),
      .dout_1_rsci_addr_d_core(nl_WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_1_rsci_1_inst_dout_1_rsci_addr_d_core[13:0]),
      .dout_1_rsci_we_d_core_psct(nl_WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_1_rsci_1_inst_dout_1_rsci_we_d_core_psct[1:0])
    );
  WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_2_rsci_1 WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_2_rsci_1_inst
      (
      .dout_2_rsci_data_in_d(dout_2_rsci_data_in_d_reg),
      .dout_2_rsci_addr_d(dout_2_rsci_addr_d_reg),
      .dout_2_rsci_we_d(dout_2_rsci_we_d_reg),
      .core_wten(nl_WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_2_rsci_1_inst_core_wten[0:0]),
      .dout_2_rsci_iswt0(nl_WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_2_rsci_1_inst_dout_2_rsci_iswt0[0:0]),
      .dout_2_rsci_data_in_d_core(nl_WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_2_rsci_1_inst_dout_2_rsci_data_in_d_core[31:0]),
      .dout_2_rsci_addr_d_core(nl_WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_2_rsci_1_inst_dout_2_rsci_addr_d_core[13:0]),
      .dout_2_rsci_we_d_core_psct(nl_WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_2_rsci_1_inst_dout_2_rsci_we_d_core_psct[1:0])
    );
  WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_3_rsci_1 WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_3_rsci_1_inst
      (
      .dout_3_rsci_data_in_d(dout_3_rsci_data_in_d_reg),
      .dout_3_rsci_addr_d(dout_3_rsci_addr_d_reg),
      .dout_3_rsci_we_d(dout_3_rsci_we_d_reg),
      .core_wten(nl_WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_3_rsci_1_inst_core_wten[0:0]),
      .dout_3_rsci_iswt0(nl_WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_3_rsci_1_inst_dout_3_rsci_iswt0[0:0]),
      .dout_3_rsci_data_in_d_core(nl_WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_3_rsci_1_inst_dout_3_rsci_data_in_d_core[31:0]),
      .dout_3_rsci_addr_d_core(nl_WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_3_rsci_1_inst_dout_3_rsci_addr_d_core[13:0]),
      .dout_3_rsci_we_d_core_psct(nl_WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_3_rsci_1_inst_dout_3_rsci_we_d_core_psct[1:0])
    );
  WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_3_rsc_rls_obj WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_3_rsc_rls_obj_inst
      (
      .dout_3_rsc_rls_lz(dout_3_rsc_rls_lz),
      .core_wten(core_wten),
      .dout_3_rsc_rls_obj_iswt0(reg_dout_0_rsc_rls_obj_ld_core_psct_cse)
    );
  WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_2_rsc_rls_obj WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_2_rsc_rls_obj_inst
      (
      .dout_2_rsc_rls_lz(dout_2_rsc_rls_lz),
      .core_wten(core_wten),
      .dout_2_rsc_rls_obj_iswt0(reg_dout_0_rsc_rls_obj_ld_core_psct_cse)
    );
  WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_1_rsc_rls_obj WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_1_rsc_rls_obj_inst
      (
      .dout_1_rsc_rls_lz(dout_1_rsc_rls_lz),
      .core_wten(core_wten),
      .dout_1_rsc_rls_obj_iswt0(reg_dout_0_rsc_rls_obj_ld_core_psct_cse)
    );
  WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_0_rsc_rls_obj WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_0_rsc_rls_obj_inst
      (
      .dout_0_rsc_rls_lz(dout_0_rsc_rls_lz),
      .core_wten(core_wten),
      .dout_0_rsc_rls_obj_iswt0(reg_dout_0_rsc_rls_obj_ld_core_psct_cse)
    );
  WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_3_rsc_req_obj WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_3_rsc_req_obj_inst
      (
      .clk(clk),
      .rst(rst),
      .dout_3_rsc_req_vz(dout_3_rsc_req_vz),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .dout_3_rsc_req_obj_oswt(reg_dout_3_rsc_req_obj_oswt_cse),
      .dout_3_rsc_req_obj_wen_comp(dout_3_rsc_req_obj_wen_comp)
    );
  WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_2_rsc_req_obj WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_2_rsc_req_obj_inst
      (
      .clk(clk),
      .rst(rst),
      .dout_2_rsc_req_vz(dout_2_rsc_req_vz),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .dout_2_rsc_req_obj_oswt(reg_dout_3_rsc_req_obj_oswt_cse),
      .dout_2_rsc_req_obj_wen_comp(dout_2_rsc_req_obj_wen_comp)
    );
  WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_1_rsc_req_obj WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_1_rsc_req_obj_inst
      (
      .clk(clk),
      .rst(rst),
      .dout_1_rsc_req_vz(dout_1_rsc_req_vz),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .dout_1_rsc_req_obj_oswt(reg_dout_3_rsc_req_obj_oswt_cse),
      .dout_1_rsc_req_obj_wen_comp(dout_1_rsc_req_obj_wen_comp)
    );
  WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_0_rsc_req_obj WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_dout_0_rsc_req_obj_inst
      (
      .clk(clk),
      .rst(rst),
      .dout_0_rsc_req_vz(dout_0_rsc_req_vz),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .dout_0_rsc_req_obj_oswt(reg_dout_3_rsc_req_obj_oswt_cse),
      .dout_0_rsc_req_obj_wen_comp(dout_0_rsc_req_obj_wen_comp)
    );
  WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_staller WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_staller_inst
      (
      .clk(clk),
      .rst(rst),
      .core_wen(core_wen),
      .din_rsci_wen_comp(din_rsci_wen_comp),
      .core_wten(core_wten),
      .dout_3_rsc_req_obj_wen_comp(dout_3_rsc_req_obj_wen_comp),
      .dout_2_rsc_req_obj_wen_comp(dout_2_rsc_req_obj_wen_comp),
      .dout_1_rsc_req_obj_wen_comp(dout_1_rsc_req_obj_wen_comp),
      .dout_0_rsc_req_obj_wen_comp(dout_0_rsc_req_obj_wen_comp)
    );
  WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_core_fsm WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_core_fsm_inst
      (
      .clk(clk),
      .rst(rst),
      .core_wen(core_wen),
      .fsm_output(fsm_output)
    );
  assign nl_WRITE_acc_6_rmff = conv_u2u_4_5(WRITE_y_idx_5_0_lpi_1_dfm[5:2]) + conv_u2u_4_5({for_c_idx_0_lpi_1_dfm
      , 3'b0}) + conv_u2u_1_5(for_c_idx_0_lpi_1_dfm);
  assign WRITE_acc_6_rmff = nl_WRITE_acc_6_rmff[4:0];
  assign for_and_cse = core_wen & (~ (fsm_output[0]));
  assign or_1_cse = WRITE_acc_itm_4_1 | (~ for_c_idx_0_lpi_1_dfm_2) | exitL_exit_for_sva;
  assign exit_for_lpi_1_dfm_2_mx0w0 = for_c_idx_0_lpi_1_dfm & (~ WRITE_acc_itm_4_1);
  assign for_c_idx_0_lpi_1_dfm = for_c_idx_0_lpi_1_dfm_2 & (~ exitL_exit_for_sva);
  assign nl_WRITE_acc_nl = conv_u2s_4_5(WRITE_y_idx_5_0_sva_1[5:2]) + 5'b10111;
  assign WRITE_acc_nl = nl_WRITE_acc_nl[4:0];
  assign WRITE_acc_itm_4_1 = readslicef_5_1_4((WRITE_acc_nl));
  assign nl_WRITE_y_idx_5_0_sva_1 = WRITE_y_idx_5_0_lpi_1_dfm + 6'b1;
  assign WRITE_y_idx_5_0_sva_1 = nl_WRITE_y_idx_5_0_sva_1[5:0];
  assign nor_nl = ~(exit_for_lpi_1_dfm_2 | exitL_exit_for_sva);
  assign WRITE_y_idx_5_0_lpi_1_dfm = MUX_v_6_2_2(6'b000000, WRITE_y_idx_5_0_lpi_1_dfm_4,
      (nor_nl));
  assign for_c_idx_0_lpi_1_dfm_1_mx0c1 = WRITE_acc_itm_4_1 & (fsm_output[1]);
  assign dout_0_rsci_we_d = dout_0_rsci_we_d_reg;
  assign dout_1_rsci_we_d = dout_1_rsci_we_d_reg;
  assign dout_2_rsci_we_d = dout_2_rsci_we_d_reg;
  assign dout_3_rsci_we_d = dout_3_rsci_we_d_reg;
  assign dout_0_rsci_data_in_d = dout_0_rsci_data_in_d_reg;
  assign dout_0_rsci_addr_d = dout_0_rsci_addr_d_reg;
  assign dout_1_rsci_data_in_d = dout_1_rsci_data_in_d_reg;
  assign dout_1_rsci_addr_d = dout_1_rsci_addr_d_reg;
  assign dout_2_rsci_data_in_d = dout_2_rsci_data_in_d_reg;
  assign dout_2_rsci_addr_d = dout_2_rsci_addr_d_reg;
  assign dout_3_rsci_data_in_d = dout_3_rsci_data_in_d_reg;
  assign dout_3_rsci_addr_d = dout_3_rsci_addr_d_reg;
  always @(posedge clk) begin
    if ( rst ) begin
      reg_dout_3_rsc_req_obj_oswt_cse <= 1'b0;
      reg_dout_0_rsc_rls_obj_ld_core_psct_cse <= 1'b0;
      reg_din_rsci_ld_core_psct_cse <= 1'b0;
    end
    else if ( core_wen ) begin
      reg_dout_3_rsc_req_obj_oswt_cse <= ~(or_1_cse & (fsm_output[1]));
      reg_dout_0_rsc_rls_obj_ld_core_psct_cse <= (~ WRITE_acc_itm_4_1) & for_c_idx_0_lpi_1_dfm_2
          & (~ exitL_exit_for_sva);
      reg_din_rsci_ld_core_psct_cse <= 1'b1;
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      exitL_exit_for_sva <= 1'b1;
      exit_for_lpi_1_dfm_2 <= 1'b0;
    end
    else if ( for_and_cse ) begin
      exitL_exit_for_sva <= exit_for_lpi_1_dfm_2_mx0w0;
      exit_for_lpi_1_dfm_2 <= exit_for_lpi_1_dfm_2_mx0w0;
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      WRITE_y_idx_5_0_lpi_1_dfm_4 <= 6'b0;
    end
    else if ( core_wen & or_1_cse ) begin
      WRITE_y_idx_5_0_lpi_1_dfm_4 <= MUX_v_6_2_2(({{5{for_c_idx_0_lpi_1_dfm}}, for_c_idx_0_lpi_1_dfm}),
          WRITE_y_idx_5_0_sva_1, WRITE_acc_itm_4_1);
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      for_c_idx_0_lpi_1_dfm_2 <= 1'b0;
    end
    else if ( core_wen & (((~ WRITE_acc_itm_4_1) & (fsm_output[1])) | for_c_idx_0_lpi_1_dfm_1_mx0c1)
        ) begin
      for_c_idx_0_lpi_1_dfm_2 <= MUX_s_1_2_2((~ for_c_idx_0_lpi_1_dfm), for_c_idx_0_lpi_1_dfm,
          for_c_idx_0_lpi_1_dfm_1_mx0c1);
    end
  end

  function [0:0] MUX_s_1_2_2;
    input [0:0] input_0;
    input [0:0] input_1;
    input [0:0] sel;
    reg [0:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_s_1_2_2 = result;
  end
  endfunction


  function [5:0] MUX_v_6_2_2;
    input [5:0] input_0;
    input [5:0] input_1;
    input [0:0] sel;
    reg [5:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_6_2_2 = result;
  end
  endfunction


  function [0:0] readslicef_5_1_4;
    input [4:0] vector;
    reg [4:0] tmp;
  begin
    tmp = vector >> 4;
    readslicef_5_1_4 = tmp[0:0];
  end
  endfunction


  function  [4:0] conv_u2s_4_5 ;
    input [3:0]  vector ;
  begin
    conv_u2s_4_5 =  {1'b0, vector};
  end
  endfunction


  function  [4:0] conv_u2u_1_5 ;
    input [0:0]  vector ;
  begin
    conv_u2u_1_5 = {{4{1'b0}}, vector};
  end
  endfunction


  function  [4:0] conv_u2u_4_5 ;
    input [3:0]  vector ;
  begin
    conv_u2u_4_5 = {1'b0, vector};
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core
// ------------------------------------------------------------------


module READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core (
  clk, rst, din_0_rsc_req_vz, din_0_rsc_rls_lz, din_1_rsc_req_vz, din_1_rsc_rls_lz,
      din_2_rsc_req_vz, din_2_rsc_rls_lz, din_3_rsc_req_vz, din_3_rsc_rls_lz, dout_rsc_z,
      dout_rsc_vz, dout_rsc_lz, din_0_rsci_addr_d, din_0_rsci_re_d, din_0_rsci_data_out_d,
      din_1_rsci_addr_d, din_1_rsci_re_d, din_1_rsci_data_out_d, din_2_rsci_addr_d,
      din_2_rsci_re_d, din_2_rsci_data_out_d, din_3_rsci_addr_d, din_3_rsci_re_d,
      din_3_rsci_data_out_d
);
  input clk;
  input rst;
  input din_0_rsc_req_vz;
  output din_0_rsc_rls_lz;
  input din_1_rsc_req_vz;
  output din_1_rsc_rls_lz;
  input din_2_rsc_req_vz;
  output din_2_rsc_rls_lz;
  input din_3_rsc_req_vz;
  output din_3_rsc_rls_lz;
  output [127:0] dout_rsc_z;
  input dout_rsc_vz;
  output dout_rsc_lz;
  output [6:0] din_0_rsci_addr_d;
  output [1:0] din_0_rsci_re_d;
  input [31:0] din_0_rsci_data_out_d;
  output [6:0] din_1_rsci_addr_d;
  output [1:0] din_1_rsci_re_d;
  input [31:0] din_1_rsci_data_out_d;
  output [6:0] din_2_rsci_addr_d;
  output [1:0] din_2_rsci_re_d;
  input [31:0] din_2_rsci_data_out_d;
  output [6:0] din_3_rsci_addr_d;
  output [1:0] din_3_rsci_re_d;
  input [31:0] din_3_rsci_data_out_d;


  // Interconnect Declarations
  wire core_wen;
  wire [15:0] din_0_rsci_data_out_d_mxwt;
  wire core_wten;
  wire [15:0] din_1_rsci_data_out_d_mxwt;
  wire [15:0] din_2_rsci_data_out_d_mxwt;
  wire [15:0] din_3_rsci_data_out_d_mxwt;
  wire dout_rsci_wen_comp;
  wire din_3_rsc_req_obj_wen_comp;
  wire din_2_rsc_req_obj_wen_comp;
  wire din_1_rsc_req_obj_wen_comp;
  wire din_0_rsc_req_obj_wen_comp;
  reg [15:0] dout_rsci_d_111_96;
  reg [15:0] dout_rsci_d_79_64;
  reg [15:0] dout_rsci_d_47_32;
  reg [15:0] dout_rsci_d_15_0;
  wire [1:0] fsm_output;
  wire [2:0] READ_for_for_for_for_acc_1_tmp;
  wire [3:0] nl_READ_for_for_for_for_acc_1_tmp;
  wire [2:0] READ_for_for_for_for_for_acc_21_tmp;
  wire [3:0] nl_READ_for_for_for_for_for_acc_21_tmp;
  wire or_dcpl;
  wire or_dcpl_1;
  wire or_dcpl_7;
  wire or_dcpl_11;
  wire and_dcpl_1;
  wire and_dcpl_7;
  wire or_dcpl_30;
  wire or_dcpl_31;
  reg exitL_exit_READ_sva;
  reg exit_READ_for_for_for_for_lpi_1_dfm_2;
  reg exit_READ_for_for_for_lpi_1_dfm_2;
  reg READ_for_for_for_k_idx_0_lpi_1_dfm_3;
  reg exit_READ_for_for_lpi_1_dfm_2;
  reg exit_READ_for_sva_2;
  reg [1:0] READ_for_for_wy_idx_1_0_lpi_1_dfm_5;
  reg exit_READ_for_lpi_1_dfm_2;
  reg [1:0] READ_for_wx_idx_1_0_lpi_1_dfm_5;
  reg READ_c_idx_0_lpi_1_dfm_2;
  reg exit_READ_lpi_1_dfm_2;
  reg [1:0] READ_for_for_for_for_for_y_idx_2_0_lpi_1_dfm_2_1_0_2;
  reg [1:0] READ_for_for_for_for_x_idx_2_0_lpi_1_dfm_3_1_0_1;
  wire READ_for_acc_tmp_2;
  wire READ_for_for_acc_tmp_2;
  wire READ_c_idx_0_lpi_1_dfm;
  wire exit_READ_for_lpi_1_dfm_2_mx0w0;
  wire exit_READ_for_for_lpi_1_dfm_2_mx0w0;
  wire exit_READ_for_for_for_lpi_1_dfm_2_mx0w0;
  wire READ_for_for_for_k_idx_0_lpi_1_dfm;
  wire exit_READ_for_for_for_for_lpi_1_dfm_2_mx0w0;
  wire lfst_exit_READ_for_for_1_lpi_1_dfm;
  wire lfst_exit_READ_for_1_lpi_1_dfm;
  wire lfst_exit_READ_lpi_1_dfm;
  wire or_39_tmp;
  reg reg_din_3_rsc_req_obj_oswt_cse;
  wire dout_and_cse;
  reg reg_din_3_rsci_re_d_core_psct_0_cse;
  reg reg_din_3_rsc_rls_obj_ld_core_psct_cse;
  reg reg_dout_rsci_ld_core_psct_cse;
  wire READ_and_cse;
  wire or_25_cse;
  wire or_12_cse;
  wire [6:0] din_0_rsci_addr_d_reg;
  wire [1:0] READ_for_for_for_for_for_acc_rmff;
  wire [2:0] nl_READ_for_for_for_for_for_acc_rmff;
  wire [1:0] din_0_rsci_re_d_reg;
  wire [6:0] din_1_rsci_addr_d_reg;
  wire [1:0] din_1_rsci_re_d_reg;
  wire [6:0] din_2_rsci_addr_d_reg;
  wire [1:0] din_2_rsci_re_d_reg;
  wire [6:0] din_3_rsci_addr_d_reg;
  wire [1:0] din_3_rsci_re_d_reg;
  wire [3:0] READ_for_for_for_for_for_acc_sdt;
  wire [4:0] nl_READ_for_for_for_for_for_acc_sdt;
  wire [3:0] READ_for_for_for_for_for_acc_29_sdt;
  wire [4:0] nl_READ_for_for_for_for_for_acc_29_sdt;
  wire [2:0] READ_for_for_for_for_for_acc_23_sdt;
  wire [3:0] nl_READ_for_for_for_for_for_acc_23_sdt;
  wire exit_READ_lpi_1_dfm_2_mx0w0;
  wire READ_c_idx_0_lpi_1_dfm_1_mx0c1;
  wire [1:0] READ_for_wx_idx_1_0_sva_1;
  wire [2:0] nl_READ_for_wx_idx_1_0_sva_1;
  wire [1:0] READ_for_wx_idx_1_0_lpi_1_dfm;
  wire [1:0] READ_for_for_wy_idx_1_0_sva_1;
  wire [2:0] nl_READ_for_for_wy_idx_1_0_sva_1;
  wire [1:0] READ_for_for_wy_idx_1_0_lpi_1_dfm;
  wire [1:0] READ_for_for_for_for_x_idx_2_0_lpi_1_dfm_1_0;
  wire lfst_exit_READ_for_for_for_1_lpi_1_dfm;
  wire [1:0] READ_for_for_for_for_for_asn_18;

  wire[0:0] READ_for_for_for_for_x_idx_and_1_nl;
  wire[0:0] READ_for_for_wy_idx_and_nl;
  wire[0:0] READ_for_wx_idx_and_nl;
  wire[0:0] READ_for_mux_1_nl;
  wire[2:0] READ_for_for_for_for_for_acc_36_nl;
  wire[3:0] nl_READ_for_for_for_for_for_acc_36_nl;
  wire[2:0] READ_for_for_for_for_for_acc_38_nl;
  wire[3:0] nl_READ_for_for_for_for_for_acc_38_nl;
  wire[1:0] READ_for_for_for_for_for_acc_39_nl;
  wire[2:0] nl_READ_for_for_for_for_for_acc_39_nl;
  wire[0:0] READ_for_for_for_READ_for_for_for_and_1_nl;

  // Interconnect Declarations for Component Instantiations 
  wire [13:0] nl_READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_0_rsci_1_inst_din_0_rsci_addr_d_core;
  assign nl_READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_0_rsci_1_inst_din_0_rsci_addr_d_core
      = {7'b0 , READ_for_for_for_for_for_acc_rmff , (READ_for_for_for_for_for_acc_sdt[2:0])
      , (READ_for_for_for_for_for_acc_29_sdt[0]) , (READ_for_for_for_for_for_acc_23_sdt[0])};
  wire [1:0] nl_READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_0_rsci_1_inst_din_0_rsci_re_d_core_psct;
  assign nl_READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_0_rsci_1_inst_din_0_rsci_re_d_core_psct
      = {1'b0 , (fsm_output[1])};
  wire [0:0] nl_READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_0_rsci_1_inst_din_0_rsci_oswt_pff;
  assign nl_READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_0_rsci_1_inst_din_0_rsci_oswt_pff
      = fsm_output[1];
  wire [13:0] nl_READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_1_rsci_1_inst_din_1_rsci_addr_d_core;
  assign nl_READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_1_rsci_1_inst_din_1_rsci_addr_d_core
      = {7'b0 , READ_for_for_for_for_for_acc_rmff , (READ_for_for_for_for_for_acc_sdt[2:0])
      , (READ_for_for_for_for_for_acc_29_sdt[0]) , (READ_for_for_for_for_for_acc_23_sdt[0])};
  wire [1:0] nl_READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_1_rsci_1_inst_din_1_rsci_re_d_core_psct;
  assign nl_READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_1_rsci_1_inst_din_1_rsci_re_d_core_psct
      = {1'b0 , (fsm_output[1])};
  wire [0:0] nl_READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_1_rsci_1_inst_din_1_rsci_oswt_pff;
  assign nl_READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_1_rsci_1_inst_din_1_rsci_oswt_pff
      = fsm_output[1];
  wire [13:0] nl_READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_2_rsci_1_inst_din_2_rsci_addr_d_core;
  assign nl_READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_2_rsci_1_inst_din_2_rsci_addr_d_core
      = {7'b0 , READ_for_for_for_for_for_acc_rmff , (READ_for_for_for_for_for_acc_sdt[2:0])
      , (READ_for_for_for_for_for_acc_29_sdt[0]) , (READ_for_for_for_for_for_acc_23_sdt[0])};
  wire [1:0] nl_READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_2_rsci_1_inst_din_2_rsci_re_d_core_psct;
  assign nl_READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_2_rsci_1_inst_din_2_rsci_re_d_core_psct
      = {1'b0 , (fsm_output[1])};
  wire [0:0] nl_READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_2_rsci_1_inst_din_2_rsci_oswt_pff;
  assign nl_READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_2_rsci_1_inst_din_2_rsci_oswt_pff
      = fsm_output[1];
  wire [13:0] nl_READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_3_rsci_1_inst_din_3_rsci_addr_d_core;
  assign nl_READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_3_rsci_1_inst_din_3_rsci_addr_d_core
      = {7'b0 , READ_for_for_for_for_for_acc_rmff , (READ_for_for_for_for_for_acc_sdt[2:0])
      , (READ_for_for_for_for_for_acc_29_sdt[0]) , (READ_for_for_for_for_for_acc_23_sdt[0])};
  wire [1:0] nl_READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_3_rsci_1_inst_din_3_rsci_re_d_core_psct;
  assign nl_READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_3_rsci_1_inst_din_3_rsci_re_d_core_psct
      = {1'b0 , (fsm_output[1])};
  wire [0:0] nl_READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_3_rsci_1_inst_din_3_rsci_oswt_pff;
  assign nl_READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_3_rsci_1_inst_din_3_rsci_oswt_pff
      = fsm_output[1];
  wire [127:0] nl_READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_dout_rsci_inst_dout_rsci_d;
  assign nl_READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_dout_rsci_inst_dout_rsci_d =
      signext_128_112({dout_rsci_d_111_96 , ({{16{dout_rsci_d_79_64[15]}}, dout_rsci_d_79_64})
      , ({{16{dout_rsci_d_47_32[15]}}, dout_rsci_d_47_32}) , ({{16{dout_rsci_d_15_0[15]}},
      dout_rsci_d_15_0})});
  READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_0_rsci_1 READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_0_rsci_1_inst
      (
      .clk(clk),
      .rst(rst),
      .din_0_rsci_addr_d(din_0_rsci_addr_d_reg),
      .din_0_rsci_re_d(din_0_rsci_re_d_reg),
      .din_0_rsci_data_out_d(din_0_rsci_data_out_d),
      .core_wen(core_wen),
      .din_0_rsci_oswt(reg_din_3_rsci_re_d_core_psct_0_cse),
      .din_0_rsci_addr_d_core(nl_READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_0_rsci_1_inst_din_0_rsci_addr_d_core[13:0]),
      .din_0_rsci_re_d_core_psct(nl_READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_0_rsci_1_inst_din_0_rsci_re_d_core_psct[1:0]),
      .din_0_rsci_data_out_d_mxwt(din_0_rsci_data_out_d_mxwt),
      .core_wten(core_wten),
      .din_0_rsci_oswt_pff(nl_READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_0_rsci_1_inst_din_0_rsci_oswt_pff[0:0])
    );
  READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_1_rsci_1 READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_1_rsci_1_inst
      (
      .clk(clk),
      .rst(rst),
      .din_1_rsci_addr_d(din_1_rsci_addr_d_reg),
      .din_1_rsci_re_d(din_1_rsci_re_d_reg),
      .din_1_rsci_data_out_d(din_1_rsci_data_out_d),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .din_1_rsci_oswt(reg_din_3_rsci_re_d_core_psct_0_cse),
      .din_1_rsci_addr_d_core(nl_READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_1_rsci_1_inst_din_1_rsci_addr_d_core[13:0]),
      .din_1_rsci_re_d_core_psct(nl_READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_1_rsci_1_inst_din_1_rsci_re_d_core_psct[1:0]),
      .din_1_rsci_data_out_d_mxwt(din_1_rsci_data_out_d_mxwt),
      .din_1_rsci_oswt_pff(nl_READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_1_rsci_1_inst_din_1_rsci_oswt_pff[0:0])
    );
  READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_2_rsci_1 READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_2_rsci_1_inst
      (
      .clk(clk),
      .rst(rst),
      .din_2_rsci_addr_d(din_2_rsci_addr_d_reg),
      .din_2_rsci_re_d(din_2_rsci_re_d_reg),
      .din_2_rsci_data_out_d(din_2_rsci_data_out_d),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .din_2_rsci_oswt(reg_din_3_rsci_re_d_core_psct_0_cse),
      .din_2_rsci_addr_d_core(nl_READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_2_rsci_1_inst_din_2_rsci_addr_d_core[13:0]),
      .din_2_rsci_re_d_core_psct(nl_READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_2_rsci_1_inst_din_2_rsci_re_d_core_psct[1:0]),
      .din_2_rsci_data_out_d_mxwt(din_2_rsci_data_out_d_mxwt),
      .din_2_rsci_oswt_pff(nl_READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_2_rsci_1_inst_din_2_rsci_oswt_pff[0:0])
    );
  READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_3_rsci_1 READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_3_rsci_1_inst
      (
      .clk(clk),
      .rst(rst),
      .din_3_rsci_addr_d(din_3_rsci_addr_d_reg),
      .din_3_rsci_re_d(din_3_rsci_re_d_reg),
      .din_3_rsci_data_out_d(din_3_rsci_data_out_d),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .din_3_rsci_oswt(reg_din_3_rsci_re_d_core_psct_0_cse),
      .din_3_rsci_addr_d_core(nl_READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_3_rsci_1_inst_din_3_rsci_addr_d_core[13:0]),
      .din_3_rsci_re_d_core_psct(nl_READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_3_rsci_1_inst_din_3_rsci_re_d_core_psct[1:0]),
      .din_3_rsci_data_out_d_mxwt(din_3_rsci_data_out_d_mxwt),
      .din_3_rsci_oswt_pff(nl_READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_3_rsci_1_inst_din_3_rsci_oswt_pff[0:0])
    );
  READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_dout_rsci READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_dout_rsci_inst
      (
      .clk(clk),
      .rst(rst),
      .dout_rsc_z(dout_rsc_z),
      .dout_rsc_vz(dout_rsc_vz),
      .dout_rsc_lz(dout_rsc_lz),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .dout_rsci_oswt(reg_dout_rsci_ld_core_psct_cse),
      .dout_rsci_wen_comp(dout_rsci_wen_comp),
      .dout_rsci_d(nl_READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_dout_rsci_inst_dout_rsci_d[127:0])
    );
  READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_0_rsc_rls_obj READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_0_rsc_rls_obj_inst
      (
      .din_0_rsc_rls_lz(din_0_rsc_rls_lz),
      .core_wten(core_wten),
      .din_0_rsc_rls_obj_iswt0(reg_din_3_rsc_rls_obj_ld_core_psct_cse)
    );
  READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_1_rsc_rls_obj READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_1_rsc_rls_obj_inst
      (
      .din_1_rsc_rls_lz(din_1_rsc_rls_lz),
      .core_wten(core_wten),
      .din_1_rsc_rls_obj_iswt0(reg_din_3_rsc_rls_obj_ld_core_psct_cse)
    );
  READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_2_rsc_rls_obj READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_2_rsc_rls_obj_inst
      (
      .din_2_rsc_rls_lz(din_2_rsc_rls_lz),
      .core_wten(core_wten),
      .din_2_rsc_rls_obj_iswt0(reg_din_3_rsc_rls_obj_ld_core_psct_cse)
    );
  READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_3_rsc_rls_obj READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_3_rsc_rls_obj_inst
      (
      .din_3_rsc_rls_lz(din_3_rsc_rls_lz),
      .core_wten(core_wten),
      .din_3_rsc_rls_obj_iswt0(reg_din_3_rsc_rls_obj_ld_core_psct_cse)
    );
  READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_3_rsc_req_obj READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_3_rsc_req_obj_inst
      (
      .clk(clk),
      .rst(rst),
      .din_3_rsc_req_vz(din_3_rsc_req_vz),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .din_3_rsc_req_obj_oswt(reg_din_3_rsc_req_obj_oswt_cse),
      .din_3_rsc_req_obj_wen_comp(din_3_rsc_req_obj_wen_comp)
    );
  READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_2_rsc_req_obj READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_2_rsc_req_obj_inst
      (
      .clk(clk),
      .rst(rst),
      .din_2_rsc_req_vz(din_2_rsc_req_vz),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .din_2_rsc_req_obj_oswt(reg_din_3_rsc_req_obj_oswt_cse),
      .din_2_rsc_req_obj_wen_comp(din_2_rsc_req_obj_wen_comp)
    );
  READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_1_rsc_req_obj READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_1_rsc_req_obj_inst
      (
      .clk(clk),
      .rst(rst),
      .din_1_rsc_req_vz(din_1_rsc_req_vz),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .din_1_rsc_req_obj_oswt(reg_din_3_rsc_req_obj_oswt_cse),
      .din_1_rsc_req_obj_wen_comp(din_1_rsc_req_obj_wen_comp)
    );
  READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_0_rsc_req_obj READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_din_0_rsc_req_obj_inst
      (
      .clk(clk),
      .rst(rst),
      .din_0_rsc_req_vz(din_0_rsc_req_vz),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .din_0_rsc_req_obj_oswt(reg_din_3_rsc_req_obj_oswt_cse),
      .din_0_rsc_req_obj_wen_comp(din_0_rsc_req_obj_wen_comp)
    );
  READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_staller READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_staller_inst
      (
      .clk(clk),
      .rst(rst),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .dout_rsci_wen_comp(dout_rsci_wen_comp),
      .din_3_rsc_req_obj_wen_comp(din_3_rsc_req_obj_wen_comp),
      .din_2_rsc_req_obj_wen_comp(din_2_rsc_req_obj_wen_comp),
      .din_1_rsc_req_obj_wen_comp(din_1_rsc_req_obj_wen_comp),
      .din_0_rsc_req_obj_wen_comp(din_0_rsc_req_obj_wen_comp)
    );
  READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_core_fsm READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_core_fsm_inst
      (
      .clk(clk),
      .rst(rst),
      .core_wen(core_wen),
      .fsm_output(fsm_output)
    );
  assign or_25_cse = or_dcpl_11 | or_dcpl_7 | READ_for_acc_tmp_2 | exitL_exit_READ_sva
      | (~ READ_c_idx_0_lpi_1_dfm_2);
  assign dout_and_cse = core_wen & reg_din_3_rsci_re_d_core_psct_0_cse;
  assign nl_READ_for_for_for_for_for_acc_rmff = conv_u2u_1_2(READ_for_for_for_for_for_acc_sdt[3])
      + conv_u2u_1_2(READ_c_idx_0_lpi_1_dfm);
  assign READ_for_for_for_for_for_acc_rmff = nl_READ_for_for_for_for_for_acc_rmff[1:0];
  assign READ_and_cse = core_wen & (~ (fsm_output[0]));
  assign or_39_tmp = or_dcpl_30 | or_dcpl_1 | exitL_exit_READ_sva;
  assign or_12_cse = or_dcpl_11 | or_dcpl_7 | READ_for_acc_tmp_2 | exitL_exit_READ_sva;
  assign exit_READ_lpi_1_dfm_2_mx0w0 = READ_c_idx_0_lpi_1_dfm & exit_READ_for_lpi_1_dfm_2_mx0w0;
  assign READ_for_acc_tmp_2 = (READ_for_wx_idx_1_0_sva_1[0]) ^ (READ_for_wx_idx_1_0_sva_1[1]);
  assign READ_for_mux_1_nl = MUX_s_1_2_2((~ READ_for_acc_tmp_2), exit_READ_for_sva_2,
      or_dcpl_31);
  assign exit_READ_for_lpi_1_dfm_2_mx0w0 = (READ_for_mux_1_nl) & exit_READ_for_for_lpi_1_dfm_2_mx0w0;
  assign exit_READ_for_for_lpi_1_dfm_2_mx0w0 = (~ READ_for_for_acc_tmp_2) & exit_READ_for_for_for_lpi_1_dfm_2_mx0w0;
  assign exit_READ_for_for_for_lpi_1_dfm_2_mx0w0 = READ_for_for_for_k_idx_0_lpi_1_dfm
      & exit_READ_for_for_for_for_lpi_1_dfm_2_mx0w0;
  assign exit_READ_for_for_for_for_lpi_1_dfm_2_mx0w0 = (READ_for_for_for_for_acc_1_tmp[2])
      & (READ_for_for_for_for_for_acc_21_tmp[2]);
  assign nl_READ_for_wx_idx_1_0_sva_1 = READ_for_wx_idx_1_0_lpi_1_dfm + 2'b1;
  assign READ_for_wx_idx_1_0_sva_1 = nl_READ_for_wx_idx_1_0_sva_1[1:0];
  assign READ_for_wx_idx_1_0_lpi_1_dfm = MUX_v_2_2_2(2'b00, READ_for_wx_idx_1_0_lpi_1_dfm_5,
      lfst_exit_READ_lpi_1_dfm);
  assign READ_for_for_acc_tmp_2 = (READ_for_for_wy_idx_1_0_sva_1[0]) ^ (READ_for_for_wy_idx_1_0_sva_1[1]);
  assign nl_READ_for_for_wy_idx_1_0_sva_1 = READ_for_for_wy_idx_1_0_lpi_1_dfm + 2'b1;
  assign READ_for_for_wy_idx_1_0_sva_1 = nl_READ_for_for_wy_idx_1_0_sva_1[1:0];
  assign READ_for_for_wy_idx_1_0_lpi_1_dfm = MUX_v_2_2_2(2'b00, READ_for_for_wy_idx_1_0_lpi_1_dfm_5,
      lfst_exit_READ_for_1_lpi_1_dfm);
  assign nl_READ_for_for_for_for_acc_1_tmp = conv_u2u_2_3(READ_for_for_for_for_x_idx_2_0_lpi_1_dfm_1_0)
      + 3'b1;
  assign READ_for_for_for_for_acc_1_tmp = nl_READ_for_for_for_for_acc_1_tmp[2:0];
  assign READ_for_for_for_for_x_idx_2_0_lpi_1_dfm_1_0 = MUX_v_2_2_2(2'b00, READ_for_for_for_for_x_idx_2_0_lpi_1_dfm_3_1_0_1,
      lfst_exit_READ_for_for_for_1_lpi_1_dfm);
  assign READ_c_idx_0_lpi_1_dfm = READ_c_idx_0_lpi_1_dfm_2 & (~ exitL_exit_READ_sva);
  assign READ_for_for_for_k_idx_0_lpi_1_dfm = READ_for_for_for_k_idx_0_lpi_1_dfm_3
      & lfst_exit_READ_for_for_1_lpi_1_dfm;
  assign nl_READ_for_for_for_for_for_acc_21_tmp = conv_u2u_2_3(READ_for_for_for_for_for_asn_18)
      + 3'b1;
  assign READ_for_for_for_for_for_acc_21_tmp = nl_READ_for_for_for_for_for_acc_21_tmp[2:0];
  assign nl_READ_for_for_for_for_for_acc_23_sdt = conv_u2u_2_3(READ_for_for_for_for_for_asn_18)
      + conv_u2u_2_3(READ_for_for_wy_idx_1_0_lpi_1_dfm);
  assign READ_for_for_for_for_for_acc_23_sdt = nl_READ_for_for_for_for_for_acc_23_sdt[2:0];
  assign nl_READ_for_for_for_for_for_acc_36_nl = conv_u2u_2_3(READ_for_for_for_for_x_idx_2_0_lpi_1_dfm_1_0)
      + conv_u2u_2_3(READ_for_wx_idx_1_0_lpi_1_dfm);
  assign READ_for_for_for_for_for_acc_36_nl = nl_READ_for_for_for_for_for_acc_36_nl[2:0];
  assign nl_READ_for_for_for_for_for_acc_sdt = conv_u2u_3_4(READ_for_for_for_for_for_acc_36_nl)
      + conv_u2u_3_4(READ_for_for_for_for_for_acc_29_sdt[3:1]);
  assign READ_for_for_for_for_for_acc_sdt = nl_READ_for_for_for_for_for_acc_sdt[3:0];
  assign nl_READ_for_for_for_for_for_acc_38_nl = conv_u2u_2_3(READ_for_for_for_for_for_acc_23_sdt[2:1])
      + conv_u2u_2_3(READ_for_for_for_for_x_idx_2_0_lpi_1_dfm_1_0);
  assign READ_for_for_for_for_for_acc_38_nl = nl_READ_for_for_for_for_for_acc_38_nl[2:0];
  assign nl_READ_for_for_for_for_for_acc_39_nl = conv_u2u_1_2(READ_for_wx_idx_1_0_lpi_1_dfm[1])
      + conv_u2u_1_2(READ_c_idx_0_lpi_1_dfm);
  assign READ_for_for_for_for_for_acc_39_nl = nl_READ_for_for_for_for_for_acc_39_nl[1:0];
  assign nl_READ_for_for_for_for_for_acc_29_sdt = conv_u2u_3_4(READ_for_for_for_for_for_acc_38_nl)
      + conv_u2u_3_4({(READ_for_for_for_for_for_acc_39_nl) , (READ_for_wx_idx_1_0_lpi_1_dfm[0])});
  assign READ_for_for_for_for_for_acc_29_sdt = nl_READ_for_for_for_for_for_acc_29_sdt[3:0];
  assign lfst_exit_READ_for_for_for_1_lpi_1_dfm = (~ exit_READ_for_for_for_lpi_1_dfm_2)
      & lfst_exit_READ_for_for_1_lpi_1_dfm;
  assign lfst_exit_READ_for_for_1_lpi_1_dfm = (~ exit_READ_for_for_lpi_1_dfm_2) &
      lfst_exit_READ_for_1_lpi_1_dfm;
  assign lfst_exit_READ_for_1_lpi_1_dfm = (~ exit_READ_for_lpi_1_dfm_2) & lfst_exit_READ_lpi_1_dfm;
  assign lfst_exit_READ_lpi_1_dfm = ~(exit_READ_lpi_1_dfm_2 | exitL_exit_READ_sva);
  assign READ_for_for_for_READ_for_for_for_and_1_nl = (~ exit_READ_for_for_for_for_lpi_1_dfm_2)
      & lfst_exit_READ_for_for_for_1_lpi_1_dfm;
  assign READ_for_for_for_for_for_asn_18 = MUX_v_2_2_2(2'b00, READ_for_for_for_for_for_y_idx_2_0_lpi_1_dfm_2_1_0_2,
      (READ_for_for_for_READ_for_for_for_and_1_nl));
  assign or_dcpl = ~((READ_for_for_for_for_for_acc_21_tmp[2]) & (READ_for_for_for_for_acc_1_tmp[2]));
  assign or_dcpl_1 = exit_READ_for_lpi_1_dfm_2 | exit_READ_lpi_1_dfm_2;
  assign or_dcpl_7 = exit_READ_lpi_1_dfm_2 | READ_for_for_acc_tmp_2;
  assign or_dcpl_11 = or_dcpl | (~ READ_for_for_for_k_idx_0_lpi_1_dfm_3) | exit_READ_for_for_lpi_1_dfm_2
      | exit_READ_for_lpi_1_dfm_2;
  assign and_dcpl_1 = ~(exit_READ_lpi_1_dfm_2 | READ_for_for_acc_tmp_2);
  assign and_dcpl_7 = (READ_for_for_for_for_for_acc_21_tmp[2]) & (READ_for_for_for_for_acc_1_tmp[2])
      & READ_for_for_for_k_idx_0_lpi_1_dfm_3 & (~(exit_READ_for_for_lpi_1_dfm_2 |
      exit_READ_for_lpi_1_dfm_2));
  assign or_dcpl_30 = or_dcpl | (~ READ_for_for_for_k_idx_0_lpi_1_dfm_3) | exit_READ_for_for_lpi_1_dfm_2;
  assign or_dcpl_31 = or_dcpl_30 | or_dcpl_1 | READ_for_for_acc_tmp_2 | exitL_exit_READ_sva;
  assign READ_c_idx_0_lpi_1_dfm_1_mx0c1 = (or_12_cse & (fsm_output[1])) | (~((~(or_dcpl_30
      | or_dcpl_1 | READ_for_for_acc_tmp_2 | READ_for_acc_tmp_2)) | exitL_exit_READ_sva));
  assign din_0_rsci_re_d = din_0_rsci_re_d_reg;
  assign din_1_rsci_re_d = din_1_rsci_re_d_reg;
  assign din_2_rsci_re_d = din_2_rsci_re_d_reg;
  assign din_3_rsci_re_d = din_3_rsci_re_d_reg;
  assign din_0_rsci_addr_d = din_0_rsci_addr_d_reg;
  assign din_1_rsci_addr_d = din_1_rsci_addr_d_reg;
  assign din_2_rsci_addr_d = din_2_rsci_addr_d_reg;
  assign din_3_rsci_addr_d = din_3_rsci_addr_d_reg;
  always @(posedge clk) begin
    if ( rst ) begin
      reg_din_3_rsc_req_obj_oswt_cse <= 1'b0;
      reg_din_3_rsci_re_d_core_psct_0_cse <= 1'b0;
      reg_din_3_rsc_rls_obj_ld_core_psct_cse <= 1'b0;
      reg_dout_rsci_ld_core_psct_cse <= 1'b0;
    end
    else if ( core_wen ) begin
      reg_din_3_rsc_req_obj_oswt_cse <= ~(or_25_cse & (fsm_output[1]));
      reg_din_3_rsci_re_d_core_psct_0_cse <= fsm_output[1];
      reg_din_3_rsc_rls_obj_ld_core_psct_cse <= and_dcpl_7 & and_dcpl_1 & (~ READ_for_acc_tmp_2)
          & (~ exitL_exit_READ_sva) & READ_c_idx_0_lpi_1_dfm_2;
      reg_dout_rsci_ld_core_psct_cse <= reg_din_3_rsci_re_d_core_psct_0_cse;
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      dout_rsci_d_15_0 <= 16'b0;
      dout_rsci_d_47_32 <= 16'b0;
      dout_rsci_d_79_64 <= 16'b0;
      dout_rsci_d_111_96 <= 16'b0;
    end
    else if ( dout_and_cse ) begin
      dout_rsci_d_15_0 <= din_0_rsci_data_out_d_mxwt;
      dout_rsci_d_47_32 <= din_1_rsci_data_out_d_mxwt;
      dout_rsci_d_79_64 <= din_2_rsci_data_out_d_mxwt;
      dout_rsci_d_111_96 <= din_3_rsci_data_out_d_mxwt;
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      exitL_exit_READ_sva <= 1'b1;
      exit_READ_lpi_1_dfm_2 <= 1'b0;
      exit_READ_for_lpi_1_dfm_2 <= 1'b0;
      exit_READ_for_for_lpi_1_dfm_2 <= 1'b0;
      exit_READ_for_for_for_lpi_1_dfm_2 <= 1'b0;
      exit_READ_for_for_for_for_lpi_1_dfm_2 <= 1'b0;
      READ_for_for_for_k_idx_0_lpi_1_dfm_3 <= 1'b0;
    end
    else if ( READ_and_cse ) begin
      exitL_exit_READ_sva <= exit_READ_lpi_1_dfm_2_mx0w0;
      exit_READ_lpi_1_dfm_2 <= exit_READ_lpi_1_dfm_2_mx0w0;
      exit_READ_for_lpi_1_dfm_2 <= exit_READ_for_lpi_1_dfm_2_mx0w0;
      exit_READ_for_for_lpi_1_dfm_2 <= exit_READ_for_for_lpi_1_dfm_2_mx0w0;
      exit_READ_for_for_for_lpi_1_dfm_2 <= exit_READ_for_for_for_lpi_1_dfm_2_mx0w0;
      exit_READ_for_for_for_for_lpi_1_dfm_2 <= exit_READ_for_for_for_for_lpi_1_dfm_2_mx0w0;
      READ_for_for_for_k_idx_0_lpi_1_dfm_3 <= MUX_s_1_2_2(READ_for_for_for_k_idx_0_lpi_1_dfm,
          (~ READ_for_for_for_k_idx_0_lpi_1_dfm), exit_READ_for_for_for_for_lpi_1_dfm_2_mx0w0);
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      exit_READ_for_sva_2 <= 1'b0;
    end
    else if ( core_wen & (~ or_dcpl_31) ) begin
      exit_READ_for_sva_2 <= ~ READ_for_acc_tmp_2;
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      READ_for_for_for_for_for_y_idx_2_0_lpi_1_dfm_2_1_0_2 <= 2'b0;
    end
    else if ( core_wen & or_dcpl ) begin
      READ_for_for_for_for_for_y_idx_2_0_lpi_1_dfm_2_1_0_2 <= READ_for_for_for_for_for_acc_21_tmp[1:0];
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      READ_for_for_for_for_x_idx_2_0_lpi_1_dfm_3_1_0_1 <= 2'b0;
    end
    else if ( core_wen & (or_dcpl | (~ READ_for_for_for_k_idx_0_lpi_1_dfm_3) | exit_READ_for_for_lpi_1_dfm_2
        | or_dcpl_1 | exitL_exit_READ_sva) ) begin
      READ_for_for_for_for_x_idx_2_0_lpi_1_dfm_3_1_0_1 <= MUX1HOT_v_2_3_2(({{1{READ_for_for_for_k_idx_0_lpi_1_dfm}},
          READ_for_for_for_k_idx_0_lpi_1_dfm}), READ_for_for_for_for_x_idx_2_0_lpi_1_dfm_1_0,
          (READ_for_for_for_for_acc_1_tmp[1:0]), {(~ or_dcpl) , (~ (READ_for_for_for_for_for_acc_21_tmp[2]))
          , (READ_for_for_for_for_x_idx_and_1_nl)});
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      READ_for_for_wy_idx_1_0_lpi_1_dfm_5 <= 2'b0;
    end
    else if ( core_wen & or_12_cse ) begin
      READ_for_for_wy_idx_1_0_lpi_1_dfm_5 <= MUX1HOT_v_2_3_2((signext_2_1(~ READ_for_acc_tmp_2)),
          READ_for_for_wy_idx_1_0_sva_1, READ_for_for_wy_idx_1_0_lpi_1_dfm, {(~ or_dcpl_31)
          , (READ_for_for_wy_idx_and_nl) , or_39_tmp});
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      READ_for_wx_idx_1_0_lpi_1_dfm_5 <= 2'b0;
    end
    else if ( core_wen & or_25_cse ) begin
      READ_for_wx_idx_1_0_lpi_1_dfm_5 <= MUX1HOT_v_2_3_2(({{1{READ_c_idx_0_lpi_1_dfm}},
          READ_c_idx_0_lpi_1_dfm}), READ_for_wx_idx_1_0_sva_1, READ_for_wx_idx_1_0_lpi_1_dfm,
          {(~ or_12_cse) , (READ_for_wx_idx_and_nl) , or_dcpl_31});
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      READ_c_idx_0_lpi_1_dfm_2 <= 1'b0;
    end
    else if ( core_wen & ((and_dcpl_7 & and_dcpl_1 & (~ READ_for_acc_tmp_2) & (~
        exitL_exit_READ_sva)) | READ_c_idx_0_lpi_1_dfm_1_mx0c1) ) begin
      READ_c_idx_0_lpi_1_dfm_2 <= MUX_s_1_2_2((~ READ_c_idx_0_lpi_1_dfm), READ_c_idx_0_lpi_1_dfm,
          READ_c_idx_0_lpi_1_dfm_1_mx0c1);
    end
  end
  assign READ_for_for_for_for_x_idx_and_1_nl = (READ_for_for_for_for_for_acc_21_tmp[2])
      & or_dcpl;
  assign READ_for_for_wy_idx_and_nl = (~ or_39_tmp) & or_dcpl_31;
  assign READ_for_wx_idx_and_nl = (~ or_dcpl_31) & or_12_cse;

  function [1:0] MUX1HOT_v_2_3_2;
    input [1:0] input_2;
    input [1:0] input_1;
    input [1:0] input_0;
    input [2:0] sel;
    reg [1:0] result;
  begin
    result = input_0 & {2{sel[0]}};
    result = result | ( input_1 & {2{sel[1]}});
    result = result | ( input_2 & {2{sel[2]}});
    MUX1HOT_v_2_3_2 = result;
  end
  endfunction


  function [0:0] MUX_s_1_2_2;
    input [0:0] input_0;
    input [0:0] input_1;
    input [0:0] sel;
    reg [0:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_s_1_2_2 = result;
  end
  endfunction


  function [1:0] MUX_v_2_2_2;
    input [1:0] input_0;
    input [1:0] input_1;
    input [0:0] sel;
    reg [1:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_2_2_2 = result;
  end
  endfunction


  function [127:0] signext_128_112;
    input [111:0] vector;
  begin
    signext_128_112= {{16{vector[111]}}, vector};
  end
  endfunction


  function [1:0] signext_2_1;
    input [0:0] vector;
  begin
    signext_2_1= {{1{vector[0]}}, vector};
  end
  endfunction


  function  [1:0] conv_u2u_1_2 ;
    input [0:0]  vector ;
  begin
    conv_u2u_1_2 = {1'b0, vector};
  end
  endfunction


  function  [2:0] conv_u2u_2_3 ;
    input [1:0]  vector ;
  begin
    conv_u2u_2_3 = {1'b0, vector};
  end
  endfunction


  function  [3:0] conv_u2u_3_4 ;
    input [2:0]  vector ;
  begin
    conv_u2u_3_4 = {1'b0, vector};
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core
// ------------------------------------------------------------------


module WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core (
  clk, rst, din_rsc_z, din_rsc_vz, din_rsc_lz, dout_0_rsc_req_vz, dout_0_rsc_rls_lz,
      dout_1_rsc_req_vz, dout_1_rsc_rls_lz, dout_2_rsc_req_vz, dout_2_rsc_rls_lz,
      dout_3_rsc_req_vz, dout_3_rsc_rls_lz, dout_0_rsci_data_in_d, dout_0_rsci_addr_d,
      dout_0_rsci_we_d, dout_1_rsci_data_in_d, dout_1_rsci_addr_d, dout_1_rsci_we_d,
      dout_2_rsci_data_in_d, dout_2_rsci_addr_d, dout_2_rsci_we_d, dout_3_rsci_data_in_d,
      dout_3_rsci_addr_d, dout_3_rsci_we_d
);
  input clk;
  input rst;
  input [255:0] din_rsc_z;
  input din_rsc_vz;
  output din_rsc_lz;
  input dout_0_rsc_req_vz;
  output dout_0_rsc_rls_lz;
  input dout_1_rsc_req_vz;
  output dout_1_rsc_rls_lz;
  input dout_2_rsc_req_vz;
  output dout_2_rsc_rls_lz;
  input dout_3_rsc_req_vz;
  output dout_3_rsc_rls_lz;
  output [63:0] dout_0_rsci_data_in_d;
  output [7:0] dout_0_rsci_addr_d;
  output [1:0] dout_0_rsci_we_d;
  output [63:0] dout_1_rsci_data_in_d;
  output [7:0] dout_1_rsci_addr_d;
  output [1:0] dout_1_rsci_we_d;
  output [63:0] dout_2_rsci_data_in_d;
  output [7:0] dout_2_rsci_addr_d;
  output [1:0] dout_2_rsci_we_d;
  output [63:0] dout_3_rsci_data_in_d;
  output [7:0] dout_3_rsci_addr_d;
  output [1:0] dout_3_rsci_we_d;


  // Interconnect Declarations
  wire core_wen;
  wire din_rsci_wen_comp;
  wire [255:0] din_rsci_d_mxwt;
  wire core_wten;
  wire dout_3_rsc_req_obj_wen_comp;
  wire dout_2_rsc_req_obj_wen_comp;
  wire dout_1_rsc_req_obj_wen_comp;
  wire dout_0_rsc_req_obj_wen_comp;
  wire [1:0] fsm_output;
  wire [2:0] WRITE_acc_13_tmp;
  wire [3:0] nl_WRITE_acc_13_tmp;
  wire or_dcpl;
  wire or_dcpl_1;
  wire or_dcpl_7;
  wire and_dcpl_3;
  reg exitL_exit_for_sva;
  reg exit_for_for_for_lpi_1_dfm_2;
  reg [3:0] for_for_for_wx_idx_3_0_lpi_1_dfm_5;
  reg exit_for_for_lpi_1_dfm_2;
  reg for_k_idx_0_lpi_1_dfm_2;
  reg for_for_c_idx_0_lpi_1_dfm_3;
  reg exit_for_lpi_1_dfm_2;
  reg [1:0] WRITE_r_idx_2_0_lpi_1_dfm_2_1_0_2;
  wire for_k_idx_0_lpi_1_dfm;
  wire exit_for_for_lpi_1_dfm_2_mx0w0;
  wire for_for_c_idx_0_lpi_1_dfm;
  wire exit_for_for_for_lpi_1_dfm_2_mx0w0;
  wire lfst_exit_for_lpi_1_dfm;
  reg reg_dout_3_rsc_req_obj_oswt_cse;
  reg reg_dout_0_rsc_rls_obj_ld_core_psct_cse;
  reg reg_din_rsci_ld_core_psct_cse;
  wire for_and_cse;
  wire [63:0] dout_0_rsci_data_in_d_reg;
  wire [7:0] dout_0_rsci_addr_d_reg;
  wire [1:0] WRITE_acc_rmff;
  wire [2:0] nl_WRITE_acc_rmff;
  wire [1:0] dout_0_rsci_we_d_reg;
  wire [63:0] dout_1_rsci_data_in_d_reg;
  wire [7:0] dout_1_rsci_addr_d_reg;
  wire [1:0] dout_1_rsci_we_d_reg;
  wire [63:0] dout_2_rsci_data_in_d_reg;
  wire [7:0] dout_2_rsci_addr_d_reg;
  wire [1:0] dout_2_rsci_we_d_reg;
  wire [63:0] dout_3_rsci_data_in_d_reg;
  wire [7:0] dout_3_rsci_addr_d_reg;
  wire [1:0] dout_3_rsci_we_d_reg;
  wire [4:0] WRITE_acc_sdt;
  wire [5:0] nl_WRITE_acc_sdt;
  wire [1:0] WRITE_r_idx_2_0_lpi_1_dfm_1_0;
  wire exit_for_lpi_1_dfm_2_mx0w0;
  wire for_k_idx_0_lpi_1_dfm_1_mx0c1;
  wire [3:0] for_for_for_wx_idx_3_0_sva_1;
  wire [4:0] nl_for_for_for_wx_idx_3_0_sva_1;
  wire [3:0] for_for_for_wx_idx_3_0_lpi_1_dfm;
  wire lfst_exit_for_for_1_lpi_1_dfm;
  wire for_for_for_acc_itm_3_1;

  wire[0:0] for_for_for_wx_idx_and_1_nl;
  wire[0:0] for_for_for_for_and_1_nl;
  wire[3:0] for_for_for_acc_nl;
  wire[4:0] nl_for_for_for_acc_nl;

  // Interconnect Declarations for Component Instantiations 
  wire [0:0] nl_WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_0_rsci_1_inst_core_wten;
  assign nl_WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_0_rsci_1_inst_core_wten
      = ~ core_wen;
  wire [0:0] nl_WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_0_rsci_1_inst_dout_0_rsci_iswt0;
  assign nl_WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_0_rsci_1_inst_dout_0_rsci_iswt0
      = fsm_output[1];
  wire [127:0] nl_WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_0_rsci_1_inst_dout_0_rsci_data_in_d_core;
  assign nl_WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_0_rsci_1_inst_dout_0_rsci_data_in_d_core
      = {64'b0 , (din_rsci_d_mxwt[63:0])};
  wire [15:0] nl_WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_0_rsci_1_inst_dout_0_rsci_addr_d_core;
  assign nl_WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_0_rsci_1_inst_dout_0_rsci_addr_d_core
      = {8'b0 , WRITE_acc_rmff , (WRITE_acc_sdt[3:0]) , WRITE_r_idx_2_0_lpi_1_dfm_1_0};
  wire [1:0] nl_WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_0_rsci_1_inst_dout_0_rsci_we_d_core_psct;
  assign nl_WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_0_rsci_1_inst_dout_0_rsci_we_d_core_psct
      = {1'b0 , (fsm_output[1])};
  wire [0:0] nl_WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_1_rsci_1_inst_core_wten;
  assign nl_WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_1_rsci_1_inst_core_wten
      = ~ core_wen;
  wire [0:0] nl_WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_1_rsci_1_inst_dout_1_rsci_iswt0;
  assign nl_WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_1_rsci_1_inst_dout_1_rsci_iswt0
      = fsm_output[1];
  wire [127:0] nl_WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_1_rsci_1_inst_dout_1_rsci_data_in_d_core;
  assign nl_WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_1_rsci_1_inst_dout_1_rsci_data_in_d_core
      = {64'b0 , (din_rsci_d_mxwt[127:64])};
  wire [15:0] nl_WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_1_rsci_1_inst_dout_1_rsci_addr_d_core;
  assign nl_WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_1_rsci_1_inst_dout_1_rsci_addr_d_core
      = {8'b0 , WRITE_acc_rmff , (WRITE_acc_sdt[3:0]) , WRITE_r_idx_2_0_lpi_1_dfm_1_0};
  wire [1:0] nl_WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_1_rsci_1_inst_dout_1_rsci_we_d_core_psct;
  assign nl_WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_1_rsci_1_inst_dout_1_rsci_we_d_core_psct
      = {1'b0 , (fsm_output[1])};
  wire [0:0] nl_WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_2_rsci_1_inst_core_wten;
  assign nl_WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_2_rsci_1_inst_core_wten
      = ~ core_wen;
  wire [0:0] nl_WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_2_rsci_1_inst_dout_2_rsci_iswt0;
  assign nl_WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_2_rsci_1_inst_dout_2_rsci_iswt0
      = fsm_output[1];
  wire [127:0] nl_WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_2_rsci_1_inst_dout_2_rsci_data_in_d_core;
  assign nl_WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_2_rsci_1_inst_dout_2_rsci_data_in_d_core
      = {64'b0 , (din_rsci_d_mxwt[191:128])};
  wire [15:0] nl_WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_2_rsci_1_inst_dout_2_rsci_addr_d_core;
  assign nl_WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_2_rsci_1_inst_dout_2_rsci_addr_d_core
      = {8'b0 , WRITE_acc_rmff , (WRITE_acc_sdt[3:0]) , WRITE_r_idx_2_0_lpi_1_dfm_1_0};
  wire [1:0] nl_WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_2_rsci_1_inst_dout_2_rsci_we_d_core_psct;
  assign nl_WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_2_rsci_1_inst_dout_2_rsci_we_d_core_psct
      = {1'b0 , (fsm_output[1])};
  wire [0:0] nl_WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_3_rsci_1_inst_core_wten;
  assign nl_WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_3_rsci_1_inst_core_wten
      = ~ core_wen;
  wire [0:0] nl_WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_3_rsci_1_inst_dout_3_rsci_iswt0;
  assign nl_WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_3_rsci_1_inst_dout_3_rsci_iswt0
      = fsm_output[1];
  wire [127:0] nl_WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_3_rsci_1_inst_dout_3_rsci_data_in_d_core;
  assign nl_WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_3_rsci_1_inst_dout_3_rsci_data_in_d_core
      = {64'b0 , (din_rsci_d_mxwt[255:192])};
  wire [15:0] nl_WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_3_rsci_1_inst_dout_3_rsci_addr_d_core;
  assign nl_WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_3_rsci_1_inst_dout_3_rsci_addr_d_core
      = {8'b0 , WRITE_acc_rmff , (WRITE_acc_sdt[3:0]) , WRITE_r_idx_2_0_lpi_1_dfm_1_0};
  wire [1:0] nl_WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_3_rsci_1_inst_dout_3_rsci_we_d_core_psct;
  assign nl_WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_3_rsci_1_inst_dout_3_rsci_we_d_core_psct
      = {1'b0 , (fsm_output[1])};
  WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_din_rsci WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_din_rsci_inst
      (
      .clk(clk),
      .rst(rst),
      .din_rsc_z(din_rsc_z),
      .din_rsc_vz(din_rsc_vz),
      .din_rsc_lz(din_rsc_lz),
      .core_wen(core_wen),
      .din_rsci_oswt(reg_din_rsci_ld_core_psct_cse),
      .din_rsci_wen_comp(din_rsci_wen_comp),
      .din_rsci_d_mxwt(din_rsci_d_mxwt),
      .core_wten(core_wten)
    );
  WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_0_rsci_1 WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_0_rsci_1_inst
      (
      .dout_0_rsci_data_in_d(dout_0_rsci_data_in_d_reg),
      .dout_0_rsci_addr_d(dout_0_rsci_addr_d_reg),
      .dout_0_rsci_we_d(dout_0_rsci_we_d_reg),
      .core_wten(nl_WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_0_rsci_1_inst_core_wten[0:0]),
      .dout_0_rsci_iswt0(nl_WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_0_rsci_1_inst_dout_0_rsci_iswt0[0:0]),
      .dout_0_rsci_data_in_d_core(nl_WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_0_rsci_1_inst_dout_0_rsci_data_in_d_core[127:0]),
      .dout_0_rsci_addr_d_core(nl_WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_0_rsci_1_inst_dout_0_rsci_addr_d_core[15:0]),
      .dout_0_rsci_we_d_core_psct(nl_WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_0_rsci_1_inst_dout_0_rsci_we_d_core_psct[1:0])
    );
  WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_1_rsci_1 WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_1_rsci_1_inst
      (
      .dout_1_rsci_data_in_d(dout_1_rsci_data_in_d_reg),
      .dout_1_rsci_addr_d(dout_1_rsci_addr_d_reg),
      .dout_1_rsci_we_d(dout_1_rsci_we_d_reg),
      .core_wten(nl_WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_1_rsci_1_inst_core_wten[0:0]),
      .dout_1_rsci_iswt0(nl_WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_1_rsci_1_inst_dout_1_rsci_iswt0[0:0]),
      .dout_1_rsci_data_in_d_core(nl_WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_1_rsci_1_inst_dout_1_rsci_data_in_d_core[127:0]),
      .dout_1_rsci_addr_d_core(nl_WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_1_rsci_1_inst_dout_1_rsci_addr_d_core[15:0]),
      .dout_1_rsci_we_d_core_psct(nl_WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_1_rsci_1_inst_dout_1_rsci_we_d_core_psct[1:0])
    );
  WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_2_rsci_1 WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_2_rsci_1_inst
      (
      .dout_2_rsci_data_in_d(dout_2_rsci_data_in_d_reg),
      .dout_2_rsci_addr_d(dout_2_rsci_addr_d_reg),
      .dout_2_rsci_we_d(dout_2_rsci_we_d_reg),
      .core_wten(nl_WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_2_rsci_1_inst_core_wten[0:0]),
      .dout_2_rsci_iswt0(nl_WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_2_rsci_1_inst_dout_2_rsci_iswt0[0:0]),
      .dout_2_rsci_data_in_d_core(nl_WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_2_rsci_1_inst_dout_2_rsci_data_in_d_core[127:0]),
      .dout_2_rsci_addr_d_core(nl_WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_2_rsci_1_inst_dout_2_rsci_addr_d_core[15:0]),
      .dout_2_rsci_we_d_core_psct(nl_WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_2_rsci_1_inst_dout_2_rsci_we_d_core_psct[1:0])
    );
  WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_3_rsci_1 WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_3_rsci_1_inst
      (
      .dout_3_rsci_data_in_d(dout_3_rsci_data_in_d_reg),
      .dout_3_rsci_addr_d(dout_3_rsci_addr_d_reg),
      .dout_3_rsci_we_d(dout_3_rsci_we_d_reg),
      .core_wten(nl_WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_3_rsci_1_inst_core_wten[0:0]),
      .dout_3_rsci_iswt0(nl_WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_3_rsci_1_inst_dout_3_rsci_iswt0[0:0]),
      .dout_3_rsci_data_in_d_core(nl_WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_3_rsci_1_inst_dout_3_rsci_data_in_d_core[127:0]),
      .dout_3_rsci_addr_d_core(nl_WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_3_rsci_1_inst_dout_3_rsci_addr_d_core[15:0]),
      .dout_3_rsci_we_d_core_psct(nl_WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_3_rsci_1_inst_dout_3_rsci_we_d_core_psct[1:0])
    );
  WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_3_rsc_rls_obj WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_3_rsc_rls_obj_inst
      (
      .dout_3_rsc_rls_lz(dout_3_rsc_rls_lz),
      .core_wten(core_wten),
      .dout_3_rsc_rls_obj_iswt0(reg_dout_0_rsc_rls_obj_ld_core_psct_cse)
    );
  WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_2_rsc_rls_obj WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_2_rsc_rls_obj_inst
      (
      .dout_2_rsc_rls_lz(dout_2_rsc_rls_lz),
      .core_wten(core_wten),
      .dout_2_rsc_rls_obj_iswt0(reg_dout_0_rsc_rls_obj_ld_core_psct_cse)
    );
  WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_1_rsc_rls_obj WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_1_rsc_rls_obj_inst
      (
      .dout_1_rsc_rls_lz(dout_1_rsc_rls_lz),
      .core_wten(core_wten),
      .dout_1_rsc_rls_obj_iswt0(reg_dout_0_rsc_rls_obj_ld_core_psct_cse)
    );
  WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_0_rsc_rls_obj WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_0_rsc_rls_obj_inst
      (
      .dout_0_rsc_rls_lz(dout_0_rsc_rls_lz),
      .core_wten(core_wten),
      .dout_0_rsc_rls_obj_iswt0(reg_dout_0_rsc_rls_obj_ld_core_psct_cse)
    );
  WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_3_rsc_req_obj WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_3_rsc_req_obj_inst
      (
      .clk(clk),
      .rst(rst),
      .dout_3_rsc_req_vz(dout_3_rsc_req_vz),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .dout_3_rsc_req_obj_oswt(reg_dout_3_rsc_req_obj_oswt_cse),
      .dout_3_rsc_req_obj_wen_comp(dout_3_rsc_req_obj_wen_comp)
    );
  WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_2_rsc_req_obj WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_2_rsc_req_obj_inst
      (
      .clk(clk),
      .rst(rst),
      .dout_2_rsc_req_vz(dout_2_rsc_req_vz),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .dout_2_rsc_req_obj_oswt(reg_dout_3_rsc_req_obj_oswt_cse),
      .dout_2_rsc_req_obj_wen_comp(dout_2_rsc_req_obj_wen_comp)
    );
  WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_1_rsc_req_obj WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_1_rsc_req_obj_inst
      (
      .clk(clk),
      .rst(rst),
      .dout_1_rsc_req_vz(dout_1_rsc_req_vz),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .dout_1_rsc_req_obj_oswt(reg_dout_3_rsc_req_obj_oswt_cse),
      .dout_1_rsc_req_obj_wen_comp(dout_1_rsc_req_obj_wen_comp)
    );
  WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_0_rsc_req_obj WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_dout_0_rsc_req_obj_inst
      (
      .clk(clk),
      .rst(rst),
      .dout_0_rsc_req_vz(dout_0_rsc_req_vz),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .dout_0_rsc_req_obj_oswt(reg_dout_3_rsc_req_obj_oswt_cse),
      .dout_0_rsc_req_obj_wen_comp(dout_0_rsc_req_obj_wen_comp)
    );
  WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_staller WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_staller_inst
      (
      .clk(clk),
      .rst(rst),
      .core_wen(core_wen),
      .din_rsci_wen_comp(din_rsci_wen_comp),
      .core_wten(core_wten),
      .dout_3_rsc_req_obj_wen_comp(dout_3_rsc_req_obj_wen_comp),
      .dout_2_rsc_req_obj_wen_comp(dout_2_rsc_req_obj_wen_comp),
      .dout_1_rsc_req_obj_wen_comp(dout_1_rsc_req_obj_wen_comp),
      .dout_0_rsc_req_obj_wen_comp(dout_0_rsc_req_obj_wen_comp)
    );
  WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_core_fsm WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_core_fsm_inst
      (
      .clk(clk),
      .rst(rst),
      .core_wen(core_wen),
      .fsm_output(fsm_output)
    );
  assign nl_WRITE_acc_rmff = conv_u2u_1_2(WRITE_acc_sdt[4]) + conv_u2u_1_2(for_k_idx_0_lpi_1_dfm);
  assign WRITE_acc_rmff = nl_WRITE_acc_rmff[1:0];
  assign for_and_cse = core_wen & (~ (fsm_output[0]));
  assign for_for_for_for_and_1_nl = (~ exit_for_for_for_lpi_1_dfm_2) & lfst_exit_for_for_1_lpi_1_dfm;
  assign WRITE_r_idx_2_0_lpi_1_dfm_1_0 = MUX_v_2_2_2(2'b00, WRITE_r_idx_2_0_lpi_1_dfm_2_1_0_2,
      (for_for_for_for_and_1_nl));
  assign exit_for_lpi_1_dfm_2_mx0w0 = for_k_idx_0_lpi_1_dfm & exit_for_for_lpi_1_dfm_2_mx0w0;
  assign nl_for_for_for_acc_nl = for_for_for_wx_idx_3_0_sva_1 + 4'b111;
  assign for_for_for_acc_nl = nl_for_for_for_acc_nl[3:0];
  assign for_for_for_acc_itm_3_1 = readslicef_4_1_3((for_for_for_acc_nl));
  assign exit_for_for_lpi_1_dfm_2_mx0w0 = for_for_c_idx_0_lpi_1_dfm & exit_for_for_for_lpi_1_dfm_2_mx0w0;
  assign exit_for_for_for_lpi_1_dfm_2_mx0w0 = (~ for_for_for_acc_itm_3_1) & (WRITE_acc_13_tmp[2]);
  assign nl_for_for_for_wx_idx_3_0_sva_1 = for_for_for_wx_idx_3_0_lpi_1_dfm + 4'b1;
  assign for_for_for_wx_idx_3_0_sva_1 = nl_for_for_for_wx_idx_3_0_sva_1[3:0];
  assign for_for_for_wx_idx_3_0_lpi_1_dfm = MUX_v_4_2_2(4'b0000, for_for_for_wx_idx_3_0_lpi_1_dfm_5,
      lfst_exit_for_for_1_lpi_1_dfm);
  assign for_k_idx_0_lpi_1_dfm = for_k_idx_0_lpi_1_dfm_2 & (~ exitL_exit_for_sva);
  assign for_for_c_idx_0_lpi_1_dfm = for_for_c_idx_0_lpi_1_dfm_3 & lfst_exit_for_lpi_1_dfm;
  assign nl_WRITE_acc_13_tmp = conv_u2u_2_3(WRITE_r_idx_2_0_lpi_1_dfm_1_0) + 3'b1;
  assign WRITE_acc_13_tmp = nl_WRITE_acc_13_tmp[2:0];
  assign nl_WRITE_acc_sdt = conv_u2u_4_5({for_for_c_idx_0_lpi_1_dfm , 1'b0 , for_k_idx_0_lpi_1_dfm
      , for_for_c_idx_0_lpi_1_dfm}) + conv_u2u_4_5(for_for_for_wx_idx_3_0_lpi_1_dfm);
  assign WRITE_acc_sdt = nl_WRITE_acc_sdt[4:0];
  assign lfst_exit_for_for_1_lpi_1_dfm = (~ exit_for_for_lpi_1_dfm_2) & lfst_exit_for_lpi_1_dfm;
  assign lfst_exit_for_lpi_1_dfm = ~(exit_for_lpi_1_dfm_2 | exitL_exit_for_sva);
  assign or_dcpl = (~ (WRITE_acc_13_tmp[2])) | for_for_for_acc_itm_3_1;
  assign or_dcpl_1 = exit_for_lpi_1_dfm_2 | exitL_exit_for_sva;
  assign or_dcpl_7 = or_dcpl | (~ for_for_c_idx_0_lpi_1_dfm_3);
  assign and_dcpl_3 = (WRITE_acc_13_tmp[2]) & (~ for_for_for_acc_itm_3_1) & for_for_c_idx_0_lpi_1_dfm_3;
  assign for_k_idx_0_lpi_1_dfm_1_mx0c1 = ((or_dcpl_7 | or_dcpl_1) & (fsm_output[1]))
      | (~((~(or_dcpl | (~ for_for_c_idx_0_lpi_1_dfm_3) | exit_for_lpi_1_dfm_2))
      | exitL_exit_for_sva));
  assign dout_0_rsci_we_d = dout_0_rsci_we_d_reg;
  assign dout_1_rsci_we_d = dout_1_rsci_we_d_reg;
  assign dout_2_rsci_we_d = dout_2_rsci_we_d_reg;
  assign dout_3_rsci_we_d = dout_3_rsci_we_d_reg;
  assign dout_0_rsci_data_in_d = dout_0_rsci_data_in_d_reg;
  assign dout_0_rsci_addr_d = dout_0_rsci_addr_d_reg;
  assign dout_1_rsci_data_in_d = dout_1_rsci_data_in_d_reg;
  assign dout_1_rsci_addr_d = dout_1_rsci_addr_d_reg;
  assign dout_2_rsci_data_in_d = dout_2_rsci_data_in_d_reg;
  assign dout_2_rsci_addr_d = dout_2_rsci_addr_d_reg;
  assign dout_3_rsci_data_in_d = dout_3_rsci_data_in_d_reg;
  assign dout_3_rsci_addr_d = dout_3_rsci_addr_d_reg;
  always @(posedge clk) begin
    if ( rst ) begin
      reg_dout_3_rsc_req_obj_oswt_cse <= 1'b0;
      reg_dout_0_rsc_rls_obj_ld_core_psct_cse <= 1'b0;
      reg_din_rsci_ld_core_psct_cse <= 1'b0;
    end
    else if ( core_wen ) begin
      reg_dout_3_rsc_req_obj_oswt_cse <= ~((or_dcpl_7 | or_dcpl_1 | (~ for_k_idx_0_lpi_1_dfm_2))
          & (fsm_output[1]));
      reg_dout_0_rsc_rls_obj_ld_core_psct_cse <= and_dcpl_3 & lfst_exit_for_lpi_1_dfm
          & for_k_idx_0_lpi_1_dfm_2;
      reg_din_rsci_ld_core_psct_cse <= 1'b1;
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      exitL_exit_for_sva <= 1'b1;
      exit_for_lpi_1_dfm_2 <= 1'b0;
      exit_for_for_lpi_1_dfm_2 <= 1'b0;
      exit_for_for_for_lpi_1_dfm_2 <= 1'b0;
      for_for_c_idx_0_lpi_1_dfm_3 <= 1'b0;
    end
    else if ( for_and_cse ) begin
      exitL_exit_for_sva <= exit_for_lpi_1_dfm_2_mx0w0;
      exit_for_lpi_1_dfm_2 <= exit_for_lpi_1_dfm_2_mx0w0;
      exit_for_for_lpi_1_dfm_2 <= exit_for_for_lpi_1_dfm_2_mx0w0;
      exit_for_for_for_lpi_1_dfm_2 <= exit_for_for_for_lpi_1_dfm_2_mx0w0;
      for_for_c_idx_0_lpi_1_dfm_3 <= MUX_s_1_2_2(for_for_c_idx_0_lpi_1_dfm, (~ for_for_c_idx_0_lpi_1_dfm),
          exit_for_for_for_lpi_1_dfm_2_mx0w0);
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      WRITE_r_idx_2_0_lpi_1_dfm_2_1_0_2 <= 2'b0;
    end
    else if ( core_wen & or_dcpl ) begin
      WRITE_r_idx_2_0_lpi_1_dfm_2_1_0_2 <= WRITE_acc_13_tmp[1:0];
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      for_for_for_wx_idx_3_0_lpi_1_dfm_5 <= 4'b0;
    end
    else if ( core_wen & (or_dcpl | (~ for_for_c_idx_0_lpi_1_dfm_3) | or_dcpl_1)
        ) begin
      for_for_for_wx_idx_3_0_lpi_1_dfm_5 <= MUX1HOT_v_4_3_2(({{3{for_for_c_idx_0_lpi_1_dfm}},
          for_for_c_idx_0_lpi_1_dfm}), for_for_for_wx_idx_3_0_lpi_1_dfm, for_for_for_wx_idx_3_0_sva_1,
          {(~ or_dcpl) , (~ (WRITE_acc_13_tmp[2])) , (for_for_for_wx_idx_and_1_nl)});
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      for_k_idx_0_lpi_1_dfm_2 <= 1'b0;
    end
    else if ( core_wen & ((and_dcpl_3 & lfst_exit_for_lpi_1_dfm) | for_k_idx_0_lpi_1_dfm_1_mx0c1)
        ) begin
      for_k_idx_0_lpi_1_dfm_2 <= MUX_s_1_2_2((~ for_k_idx_0_lpi_1_dfm), for_k_idx_0_lpi_1_dfm,
          for_k_idx_0_lpi_1_dfm_1_mx0c1);
    end
  end
  assign for_for_for_wx_idx_and_1_nl = (WRITE_acc_13_tmp[2]) & or_dcpl;

  function [3:0] MUX1HOT_v_4_3_2;
    input [3:0] input_2;
    input [3:0] input_1;
    input [3:0] input_0;
    input [2:0] sel;
    reg [3:0] result;
  begin
    result = input_0 & {4{sel[0]}};
    result = result | ( input_1 & {4{sel[1]}});
    result = result | ( input_2 & {4{sel[2]}});
    MUX1HOT_v_4_3_2 = result;
  end
  endfunction


  function [0:0] MUX_s_1_2_2;
    input [0:0] input_0;
    input [0:0] input_1;
    input [0:0] sel;
    reg [0:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_s_1_2_2 = result;
  end
  endfunction


  function [1:0] MUX_v_2_2_2;
    input [1:0] input_0;
    input [1:0] input_1;
    input [0:0] sel;
    reg [1:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_2_2_2 = result;
  end
  endfunction


  function [3:0] MUX_v_4_2_2;
    input [3:0] input_0;
    input [3:0] input_1;
    input [0:0] sel;
    reg [3:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_4_2_2 = result;
  end
  endfunction


  function [0:0] readslicef_4_1_3;
    input [3:0] vector;
    reg [3:0] tmp;
  begin
    tmp = vector >> 3;
    readslicef_4_1_3 = tmp[0:0];
  end
  endfunction


  function  [1:0] conv_u2u_1_2 ;
    input [0:0]  vector ;
  begin
    conv_u2u_1_2 = {1'b0, vector};
  end
  endfunction


  function  [2:0] conv_u2u_2_3 ;
    input [1:0]  vector ;
  begin
    conv_u2u_2_3 = {1'b0, vector};
  end
  endfunction


  function  [4:0] conv_u2u_4_5 ;
    input [3:0]  vector ;
  begin
    conv_u2u_4_5 = {1'b0, vector};
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core
// ------------------------------------------------------------------


module READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core (
  clk, rst, din_0_rsc_req_vz, din_0_rsc_rls_lz, din_1_rsc_req_vz, din_1_rsc_rls_lz,
      din_2_rsc_req_vz, din_2_rsc_rls_lz, din_3_rsc_req_vz, din_3_rsc_rls_lz, dout_rsc_z,
      dout_rsc_vz, dout_rsc_lz, din_0_rsci_addr_d, din_0_rsci_re_d, din_0_rsci_data_out_d,
      din_1_rsci_addr_d, din_1_rsci_re_d, din_1_rsci_data_out_d, din_2_rsci_addr_d,
      din_2_rsci_re_d, din_2_rsci_data_out_d, din_3_rsci_addr_d, din_3_rsci_re_d,
      din_3_rsci_data_out_d
);
  input clk;
  input rst;
  input din_0_rsc_req_vz;
  output din_0_rsc_rls_lz;
  input din_1_rsc_req_vz;
  output din_1_rsc_rls_lz;
  input din_2_rsc_req_vz;
  output din_2_rsc_rls_lz;
  input din_3_rsc_req_vz;
  output din_3_rsc_rls_lz;
  output [255:0] dout_rsc_z;
  input dout_rsc_vz;
  output dout_rsc_lz;
  output [7:0] din_0_rsci_addr_d;
  output [1:0] din_0_rsci_re_d;
  input [127:0] din_0_rsci_data_out_d;
  output [7:0] din_1_rsci_addr_d;
  output [1:0] din_1_rsci_re_d;
  input [127:0] din_1_rsci_data_out_d;
  output [7:0] din_2_rsci_addr_d;
  output [1:0] din_2_rsci_re_d;
  input [127:0] din_2_rsci_data_out_d;
  output [7:0] din_3_rsci_addr_d;
  output [1:0] din_3_rsci_re_d;
  input [127:0] din_3_rsci_data_out_d;


  // Interconnect Declarations
  wire core_wen;
  wire [63:0] din_0_rsci_data_out_d_mxwt;
  wire core_wten;
  wire [63:0] din_1_rsci_data_out_d_mxwt;
  wire [63:0] din_2_rsci_data_out_d_mxwt;
  wire [63:0] din_3_rsci_data_out_d_mxwt;
  wire dout_rsci_wen_comp;
  wire din_3_rsc_req_obj_wen_comp;
  wire din_2_rsc_req_obj_wen_comp;
  wire din_1_rsc_req_obj_wen_comp;
  wire din_0_rsc_req_obj_wen_comp;
  reg [63:0] dout_rsci_d_255_192;
  reg [63:0] dout_rsci_d_191_128;
  reg [63:0] dout_rsci_d_127_64;
  reg [63:0] dout_rsci_d_63_0;
  wire [1:0] fsm_output;
  wire [2:0] READ_for_for_for_acc_21_tmp;
  wire [3:0] nl_READ_for_for_for_acc_21_tmp;
  wire or_dcpl;
  wire or_dcpl_1;
  wire and_dcpl_3;
  wire or_dcpl_15;
  wire or_dcpl_17;
  wire or_dcpl_18;
  reg exitL_exit_READ_sva;
  reg exit_READ_for_for_lpi_1_dfm_2;
  reg READ_for_for_k_idx_0_lpi_1_dfm_3;
  reg exit_READ_for_lpi_1_dfm_2;
  reg [3:0] READ_for_wx_idx_3_0_lpi_1_dfm_5;
  reg READ_c_idx_0_lpi_1_dfm_2;
  reg exit_READ_lpi_1_dfm_2;
  reg [1:0] READ_for_for_for_r_idx_2_0_lpi_1_dfm_2_1_0_2;
  wire READ_c_idx_0_lpi_1_dfm;
  wire exit_READ_for_lpi_1_dfm_2_mx0w0;
  wire exit_READ_for_for_lpi_1_dfm_2_mx0w0;
  wire READ_for_for_k_idx_0_lpi_1_dfm;
  wire lfst_exit_READ_for_1_lpi_1_dfm;
  wire lfst_exit_READ_lpi_1_dfm;
  wire or_21_tmp;
  reg reg_din_3_rsc_req_obj_oswt_cse;
  wire dout_and_cse;
  reg reg_din_3_rsci_re_d_core_psct_0_cse;
  reg reg_din_3_rsc_rls_obj_ld_core_psct_cse;
  reg reg_dout_rsci_ld_core_psct_cse;
  wire READ_and_cse;
  wire or_14_cse;
  wire [7:0] din_0_rsci_addr_d_reg;
  wire [1:0] READ_for_for_for_acc_rmff;
  wire [2:0] nl_READ_for_for_for_acc_rmff;
  wire [1:0] din_0_rsci_re_d_reg;
  wire [7:0] din_1_rsci_addr_d_reg;
  wire [1:0] din_1_rsci_re_d_reg;
  wire [7:0] din_2_rsci_addr_d_reg;
  wire [1:0] din_2_rsci_re_d_reg;
  wire [7:0] din_3_rsci_addr_d_reg;
  wire [1:0] din_3_rsci_re_d_reg;
  wire [4:0] READ_for_for_for_acc_sdt;
  wire [5:0] nl_READ_for_for_for_acc_sdt;
  wire [1:0] READ_for_for_for_r_idx_2_0_lpi_1_dfm_1_0;
  wire exit_READ_lpi_1_dfm_2_mx0w0;
  wire READ_c_idx_0_lpi_1_dfm_1_mx0c1;
  wire [3:0] READ_for_wx_idx_3_0_sva_1;
  wire [4:0] nl_READ_for_wx_idx_3_0_sva_1;
  wire [3:0] READ_for_wx_idx_3_0_lpi_1_dfm;
  wire READ_for_acc_itm_3_1;

  wire[0:0] READ_for_wx_idx_and_nl;
  wire[0:0] READ_for_READ_for_and_1_nl;
  wire[3:0] READ_for_acc_nl;
  wire[4:0] nl_READ_for_acc_nl;

  // Interconnect Declarations for Component Instantiations 
  wire [15:0] nl_READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_0_rsci_1_inst_din_0_rsci_addr_d_core;
  assign nl_READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_0_rsci_1_inst_din_0_rsci_addr_d_core
      = {8'b0 , READ_for_for_for_acc_rmff , (READ_for_for_for_acc_sdt[3:0]) , READ_for_for_for_r_idx_2_0_lpi_1_dfm_1_0};
  wire [1:0] nl_READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_0_rsci_1_inst_din_0_rsci_re_d_core_psct;
  assign nl_READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_0_rsci_1_inst_din_0_rsci_re_d_core_psct
      = {1'b0 , (fsm_output[1])};
  wire [0:0] nl_READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_0_rsci_1_inst_din_0_rsci_oswt_pff;
  assign nl_READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_0_rsci_1_inst_din_0_rsci_oswt_pff
      = fsm_output[1];
  wire [15:0] nl_READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_1_rsci_1_inst_din_1_rsci_addr_d_core;
  assign nl_READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_1_rsci_1_inst_din_1_rsci_addr_d_core
      = {8'b0 , READ_for_for_for_acc_rmff , (READ_for_for_for_acc_sdt[3:0]) , READ_for_for_for_r_idx_2_0_lpi_1_dfm_1_0};
  wire [1:0] nl_READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_1_rsci_1_inst_din_1_rsci_re_d_core_psct;
  assign nl_READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_1_rsci_1_inst_din_1_rsci_re_d_core_psct
      = {1'b0 , (fsm_output[1])};
  wire [0:0] nl_READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_1_rsci_1_inst_din_1_rsci_oswt_pff;
  assign nl_READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_1_rsci_1_inst_din_1_rsci_oswt_pff
      = fsm_output[1];
  wire [15:0] nl_READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_2_rsci_1_inst_din_2_rsci_addr_d_core;
  assign nl_READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_2_rsci_1_inst_din_2_rsci_addr_d_core
      = {8'b0 , READ_for_for_for_acc_rmff , (READ_for_for_for_acc_sdt[3:0]) , READ_for_for_for_r_idx_2_0_lpi_1_dfm_1_0};
  wire [1:0] nl_READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_2_rsci_1_inst_din_2_rsci_re_d_core_psct;
  assign nl_READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_2_rsci_1_inst_din_2_rsci_re_d_core_psct
      = {1'b0 , (fsm_output[1])};
  wire [0:0] nl_READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_2_rsci_1_inst_din_2_rsci_oswt_pff;
  assign nl_READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_2_rsci_1_inst_din_2_rsci_oswt_pff
      = fsm_output[1];
  wire [15:0] nl_READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_3_rsci_1_inst_din_3_rsci_addr_d_core;
  assign nl_READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_3_rsci_1_inst_din_3_rsci_addr_d_core
      = {8'b0 , READ_for_for_for_acc_rmff , (READ_for_for_for_acc_sdt[3:0]) , READ_for_for_for_r_idx_2_0_lpi_1_dfm_1_0};
  wire [1:0] nl_READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_3_rsci_1_inst_din_3_rsci_re_d_core_psct;
  assign nl_READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_3_rsci_1_inst_din_3_rsci_re_d_core_psct
      = {1'b0 , (fsm_output[1])};
  wire [0:0] nl_READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_3_rsci_1_inst_din_3_rsci_oswt_pff;
  assign nl_READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_3_rsci_1_inst_din_3_rsci_oswt_pff
      = fsm_output[1];
  wire [255:0] nl_READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_dout_rsci_inst_dout_rsci_d;
  assign nl_READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_dout_rsci_inst_dout_rsci_d
      = {dout_rsci_d_255_192 , dout_rsci_d_191_128 , dout_rsci_d_127_64 , dout_rsci_d_63_0};
  READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_0_rsci_1 READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_0_rsci_1_inst
      (
      .clk(clk),
      .rst(rst),
      .din_0_rsci_addr_d(din_0_rsci_addr_d_reg),
      .din_0_rsci_re_d(din_0_rsci_re_d_reg),
      .din_0_rsci_data_out_d(din_0_rsci_data_out_d),
      .core_wen(core_wen),
      .din_0_rsci_oswt(reg_din_3_rsci_re_d_core_psct_0_cse),
      .din_0_rsci_addr_d_core(nl_READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_0_rsci_1_inst_din_0_rsci_addr_d_core[15:0]),
      .din_0_rsci_re_d_core_psct(nl_READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_0_rsci_1_inst_din_0_rsci_re_d_core_psct[1:0]),
      .din_0_rsci_data_out_d_mxwt(din_0_rsci_data_out_d_mxwt),
      .core_wten(core_wten),
      .din_0_rsci_oswt_pff(nl_READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_0_rsci_1_inst_din_0_rsci_oswt_pff[0:0])
    );
  READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_1_rsci_1 READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_1_rsci_1_inst
      (
      .clk(clk),
      .rst(rst),
      .din_1_rsci_addr_d(din_1_rsci_addr_d_reg),
      .din_1_rsci_re_d(din_1_rsci_re_d_reg),
      .din_1_rsci_data_out_d(din_1_rsci_data_out_d),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .din_1_rsci_oswt(reg_din_3_rsci_re_d_core_psct_0_cse),
      .din_1_rsci_addr_d_core(nl_READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_1_rsci_1_inst_din_1_rsci_addr_d_core[15:0]),
      .din_1_rsci_re_d_core_psct(nl_READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_1_rsci_1_inst_din_1_rsci_re_d_core_psct[1:0]),
      .din_1_rsci_data_out_d_mxwt(din_1_rsci_data_out_d_mxwt),
      .din_1_rsci_oswt_pff(nl_READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_1_rsci_1_inst_din_1_rsci_oswt_pff[0:0])
    );
  READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_2_rsci_1 READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_2_rsci_1_inst
      (
      .clk(clk),
      .rst(rst),
      .din_2_rsci_addr_d(din_2_rsci_addr_d_reg),
      .din_2_rsci_re_d(din_2_rsci_re_d_reg),
      .din_2_rsci_data_out_d(din_2_rsci_data_out_d),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .din_2_rsci_oswt(reg_din_3_rsci_re_d_core_psct_0_cse),
      .din_2_rsci_addr_d_core(nl_READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_2_rsci_1_inst_din_2_rsci_addr_d_core[15:0]),
      .din_2_rsci_re_d_core_psct(nl_READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_2_rsci_1_inst_din_2_rsci_re_d_core_psct[1:0]),
      .din_2_rsci_data_out_d_mxwt(din_2_rsci_data_out_d_mxwt),
      .din_2_rsci_oswt_pff(nl_READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_2_rsci_1_inst_din_2_rsci_oswt_pff[0:0])
    );
  READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_3_rsci_1 READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_3_rsci_1_inst
      (
      .clk(clk),
      .rst(rst),
      .din_3_rsci_addr_d(din_3_rsci_addr_d_reg),
      .din_3_rsci_re_d(din_3_rsci_re_d_reg),
      .din_3_rsci_data_out_d(din_3_rsci_data_out_d),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .din_3_rsci_oswt(reg_din_3_rsci_re_d_core_psct_0_cse),
      .din_3_rsci_addr_d_core(nl_READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_3_rsci_1_inst_din_3_rsci_addr_d_core[15:0]),
      .din_3_rsci_re_d_core_psct(nl_READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_3_rsci_1_inst_din_3_rsci_re_d_core_psct[1:0]),
      .din_3_rsci_data_out_d_mxwt(din_3_rsci_data_out_d_mxwt),
      .din_3_rsci_oswt_pff(nl_READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_3_rsci_1_inst_din_3_rsci_oswt_pff[0:0])
    );
  READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_dout_rsci READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_dout_rsci_inst
      (
      .clk(clk),
      .rst(rst),
      .dout_rsc_z(dout_rsc_z),
      .dout_rsc_vz(dout_rsc_vz),
      .dout_rsc_lz(dout_rsc_lz),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .dout_rsci_oswt(reg_dout_rsci_ld_core_psct_cse),
      .dout_rsci_wen_comp(dout_rsci_wen_comp),
      .dout_rsci_d(nl_READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_dout_rsci_inst_dout_rsci_d[255:0])
    );
  READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_0_rsc_rls_obj READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_0_rsc_rls_obj_inst
      (
      .din_0_rsc_rls_lz(din_0_rsc_rls_lz),
      .core_wten(core_wten),
      .din_0_rsc_rls_obj_iswt0(reg_din_3_rsc_rls_obj_ld_core_psct_cse)
    );
  READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_1_rsc_rls_obj READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_1_rsc_rls_obj_inst
      (
      .din_1_rsc_rls_lz(din_1_rsc_rls_lz),
      .core_wten(core_wten),
      .din_1_rsc_rls_obj_iswt0(reg_din_3_rsc_rls_obj_ld_core_psct_cse)
    );
  READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_2_rsc_rls_obj READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_2_rsc_rls_obj_inst
      (
      .din_2_rsc_rls_lz(din_2_rsc_rls_lz),
      .core_wten(core_wten),
      .din_2_rsc_rls_obj_iswt0(reg_din_3_rsc_rls_obj_ld_core_psct_cse)
    );
  READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_3_rsc_rls_obj READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_3_rsc_rls_obj_inst
      (
      .din_3_rsc_rls_lz(din_3_rsc_rls_lz),
      .core_wten(core_wten),
      .din_3_rsc_rls_obj_iswt0(reg_din_3_rsc_rls_obj_ld_core_psct_cse)
    );
  READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_3_rsc_req_obj READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_3_rsc_req_obj_inst
      (
      .clk(clk),
      .rst(rst),
      .din_3_rsc_req_vz(din_3_rsc_req_vz),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .din_3_rsc_req_obj_oswt(reg_din_3_rsc_req_obj_oswt_cse),
      .din_3_rsc_req_obj_wen_comp(din_3_rsc_req_obj_wen_comp)
    );
  READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_2_rsc_req_obj READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_2_rsc_req_obj_inst
      (
      .clk(clk),
      .rst(rst),
      .din_2_rsc_req_vz(din_2_rsc_req_vz),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .din_2_rsc_req_obj_oswt(reg_din_3_rsc_req_obj_oswt_cse),
      .din_2_rsc_req_obj_wen_comp(din_2_rsc_req_obj_wen_comp)
    );
  READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_1_rsc_req_obj READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_1_rsc_req_obj_inst
      (
      .clk(clk),
      .rst(rst),
      .din_1_rsc_req_vz(din_1_rsc_req_vz),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .din_1_rsc_req_obj_oswt(reg_din_3_rsc_req_obj_oswt_cse),
      .din_1_rsc_req_obj_wen_comp(din_1_rsc_req_obj_wen_comp)
    );
  READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_0_rsc_req_obj READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_din_0_rsc_req_obj_inst
      (
      .clk(clk),
      .rst(rst),
      .din_0_rsc_req_vz(din_0_rsc_req_vz),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .din_0_rsc_req_obj_oswt(reg_din_3_rsc_req_obj_oswt_cse),
      .din_0_rsc_req_obj_wen_comp(din_0_rsc_req_obj_wen_comp)
    );
  READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_staller READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_staller_inst
      (
      .clk(clk),
      .rst(rst),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .dout_rsci_wen_comp(dout_rsci_wen_comp),
      .din_3_rsc_req_obj_wen_comp(din_3_rsc_req_obj_wen_comp),
      .din_2_rsc_req_obj_wen_comp(din_2_rsc_req_obj_wen_comp),
      .din_1_rsc_req_obj_wen_comp(din_1_rsc_req_obj_wen_comp),
      .din_0_rsc_req_obj_wen_comp(din_0_rsc_req_obj_wen_comp)
    );
  READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_core_fsm READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_core_fsm_inst
      (
      .clk(clk),
      .rst(rst),
      .core_wen(core_wen),
      .fsm_output(fsm_output)
    );
  assign or_14_cse = or_dcpl_1 | exit_READ_for_lpi_1_dfm_2 | exit_READ_lpi_1_dfm_2
      | READ_for_acc_itm_3_1 | exitL_exit_READ_sva | (~ READ_c_idx_0_lpi_1_dfm_2);
  assign nl_READ_for_for_for_acc_rmff = conv_u2u_1_2(READ_for_for_for_acc_sdt[4])
      + conv_u2u_1_2(READ_for_for_k_idx_0_lpi_1_dfm);
  assign READ_for_for_for_acc_rmff = nl_READ_for_for_for_acc_rmff[1:0];
  assign dout_and_cse = core_wen & reg_din_3_rsci_re_d_core_psct_0_cse;
  assign READ_and_cse = core_wen & (~ (fsm_output[0]));
  assign or_21_tmp = or_dcpl_17 | or_dcpl;
  assign READ_for_READ_for_and_1_nl = (~ exit_READ_for_for_lpi_1_dfm_2) & lfst_exit_READ_for_1_lpi_1_dfm;
  assign READ_for_for_for_r_idx_2_0_lpi_1_dfm_1_0 = MUX_v_2_2_2(2'b00, READ_for_for_for_r_idx_2_0_lpi_1_dfm_2_1_0_2,
      (READ_for_READ_for_and_1_nl));
  assign exit_READ_lpi_1_dfm_2_mx0w0 = READ_c_idx_0_lpi_1_dfm & exit_READ_for_lpi_1_dfm_2_mx0w0;
  assign exit_READ_for_lpi_1_dfm_2_mx0w0 = (~ READ_for_acc_itm_3_1) & exit_READ_for_for_lpi_1_dfm_2_mx0w0;
  assign exit_READ_for_for_lpi_1_dfm_2_mx0w0 = READ_for_for_k_idx_0_lpi_1_dfm & (READ_for_for_for_acc_21_tmp[2]);
  assign nl_READ_for_acc_nl = READ_for_wx_idx_3_0_sva_1 + 4'b111;
  assign READ_for_acc_nl = nl_READ_for_acc_nl[3:0];
  assign READ_for_acc_itm_3_1 = readslicef_4_1_3((READ_for_acc_nl));
  assign nl_READ_for_wx_idx_3_0_sva_1 = READ_for_wx_idx_3_0_lpi_1_dfm + 4'b1;
  assign READ_for_wx_idx_3_0_sva_1 = nl_READ_for_wx_idx_3_0_sva_1[3:0];
  assign READ_for_wx_idx_3_0_lpi_1_dfm = MUX_v_4_2_2(4'b0000, READ_for_wx_idx_3_0_lpi_1_dfm_5,
      lfst_exit_READ_lpi_1_dfm);
  assign READ_c_idx_0_lpi_1_dfm = READ_c_idx_0_lpi_1_dfm_2 & (~ exitL_exit_READ_sva);
  assign READ_for_for_k_idx_0_lpi_1_dfm = READ_for_for_k_idx_0_lpi_1_dfm_3 & lfst_exit_READ_for_1_lpi_1_dfm;
  assign nl_READ_for_for_for_acc_21_tmp = conv_u2u_2_3(READ_for_for_for_r_idx_2_0_lpi_1_dfm_1_0)
      + 3'b1;
  assign READ_for_for_for_acc_21_tmp = nl_READ_for_for_for_acc_21_tmp[2:0];
  assign nl_READ_for_for_for_acc_sdt = conv_u2u_4_5({READ_c_idx_0_lpi_1_dfm , 1'b0
      , READ_for_for_k_idx_0_lpi_1_dfm , READ_c_idx_0_lpi_1_dfm}) + conv_u2u_4_5(READ_for_wx_idx_3_0_lpi_1_dfm);
  assign READ_for_for_for_acc_sdt = nl_READ_for_for_for_acc_sdt[4:0];
  assign lfst_exit_READ_for_1_lpi_1_dfm = (~ exit_READ_for_lpi_1_dfm_2) & lfst_exit_READ_lpi_1_dfm;
  assign lfst_exit_READ_lpi_1_dfm = ~(exit_READ_lpi_1_dfm_2 | exitL_exit_READ_sva);
  assign or_dcpl = exit_READ_lpi_1_dfm_2 | exitL_exit_READ_sva;
  assign or_dcpl_1 = ~(READ_for_for_k_idx_0_lpi_1_dfm_3 & (READ_for_for_for_acc_21_tmp[2]));
  assign and_dcpl_3 = READ_for_for_k_idx_0_lpi_1_dfm_3 & (READ_for_for_for_acc_21_tmp[2]);
  assign or_dcpl_15 = exit_READ_lpi_1_dfm_2 | READ_for_acc_itm_3_1;
  assign or_dcpl_17 = or_dcpl_1 | exit_READ_for_lpi_1_dfm_2;
  assign or_dcpl_18 = or_dcpl_17 | or_dcpl_15 | exitL_exit_READ_sva;
  assign READ_c_idx_0_lpi_1_dfm_1_mx0c1 = (or_dcpl_18 & (fsm_output[1])) | (~((~(or_dcpl_17
      | or_dcpl_15)) | exitL_exit_READ_sva));
  assign din_0_rsci_re_d = din_0_rsci_re_d_reg;
  assign din_1_rsci_re_d = din_1_rsci_re_d_reg;
  assign din_2_rsci_re_d = din_2_rsci_re_d_reg;
  assign din_3_rsci_re_d = din_3_rsci_re_d_reg;
  assign din_0_rsci_addr_d = din_0_rsci_addr_d_reg;
  assign din_1_rsci_addr_d = din_1_rsci_addr_d_reg;
  assign din_2_rsci_addr_d = din_2_rsci_addr_d_reg;
  assign din_3_rsci_addr_d = din_3_rsci_addr_d_reg;
  always @(posedge clk) begin
    if ( rst ) begin
      reg_din_3_rsc_req_obj_oswt_cse <= 1'b0;
      reg_din_3_rsci_re_d_core_psct_0_cse <= 1'b0;
      reg_din_3_rsc_rls_obj_ld_core_psct_cse <= 1'b0;
      reg_dout_rsci_ld_core_psct_cse <= 1'b0;
    end
    else if ( core_wen ) begin
      reg_din_3_rsc_req_obj_oswt_cse <= ~(or_14_cse & (fsm_output[1]));
      reg_din_3_rsci_re_d_core_psct_0_cse <= fsm_output[1];
      reg_din_3_rsc_rls_obj_ld_core_psct_cse <= and_dcpl_3 & (~ exit_READ_for_lpi_1_dfm_2)
          & (~ exit_READ_lpi_1_dfm_2) & (~ READ_for_acc_itm_3_1) & (~ exitL_exit_READ_sva)
          & READ_c_idx_0_lpi_1_dfm_2;
      reg_dout_rsci_ld_core_psct_cse <= reg_din_3_rsci_re_d_core_psct_0_cse;
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      dout_rsci_d_63_0 <= 64'b0;
      dout_rsci_d_127_64 <= 64'b0;
      dout_rsci_d_191_128 <= 64'b0;
      dout_rsci_d_255_192 <= 64'b0;
    end
    else if ( dout_and_cse ) begin
      dout_rsci_d_63_0 <= din_0_rsci_data_out_d_mxwt;
      dout_rsci_d_127_64 <= din_1_rsci_data_out_d_mxwt;
      dout_rsci_d_191_128 <= din_2_rsci_data_out_d_mxwt;
      dout_rsci_d_255_192 <= din_3_rsci_data_out_d_mxwt;
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      exitL_exit_READ_sva <= 1'b1;
      exit_READ_lpi_1_dfm_2 <= 1'b0;
      exit_READ_for_lpi_1_dfm_2 <= 1'b0;
      exit_READ_for_for_lpi_1_dfm_2 <= 1'b0;
      READ_for_for_k_idx_0_lpi_1_dfm_3 <= 1'b0;
    end
    else if ( READ_and_cse ) begin
      exitL_exit_READ_sva <= exit_READ_lpi_1_dfm_2_mx0w0;
      exit_READ_lpi_1_dfm_2 <= exit_READ_lpi_1_dfm_2_mx0w0;
      exit_READ_for_lpi_1_dfm_2 <= exit_READ_for_lpi_1_dfm_2_mx0w0;
      exit_READ_for_for_lpi_1_dfm_2 <= exit_READ_for_for_lpi_1_dfm_2_mx0w0;
      READ_for_for_k_idx_0_lpi_1_dfm_3 <= MUX_s_1_2_2(READ_for_for_k_idx_0_lpi_1_dfm,
          (~ READ_for_for_k_idx_0_lpi_1_dfm), READ_for_for_for_acc_21_tmp[2]);
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      READ_for_for_for_r_idx_2_0_lpi_1_dfm_2_1_0_2 <= 2'b0;
    end
    else if ( core_wen & (or_dcpl_1 | exit_READ_for_lpi_1_dfm_2 | or_dcpl) ) begin
      READ_for_for_for_r_idx_2_0_lpi_1_dfm_2_1_0_2 <= READ_for_for_for_acc_21_tmp[1:0];
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      READ_for_wx_idx_3_0_lpi_1_dfm_5 <= 4'b0;
    end
    else if ( core_wen & or_14_cse ) begin
      READ_for_wx_idx_3_0_lpi_1_dfm_5 <= MUX1HOT_v_4_3_2(({{3{READ_c_idx_0_lpi_1_dfm}},
          READ_c_idx_0_lpi_1_dfm}), READ_for_wx_idx_3_0_sva_1, READ_for_wx_idx_3_0_lpi_1_dfm,
          {(~ or_dcpl_18) , (READ_for_wx_idx_and_nl) , or_21_tmp});
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      READ_c_idx_0_lpi_1_dfm_2 <= 1'b0;
    end
    else if ( core_wen & ((~((~ and_dcpl_3) | exit_READ_for_lpi_1_dfm_2 | exit_READ_lpi_1_dfm_2
        | READ_for_acc_itm_3_1 | exitL_exit_READ_sva)) | READ_c_idx_0_lpi_1_dfm_1_mx0c1)
        ) begin
      READ_c_idx_0_lpi_1_dfm_2 <= MUX_s_1_2_2((~ READ_c_idx_0_lpi_1_dfm), READ_c_idx_0_lpi_1_dfm,
          READ_c_idx_0_lpi_1_dfm_1_mx0c1);
    end
  end
  assign READ_for_wx_idx_and_nl = (~ or_21_tmp) & or_dcpl_18;

  function [3:0] MUX1HOT_v_4_3_2;
    input [3:0] input_2;
    input [3:0] input_1;
    input [3:0] input_0;
    input [2:0] sel;
    reg [3:0] result;
  begin
    result = input_0 & {4{sel[0]}};
    result = result | ( input_1 & {4{sel[1]}});
    result = result | ( input_2 & {4{sel[2]}});
    MUX1HOT_v_4_3_2 = result;
  end
  endfunction


  function [0:0] MUX_s_1_2_2;
    input [0:0] input_0;
    input [0:0] input_1;
    input [0:0] sel;
    reg [0:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_s_1_2_2 = result;
  end
  endfunction


  function [1:0] MUX_v_2_2_2;
    input [1:0] input_0;
    input [1:0] input_1;
    input [0:0] sel;
    reg [1:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_2_2_2 = result;
  end
  endfunction


  function [3:0] MUX_v_4_2_2;
    input [3:0] input_0;
    input [3:0] input_1;
    input [0:0] sel;
    reg [3:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_4_2_2 = result;
  end
  endfunction


  function [0:0] readslicef_4_1_3;
    input [3:0] vector;
    reg [3:0] tmp;
  begin
    tmp = vector >> 3;
    readslicef_4_1_3 = tmp[0:0];
  end
  endfunction


  function  [1:0] conv_u2u_1_2 ;
    input [0:0]  vector ;
  begin
    conv_u2u_1_2 = {1'b0, vector};
  end
  endfunction


  function  [2:0] conv_u2u_2_3 ;
    input [1:0]  vector ;
  begin
    conv_u2u_2_3 = {1'b0, vector};
  end
  endfunction


  function  [4:0] conv_u2u_4_5 ;
    input [3:0]  vector ;
  begin
    conv_u2u_4_5 = {1'b0, vector};
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    systolic_array_DTYPE_2_4_16_4_2_2_3_core
// ------------------------------------------------------------------


module systolic_array_DTYPE_2_4_16_4_2_2_3_core (
  clk, rst, input_rsc_z, input_rsc_vz, input_rsc_lz, weight_rsc_z, weight_rsc_vz,
      weight_rsc_lz, output_rsc_z, output_rsc_vz, output_rsc_lz, out_tile_0_value_rsc_cge,
      out_tile_0_value_rsci_data_in_d, out_tile_0_value_rsci_re_d, out_tile_0_value_rsci_we_d,
      out_tile_0_value_rsci_data_out_d, out_tile_1_value_rsci_data_in_d, out_tile_1_value_rsci_re_d,
      out_tile_1_value_rsci_we_d, out_tile_1_value_rsci_data_out_d, out_tile_2_value_rsci_data_in_d,
      out_tile_2_value_rsci_re_d, out_tile_2_value_rsci_we_d, out_tile_2_value_rsci_data_out_d,
      out_tile_3_value_rsci_data_in_d, out_tile_3_value_rsci_re_d, out_tile_3_value_rsci_we_d,
      out_tile_3_value_rsci_data_out_d, out_tile_0_value_rsci_addr_d_pff
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
  output out_tile_0_value_rsc_cge;
  output [63:0] out_tile_0_value_rsci_data_in_d;
  output [1:0] out_tile_0_value_rsci_re_d;
  output [1:0] out_tile_0_value_rsci_we_d;
  input [127:0] out_tile_0_value_rsci_data_out_d;
  output [63:0] out_tile_1_value_rsci_data_in_d;
  output [1:0] out_tile_1_value_rsci_re_d;
  output [1:0] out_tile_1_value_rsci_we_d;
  input [127:0] out_tile_1_value_rsci_data_out_d;
  output [63:0] out_tile_2_value_rsci_data_in_d;
  output [1:0] out_tile_2_value_rsci_re_d;
  output [1:0] out_tile_2_value_rsci_we_d;
  input [127:0] out_tile_2_value_rsci_data_out_d;
  output [63:0] out_tile_3_value_rsci_data_in_d;
  output [1:0] out_tile_3_value_rsci_re_d;
  output [1:0] out_tile_3_value_rsci_we_d;
  input [127:0] out_tile_3_value_rsci_data_out_d;
  output [9:0] out_tile_0_value_rsci_addr_d_pff;


  // Interconnect Declarations
  wire core_wen;
  wire input_rsci_wen_comp;
  wire [63:0] input_rsci_d_mxwt;
  wire core_wten;
  wire weight_rsci_wen_comp;
  wire [127:0] weight_rsci_d_mxwt;
  wire output_rsci_wen_comp;
  reg [31:0] output_rsci_d_255_224;
  reg [31:0] output_rsci_d_223_192;
  reg [31:0] output_rsci_d_191_160;
  reg [31:0] output_rsci_d_159_128;
  reg [31:0] output_rsci_d_127_96;
  reg [31:0] output_rsci_d_95_64;
  reg [31:0] output_rsci_d_63_32;
  reg [31:0] output_rsci_d_31_0;
  wire [1:0] fsm_output;
  wire COMP_and_13_tmp;
  wire or_dcpl;
  wire or_dcpl_3;
  wire or_dcpl_4;
  wire and_dcpl_6;
  wire or_dcpl_9;
  wire or_dcpl_11;
  wire or_dcpl_13;
  wire or_dcpl_35;
  wire and_dcpl_29;
  wire nand_tmp;
  wire or_tmp_7;
  wire or_tmp_12;
  wire mux_tmp_6;
  wire mux_tmp_7;
  wire and_dcpl_38;
  wire and_dcpl_41;
  wire mux_tmp_11;
  wire and_dcpl_49;
  wire or_dcpl_46;
  wire or_dcpl_47;
  wire or_dcpl_48;
  wire or_dcpl_51;
  wire or_dcpl_54;
  wire or_dcpl_56;
  wire or_dcpl_58;
  wire or_dcpl_64;
  wire and_dcpl_51;
  wire and_dcpl_53;
  wire mux_tmp_12;
  wire mux_tmp_13;
  wire and_dcpl_63;
  wire and_dcpl_65;
  wire and_dcpl_67;
  wire mux_tmp_14;
  wire mux_tmp_15;
  wire mux_tmp_16;
  wire and_dcpl_81;
  wire and_dcpl_83;
  wire and_dcpl_85;
  wire and_dcpl_87;
  wire mux_tmp_17;
  wire mux_tmp_18;
  wire mux_tmp_19;
  wire mux_tmp_20;
  wire and_dcpl_105;
  wire and_dcpl_107;
  wire and_dcpl_109;
  wire mux_tmp_21;
  wire mux_tmp_22;
  wire mux_tmp_23;
  wire and_dcpl_123;
  wire and_dcpl_125;
  wire mux_tmp_24;
  wire mux_tmp_25;
  wire and_dcpl_134;
  wire and_dcpl_135;
  reg Co_c_idx_0_lpi_1;
  reg [1:0] winx_wx_idx_1_0_lpi_2;
  reg [1:0] winy_wy_idx_1_0_lpi_2;
  reg Ko_k_idx_0_lpi_2;
  reg [4:0] STEPS_step_4_0_lpi_2;
  reg [15:0] pe_x_reg_2_2_sva;
  reg [15:0] pe_x_reg_2_1_sva;
  reg [15:0] pe_x_reg_2_0_sva;
  reg [15:0] pe_x_reg_3_0_sva;
  reg [15:0] pe_x_reg_3_1_sva;
  reg [15:0] pe_x_reg_1_2_sva;
  reg [15:0] pe_x_reg_3_2_sva;
  reg [15:0] pe_x_reg_1_1_sva;
  reg [15:0] pe_x_reg_1_0_sva;
  reg [15:0] pe_x_reg_0_2_sva;
  reg [15:0] pe_x_reg_0_1_sva;
  reg [15:0] pe_x_reg_0_0_sva;
  reg [31:0] pe_y_reg_value_0_0_31_0_sva;
  reg [31:0] pe_y_reg_value_0_0_63_32_sva;
  reg [15:0] fifo_60001_DTYPE_2_regs_0_sva;
  reg [15:0] fifo_60002_DTYPE_3_regs_1_sva;
  reg [15:0] fifo_60002_DTYPE_3_regs_0_sva;
  reg [15:0] fifo_60003_DTYPE_4_regs_1_sva;
  reg [15:0] fifo_60003_DTYPE_4_regs_2_sva;
  reg [15:0] fifo_60003_DTYPE_4_regs_0_sva;
  reg [63:0] fifo_90002_PackedStencil_DTYPE_2U_1U_1U_1U_3_regs_value_1_sva;
  reg [63:0] fifo_90002_PackedStencil_DTYPE_2U_1U_1U_1U_3_regs_value_0_sva;
  reg [63:0] fifo_90003_PackedStencil_DTYPE_2U_1U_1U_1U_4_regs_value_1_sva;
  reg [63:0] fifo_90003_PackedStencil_DTYPE_2U_1U_1U_1U_4_regs_value_2_sva;
  reg [63:0] fifo_90003_PackedStencil_DTYPE_2U_1U_1U_1U_4_regs_value_0_sva;
  reg [31:0] fifo_0_PackedStencil_DTYPE_2U_1U_1U_1U_4_regs_value_1_31_0_sva;
  reg [31:0] fifo_0_PackedStencil_DTYPE_2U_1U_1U_1U_4_regs_value_1_63_32_sva;
  reg [31:0] fifo_0_PackedStencil_DTYPE_2U_1U_1U_1U_4_regs_value_2_31_0_sva;
  reg [31:0] fifo_0_PackedStencil_DTYPE_2U_1U_1U_1U_4_regs_value_2_63_32_sva;
  reg [31:0] fifo_0_PackedStencil_DTYPE_2U_1U_1U_1U_4_regs_value_0_31_0_sva;
  reg [31:0] fifo_0_PackedStencil_DTYPE_2U_1U_1U_1U_4_regs_value_0_63_32_sva;
  reg [31:0] fifo_1_PackedStencil_DTYPE_2U_1U_1U_1U_3_regs_value_1_31_0_sva;
  reg [31:0] fifo_1_PackedStencil_DTYPE_2U_1U_1U_1U_3_regs_value_1_63_32_sva;
  reg [31:0] fifo_1_PackedStencil_DTYPE_2U_1U_1U_1U_3_regs_value_0_31_0_sva;
  reg [31:0] fifo_1_PackedStencil_DTYPE_2U_1U_1U_1U_3_regs_value_0_63_32_sva;
  reg [31:0] fifo_2_PackedStencil_DTYPE_2U_1U_1U_1U_2_regs_value_0_31_0_sva;
  reg [31:0] fifo_2_PackedStencil_DTYPE_2U_1U_1U_1U_2_regs_value_0_63_32_sva;
  reg exitL_exit_Co_sva;
  reg [31:0] COL_1_ROW_4_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_y_reg_value_64_63_0_ncse_63_32_lpi_1_dfm_1;
  reg [31:0] COL_1_ROW_4_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_y_reg_value_64_63_0_ncse_31_0_lpi_1_dfm_1;
  reg [31:0] COL_2_ROW_4_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_y_reg_value_64_63_0_ncse_63_32_lpi_1_dfm_1;
  reg [31:0] COL_2_ROW_4_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_y_reg_value_64_63_0_ncse_31_0_lpi_1_dfm_1;
  reg [31:0] COL_3_ROW_4_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_y_reg_value_64_63_0_ncse_63_32_lpi_1_dfm_1;
  reg [31:0] COL_3_ROW_4_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_y_reg_value_64_63_0_ncse_31_0_lpi_1_dfm_1;
  reg [31:0] COL_4_ROW_4_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_y_reg_value_64_63_0_ncse_63_32_lpi_1_dfm_1;
  reg [31:0] COL_4_ROW_4_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_y_reg_value_64_63_0_ncse_31_0_lpi_1_dfm_1;
  reg COMP_and_13_mdf_sva_1;
  reg exit_STEPS_lpi_1_dfm_1;
  reg exit_Ko_lpi_1_dfm_2;
  reg exit_winy_sva_2;
  reg exit_winy_lpi_1_dfm_2;
  reg exit_winx_sva_2;
  reg exit_winx_lpi_1_dfm_2;
  reg exit_Co_lpi_1_dfm_2;
  reg STEPS_if_slc_STEPS_if_acc_3_svs_2;
  reg COMP_i_0_lpi_1_dfm_2;
  reg [15:0] SHIFT_1_1_else_SHIFT_1_else_slc_fifo_60001_DTYPE_2_regs_16_15_0_ncse_lpi_1_dfm_1;
  reg [15:0] SHIFT_2_1_else_SHIFT_2_else_slc_fifo_60002_DTYPE_3_regs_16_15_0_ncse_lpi_1_dfm_1;
  reg [15:0] SHIFT_3_1_else_SHIFT_3_else_slc_fifo_60003_DTYPE_4_regs_16_15_0_ncse_lpi_1_dfm_1;
  reg COMP_i_0_1_lpi_1_dfm_2;
  reg COMP_i_0_2_lpi_1_dfm_2;
  reg COMP_i_0_3_lpi_1_dfm_2;
  reg COMP_i_0_4_lpi_1_dfm_2;
  reg COMP_i_0_5_lpi_1_dfm_2;
  reg COMP_i_0_6_lpi_1_dfm_2;
  reg COMP_i_0_7_lpi_1_dfm_2;
  reg COMP_i_0_8_lpi_1_dfm_2;
  reg COMP_i_0_9_lpi_1_dfm_2;
  reg COMP_i_0_10_lpi_1_dfm_2;
  reg COMP_i_0_11_lpi_1_dfm_2;
  reg COMP_i_0_12_lpi_1_dfm_2;
  reg COMP_i_0_13_lpi_1_dfm_2;
  reg COMP_i_0_14_lpi_1_dfm_2;
  reg COMP_i_0_15_lpi_1_dfm_2;
  reg [15:0] COL_1_ROW_1_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_x_reg_16_15_0_ncse_lpi_1_dfm_1;
  reg [15:0] COL_1_ROW_2_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_x_reg_16_15_0_ncse_lpi_1_dfm_1;
  reg [15:0] COL_1_ROW_3_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_x_reg_16_15_0_ncse_lpi_1_dfm_1;
  reg [15:0] COL_1_ROW_4_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_x_reg_16_15_0_ncse_lpi_1_dfm_1;
  reg [15:0] COL_2_ROW_1_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_x_reg_16_15_0_ncse_lpi_1_dfm_1;
  reg [15:0] COL_2_ROW_2_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_x_reg_16_15_0_ncse_lpi_1_dfm_1;
  reg [15:0] COL_2_ROW_3_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_x_reg_16_15_0_ncse_lpi_1_dfm_1;
  reg [15:0] COL_2_ROW_4_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_x_reg_16_15_0_ncse_lpi_1_dfm_1;
  reg [15:0] COL_3_ROW_1_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_x_reg_16_15_0_ncse_lpi_1_dfm_1;
  reg [15:0] COL_3_ROW_2_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_x_reg_16_15_0_ncse_lpi_1_dfm_1;
  reg [15:0] COL_3_ROW_3_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_x_reg_16_15_0_ncse_lpi_1_dfm_1;
  reg [15:0] COL_3_ROW_4_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_x_reg_16_15_0_ncse_lpi_1_dfm_1;
  reg [31:0] pe_y_reg_value_0_1_31_0_sva_dfm_1;
  reg [31:0] pe_y_reg_value_0_2_31_0_sva_dfm_1;
  reg [31:0] pe_y_reg_value_0_3_31_0_sva_dfm_1;
  reg [31:0] pe_y_reg_value_1_0_31_0_sva_dfm_1;
  reg [31:0] pe_y_reg_value_1_1_31_0_sva_dfm_1;
  reg [31:0] pe_y_reg_value_1_2_31_0_sva_dfm_1;
  reg [31:0] pe_y_reg_value_1_3_31_0_sva_dfm_1;
  reg [31:0] pe_y_reg_value_2_0_31_0_sva_dfm_1;
  reg [31:0] pe_y_reg_value_2_1_31_0_sva_dfm_1;
  reg [31:0] pe_y_reg_value_2_2_31_0_sva_dfm_1;
  reg [31:0] pe_y_reg_value_2_3_31_0_sva_dfm_1;
  reg [31:0] pe_y_reg_value_3_0_31_0_sva_dfm_1;
  reg [31:0] pe_y_reg_value_3_1_31_0_sva_dfm_1;
  reg [31:0] pe_y_reg_value_3_2_31_0_sva_dfm_1;
  reg [31:0] pe_y_reg_value_3_3_31_0_sva_dfm_1;
  reg [15:0] COL_1_ROW_2_PackedStencil_DTYPE_2U_1U_1U_1U_operator_rshift_itm_1;
  reg [15:0] COL_1_ROW_3_PackedStencil_DTYPE_2U_1U_1U_1U_operator_rshift_itm_1;
  reg [15:0] COL_1_ROW_4_PackedStencil_DTYPE_2U_1U_1U_1U_operator_rshift_itm_1;
  reg [15:0] COL_2_ROW_1_PackedStencil_DTYPE_2U_1U_1U_1U_operator_rshift_itm_1;
  reg [15:0] COL_2_ROW_2_PackedStencil_DTYPE_2U_1U_1U_1U_operator_rshift_itm_1;
  reg [15:0] COL_2_ROW_3_PackedStencil_DTYPE_2U_1U_1U_1U_operator_rshift_itm_1;
  reg [15:0] COL_2_ROW_4_PackedStencil_DTYPE_2U_1U_1U_1U_operator_rshift_itm_1;
  reg [15:0] COL_3_ROW_1_PackedStencil_DTYPE_2U_1U_1U_1U_operator_rshift_itm_1;
  reg [15:0] COL_3_ROW_2_PackedStencil_DTYPE_2U_1U_1U_1U_operator_rshift_itm_1;
  reg [15:0] COL_3_ROW_3_PackedStencil_DTYPE_2U_1U_1U_1U_operator_rshift_itm_1;
  reg [15:0] COL_3_ROW_4_PackedStencil_DTYPE_2U_1U_1U_1U_operator_rshift_itm_1;
  reg [15:0] COL_4_ROW_1_PackedStencil_DTYPE_2U_1U_1U_1U_operator_rshift_itm_1;
  reg [15:0] COL_4_ROW_2_PackedStencil_DTYPE_2U_1U_1U_1U_operator_rshift_itm_1;
  reg [15:0] COL_4_ROW_3_PackedStencil_DTYPE_2U_1U_1U_1U_operator_rshift_itm_1;
  reg [15:0] COL_4_ROW_4_PackedStencil_DTYPE_2U_1U_1U_1U_operator_rshift_itm_1;
  reg STEPS_step_slc_STEPS_step_4_0_4_4_itm_2;
  reg COMP_and_13_mdf_sva_st_1;
  reg STEPS_if_3_slc_STEPS_acc_5_5_itm_3;
  reg main_stage_0_2;
  reg [15:0] STEPS_in_col_value_111_0_lpi_1_dfm_1_15_0_1;
  reg [15:0] STEPS_if_w_row_value_239_0_lpi_1_dfm_1_239_224;
  reg [15:0] STEPS_if_w_row_value_239_0_lpi_1_dfm_1_207_192;
  reg [15:0] STEPS_if_w_row_value_239_0_lpi_1_dfm_1_175_160;
  reg [15:0] STEPS_if_w_row_value_239_0_lpi_1_dfm_1_143_128;
  reg [15:0] STEPS_if_w_row_value_239_0_lpi_1_dfm_1_111_96;
  reg [15:0] STEPS_if_w_row_value_239_0_lpi_1_dfm_1_79_64;
  reg [15:0] STEPS_if_w_row_value_239_0_lpi_1_dfm_1_47_32;
  reg [15:0] STEPS_if_w_row_value_239_0_lpi_1_dfm_1_15_0;
  wire winx_acc_tmp_2;
  wire exit_winy_lpi_1_dfm_2_mx0w0;
  wire exit_Ko_lpi_1_dfm_2_mx0w0;
  wire xor_cse;
  wire Ko_k_idx_0_lpi_1_dfm;
  wire exit_STEPS_lpi_1_dfm_1_mx0w0;
  wire Co_c_idx_0_lpi_1_dfm;
  wire lfst_exit_Ko_1_lpi_1_dfm;
  wire lfst_exit_winy_1_lpi_1_dfm;
  wire lfst_exit_winx_1_lpi_1_dfm;
  wire lfst_exit_Co_lpi_1_dfm;
  wire exit_winx_lpi_1_dfm_2_mx0w0;
  wire [1:0] winy_wy_idx_1_0_lpi_1_dfm;
  wire [1:0] winx_wx_idx_1_0_lpi_1_dfm;
  wire exitL_exit_COL_1_ROW_1_COMP_lpi_1_dfm;
  wire or_111_tmp;
  wire or_109_tmp;
  wire or_107_tmp;
  wire or_105_tmp;
  wire or_103_tmp;
  wire or_101_tmp;
  wire or_99_tmp;
  wire or_97_tmp;
  wire or_95_tmp;
  wire or_93_tmp;
  wire or_91_tmp;
  wire or_89_tmp;
  wire or_87_tmp;
  wire or_85_tmp;
  wire or_71_tmp;
  wire output_and_cse;
  wire output_and_6_cse;
  reg reg_out_tile_3_value_rsc_cgo_cse;
  reg reg_output_rsci_ld_core_psct_cse;
  reg reg_weight_rsci_ld_core_psct_cse;
  reg reg_input_rsci_ld_core_psct_cse;
  wire STEPS_if_w_row_value_and_cse;
  reg reg_exitL_exit_COL_1_ROW_1_COMP_lpi_1_dfm_3_cse;
  wire fifo_0_PackedStencil_DTYPE_2U_1U_1U_1U_4_regs_value_and_cse;
  wire pe_class_DTYPE_2_exec_and_cse;
  wire pe_x_reg_and_cse;
  reg reg_STEPS_if_2_land_1_lpi_1_dfm_st_1_cse;
  wire nor_12_cse;
  wire or_54_cse;
  wire or_8_cse;
  wire and_164_rmff;
  wire out_tile_3_value_nand_1_rmff;
  wire out_tile_3_value_nand_rmff;
  wire [31:0] COL_4_ROW_4_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_y_reg_value_64_63_0_ncse_63_32_lpi_1_dfm_mx0;
  wire [31:0] COL_4_ROW_4_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_y_reg_value_64_63_0_ncse_31_0_lpi_1_dfm_mx0;
  wire [4:0] STEPS_step_4_0_lpi_1_dfm;
  wire [31:0] asn_176_mx0w0;
  wire [31:0] asn_200_mx0w0;
  wire [31:0] asn_182_mx0w0;
  wire [31:0] asn_224_mx0w0;
  wire [31:0] asn_206_mx0w0;
  wire [31:0] asn_188_mx0w0;
  wire [31:0] asn_230_mx0w0;
  wire [31:0] asn_212_mx0w0;
  wire [31:0] asn_194_mx0w0;
  wire [31:0] asn_236_mx0w0;
  wire [31:0] asn_218_mx0w0;
  wire [63:0] STEPS_tmp_row_0_value_lpi_1_dfm;
  wire [15:0] COL_1_ROW_1_PackedStencil_DTYPE_2U_1U_1U_1U_operator_rshift_itm;
  wire [31:0] pe_y_reg_value_3_3_31_0_sva_mx0;
  wire [31:0] pe_y_reg_value_3_3_63_32_sva_mx0;
  wire COMP_i_0_lpi_1_dfm;
  wire COMP_i_0_15_lpi_1_dfm;
  wire COMP_i_0_14_lpi_1_dfm;
  wire COMP_i_0_13_lpi_1_dfm;
  wire COMP_i_0_12_lpi_1_dfm;
  wire COMP_i_0_11_lpi_1_dfm;
  wire COMP_i_0_10_lpi_1_dfm;
  wire COMP_i_0_9_lpi_1_dfm;
  wire COMP_i_0_8_lpi_1_dfm;
  wire COMP_i_0_7_lpi_1_dfm;
  wire COMP_i_0_6_lpi_1_dfm;
  wire COMP_i_0_5_lpi_1_dfm;
  wire COMP_i_0_4_lpi_1_dfm;
  wire COMP_i_0_3_lpi_1_dfm;
  wire COMP_i_0_2_lpi_1_dfm;
  wire COMP_i_0_1_lpi_1_dfm;
  wire [15:0] STEPS_if_w_row_value_239_0_lpi_1_dfm_1_207_192_mx1;
  wire [15:0] STEPS_if_w_row_value_239_0_lpi_1_dfm_1_239_224_mx1;
  wire exit_Co_lpi_1_dfm_2_mx0w0;
  wire [31:0] pe_y_reg_value_2_3_63_32_sva_mx0;
  wire [31:0] asn_158_mx0w0;
  wire [31:0] asn_161_mx0w2;
  wire [15:0] STEPS_if_w_row_value_239_0_lpi_1_dfm_1_143_128_mx1;
  wire [15:0] STEPS_if_w_row_value_239_0_lpi_1_dfm_1_175_160_mx1;
  wire [31:0] COL_3_ROW_4_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_y_reg_value_64_63_0_ncse_31_0_lpi_1_dfm_mx0;
  wire [31:0] COL_3_ROW_4_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_y_reg_value_64_63_0_ncse_63_32_lpi_1_dfm_mx0;
  wire [31:0] pe_y_reg_value_2_2_63_32_sva_mx0;
  wire [31:0] pe_y_reg_value_1_3_63_32_sva_mx0;
  wire [31:0] asn_164_mx0w0;
  wire [31:0] asn_167_mx0w2;
  wire [15:0] STEPS_if_w_row_value_239_0_lpi_1_dfm_1_79_64_mx1;
  wire [15:0] STEPS_if_w_row_value_239_0_lpi_1_dfm_1_111_96_mx1;
  wire [31:0] COL_2_ROW_4_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_y_reg_value_64_63_0_ncse_31_0_lpi_1_dfm_mx0;
  wire [31:0] COL_2_ROW_4_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_y_reg_value_64_63_0_ncse_63_32_lpi_1_dfm_mx0;
  wire [31:0] pe_y_reg_value_2_1_63_32_sva_mx0;
  wire [31:0] pe_y_reg_value_1_2_63_32_sva_mx0;
  wire [31:0] pe_y_reg_value_0_3_63_32_sva_mx0;
  wire [31:0] asn_170_mx0w0;
  wire [31:0] asn_173_mx0w2;
  wire [15:0] STEPS_if_w_row_value_239_0_lpi_1_dfm_1_15_0_mx1;
  wire [15:0] STEPS_if_w_row_value_239_0_lpi_1_dfm_1_47_32_mx1;
  wire [31:0] COL_1_ROW_4_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_y_reg_value_64_63_0_ncse_31_0_lpi_1_dfm_mx0;
  wire [31:0] COL_1_ROW_4_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_y_reg_value_64_63_0_ncse_63_32_lpi_1_dfm_mx0;
  wire [31:0] pe_y_reg_value_2_0_63_32_sva_mx0;
  wire [31:0] pe_y_reg_value_1_1_63_32_sva_mx0;
  wire [31:0] pe_y_reg_value_0_2_63_32_sva_mx0;
  wire [31:0] pe_y_reg_value_1_0_63_32_sva_mx0;
  wire [31:0] pe_y_reg_value_0_1_63_32_sva_mx0;
  wire [31:0] pe_y_reg_value_0_0_31_0_sva_mx1;
  wire [31:0] pe_y_reg_value_0_0_63_32_sva_mx1;
  wire [63:0] fifo_90003_PackedStencil_DTYPE_2U_1U_1U_1U_4_regs_value_0_sva_mx1;
  wire [63:0] fifo_90002_PackedStencil_DTYPE_2U_1U_1U_1U_3_regs_value_0_sva_mx1;
  wire [15:0] fifo_60003_DTYPE_4_regs_0_sva_mx1;
  wire [15:0] fifo_60002_DTYPE_3_regs_0_sva_mx1;
  wire [15:0] fifo_60001_DTYPE_2_regs_0_sva_mx1;
  wire [15:0] pe_x_reg_0_0_sva_mx1;
  wire [15:0] COL_4_ROW_4_COMP_tmp_acc_psp_sva;
  wire [16:0] nl_COL_4_ROW_4_COMP_tmp_acc_psp_sva;
  wire [1:0] winx_wx_idx_1_0_sva_1;
  wire [2:0] nl_winx_wx_idx_1_0_sva_1;
  wire [1:0] winy_wy_idx_1_0_sva_1;
  wire [2:0] nl_winy_wy_idx_1_0_sva_1;
  wire [4:0] STEPS_step_4_0_sva_1;
  wire [5:0] nl_STEPS_step_4_0_sva_1;
  wire [15:0] COL_3_ROW_4_COMP_tmp_acc_psp_sva;
  wire [16:0] nl_COL_3_ROW_4_COMP_tmp_acc_psp_sva;
  wire [15:0] COL_4_ROW_3_COMP_tmp_acc_psp_sva;
  wire [16:0] nl_COL_4_ROW_3_COMP_tmp_acc_psp_sva;
  wire [15:0] COL_2_ROW_4_COMP_tmp_acc_psp_sva;
  wire [16:0] nl_COL_2_ROW_4_COMP_tmp_acc_psp_sva;
  wire [15:0] COL_3_ROW_3_COMP_tmp_acc_psp_sva;
  wire [16:0] nl_COL_3_ROW_3_COMP_tmp_acc_psp_sva;
  wire [15:0] COL_4_ROW_2_COMP_tmp_acc_psp_sva;
  wire [16:0] nl_COL_4_ROW_2_COMP_tmp_acc_psp_sva;
  wire [15:0] COL_1_ROW_4_COMP_tmp_acc_psp_sva;
  wire [16:0] nl_COL_1_ROW_4_COMP_tmp_acc_psp_sva;
  wire [15:0] COL_2_ROW_3_COMP_tmp_acc_psp_sva;
  wire [16:0] nl_COL_2_ROW_3_COMP_tmp_acc_psp_sva;
  wire [15:0] COL_3_ROW_2_COMP_tmp_acc_psp_sva;
  wire [16:0] nl_COL_3_ROW_2_COMP_tmp_acc_psp_sva;
  wire [15:0] COL_4_ROW_1_COMP_tmp_acc_psp_sva;
  wire [16:0] nl_COL_4_ROW_1_COMP_tmp_acc_psp_sva;
  wire [15:0] COL_1_ROW_3_COMP_tmp_acc_psp_sva;
  wire [16:0] nl_COL_1_ROW_3_COMP_tmp_acc_psp_sva;
  wire [15:0] COL_2_ROW_2_COMP_tmp_acc_psp_sva;
  wire [16:0] nl_COL_2_ROW_2_COMP_tmp_acc_psp_sva;
  wire [15:0] COL_3_ROW_1_COMP_tmp_acc_psp_sva;
  wire [16:0] nl_COL_3_ROW_1_COMP_tmp_acc_psp_sva;
  wire [15:0] COL_1_ROW_2_COMP_tmp_acc_psp_sva;
  wire [16:0] nl_COL_1_ROW_2_COMP_tmp_acc_psp_sva;
  wire [15:0] COL_2_ROW_1_COMP_tmp_acc_psp_sva;
  wire [16:0] nl_COL_2_ROW_1_COMP_tmp_acc_psp_sva;
  wire [15:0] COL_1_ROW_1_COMP_tmp_acc_psp_sva;
  wire [16:0] nl_COL_1_ROW_1_COMP_tmp_acc_psp_sva;
  wire [63:0] STEPS_if_2_STEPS_if_2_and_1_rgt;
  reg [31:0] reg_fifo_90001_PackedStencil_DTYPE_2U_1U_1U_1U_2_regs_value_0_tmp;
  reg [15:0] reg_fifo_90001_PackedStencil_DTYPE_2U_1U_1U_1U_2_regs_value_0_tmp_17;
  wire [31:0] fifo_90001_PackedStencil_DTYPE_2U_1U_1U_1U_2_regs_value_0_sva_mx1_63_32;
  wire [15:0] fifo_90001_PackedStencil_DTYPE_2U_1U_1U_1U_2_regs_value_0_sva_mx1_15_0;
  wire STEPS_if_w_row_value_and_14_cse;
  wire pe_class_DTYPE_2_exec_and_12_cse;
  wire STEPS_if_w_row_value_and_8_cse;
  wire pe_y_reg_value_and_cse;
  wire STEPS_if_acc_itm_3_1;
  wire STEPS_acc_5_itm_5_1;
  wire STEPS_acc_itm_5_1;

  wire[0:0] mux_23_nl;
  wire[0:0] mux_22_nl;
  wire[0:0] nor_2_nl;
  wire[0:0] mux_21_nl;
  wire[0:0] nor_3_nl;
  wire[0:0] mux_20_nl;
  wire[0:0] mux_19_nl;
  wire[0:0] mux_18_nl;
  wire[0:0] and_72_nl;
  wire[0:0] and_74_nl;
  wire[0:0] PackedStencil_DTYPE_2U_1U_1U_1U_operator_and_29_nl;
  wire[0:0] STEPS_and_2_nl;
  wire[0:0] winy_and_3_nl;
  wire[0:0] winx_and_3_nl;
  wire[0:0] and_83_nl;
  wire[0:0] and_85_nl;
  wire[0:0] and_87_nl;
  wire[0:0] and_89_nl;
  wire[0:0] PackedStencil_DTYPE_2U_1U_1U_1U_operator_and_27_nl;
  wire[0:0] PackedStencil_DTYPE_2U_1U_1U_1U_operator_and_25_nl;
  wire[0:0] and_97_nl;
  wire[0:0] and_99_nl;
  wire[0:0] and_101_nl;
  wire[0:0] and_103_nl;
  wire[0:0] and_105_nl;
  wire[0:0] and_107_nl;
  wire[0:0] PackedStencil_DTYPE_2U_1U_1U_1U_operator_and_23_nl;
  wire[0:0] PackedStencil_DTYPE_2U_1U_1U_1U_operator_and_21_nl;
  wire[0:0] PackedStencil_DTYPE_2U_1U_1U_1U_operator_and_19_nl;
  wire[0:0] and_117_nl;
  wire[0:0] and_119_nl;
  wire[0:0] and_121_nl;
  wire[0:0] and_123_nl;
  wire[0:0] and_125_nl;
  wire[0:0] and_127_nl;
  wire[0:0] and_129_nl;
  wire[0:0] and_131_nl;
  wire[0:0] PackedStencil_DTYPE_2U_1U_1U_1U_operator_and_17_nl;
  wire[0:0] PackedStencil_DTYPE_2U_1U_1U_1U_operator_and_15_nl;
  wire[0:0] PackedStencil_DTYPE_2U_1U_1U_1U_operator_and_13_nl;
  wire[0:0] PackedStencil_DTYPE_2U_1U_1U_1U_operator_and_11_nl;
  wire[0:0] and_139_nl;
  wire[0:0] and_141_nl;
  wire[0:0] and_143_nl;
  wire[0:0] and_145_nl;
  wire[0:0] and_147_nl;
  wire[0:0] and_149_nl;
  wire[0:0] PackedStencil_DTYPE_2U_1U_1U_1U_operator_and_9_nl;
  wire[0:0] PackedStencil_DTYPE_2U_1U_1U_1U_operator_and_7_nl;
  wire[0:0] PackedStencil_DTYPE_2U_1U_1U_1U_operator_and_5_nl;
  wire[0:0] and_155_nl;
  wire[0:0] and_157_nl;
  wire[0:0] and_159_nl;
  wire[0:0] and_161_nl;
  wire[0:0] PackedStencil_DTYPE_2U_1U_1U_1U_operator_and_3_nl;
  wire[0:0] PackedStencil_DTYPE_2U_1U_1U_1U_operator_and_1_nl;
  wire[0:0] STEPS_if_2_aelse_1_not_8_nl;
  wire[31:0] pe_y_reg_value_mux_2_nl;
  wire[31:0] PackedStencil_DTYPE_2U_1U_1U_1U_operator_1_mux_nl;
  wire[3:0] STEPS_if_acc_nl;
  wire[4:0] nl_STEPS_if_acc_nl;
  wire[5:0] STEPS_acc_5_nl;
  wire[6:0] nl_STEPS_acc_5_nl;
  wire[0:0] winx_mux_1_nl;
  wire[0:0] winy_mux_1_nl;
  wire[31:0] PackedStencil_DTYPE_2U_1U_1U_1U_operator_1_mux_2_nl;
  wire[31:0] pe_y_reg_value_mux_3_nl;
  wire[31:0] PackedStencil_DTYPE_2U_1U_1U_1U_operator_1_mux_1_nl;
  wire[31:0] pe_y_reg_value_mux_4_nl;
  wire[31:0] PackedStencil_DTYPE_2U_1U_1U_1U_operator_1_mux_4_nl;
  wire[31:0] PackedStencil_DTYPE_2U_1U_1U_1U_operator_1_mux_5_nl;
  wire[31:0] pe_y_reg_value_mux_5_nl;
  wire[31:0] PackedStencil_DTYPE_2U_1U_1U_1U_operator_1_mux_3_nl;
  wire[31:0] pe_y_reg_value_mux_6_nl;
  wire[31:0] pe_y_reg_value_mux_7_nl;
  wire[31:0] PackedStencil_DTYPE_2U_1U_1U_1U_operator_1_mux_7_nl;
  wire[31:0] PackedStencil_DTYPE_2U_1U_1U_1U_operator_1_mux_8_nl;
  wire[31:0] PackedStencil_DTYPE_2U_1U_1U_1U_operator_1_mux_9_nl;
  wire[31:0] pe_y_reg_value_mux_8_nl;
  wire[31:0] PackedStencil_DTYPE_2U_1U_1U_1U_operator_1_mux_6_nl;
  wire[31:0] pe_y_reg_value_mux_9_nl;
  wire[31:0] pe_y_reg_value_mux_10_nl;
  wire[31:0] pe_y_reg_value_mux_11_nl;
  wire[31:0] PackedStencil_DTYPE_2U_1U_1U_1U_operator_1_mux_10_nl;
  wire[31:0] PackedStencil_DTYPE_2U_1U_1U_1U_operator_1_mux_11_nl;
  wire[31:0] PackedStencil_DTYPE_2U_1U_1U_1U_operator_1_mux_12_nl;
  wire[31:0] pe_y_reg_value_mux_12_nl;
  wire[31:0] pe_y_reg_value_mux_13_nl;
  wire[31:0] pe_y_reg_value_mux_14_nl;
  wire[31:0] PackedStencil_DTYPE_2U_1U_1U_1U_operator_1_mux_13_nl;
  wire[31:0] PackedStencil_DTYPE_2U_1U_1U_1U_operator_1_mux_14_nl;
  wire[31:0] pe_y_reg_value_mux_15_nl;
  wire[31:0] pe_y_reg_value_mux_16_nl;
  wire[0:0] PackedStencil_DTYPE_2U_1U_1U_1U_operator_1_nand_2_nl;
  wire[0:0] PackedStencil_DTYPE_2U_1U_1U_1U_operator_1_and_1_nl;
  wire[0:0] PackedStencil_DTYPE_2U_1U_1U_1U_operator_1_nand_nl;
  wire[0:0] PackedStencil_DTYPE_2U_1U_1U_1U_operator_1_and_nl;
  wire[63:0] STEPS_if_2_STEPS_if_2_and_3_nl;
  wire[0:0] STEPS_if_2_aelse_1_not_6_nl;
  wire[63:0] STEPS_if_2_STEPS_if_2_and_2_nl;
  wire[0:0] STEPS_if_2_aelse_1_not_7_nl;
  wire[15:0] COL_4_ROW_4_COMP_tmp_mul_nl;
  wire signed [32:0] nl_COL_4_ROW_4_COMP_tmp_mul_nl;
  wire[15:0] weight_value_operator_mux_15_nl;
  wire[5:0] STEPS_acc_nl;
  wire[6:0] nl_STEPS_acc_nl;
  wire[15:0] COL_3_ROW_4_COMP_tmp_mul_nl;
  wire signed [32:0] nl_COL_3_ROW_4_COMP_tmp_mul_nl;
  wire[15:0] weight_value_operator_mux_11_nl;
  wire[15:0] COL_4_ROW_3_COMP_tmp_mul_nl;
  wire signed [32:0] nl_COL_4_ROW_3_COMP_tmp_mul_nl;
  wire[15:0] weight_value_operator_mux_14_nl;
  wire[15:0] COL_2_ROW_4_COMP_tmp_mul_nl;
  wire signed [32:0] nl_COL_2_ROW_4_COMP_tmp_mul_nl;
  wire[15:0] weight_value_operator_mux_7_nl;
  wire[15:0] COL_3_ROW_3_COMP_tmp_mul_nl;
  wire signed [32:0] nl_COL_3_ROW_3_COMP_tmp_mul_nl;
  wire[15:0] weight_value_operator_mux_10_nl;
  wire[15:0] COL_4_ROW_2_COMP_tmp_mul_nl;
  wire signed [32:0] nl_COL_4_ROW_2_COMP_tmp_mul_nl;
  wire[15:0] weight_value_operator_mux_13_nl;
  wire[15:0] COL_1_ROW_4_COMP_tmp_mul_nl;
  wire signed [32:0] nl_COL_1_ROW_4_COMP_tmp_mul_nl;
  wire[15:0] weight_value_operator_mux_3_nl;
  wire[15:0] COL_2_ROW_3_COMP_tmp_mul_nl;
  wire signed [32:0] nl_COL_2_ROW_3_COMP_tmp_mul_nl;
  wire[15:0] weight_value_operator_mux_6_nl;
  wire[15:0] COL_3_ROW_2_COMP_tmp_mul_nl;
  wire signed [32:0] nl_COL_3_ROW_2_COMP_tmp_mul_nl;
  wire[15:0] weight_value_operator_mux_9_nl;
  wire[15:0] COL_4_ROW_1_COMP_tmp_mul_nl;
  wire signed [32:0] nl_COL_4_ROW_1_COMP_tmp_mul_nl;
  wire[15:0] weight_value_operator_mux_12_nl;
  wire[15:0] COL_1_ROW_3_COMP_tmp_mul_nl;
  wire signed [32:0] nl_COL_1_ROW_3_COMP_tmp_mul_nl;
  wire[15:0] weight_value_operator_mux_2_nl;
  wire[15:0] COL_2_ROW_2_COMP_tmp_mul_nl;
  wire signed [32:0] nl_COL_2_ROW_2_COMP_tmp_mul_nl;
  wire[15:0] weight_value_operator_mux_5_nl;
  wire[15:0] COL_3_ROW_1_COMP_tmp_mul_nl;
  wire signed [32:0] nl_COL_3_ROW_1_COMP_tmp_mul_nl;
  wire[15:0] weight_value_operator_mux_8_nl;
  wire[15:0] COL_1_ROW_2_COMP_tmp_mul_nl;
  wire signed [32:0] nl_COL_1_ROW_2_COMP_tmp_mul_nl;
  wire[15:0] weight_value_operator_mux_1_nl;
  wire[15:0] COL_2_ROW_1_COMP_tmp_mul_nl;
  wire signed [32:0] nl_COL_2_ROW_1_COMP_tmp_mul_nl;
  wire[15:0] weight_value_operator_mux_4_nl;
  wire[0:0] STEPS_if_2_aelse_1_not_4_nl;
  wire[15:0] COL_1_ROW_1_COMP_tmp_mul_nl;
  wire[31:0] nl_COL_1_ROW_1_COMP_tmp_mul_nl;
  wire[15:0] STEPS_in_col_value_mux_4_nl;
  wire[15:0] weight_value_operator_mux_nl;
  wire[0:0] or_61_nl;
  wire[0:0] and_280_nl;
  wire[0:0] mux_28_nl;
  wire[0:0] mux_26_nl;
  wire[0:0] mux_27_nl;
  wire[0:0] or_62_nl;
  wire[4:0] STEPS_if_3_acc_nl;
  wire[5:0] nl_STEPS_if_3_acc_nl;
  wire[0:0] STEPS_if_3_xor_nl;

  // Interconnect Declarations for Component Instantiations 
  wire[31:0] pe_class_DTYPE_2_exec_mux_12_nl;
  wire[31:0] pe_class_DTYPE_2_exec_mux_11_nl;
  wire [63:0] nl_COL_1_ROW_1_PackedStencil_DTYPE_2U_1U_1U_1U_operator_rshift_rg_a;
  assign pe_class_DTYPE_2_exec_mux_12_nl = MUX_v_32_2_2(pe_y_reg_value_0_0_63_32_sva,
      (STEPS_tmp_row_0_value_lpi_1_dfm[63:32]), reg_exitL_exit_COL_1_ROW_1_COMP_lpi_1_dfm_3_cse);
  assign pe_class_DTYPE_2_exec_mux_11_nl = MUX_v_32_2_2(pe_y_reg_value_0_0_31_0_sva,
      (STEPS_tmp_row_0_value_lpi_1_dfm[31:0]), reg_exitL_exit_COL_1_ROW_1_COMP_lpi_1_dfm_3_cse);
  assign nl_COL_1_ROW_1_PackedStencil_DTYPE_2U_1U_1U_1U_operator_rshift_rg_a = {(pe_class_DTYPE_2_exec_mux_12_nl)
      , (pe_class_DTYPE_2_exec_mux_11_nl)};
  wire [5:0] nl_COL_1_ROW_1_PackedStencil_DTYPE_2U_1U_1U_1U_operator_rshift_rg_s;
  assign nl_COL_1_ROW_1_PackedStencil_DTYPE_2U_1U_1U_1U_operator_rshift_rg_s = {COMP_i_0_7_lpi_1_dfm_2
      , 5'b0};
  wire [255:0] nl_systolic_array_DTYPE_2_4_16_4_2_2_3_core_output_rsci_inst_output_rsci_d;
  assign nl_systolic_array_DTYPE_2_4_16_4_2_2_3_core_output_rsci_inst_output_rsci_d
      = {output_rsci_d_255_224 , output_rsci_d_223_192 , output_rsci_d_191_160 ,
      output_rsci_d_159_128 , output_rsci_d_127_96 , output_rsci_d_95_64 , output_rsci_d_63_32
      , output_rsci_d_31_0};
  mgc_shift_r_v4 #(.width_a(32'sd64),
  .signd_a(32'sd0),
  .width_s(32'sd6),
  .width_z(32'sd16)) COL_1_ROW_1_PackedStencil_DTYPE_2U_1U_1U_1U_operator_rshift_rg
      (
      .a(nl_COL_1_ROW_1_PackedStencil_DTYPE_2U_1U_1U_1U_operator_rshift_rg_a[63:0]),
      .s(nl_COL_1_ROW_1_PackedStencil_DTYPE_2U_1U_1U_1U_operator_rshift_rg_s[5:0]),
      .z(COL_1_ROW_1_PackedStencil_DTYPE_2U_1U_1U_1U_operator_rshift_itm)
    );
  systolic_array_DTYPE_2_4_16_4_2_2_3_core_input_rsci systolic_array_DTYPE_2_4_16_4_2_2_3_core_input_rsci_inst
      (
      .clk(clk),
      .rst(rst),
      .input_rsc_z(input_rsc_z),
      .input_rsc_vz(input_rsc_vz),
      .input_rsc_lz(input_rsc_lz),
      .core_wen(core_wen),
      .input_rsci_oswt(reg_input_rsci_ld_core_psct_cse),
      .input_rsci_wen_comp(input_rsci_wen_comp),
      .input_rsci_d_mxwt(input_rsci_d_mxwt),
      .core_wten(core_wten)
    );
  systolic_array_DTYPE_2_4_16_4_2_2_3_core_weight_rsci systolic_array_DTYPE_2_4_16_4_2_2_3_core_weight_rsci_inst
      (
      .clk(clk),
      .rst(rst),
      .weight_rsc_z(weight_rsc_z),
      .weight_rsc_vz(weight_rsc_vz),
      .weight_rsc_lz(weight_rsc_lz),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .weight_rsci_oswt(reg_weight_rsci_ld_core_psct_cse),
      .weight_rsci_wen_comp(weight_rsci_wen_comp),
      .weight_rsci_d_mxwt(weight_rsci_d_mxwt)
    );
  systolic_array_DTYPE_2_4_16_4_2_2_3_core_output_rsci systolic_array_DTYPE_2_4_16_4_2_2_3_core_output_rsci_inst
      (
      .clk(clk),
      .rst(rst),
      .output_rsc_z(output_rsc_z),
      .output_rsc_vz(output_rsc_vz),
      .output_rsc_lz(output_rsc_lz),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .output_rsci_oswt(reg_output_rsci_ld_core_psct_cse),
      .output_rsci_wen_comp(output_rsci_wen_comp),
      .output_rsci_d(nl_systolic_array_DTYPE_2_4_16_4_2_2_3_core_output_rsci_inst_output_rsci_d[255:0])
    );
  systolic_array_DTYPE_2_4_16_4_2_2_3_core_wait_dp systolic_array_DTYPE_2_4_16_4_2_2_3_core_wait_dp_inst
      (
      .out_tile_0_value_rsc_cgo_iro(and_164_rmff),
      .out_tile_0_value_rsc_cge(out_tile_0_value_rsc_cge),
      .core_wen(core_wen),
      .out_tile_0_value_rsc_cgo(reg_out_tile_3_value_rsc_cgo_cse)
    );
  systolic_array_DTYPE_2_4_16_4_2_2_3_core_staller systolic_array_DTYPE_2_4_16_4_2_2_3_core_staller_inst
      (
      .clk(clk),
      .rst(rst),
      .core_wen(core_wen),
      .input_rsci_wen_comp(input_rsci_wen_comp),
      .core_wten(core_wten),
      .weight_rsci_wen_comp(weight_rsci_wen_comp),
      .output_rsci_wen_comp(output_rsci_wen_comp)
    );
  systolic_array_DTYPE_2_4_16_4_2_2_3_core_core_fsm systolic_array_DTYPE_2_4_16_4_2_2_3_core_core_fsm_inst
      (
      .clk(clk),
      .rst(rst),
      .core_wen(core_wen),
      .fsm_output(fsm_output)
    );
  assign output_and_cse = core_wen & (~((~ Co_c_idx_0_lpi_1) | (winx_wx_idx_1_0_lpi_2!=2'b10)
      | (winy_wy_idx_1_0_lpi_2!=2'b10) | (~ COMP_and_13_tmp) | STEPS_acc_5_itm_5_1));
  assign output_and_6_cse = core_wen & Co_c_idx_0_lpi_1_dfm & (winx_wx_idx_1_0_lpi_2==2'b10)
      & (winy_wy_idx_1_0_lpi_2==2'b10) & COMP_and_13_tmp & (~ STEPS_acc_5_itm_5_1);
  assign nor_2_nl = ~(Co_c_idx_0_lpi_1 | (~ nand_tmp));
  assign nor_3_nl = ~((winx_wx_idx_1_0_lpi_2!=2'b00) | Co_c_idx_0_lpi_1 | (~ nand_tmp));
  assign mux_18_nl = MUX_s_1_2_2(nand_tmp, (~ or_tmp_7), or_dcpl);
  assign mux_19_nl = MUX_s_1_2_2((mux_18_nl), nand_tmp, STEPS_step_4_0_lpi_2[4]);
  assign mux_20_nl = MUX_s_1_2_2((mux_19_nl), (~ or_tmp_7), or_dcpl_35);
  assign mux_21_nl = MUX_s_1_2_2((mux_20_nl), (nor_3_nl), exit_winx_lpi_1_dfm_2);
  assign mux_22_nl = MUX_s_1_2_2((mux_21_nl), (nor_2_nl), exit_Co_lpi_1_dfm_2);
  assign mux_23_nl = MUX_s_1_2_2((mux_22_nl), nand_tmp, exitL_exit_Co_sva);
  assign and_164_rmff = ((~ (mux_23_nl)) | and_dcpl_29) & (fsm_output[1]);
  assign or_54_cse = or_dcpl_4 | (or_dcpl & (~ (STEPS_step_4_0_lpi_2[4]))) | exit_Ko_lpi_1_dfm_2;
  assign or_8_cse = or_dcpl_4 | exit_Ko_lpi_1_dfm_2 | COMP_and_13_mdf_sva_1 | exit_STEPS_lpi_1_dfm_1;
  assign pe_class_DTYPE_2_exec_and_cse = core_wen & (~ and_dcpl_49);
  assign STEPS_if_w_row_value_and_cse = core_wen & (~ (fsm_output[0]));
  assign STEPS_if_w_row_value_and_14_cse = STEPS_if_w_row_value_and_cse & or_dcpl_9;
  assign or_71_tmp = or_dcpl_51 | mux_tmp_11 | or_dcpl;
  assign pe_class_DTYPE_2_exec_and_12_cse = core_wen & (~ COMP_and_13_tmp);
  assign fifo_0_PackedStencil_DTYPE_2U_1U_1U_1U_4_regs_value_and_cse = core_wen &
      (~((~ COMP_and_13_tmp) | (fsm_output[0])));
  assign or_85_tmp = or_dcpl_51 | mux_tmp_13 | or_dcpl;
  assign STEPS_if_w_row_value_and_8_cse = STEPS_if_w_row_value_and_cse & (~ or_dcpl_48)
      & or_dcpl_9;
  assign or_87_tmp = or_dcpl_51 | mux_tmp_12 | or_dcpl;
  assign pe_x_reg_and_cse = core_wen & (~(and_dcpl_49 | (fsm_output[0])));
  assign or_89_tmp = or_dcpl_51 | mux_tmp_16 | or_dcpl;
  assign or_91_tmp = or_dcpl_51 | mux_tmp_15 | or_dcpl;
  assign or_93_tmp = or_dcpl_51 | mux_tmp_14 | or_dcpl;
  assign or_95_tmp = or_dcpl_51 | mux_tmp_20 | or_dcpl;
  assign or_97_tmp = or_dcpl_51 | mux_tmp_19 | or_dcpl;
  assign or_99_tmp = or_dcpl_51 | mux_tmp_18 | or_dcpl;
  assign or_101_tmp = or_dcpl_51 | mux_tmp_17 | or_dcpl;
  assign or_103_tmp = or_dcpl_51 | mux_tmp_23 | or_dcpl;
  assign or_105_tmp = or_dcpl_51 | mux_tmp_22 | or_dcpl;
  assign or_107_tmp = or_dcpl_51 | mux_tmp_21 | or_dcpl;
  assign or_109_tmp = or_dcpl_51 | mux_tmp_25 | or_dcpl;
  assign or_111_tmp = or_dcpl_51 | mux_tmp_24 | or_dcpl;
  assign pe_y_reg_value_and_cse = (~ (fsm_output[0])) & core_wen & and_dcpl_6;
  assign STEPS_if_2_aelse_1_not_8_nl = ~ reg_STEPS_if_2_land_1_lpi_1_dfm_st_1_cse;
  assign STEPS_if_2_STEPS_if_2_and_1_rgt = MUX_v_64_2_2(64'b0000000000000000000000000000000000000000000000000000000000000000,
      (out_tile_1_value_rsci_data_out_d[63:0]), (STEPS_if_2_aelse_1_not_8_nl));
  assign pe_y_reg_value_mux_2_nl = MUX_v_32_2_2(pe_y_reg_value_3_3_31_0_sva_dfm_1,
      ({{16{COL_4_ROW_4_COMP_tmp_acc_psp_sva[15]}}, COL_4_ROW_4_COMP_tmp_acc_psp_sva}),
      and_dcpl_38);
  assign pe_y_reg_value_3_3_31_0_sva_mx0 = MUX_v_32_2_2(32'b00000000000000000000000000000000,
      (pe_y_reg_value_mux_2_nl), main_stage_0_2);
  assign PackedStencil_DTYPE_2U_1U_1U_1U_operator_1_mux_nl = MUX_v_32_2_2(({{16{COL_4_ROW_4_COMP_tmp_acc_psp_sva[15]}},
      COL_4_ROW_4_COMP_tmp_acc_psp_sva}), pe_y_reg_value_3_3_31_0_sva_dfm_1, and_dcpl_38);
  assign pe_y_reg_value_3_3_63_32_sva_mx0 = MUX_v_32_2_2(32'b00000000000000000000000000000000,
      (PackedStencil_DTYPE_2U_1U_1U_1U_operator_1_mux_nl), main_stage_0_2);
  assign nl_STEPS_if_acc_nl = conv_u2s_3_4(STEPS_step_4_0_lpi_1_dfm[4:2]) + 4'b1111;
  assign STEPS_if_acc_nl = nl_STEPS_if_acc_nl[3:0];
  assign STEPS_if_acc_itm_3_1 = readslicef_4_1_3((STEPS_if_acc_nl));
  assign nl_STEPS_acc_5_nl = conv_u2s_5_6(STEPS_step_4_0_lpi_1_dfm) + 6'b111001;
  assign STEPS_acc_5_nl = nl_STEPS_acc_5_nl[5:0];
  assign STEPS_acc_5_itm_5_1 = readslicef_6_1_5((STEPS_acc_5_nl));
  assign COMP_i_0_lpi_1_dfm = ~(COMP_i_0_lpi_1_dfm_2 | exitL_exit_COL_1_ROW_1_COMP_lpi_1_dfm);
  assign COMP_i_0_15_lpi_1_dfm = ~(COMP_i_0_15_lpi_1_dfm_2 | exitL_exit_COL_1_ROW_1_COMP_lpi_1_dfm);
  assign COMP_i_0_14_lpi_1_dfm = ~(COMP_i_0_14_lpi_1_dfm_2 | exitL_exit_COL_1_ROW_1_COMP_lpi_1_dfm);
  assign COMP_i_0_13_lpi_1_dfm = ~(COMP_i_0_13_lpi_1_dfm_2 | exitL_exit_COL_1_ROW_1_COMP_lpi_1_dfm);
  assign COMP_i_0_12_lpi_1_dfm = ~(COMP_i_0_12_lpi_1_dfm_2 | exitL_exit_COL_1_ROW_1_COMP_lpi_1_dfm);
  assign COMP_i_0_11_lpi_1_dfm = ~(COMP_i_0_11_lpi_1_dfm_2 | exitL_exit_COL_1_ROW_1_COMP_lpi_1_dfm);
  assign COMP_i_0_10_lpi_1_dfm = ~(COMP_i_0_10_lpi_1_dfm_2 | exitL_exit_COL_1_ROW_1_COMP_lpi_1_dfm);
  assign COMP_i_0_9_lpi_1_dfm = ~(COMP_i_0_9_lpi_1_dfm_2 | exitL_exit_COL_1_ROW_1_COMP_lpi_1_dfm);
  assign COMP_i_0_8_lpi_1_dfm = ~(COMP_i_0_8_lpi_1_dfm_2 | exitL_exit_COL_1_ROW_1_COMP_lpi_1_dfm);
  assign COMP_i_0_7_lpi_1_dfm = ~(COMP_i_0_7_lpi_1_dfm_2 | exitL_exit_COL_1_ROW_1_COMP_lpi_1_dfm);
  assign COMP_i_0_6_lpi_1_dfm = ~(COMP_i_0_6_lpi_1_dfm_2 | exitL_exit_COL_1_ROW_1_COMP_lpi_1_dfm);
  assign COMP_i_0_5_lpi_1_dfm = ~(COMP_i_0_5_lpi_1_dfm_2 | exitL_exit_COL_1_ROW_1_COMP_lpi_1_dfm);
  assign COMP_i_0_4_lpi_1_dfm = ~(COMP_i_0_4_lpi_1_dfm_2 | exitL_exit_COL_1_ROW_1_COMP_lpi_1_dfm);
  assign COMP_i_0_3_lpi_1_dfm = ~(COMP_i_0_3_lpi_1_dfm_2 | exitL_exit_COL_1_ROW_1_COMP_lpi_1_dfm);
  assign COMP_i_0_2_lpi_1_dfm = ~(COMP_i_0_2_lpi_1_dfm_2 | exitL_exit_COL_1_ROW_1_COMP_lpi_1_dfm);
  assign COMP_i_0_1_lpi_1_dfm = ~(COMP_i_0_1_lpi_1_dfm_2 | exitL_exit_COL_1_ROW_1_COMP_lpi_1_dfm);
  assign COMP_and_13_tmp = COMP_i_0_7_lpi_1_dfm & COMP_i_0_10_lpi_1_dfm & COMP_i_0_13_lpi_1_dfm
      & COMP_i_0_4_lpi_1_dfm & COMP_i_0_8_lpi_1_dfm & COMP_i_0_11_lpi_1_dfm & COMP_i_0_14_lpi_1_dfm
      & COMP_i_0_5_lpi_1_dfm & COMP_i_0_9_lpi_1_dfm & COMP_i_0_12_lpi_1_dfm & COMP_i_0_15_lpi_1_dfm
      & COMP_i_0_6_lpi_1_dfm & COMP_i_0_1_lpi_1_dfm & COMP_i_0_2_lpi_1_dfm & COMP_i_0_3_lpi_1_dfm
      & COMP_i_0_lpi_1_dfm;
  assign STEPS_if_w_row_value_239_0_lpi_1_dfm_1_207_192_mx1 = MUX_v_16_2_2((weight_rsci_d_mxwt[111:96]),
      STEPS_if_w_row_value_239_0_lpi_1_dfm_1_207_192, or_dcpl_46);
  assign STEPS_if_w_row_value_239_0_lpi_1_dfm_1_239_224_mx1 = MUX_v_16_2_2((weight_rsci_d_mxwt[127:112]),
      STEPS_if_w_row_value_239_0_lpi_1_dfm_1_239_224, or_dcpl_46);
  assign exitL_exit_COL_1_ROW_1_COMP_lpi_1_dfm = COMP_and_13_mdf_sva_1 | (~((~ exit_STEPS_lpi_1_dfm_1)
      & lfst_exit_Ko_1_lpi_1_dfm));
  assign winx_acc_tmp_2 = (winx_wx_idx_1_0_sva_1[0]) ^ (winx_wx_idx_1_0_sva_1[1]);
  assign COL_4_ROW_4_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_y_reg_value_64_63_0_ncse_63_32_lpi_1_dfm_mx0
      = MUX_v_32_2_2(pe_y_reg_value_3_3_63_32_sva_mx0, COL_4_ROW_4_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_y_reg_value_64_63_0_ncse_63_32_lpi_1_dfm_1,
      and_dcpl_49);
  assign COL_4_ROW_4_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_y_reg_value_64_63_0_ncse_31_0_lpi_1_dfm_mx0
      = MUX_v_32_2_2(pe_y_reg_value_3_3_31_0_sva_mx0, COL_4_ROW_4_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_y_reg_value_64_63_0_ncse_31_0_lpi_1_dfm_1,
      and_dcpl_49);
  assign winx_mux_1_nl = MUX_s_1_2_2((~ winx_acc_tmp_2), exit_winx_sva_2, or_dcpl_56);
  assign exit_winx_lpi_1_dfm_2_mx0w0 = (winx_mux_1_nl) & exit_winy_lpi_1_dfm_2_mx0w0;
  assign winy_mux_1_nl = MUX_s_1_2_2((~ xor_cse), exit_winy_sva_2, or_dcpl_58);
  assign exit_winy_lpi_1_dfm_2_mx0w0 = (winy_mux_1_nl) & exit_Ko_lpi_1_dfm_2_mx0w0;
  assign exit_Ko_lpi_1_dfm_2_mx0w0 = Ko_k_idx_0_lpi_1_dfm & exit_STEPS_lpi_1_dfm_1_mx0w0;
  assign exit_STEPS_lpi_1_dfm_1_mx0w0 = (~ STEPS_acc_itm_5_1) & COMP_and_13_tmp;
  assign exit_Co_lpi_1_dfm_2_mx0w0 = Co_c_idx_0_lpi_1_dfm & exit_winx_lpi_1_dfm_2_mx0w0;
  assign PackedStencil_DTYPE_2U_1U_1U_1U_operator_1_mux_2_nl = MUX_v_32_2_2(({{16{COL_4_ROW_3_COMP_tmp_acc_psp_sva[15]}},
      COL_4_ROW_3_COMP_tmp_acc_psp_sva}), pe_y_reg_value_2_3_31_0_sva_dfm_1, and_dcpl_53);
  assign pe_y_reg_value_2_3_63_32_sva_mx0 = MUX_v_32_2_2(32'b00000000000000000000000000000000,
      (PackedStencil_DTYPE_2U_1U_1U_1U_operator_1_mux_2_nl), main_stage_0_2);
  assign pe_y_reg_value_mux_3_nl = MUX_v_32_2_2(pe_y_reg_value_3_2_31_0_sva_dfm_1,
      ({{16{COL_3_ROW_4_COMP_tmp_acc_psp_sva[15]}}, COL_3_ROW_4_COMP_tmp_acc_psp_sva}),
      and_dcpl_51);
  assign asn_158_mx0w0 = MUX_v_32_2_2(32'b00000000000000000000000000000000, (pe_y_reg_value_mux_3_nl),
      main_stage_0_2);
  assign PackedStencil_DTYPE_2U_1U_1U_1U_operator_1_mux_1_nl = MUX_v_32_2_2(({{16{COL_3_ROW_4_COMP_tmp_acc_psp_sva[15]}},
      COL_3_ROW_4_COMP_tmp_acc_psp_sva}), pe_y_reg_value_3_2_31_0_sva_dfm_1, and_dcpl_51);
  assign asn_161_mx0w2 = MUX_v_32_2_2(32'b00000000000000000000000000000000, (PackedStencil_DTYPE_2U_1U_1U_1U_operator_1_mux_1_nl),
      main_stage_0_2);
  assign pe_y_reg_value_mux_4_nl = MUX_v_32_2_2(pe_y_reg_value_2_3_31_0_sva_dfm_1,
      ({{16{COL_4_ROW_3_COMP_tmp_acc_psp_sva[15]}}, COL_4_ROW_3_COMP_tmp_acc_psp_sva}),
      and_dcpl_53);
  assign asn_176_mx0w0 = MUX_v_32_2_2(32'b00000000000000000000000000000000, (pe_y_reg_value_mux_4_nl),
      main_stage_0_2);
  assign STEPS_if_w_row_value_239_0_lpi_1_dfm_1_143_128_mx1 = MUX_v_16_2_2((weight_rsci_d_mxwt[79:64]),
      STEPS_if_w_row_value_239_0_lpi_1_dfm_1_143_128, or_dcpl_46);
  assign STEPS_if_w_row_value_239_0_lpi_1_dfm_1_175_160_mx1 = MUX_v_16_2_2((weight_rsci_d_mxwt[95:80]),
      STEPS_if_w_row_value_239_0_lpi_1_dfm_1_175_160, or_dcpl_46);
  assign COL_3_ROW_4_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_y_reg_value_64_63_0_ncse_31_0_lpi_1_dfm_mx0
      = MUX_v_32_2_2(asn_158_mx0w0, COL_3_ROW_4_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_y_reg_value_64_63_0_ncse_31_0_lpi_1_dfm_1,
      and_dcpl_49);
  assign COL_3_ROW_4_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_y_reg_value_64_63_0_ncse_63_32_lpi_1_dfm_mx0
      = MUX_v_32_2_2(asn_161_mx0w2, COL_3_ROW_4_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_y_reg_value_64_63_0_ncse_63_32_lpi_1_dfm_1,
      and_dcpl_49);
  assign PackedStencil_DTYPE_2U_1U_1U_1U_operator_1_mux_4_nl = MUX_v_32_2_2(({{16{COL_3_ROW_3_COMP_tmp_acc_psp_sva[15]}},
      COL_3_ROW_3_COMP_tmp_acc_psp_sva}), pe_y_reg_value_2_2_31_0_sva_dfm_1, and_dcpl_65);
  assign pe_y_reg_value_2_2_63_32_sva_mx0 = MUX_v_32_2_2(32'b00000000000000000000000000000000,
      (PackedStencil_DTYPE_2U_1U_1U_1U_operator_1_mux_4_nl), main_stage_0_2);
  assign PackedStencil_DTYPE_2U_1U_1U_1U_operator_1_mux_5_nl = MUX_v_32_2_2(({{16{COL_4_ROW_2_COMP_tmp_acc_psp_sva[15]}},
      COL_4_ROW_2_COMP_tmp_acc_psp_sva}), pe_y_reg_value_1_3_31_0_sva_dfm_1, and_dcpl_67);
  assign pe_y_reg_value_1_3_63_32_sva_mx0 = MUX_v_32_2_2(32'b00000000000000000000000000000000,
      (PackedStencil_DTYPE_2U_1U_1U_1U_operator_1_mux_5_nl), main_stage_0_2);
  assign pe_y_reg_value_mux_5_nl = MUX_v_32_2_2(pe_y_reg_value_3_1_31_0_sva_dfm_1,
      ({{16{COL_2_ROW_4_COMP_tmp_acc_psp_sva[15]}}, COL_2_ROW_4_COMP_tmp_acc_psp_sva}),
      and_dcpl_63);
  assign asn_164_mx0w0 = MUX_v_32_2_2(32'b00000000000000000000000000000000, (pe_y_reg_value_mux_5_nl),
      main_stage_0_2);
  assign PackedStencil_DTYPE_2U_1U_1U_1U_operator_1_mux_3_nl = MUX_v_32_2_2(({{16{COL_2_ROW_4_COMP_tmp_acc_psp_sva[15]}},
      COL_2_ROW_4_COMP_tmp_acc_psp_sva}), pe_y_reg_value_3_1_31_0_sva_dfm_1, and_dcpl_63);
  assign asn_167_mx0w2 = MUX_v_32_2_2(32'b00000000000000000000000000000000, (PackedStencil_DTYPE_2U_1U_1U_1U_operator_1_mux_3_nl),
      main_stage_0_2);
  assign pe_y_reg_value_mux_6_nl = MUX_v_32_2_2(pe_y_reg_value_2_2_31_0_sva_dfm_1,
      ({{16{COL_3_ROW_3_COMP_tmp_acc_psp_sva[15]}}, COL_3_ROW_3_COMP_tmp_acc_psp_sva}),
      and_dcpl_65);
  assign asn_182_mx0w0 = MUX_v_32_2_2(32'b00000000000000000000000000000000, (pe_y_reg_value_mux_6_nl),
      main_stage_0_2);
  assign pe_y_reg_value_mux_7_nl = MUX_v_32_2_2(pe_y_reg_value_1_3_31_0_sva_dfm_1,
      ({{16{COL_4_ROW_2_COMP_tmp_acc_psp_sva[15]}}, COL_4_ROW_2_COMP_tmp_acc_psp_sva}),
      and_dcpl_67);
  assign asn_200_mx0w0 = MUX_v_32_2_2(32'b00000000000000000000000000000000, (pe_y_reg_value_mux_7_nl),
      main_stage_0_2);
  assign STEPS_if_w_row_value_239_0_lpi_1_dfm_1_79_64_mx1 = MUX_v_16_2_2((weight_rsci_d_mxwt[47:32]),
      STEPS_if_w_row_value_239_0_lpi_1_dfm_1_79_64, or_dcpl_46);
  assign STEPS_if_w_row_value_239_0_lpi_1_dfm_1_111_96_mx1 = MUX_v_16_2_2((weight_rsci_d_mxwt[63:48]),
      STEPS_if_w_row_value_239_0_lpi_1_dfm_1_111_96, or_dcpl_46);
  assign COL_2_ROW_4_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_y_reg_value_64_63_0_ncse_31_0_lpi_1_dfm_mx0
      = MUX_v_32_2_2(asn_164_mx0w0, COL_2_ROW_4_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_y_reg_value_64_63_0_ncse_31_0_lpi_1_dfm_1,
      and_dcpl_49);
  assign COL_2_ROW_4_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_y_reg_value_64_63_0_ncse_63_32_lpi_1_dfm_mx0
      = MUX_v_32_2_2(asn_167_mx0w2, COL_2_ROW_4_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_y_reg_value_64_63_0_ncse_63_32_lpi_1_dfm_1,
      and_dcpl_49);
  assign PackedStencil_DTYPE_2U_1U_1U_1U_operator_1_mux_7_nl = MUX_v_32_2_2(({{16{COL_2_ROW_3_COMP_tmp_acc_psp_sva[15]}},
      COL_2_ROW_3_COMP_tmp_acc_psp_sva}), pe_y_reg_value_2_1_31_0_sva_dfm_1, and_dcpl_83);
  assign pe_y_reg_value_2_1_63_32_sva_mx0 = MUX_v_32_2_2(32'b00000000000000000000000000000000,
      (PackedStencil_DTYPE_2U_1U_1U_1U_operator_1_mux_7_nl), main_stage_0_2);
  assign PackedStencil_DTYPE_2U_1U_1U_1U_operator_1_mux_8_nl = MUX_v_32_2_2(({{16{COL_3_ROW_2_COMP_tmp_acc_psp_sva[15]}},
      COL_3_ROW_2_COMP_tmp_acc_psp_sva}), pe_y_reg_value_1_2_31_0_sva_dfm_1, and_dcpl_85);
  assign pe_y_reg_value_1_2_63_32_sva_mx0 = MUX_v_32_2_2(32'b00000000000000000000000000000000,
      (PackedStencil_DTYPE_2U_1U_1U_1U_operator_1_mux_8_nl), main_stage_0_2);
  assign PackedStencil_DTYPE_2U_1U_1U_1U_operator_1_mux_9_nl = MUX_v_32_2_2(({{16{COL_4_ROW_1_COMP_tmp_acc_psp_sva[15]}},
      COL_4_ROW_1_COMP_tmp_acc_psp_sva}), pe_y_reg_value_0_3_31_0_sva_dfm_1, and_dcpl_87);
  assign pe_y_reg_value_0_3_63_32_sva_mx0 = MUX_v_32_2_2(32'b00000000000000000000000000000000,
      (PackedStencil_DTYPE_2U_1U_1U_1U_operator_1_mux_9_nl), main_stage_0_2);
  assign pe_y_reg_value_mux_8_nl = MUX_v_32_2_2(pe_y_reg_value_3_0_31_0_sva_dfm_1,
      ({{16{COL_1_ROW_4_COMP_tmp_acc_psp_sva[15]}}, COL_1_ROW_4_COMP_tmp_acc_psp_sva}),
      and_dcpl_81);
  assign asn_170_mx0w0 = MUX_v_32_2_2(32'b00000000000000000000000000000000, (pe_y_reg_value_mux_8_nl),
      main_stage_0_2);
  assign PackedStencil_DTYPE_2U_1U_1U_1U_operator_1_mux_6_nl = MUX_v_32_2_2(({{16{COL_1_ROW_4_COMP_tmp_acc_psp_sva[15]}},
      COL_1_ROW_4_COMP_tmp_acc_psp_sva}), pe_y_reg_value_3_0_31_0_sva_dfm_1, and_dcpl_81);
  assign asn_173_mx0w2 = MUX_v_32_2_2(32'b00000000000000000000000000000000, (PackedStencil_DTYPE_2U_1U_1U_1U_operator_1_mux_6_nl),
      main_stage_0_2);
  assign pe_y_reg_value_mux_9_nl = MUX_v_32_2_2(pe_y_reg_value_2_1_31_0_sva_dfm_1,
      ({{16{COL_2_ROW_3_COMP_tmp_acc_psp_sva[15]}}, COL_2_ROW_3_COMP_tmp_acc_psp_sva}),
      and_dcpl_83);
  assign asn_188_mx0w0 = MUX_v_32_2_2(32'b00000000000000000000000000000000, (pe_y_reg_value_mux_9_nl),
      main_stage_0_2);
  assign pe_y_reg_value_mux_10_nl = MUX_v_32_2_2(pe_y_reg_value_1_2_31_0_sva_dfm_1,
      ({{16{COL_3_ROW_2_COMP_tmp_acc_psp_sva[15]}}, COL_3_ROW_2_COMP_tmp_acc_psp_sva}),
      and_dcpl_85);
  assign asn_206_mx0w0 = MUX_v_32_2_2(32'b00000000000000000000000000000000, (pe_y_reg_value_mux_10_nl),
      main_stage_0_2);
  assign pe_y_reg_value_mux_11_nl = MUX_v_32_2_2(pe_y_reg_value_0_3_31_0_sva_dfm_1,
      ({{16{COL_4_ROW_1_COMP_tmp_acc_psp_sva[15]}}, COL_4_ROW_1_COMP_tmp_acc_psp_sva}),
      and_dcpl_87);
  assign asn_224_mx0w0 = MUX_v_32_2_2(32'b00000000000000000000000000000000, (pe_y_reg_value_mux_11_nl),
      main_stage_0_2);
  assign STEPS_if_w_row_value_239_0_lpi_1_dfm_1_15_0_mx1 = MUX_v_16_2_2((weight_rsci_d_mxwt[15:0]),
      STEPS_if_w_row_value_239_0_lpi_1_dfm_1_15_0, or_dcpl_46);
  assign STEPS_if_w_row_value_239_0_lpi_1_dfm_1_47_32_mx1 = MUX_v_16_2_2((weight_rsci_d_mxwt[31:16]),
      STEPS_if_w_row_value_239_0_lpi_1_dfm_1_47_32, or_dcpl_46);
  assign COL_1_ROW_4_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_y_reg_value_64_63_0_ncse_31_0_lpi_1_dfm_mx0
      = MUX_v_32_2_2(asn_170_mx0w0, COL_1_ROW_4_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_y_reg_value_64_63_0_ncse_31_0_lpi_1_dfm_1,
      and_dcpl_49);
  assign COL_1_ROW_4_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_y_reg_value_64_63_0_ncse_63_32_lpi_1_dfm_mx0
      = MUX_v_32_2_2(asn_173_mx0w2, COL_1_ROW_4_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_y_reg_value_64_63_0_ncse_63_32_lpi_1_dfm_1,
      and_dcpl_49);
  assign PackedStencil_DTYPE_2U_1U_1U_1U_operator_1_mux_10_nl = MUX_v_32_2_2(({{16{COL_1_ROW_3_COMP_tmp_acc_psp_sva[15]}},
      COL_1_ROW_3_COMP_tmp_acc_psp_sva}), pe_y_reg_value_2_0_31_0_sva_dfm_1, and_dcpl_105);
  assign pe_y_reg_value_2_0_63_32_sva_mx0 = MUX_v_32_2_2(32'b00000000000000000000000000000000,
      (PackedStencil_DTYPE_2U_1U_1U_1U_operator_1_mux_10_nl), main_stage_0_2);
  assign PackedStencil_DTYPE_2U_1U_1U_1U_operator_1_mux_11_nl = MUX_v_32_2_2(({{16{COL_2_ROW_2_COMP_tmp_acc_psp_sva[15]}},
      COL_2_ROW_2_COMP_tmp_acc_psp_sva}), pe_y_reg_value_1_1_31_0_sva_dfm_1, and_dcpl_107);
  assign pe_y_reg_value_1_1_63_32_sva_mx0 = MUX_v_32_2_2(32'b00000000000000000000000000000000,
      (PackedStencil_DTYPE_2U_1U_1U_1U_operator_1_mux_11_nl), main_stage_0_2);
  assign PackedStencil_DTYPE_2U_1U_1U_1U_operator_1_mux_12_nl = MUX_v_32_2_2(({{16{COL_3_ROW_1_COMP_tmp_acc_psp_sva[15]}},
      COL_3_ROW_1_COMP_tmp_acc_psp_sva}), pe_y_reg_value_0_2_31_0_sva_dfm_1, and_dcpl_109);
  assign pe_y_reg_value_0_2_63_32_sva_mx0 = MUX_v_32_2_2(32'b00000000000000000000000000000000,
      (PackedStencil_DTYPE_2U_1U_1U_1U_operator_1_mux_12_nl), main_stage_0_2);
  assign pe_y_reg_value_mux_12_nl = MUX_v_32_2_2(pe_y_reg_value_2_0_31_0_sva_dfm_1,
      ({{16{COL_1_ROW_3_COMP_tmp_acc_psp_sva[15]}}, COL_1_ROW_3_COMP_tmp_acc_psp_sva}),
      and_dcpl_105);
  assign asn_194_mx0w0 = MUX_v_32_2_2(32'b00000000000000000000000000000000, (pe_y_reg_value_mux_12_nl),
      main_stage_0_2);
  assign pe_y_reg_value_mux_13_nl = MUX_v_32_2_2(pe_y_reg_value_1_1_31_0_sva_dfm_1,
      ({{16{COL_2_ROW_2_COMP_tmp_acc_psp_sva[15]}}, COL_2_ROW_2_COMP_tmp_acc_psp_sva}),
      and_dcpl_107);
  assign asn_212_mx0w0 = MUX_v_32_2_2(32'b00000000000000000000000000000000, (pe_y_reg_value_mux_13_nl),
      main_stage_0_2);
  assign pe_y_reg_value_mux_14_nl = MUX_v_32_2_2(pe_y_reg_value_0_2_31_0_sva_dfm_1,
      ({{16{COL_3_ROW_1_COMP_tmp_acc_psp_sva[15]}}, COL_3_ROW_1_COMP_tmp_acc_psp_sva}),
      and_dcpl_109);
  assign asn_230_mx0w0 = MUX_v_32_2_2(32'b00000000000000000000000000000000, (pe_y_reg_value_mux_14_nl),
      main_stage_0_2);
  assign PackedStencil_DTYPE_2U_1U_1U_1U_operator_1_mux_13_nl = MUX_v_32_2_2(({{16{COL_1_ROW_2_COMP_tmp_acc_psp_sva[15]}},
      COL_1_ROW_2_COMP_tmp_acc_psp_sva}), pe_y_reg_value_1_0_31_0_sva_dfm_1, and_dcpl_123);
  assign pe_y_reg_value_1_0_63_32_sva_mx0 = MUX_v_32_2_2(32'b00000000000000000000000000000000,
      (PackedStencil_DTYPE_2U_1U_1U_1U_operator_1_mux_13_nl), main_stage_0_2);
  assign PackedStencil_DTYPE_2U_1U_1U_1U_operator_1_mux_14_nl = MUX_v_32_2_2(({{16{COL_2_ROW_1_COMP_tmp_acc_psp_sva[15]}},
      COL_2_ROW_1_COMP_tmp_acc_psp_sva}), pe_y_reg_value_0_1_31_0_sva_dfm_1, and_dcpl_125);
  assign pe_y_reg_value_0_1_63_32_sva_mx0 = MUX_v_32_2_2(32'b00000000000000000000000000000000,
      (PackedStencil_DTYPE_2U_1U_1U_1U_operator_1_mux_14_nl), main_stage_0_2);
  assign pe_y_reg_value_mux_15_nl = MUX_v_32_2_2(pe_y_reg_value_1_0_31_0_sva_dfm_1,
      ({{16{COL_1_ROW_2_COMP_tmp_acc_psp_sva[15]}}, COL_1_ROW_2_COMP_tmp_acc_psp_sva}),
      and_dcpl_123);
  assign asn_218_mx0w0 = MUX_v_32_2_2(32'b00000000000000000000000000000000, (pe_y_reg_value_mux_15_nl),
      main_stage_0_2);
  assign pe_y_reg_value_mux_16_nl = MUX_v_32_2_2(pe_y_reg_value_0_1_31_0_sva_dfm_1,
      ({{16{COL_2_ROW_1_COMP_tmp_acc_psp_sva[15]}}, COL_2_ROW_1_COMP_tmp_acc_psp_sva}),
      and_dcpl_125);
  assign asn_236_mx0w0 = MUX_v_32_2_2(32'b00000000000000000000000000000000, (pe_y_reg_value_mux_16_nl),
      main_stage_0_2);
  assign PackedStencil_DTYPE_2U_1U_1U_1U_operator_1_nand_2_nl = ~((~((~ reg_exitL_exit_COL_1_ROW_1_COMP_lpi_1_dfm_3_cse)
      & and_dcpl_134)) & main_stage_0_2);
  assign PackedStencil_DTYPE_2U_1U_1U_1U_operator_1_and_1_nl = reg_exitL_exit_COL_1_ROW_1_COMP_lpi_1_dfm_3_cse
      & and_dcpl_134;
  assign pe_y_reg_value_0_0_31_0_sva_mx1 = MUX1HOT_v_32_3_2(pe_y_reg_value_0_0_31_0_sva,
      (STEPS_tmp_row_0_value_lpi_1_dfm[31:0]), ({{16{COL_1_ROW_1_COMP_tmp_acc_psp_sva[15]}},
      COL_1_ROW_1_COMP_tmp_acc_psp_sva}), {(PackedStencil_DTYPE_2U_1U_1U_1U_operator_1_nand_2_nl)
      , (PackedStencil_DTYPE_2U_1U_1U_1U_operator_1_and_1_nl) , and_dcpl_135});
  assign PackedStencil_DTYPE_2U_1U_1U_1U_operator_1_nand_nl = ~((~((~ reg_exitL_exit_COL_1_ROW_1_COMP_lpi_1_dfm_3_cse)
      & and_dcpl_135)) & main_stage_0_2);
  assign PackedStencil_DTYPE_2U_1U_1U_1U_operator_1_and_nl = reg_exitL_exit_COL_1_ROW_1_COMP_lpi_1_dfm_3_cse
      & and_dcpl_135;
  assign pe_y_reg_value_0_0_63_32_sva_mx1 = MUX1HOT_v_32_3_2(({{16{COL_1_ROW_1_COMP_tmp_acc_psp_sva[15]}},
      COL_1_ROW_1_COMP_tmp_acc_psp_sva}), pe_y_reg_value_0_0_63_32_sva, (STEPS_tmp_row_0_value_lpi_1_dfm[63:32]),
      {and_dcpl_134 , (PackedStencil_DTYPE_2U_1U_1U_1U_operator_1_nand_nl) , (PackedStencil_DTYPE_2U_1U_1U_1U_operator_1_and_nl)});
  assign STEPS_if_2_aelse_1_not_6_nl = ~ reg_STEPS_if_2_land_1_lpi_1_dfm_st_1_cse;
  assign STEPS_if_2_STEPS_if_2_and_3_nl = MUX_v_64_2_2(64'b0000000000000000000000000000000000000000000000000000000000000000,
      (out_tile_3_value_rsci_data_out_d[63:0]), (STEPS_if_2_aelse_1_not_6_nl));
  assign fifo_90003_PackedStencil_DTYPE_2U_1U_1U_1U_4_regs_value_0_sva_mx1 = MUX_v_64_2_2((STEPS_if_2_STEPS_if_2_and_3_nl),
      fifo_90003_PackedStencil_DTYPE_2U_1U_1U_1U_4_regs_value_0_sva, or_dcpl_47);
  assign STEPS_if_2_aelse_1_not_7_nl = ~ reg_STEPS_if_2_land_1_lpi_1_dfm_st_1_cse;
  assign STEPS_if_2_STEPS_if_2_and_2_nl = MUX_v_64_2_2(64'b0000000000000000000000000000000000000000000000000000000000000000,
      (out_tile_2_value_rsci_data_out_d[63:0]), (STEPS_if_2_aelse_1_not_7_nl));
  assign fifo_90002_PackedStencil_DTYPE_2U_1U_1U_1U_3_regs_value_0_sva_mx1 = MUX_v_64_2_2((STEPS_if_2_STEPS_if_2_and_2_nl),
      fifo_90002_PackedStencil_DTYPE_2U_1U_1U_1U_3_regs_value_0_sva, or_dcpl_47);
  assign fifo_90001_PackedStencil_DTYPE_2U_1U_1U_1U_2_regs_value_0_sva_mx1_63_32
      = MUX_v_32_2_2((STEPS_if_2_STEPS_if_2_and_1_rgt[63:32]), reg_fifo_90001_PackedStencil_DTYPE_2U_1U_1U_1U_2_regs_value_0_tmp,
      or_dcpl_47);
  assign fifo_90001_PackedStencil_DTYPE_2U_1U_1U_1U_2_regs_value_0_sva_mx1_15_0 =
      MUX_v_16_2_2((STEPS_if_2_STEPS_if_2_and_1_rgt[15:0]), reg_fifo_90001_PackedStencil_DTYPE_2U_1U_1U_1U_2_regs_value_0_tmp_17,
      or_dcpl_47);
  assign fifo_60003_DTYPE_4_regs_0_sva_mx1 = MUX_v_16_2_2((input_rsci_d_mxwt[63:48]),
      fifo_60003_DTYPE_4_regs_0_sva, or_dcpl_47);
  assign fifo_60002_DTYPE_3_regs_0_sva_mx1 = MUX_v_16_2_2((input_rsci_d_mxwt[47:32]),
      fifo_60002_DTYPE_3_regs_0_sva, or_dcpl_47);
  assign fifo_60001_DTYPE_2_regs_0_sva_mx1 = MUX_v_16_2_2((input_rsci_d_mxwt[31:16]),
      fifo_60001_DTYPE_2_regs_0_sva, or_dcpl_47);
  assign pe_x_reg_0_0_sva_mx1 = MUX_v_16_2_2((input_rsci_d_mxwt[15:0]), pe_x_reg_0_0_sva,
      or_dcpl_47);
  assign weight_value_operator_mux_15_nl = MUX_v_16_2_2(STEPS_if_w_row_value_239_0_lpi_1_dfm_1_207_192_mx1,
      STEPS_if_w_row_value_239_0_lpi_1_dfm_1_239_224_mx1, COMP_i_0_lpi_1_dfm_2);
  assign nl_COL_4_ROW_4_COMP_tmp_mul_nl = $signed(COL_3_ROW_4_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_x_reg_16_15_0_ncse_lpi_1_dfm_1)
      * $signed(conv_u2s_16_17(weight_value_operator_mux_15_nl));
  assign COL_4_ROW_4_COMP_tmp_mul_nl = nl_COL_4_ROW_4_COMP_tmp_mul_nl[15:0];
  assign nl_COL_4_ROW_4_COMP_tmp_acc_psp_sva = (COL_4_ROW_4_COMP_tmp_mul_nl) + COL_4_ROW_4_PackedStencil_DTYPE_2U_1U_1U_1U_operator_rshift_itm_1;
  assign COL_4_ROW_4_COMP_tmp_acc_psp_sva = nl_COL_4_ROW_4_COMP_tmp_acc_psp_sva[15:0];
  assign Ko_k_idx_0_lpi_1_dfm = Ko_k_idx_0_lpi_2 & lfst_exit_winy_1_lpi_1_dfm;
  assign STEPS_step_4_0_lpi_1_dfm = MUX_v_5_2_2(5'b00000, STEPS_step_4_0_lpi_2, lfst_exit_Ko_1_lpi_1_dfm);
  assign winy_wy_idx_1_0_lpi_1_dfm = MUX_v_2_2_2(2'b00, winy_wy_idx_1_0_lpi_2, lfst_exit_winx_1_lpi_1_dfm);
  assign winx_wx_idx_1_0_lpi_1_dfm = MUX_v_2_2_2(2'b00, winx_wx_idx_1_0_lpi_2, lfst_exit_Co_lpi_1_dfm);
  assign Co_c_idx_0_lpi_1_dfm = Co_c_idx_0_lpi_1 & (~ exitL_exit_Co_sva);
  assign nl_winx_wx_idx_1_0_sva_1 = winx_wx_idx_1_0_lpi_1_dfm + 2'b1;
  assign winx_wx_idx_1_0_sva_1 = nl_winx_wx_idx_1_0_sva_1[1:0];
  assign nl_winy_wy_idx_1_0_sva_1 = winy_wy_idx_1_0_lpi_1_dfm + 2'b1;
  assign winy_wy_idx_1_0_sva_1 = nl_winy_wy_idx_1_0_sva_1[1:0];
  assign nl_STEPS_acc_nl = conv_u2s_5_6(STEPS_step_4_0_sva_1) + 6'b101001;
  assign STEPS_acc_nl = nl_STEPS_acc_nl[5:0];
  assign STEPS_acc_itm_5_1 = readslicef_6_1_5((STEPS_acc_nl));
  assign nl_STEPS_step_4_0_sva_1 = STEPS_step_4_0_lpi_1_dfm + 5'b1;
  assign STEPS_step_4_0_sva_1 = nl_STEPS_step_4_0_sva_1[4:0];
  assign lfst_exit_Ko_1_lpi_1_dfm = (~ exit_Ko_lpi_1_dfm_2) & lfst_exit_winy_1_lpi_1_dfm;
  assign lfst_exit_winy_1_lpi_1_dfm = (~ exit_winy_lpi_1_dfm_2) & lfst_exit_winx_1_lpi_1_dfm;
  assign lfst_exit_winx_1_lpi_1_dfm = (~ exit_winx_lpi_1_dfm_2) & lfst_exit_Co_lpi_1_dfm;
  assign lfst_exit_Co_lpi_1_dfm = ~(exit_Co_lpi_1_dfm_2 | exitL_exit_Co_sva);
  assign weight_value_operator_mux_11_nl = MUX_v_16_2_2(STEPS_if_w_row_value_239_0_lpi_1_dfm_1_143_128_mx1,
      STEPS_if_w_row_value_239_0_lpi_1_dfm_1_175_160_mx1, COMP_i_0_6_lpi_1_dfm_2);
  assign nl_COL_3_ROW_4_COMP_tmp_mul_nl = $signed(COL_2_ROW_4_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_x_reg_16_15_0_ncse_lpi_1_dfm_1)
      * $signed(conv_u2s_16_17(weight_value_operator_mux_11_nl));
  assign COL_3_ROW_4_COMP_tmp_mul_nl = nl_COL_3_ROW_4_COMP_tmp_mul_nl[15:0];
  assign nl_COL_3_ROW_4_COMP_tmp_acc_psp_sva = (COL_3_ROW_4_COMP_tmp_mul_nl) + COL_3_ROW_4_PackedStencil_DTYPE_2U_1U_1U_1U_operator_rshift_itm_1;
  assign COL_3_ROW_4_COMP_tmp_acc_psp_sva = nl_COL_3_ROW_4_COMP_tmp_acc_psp_sva[15:0];
  assign weight_value_operator_mux_14_nl = MUX_v_16_2_2(STEPS_if_w_row_value_239_0_lpi_1_dfm_1_207_192_mx1,
      STEPS_if_w_row_value_239_0_lpi_1_dfm_1_239_224_mx1, COMP_i_0_3_lpi_1_dfm_2);
  assign nl_COL_4_ROW_3_COMP_tmp_mul_nl = $signed(COL_3_ROW_3_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_x_reg_16_15_0_ncse_lpi_1_dfm_1)
      * $signed(conv_u2s_16_17(weight_value_operator_mux_14_nl));
  assign COL_4_ROW_3_COMP_tmp_mul_nl = nl_COL_4_ROW_3_COMP_tmp_mul_nl[15:0];
  assign nl_COL_4_ROW_3_COMP_tmp_acc_psp_sva = (COL_4_ROW_3_COMP_tmp_mul_nl) + COL_4_ROW_3_PackedStencil_DTYPE_2U_1U_1U_1U_operator_rshift_itm_1;
  assign COL_4_ROW_3_COMP_tmp_acc_psp_sva = nl_COL_4_ROW_3_COMP_tmp_acc_psp_sva[15:0];
  assign weight_value_operator_mux_7_nl = MUX_v_16_2_2(STEPS_if_w_row_value_239_0_lpi_1_dfm_1_79_64_mx1,
      STEPS_if_w_row_value_239_0_lpi_1_dfm_1_111_96_mx1, COMP_i_0_5_lpi_1_dfm_2);
  assign nl_COL_2_ROW_4_COMP_tmp_mul_nl = $signed(COL_1_ROW_4_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_x_reg_16_15_0_ncse_lpi_1_dfm_1)
      * $signed(conv_u2s_16_17(weight_value_operator_mux_7_nl));
  assign COL_2_ROW_4_COMP_tmp_mul_nl = nl_COL_2_ROW_4_COMP_tmp_mul_nl[15:0];
  assign nl_COL_2_ROW_4_COMP_tmp_acc_psp_sva = (COL_2_ROW_4_COMP_tmp_mul_nl) + COL_2_ROW_4_PackedStencil_DTYPE_2U_1U_1U_1U_operator_rshift_itm_1;
  assign COL_2_ROW_4_COMP_tmp_acc_psp_sva = nl_COL_2_ROW_4_COMP_tmp_acc_psp_sva[15:0];
  assign weight_value_operator_mux_10_nl = MUX_v_16_2_2(STEPS_if_w_row_value_239_0_lpi_1_dfm_1_143_128_mx1,
      STEPS_if_w_row_value_239_0_lpi_1_dfm_1_175_160_mx1, COMP_i_0_15_lpi_1_dfm_2);
  assign nl_COL_3_ROW_3_COMP_tmp_mul_nl = $signed(COL_2_ROW_3_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_x_reg_16_15_0_ncse_lpi_1_dfm_1)
      * $signed(conv_u2s_16_17(weight_value_operator_mux_10_nl));
  assign COL_3_ROW_3_COMP_tmp_mul_nl = nl_COL_3_ROW_3_COMP_tmp_mul_nl[15:0];
  assign nl_COL_3_ROW_3_COMP_tmp_acc_psp_sva = (COL_3_ROW_3_COMP_tmp_mul_nl) + COL_3_ROW_3_PackedStencil_DTYPE_2U_1U_1U_1U_operator_rshift_itm_1;
  assign COL_3_ROW_3_COMP_tmp_acc_psp_sva = nl_COL_3_ROW_3_COMP_tmp_acc_psp_sva[15:0];
  assign weight_value_operator_mux_13_nl = MUX_v_16_2_2(STEPS_if_w_row_value_239_0_lpi_1_dfm_1_207_192_mx1,
      STEPS_if_w_row_value_239_0_lpi_1_dfm_1_239_224_mx1, COMP_i_0_2_lpi_1_dfm_2);
  assign nl_COL_4_ROW_2_COMP_tmp_mul_nl = $signed(COL_3_ROW_2_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_x_reg_16_15_0_ncse_lpi_1_dfm_1)
      * $signed(conv_u2s_16_17(weight_value_operator_mux_13_nl));
  assign COL_4_ROW_2_COMP_tmp_mul_nl = nl_COL_4_ROW_2_COMP_tmp_mul_nl[15:0];
  assign nl_COL_4_ROW_2_COMP_tmp_acc_psp_sva = (COL_4_ROW_2_COMP_tmp_mul_nl) + COL_4_ROW_2_PackedStencil_DTYPE_2U_1U_1U_1U_operator_rshift_itm_1;
  assign COL_4_ROW_2_COMP_tmp_acc_psp_sva = nl_COL_4_ROW_2_COMP_tmp_acc_psp_sva[15:0];
  assign weight_value_operator_mux_3_nl = MUX_v_16_2_2(STEPS_if_w_row_value_239_0_lpi_1_dfm_1_15_0_mx1,
      STEPS_if_w_row_value_239_0_lpi_1_dfm_1_47_32_mx1, COMP_i_0_4_lpi_1_dfm_2);
  assign nl_COL_1_ROW_4_COMP_tmp_mul_nl = $signed(SHIFT_3_1_else_SHIFT_3_else_slc_fifo_60003_DTYPE_4_regs_16_15_0_ncse_lpi_1_dfm_1)
      * $signed(conv_u2s_16_17(weight_value_operator_mux_3_nl));
  assign COL_1_ROW_4_COMP_tmp_mul_nl = nl_COL_1_ROW_4_COMP_tmp_mul_nl[15:0];
  assign nl_COL_1_ROW_4_COMP_tmp_acc_psp_sva = (COL_1_ROW_4_COMP_tmp_mul_nl) + COL_1_ROW_4_PackedStencil_DTYPE_2U_1U_1U_1U_operator_rshift_itm_1;
  assign COL_1_ROW_4_COMP_tmp_acc_psp_sva = nl_COL_1_ROW_4_COMP_tmp_acc_psp_sva[15:0];
  assign weight_value_operator_mux_6_nl = MUX_v_16_2_2(STEPS_if_w_row_value_239_0_lpi_1_dfm_1_79_64_mx1,
      STEPS_if_w_row_value_239_0_lpi_1_dfm_1_111_96_mx1, COMP_i_0_14_lpi_1_dfm_2);
  assign nl_COL_2_ROW_3_COMP_tmp_mul_nl = $signed(COL_1_ROW_3_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_x_reg_16_15_0_ncse_lpi_1_dfm_1)
      * $signed(conv_u2s_16_17(weight_value_operator_mux_6_nl));
  assign COL_2_ROW_3_COMP_tmp_mul_nl = nl_COL_2_ROW_3_COMP_tmp_mul_nl[15:0];
  assign nl_COL_2_ROW_3_COMP_tmp_acc_psp_sva = (COL_2_ROW_3_COMP_tmp_mul_nl) + COL_2_ROW_3_PackedStencil_DTYPE_2U_1U_1U_1U_operator_rshift_itm_1;
  assign COL_2_ROW_3_COMP_tmp_acc_psp_sva = nl_COL_2_ROW_3_COMP_tmp_acc_psp_sva[15:0];
  assign weight_value_operator_mux_9_nl = MUX_v_16_2_2(STEPS_if_w_row_value_239_0_lpi_1_dfm_1_143_128_mx1,
      STEPS_if_w_row_value_239_0_lpi_1_dfm_1_175_160_mx1, COMP_i_0_12_lpi_1_dfm_2);
  assign nl_COL_3_ROW_2_COMP_tmp_mul_nl = $signed(COL_2_ROW_2_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_x_reg_16_15_0_ncse_lpi_1_dfm_1)
      * $signed(conv_u2s_16_17(weight_value_operator_mux_9_nl));
  assign COL_3_ROW_2_COMP_tmp_mul_nl = nl_COL_3_ROW_2_COMP_tmp_mul_nl[15:0];
  assign nl_COL_3_ROW_2_COMP_tmp_acc_psp_sva = (COL_3_ROW_2_COMP_tmp_mul_nl) + COL_3_ROW_2_PackedStencil_DTYPE_2U_1U_1U_1U_operator_rshift_itm_1;
  assign COL_3_ROW_2_COMP_tmp_acc_psp_sva = nl_COL_3_ROW_2_COMP_tmp_acc_psp_sva[15:0];
  assign weight_value_operator_mux_12_nl = MUX_v_16_2_2(STEPS_if_w_row_value_239_0_lpi_1_dfm_1_207_192_mx1,
      STEPS_if_w_row_value_239_0_lpi_1_dfm_1_239_224_mx1, COMP_i_0_1_lpi_1_dfm_2);
  assign nl_COL_4_ROW_1_COMP_tmp_mul_nl = $signed(COL_3_ROW_1_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_x_reg_16_15_0_ncse_lpi_1_dfm_1)
      * $signed(conv_u2s_16_17(weight_value_operator_mux_12_nl));
  assign COL_4_ROW_1_COMP_tmp_mul_nl = nl_COL_4_ROW_1_COMP_tmp_mul_nl[15:0];
  assign nl_COL_4_ROW_1_COMP_tmp_acc_psp_sva = (COL_4_ROW_1_COMP_tmp_mul_nl) + COL_4_ROW_1_PackedStencil_DTYPE_2U_1U_1U_1U_operator_rshift_itm_1;
  assign COL_4_ROW_1_COMP_tmp_acc_psp_sva = nl_COL_4_ROW_1_COMP_tmp_acc_psp_sva[15:0];
  assign weight_value_operator_mux_2_nl = MUX_v_16_2_2(STEPS_if_w_row_value_239_0_lpi_1_dfm_1_15_0_mx1,
      STEPS_if_w_row_value_239_0_lpi_1_dfm_1_47_32_mx1, COMP_i_0_13_lpi_1_dfm_2);
  assign nl_COL_1_ROW_3_COMP_tmp_mul_nl = $signed(SHIFT_2_1_else_SHIFT_2_else_slc_fifo_60002_DTYPE_3_regs_16_15_0_ncse_lpi_1_dfm_1)
      * $signed(conv_u2s_16_17(weight_value_operator_mux_2_nl));
  assign COL_1_ROW_3_COMP_tmp_mul_nl = nl_COL_1_ROW_3_COMP_tmp_mul_nl[15:0];
  assign nl_COL_1_ROW_3_COMP_tmp_acc_psp_sva = (COL_1_ROW_3_COMP_tmp_mul_nl) + COL_1_ROW_3_PackedStencil_DTYPE_2U_1U_1U_1U_operator_rshift_itm_1;
  assign COL_1_ROW_3_COMP_tmp_acc_psp_sva = nl_COL_1_ROW_3_COMP_tmp_acc_psp_sva[15:0];
  assign weight_value_operator_mux_5_nl = MUX_v_16_2_2(STEPS_if_w_row_value_239_0_lpi_1_dfm_1_79_64_mx1,
      STEPS_if_w_row_value_239_0_lpi_1_dfm_1_111_96_mx1, COMP_i_0_11_lpi_1_dfm_2);
  assign nl_COL_2_ROW_2_COMP_tmp_mul_nl = $signed(COL_1_ROW_2_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_x_reg_16_15_0_ncse_lpi_1_dfm_1)
      * $signed(conv_u2s_16_17(weight_value_operator_mux_5_nl));
  assign COL_2_ROW_2_COMP_tmp_mul_nl = nl_COL_2_ROW_2_COMP_tmp_mul_nl[15:0];
  assign nl_COL_2_ROW_2_COMP_tmp_acc_psp_sva = (COL_2_ROW_2_COMP_tmp_mul_nl) + COL_2_ROW_2_PackedStencil_DTYPE_2U_1U_1U_1U_operator_rshift_itm_1;
  assign COL_2_ROW_2_COMP_tmp_acc_psp_sva = nl_COL_2_ROW_2_COMP_tmp_acc_psp_sva[15:0];
  assign weight_value_operator_mux_8_nl = MUX_v_16_2_2(STEPS_if_w_row_value_239_0_lpi_1_dfm_1_143_128_mx1,
      STEPS_if_w_row_value_239_0_lpi_1_dfm_1_175_160_mx1, COMP_i_0_9_lpi_1_dfm_2);
  assign nl_COL_3_ROW_1_COMP_tmp_mul_nl = $signed(COL_2_ROW_1_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_x_reg_16_15_0_ncse_lpi_1_dfm_1)
      * $signed(conv_u2s_16_17(weight_value_operator_mux_8_nl));
  assign COL_3_ROW_1_COMP_tmp_mul_nl = nl_COL_3_ROW_1_COMP_tmp_mul_nl[15:0];
  assign nl_COL_3_ROW_1_COMP_tmp_acc_psp_sva = (COL_3_ROW_1_COMP_tmp_mul_nl) + COL_3_ROW_1_PackedStencil_DTYPE_2U_1U_1U_1U_operator_rshift_itm_1;
  assign COL_3_ROW_1_COMP_tmp_acc_psp_sva = nl_COL_3_ROW_1_COMP_tmp_acc_psp_sva[15:0];
  assign weight_value_operator_mux_1_nl = MUX_v_16_2_2(STEPS_if_w_row_value_239_0_lpi_1_dfm_1_15_0_mx1,
      STEPS_if_w_row_value_239_0_lpi_1_dfm_1_47_32_mx1, COMP_i_0_10_lpi_1_dfm_2);
  assign nl_COL_1_ROW_2_COMP_tmp_mul_nl = $signed(SHIFT_1_1_else_SHIFT_1_else_slc_fifo_60001_DTYPE_2_regs_16_15_0_ncse_lpi_1_dfm_1)
      * $signed(conv_u2s_16_17(weight_value_operator_mux_1_nl));
  assign COL_1_ROW_2_COMP_tmp_mul_nl = nl_COL_1_ROW_2_COMP_tmp_mul_nl[15:0];
  assign nl_COL_1_ROW_2_COMP_tmp_acc_psp_sva = (COL_1_ROW_2_COMP_tmp_mul_nl) + COL_1_ROW_2_PackedStencil_DTYPE_2U_1U_1U_1U_operator_rshift_itm_1;
  assign COL_1_ROW_2_COMP_tmp_acc_psp_sva = nl_COL_1_ROW_2_COMP_tmp_acc_psp_sva[15:0];
  assign weight_value_operator_mux_4_nl = MUX_v_16_2_2(STEPS_if_w_row_value_239_0_lpi_1_dfm_1_79_64_mx1,
      STEPS_if_w_row_value_239_0_lpi_1_dfm_1_111_96_mx1, COMP_i_0_8_lpi_1_dfm_2);
  assign nl_COL_2_ROW_1_COMP_tmp_mul_nl = $signed(COL_1_ROW_1_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_x_reg_16_15_0_ncse_lpi_1_dfm_1)
      * $signed(conv_u2s_16_17(weight_value_operator_mux_4_nl));
  assign COL_2_ROW_1_COMP_tmp_mul_nl = nl_COL_2_ROW_1_COMP_tmp_mul_nl[15:0];
  assign nl_COL_2_ROW_1_COMP_tmp_acc_psp_sva = (COL_2_ROW_1_COMP_tmp_mul_nl) + COL_2_ROW_1_PackedStencil_DTYPE_2U_1U_1U_1U_operator_rshift_itm_1;
  assign COL_2_ROW_1_COMP_tmp_acc_psp_sva = nl_COL_2_ROW_1_COMP_tmp_acc_psp_sva[15:0];
  assign STEPS_if_2_aelse_1_not_4_nl = ~ reg_STEPS_if_2_land_1_lpi_1_dfm_st_1_cse;
  assign STEPS_tmp_row_0_value_lpi_1_dfm = MUX_v_64_2_2(64'b0000000000000000000000000000000000000000000000000000000000000000,
      (out_tile_0_value_rsci_data_out_d[63:0]), (STEPS_if_2_aelse_1_not_4_nl));
  assign STEPS_in_col_value_mux_4_nl = MUX_v_16_2_2(STEPS_in_col_value_111_0_lpi_1_dfm_1_15_0_1,
      (input_rsci_d_mxwt[15:0]), reg_exitL_exit_COL_1_ROW_1_COMP_lpi_1_dfm_3_cse);
  assign weight_value_operator_mux_nl = MUX_v_16_2_2(STEPS_if_w_row_value_239_0_lpi_1_dfm_1_15_0_mx1,
      STEPS_if_w_row_value_239_0_lpi_1_dfm_1_47_32_mx1, COMP_i_0_7_lpi_1_dfm_2);
  assign nl_COL_1_ROW_1_COMP_tmp_mul_nl = (STEPS_in_col_value_mux_4_nl) * (weight_value_operator_mux_nl);
  assign COL_1_ROW_1_COMP_tmp_mul_nl = nl_COL_1_ROW_1_COMP_tmp_mul_nl[15:0];
  assign nl_COL_1_ROW_1_COMP_tmp_acc_psp_sva = (COL_1_ROW_1_COMP_tmp_mul_nl) + COL_1_ROW_1_PackedStencil_DTYPE_2U_1U_1U_1U_operator_rshift_itm;
  assign COL_1_ROW_1_COMP_tmp_acc_psp_sva = nl_COL_1_ROW_1_COMP_tmp_acc_psp_sva[15:0];
  assign or_dcpl = COMP_and_13_mdf_sva_1 | exit_STEPS_lpi_1_dfm_1;
  assign or_dcpl_3 = exitL_exit_Co_sva | exit_Co_lpi_1_dfm_2;
  assign or_dcpl_4 = or_dcpl_3 | exit_winx_lpi_1_dfm_2 | exit_winy_lpi_1_dfm_2;
  assign nor_12_cse = ~(exit_winx_lpi_1_dfm_2 | exit_winy_lpi_1_dfm_2);
  assign and_dcpl_6 = lfst_exit_Co_lpi_1_dfm & nor_12_cse & (~(exit_Ko_lpi_1_dfm_2
      | COMP_and_13_mdf_sva_1 | exit_STEPS_lpi_1_dfm_1));
  assign or_dcpl_9 = and_dcpl_6 | (~ STEPS_if_acc_itm_3_1);
  assign or_dcpl_11 = (~ COMP_and_13_tmp) | STEPS_acc_itm_5_1 | (~ Ko_k_idx_0_lpi_2);
  assign or_dcpl_13 = xor_cse | winx_acc_tmp_2;
  assign or_dcpl_35 = exit_winy_lpi_1_dfm_2 | exit_Ko_lpi_1_dfm_2;
  assign and_dcpl_29 = COMP_and_13_tmp & (~ STEPS_acc_5_itm_5_1);
  assign nand_tmp = ~(main_stage_0_2 & (~(((~ reg_exitL_exit_COL_1_ROW_1_COMP_lpi_1_dfm_3_cse)
      | STEPS_step_slc_STEPS_step_4_0_4_4_itm_2 | reg_STEPS_if_2_land_1_lpi_1_dfm_st_1_cse)
      & ((~ COMP_and_13_mdf_sva_st_1) | STEPS_if_3_slc_STEPS_acc_5_5_itm_3))));
  assign or_tmp_7 = (winy_wy_idx_1_0_lpi_2!=2'b00) | (winx_wx_idx_1_0_lpi_2!=2'b00)
      | Co_c_idx_0_lpi_1 | (~ nand_tmp);
  assign or_tmp_12 = (~((~((winx_wx_idx_1_0_lpi_2!=2'b00))) | exit_Co_lpi_1_dfm_2))
      | Co_c_idx_0_lpi_1;
  assign or_61_nl = (~((~((winy_wy_idx_1_0_lpi_2!=2'b00) | (winx_wx_idx_1_0_lpi_2!=2'b00)))
      | exit_Co_lpi_1_dfm_2)) | Co_c_idx_0_lpi_1;
  assign mux_tmp_6 = MUX_s_1_2_2((or_61_nl), or_tmp_12, exit_winx_lpi_1_dfm_2);
  assign and_280_nl = exit_Co_lpi_1_dfm_2 & Co_c_idx_0_lpi_1;
  assign mux_tmp_7 = MUX_s_1_2_2((and_280_nl), or_tmp_12, exit_winx_lpi_1_dfm_2);
  assign and_dcpl_38 = main_stage_0_2 & (~ COMP_i_0_lpi_1_dfm_2);
  assign and_dcpl_41 = nor_12_cse & (~ exit_Ko_lpi_1_dfm_2) & (~(COMP_and_13_mdf_sva_1
      | exit_STEPS_lpi_1_dfm_1));
  assign mux_tmp_11 = MUX_s_1_2_2((~ main_stage_0_2), main_stage_0_2, COMP_i_0_lpi_1_dfm_2);
  assign and_dcpl_49 = lfst_exit_Co_lpi_1_dfm & nor_12_cse & (~(exit_Ko_lpi_1_dfm_2
      | COMP_and_13_mdf_sva_1)) & (~ exit_STEPS_lpi_1_dfm_1);
  assign or_dcpl_46 = ~(reg_exitL_exit_COL_1_ROW_1_COMP_lpi_1_dfm_3_cse & STEPS_if_slc_STEPS_if_acc_3_svs_2);
  assign or_dcpl_47 = ~(main_stage_0_2 & reg_exitL_exit_COL_1_ROW_1_COMP_lpi_1_dfm_3_cse);
  assign or_dcpl_48 = or_dcpl_47 | (~ STEPS_if_slc_STEPS_if_acc_3_svs_2);
  assign or_dcpl_51 = or_dcpl_3 | exit_winx_lpi_1_dfm_2 | or_dcpl_35;
  assign or_dcpl_54 = (~ COMP_and_13_tmp) | STEPS_acc_itm_5_1;
  assign or_dcpl_56 = or_dcpl_54 | (~ Ko_k_idx_0_lpi_2) | xor_cse;
  assign or_dcpl_58 = or_dcpl_54 | (~ Ko_k_idx_0_lpi_2);
  assign or_dcpl_64 = (~ COMP_and_13_tmp) | STEPS_acc_itm_5_1 | (~ Ko_k_idx_0_lpi_2)
      | xor_cse | winx_acc_tmp_2;
  assign and_dcpl_51 = main_stage_0_2 & (~ COMP_i_0_6_lpi_1_dfm_2);
  assign and_dcpl_53 = main_stage_0_2 & (~ COMP_i_0_3_lpi_1_dfm_2);
  assign mux_tmp_12 = MUX_s_1_2_2((~ main_stage_0_2), main_stage_0_2, COMP_i_0_6_lpi_1_dfm_2);
  assign mux_tmp_13 = MUX_s_1_2_2((~ main_stage_0_2), main_stage_0_2, COMP_i_0_3_lpi_1_dfm_2);
  assign and_dcpl_63 = main_stage_0_2 & (~ COMP_i_0_5_lpi_1_dfm_2);
  assign and_dcpl_65 = main_stage_0_2 & (~ COMP_i_0_15_lpi_1_dfm_2);
  assign and_dcpl_67 = main_stage_0_2 & (~ COMP_i_0_2_lpi_1_dfm_2);
  assign mux_tmp_14 = MUX_s_1_2_2((~ main_stage_0_2), main_stage_0_2, COMP_i_0_5_lpi_1_dfm_2);
  assign mux_tmp_15 = MUX_s_1_2_2((~ main_stage_0_2), main_stage_0_2, COMP_i_0_15_lpi_1_dfm_2);
  assign mux_tmp_16 = MUX_s_1_2_2((~ main_stage_0_2), main_stage_0_2, COMP_i_0_2_lpi_1_dfm_2);
  assign and_dcpl_81 = main_stage_0_2 & (~ COMP_i_0_4_lpi_1_dfm_2);
  assign and_dcpl_83 = main_stage_0_2 & (~ COMP_i_0_14_lpi_1_dfm_2);
  assign and_dcpl_85 = main_stage_0_2 & (~ COMP_i_0_12_lpi_1_dfm_2);
  assign and_dcpl_87 = main_stage_0_2 & (~ COMP_i_0_1_lpi_1_dfm_2);
  assign mux_tmp_17 = MUX_s_1_2_2((~ main_stage_0_2), main_stage_0_2, COMP_i_0_4_lpi_1_dfm_2);
  assign mux_tmp_18 = MUX_s_1_2_2((~ main_stage_0_2), main_stage_0_2, COMP_i_0_14_lpi_1_dfm_2);
  assign mux_tmp_19 = MUX_s_1_2_2((~ main_stage_0_2), main_stage_0_2, COMP_i_0_12_lpi_1_dfm_2);
  assign mux_tmp_20 = MUX_s_1_2_2((~ main_stage_0_2), main_stage_0_2, COMP_i_0_1_lpi_1_dfm_2);
  assign and_dcpl_105 = main_stage_0_2 & (~ COMP_i_0_13_lpi_1_dfm_2);
  assign and_dcpl_107 = main_stage_0_2 & (~ COMP_i_0_11_lpi_1_dfm_2);
  assign and_dcpl_109 = main_stage_0_2 & (~ COMP_i_0_9_lpi_1_dfm_2);
  assign mux_tmp_21 = MUX_s_1_2_2((~ main_stage_0_2), main_stage_0_2, COMP_i_0_13_lpi_1_dfm_2);
  assign mux_tmp_22 = MUX_s_1_2_2((~ main_stage_0_2), main_stage_0_2, COMP_i_0_11_lpi_1_dfm_2);
  assign mux_tmp_23 = MUX_s_1_2_2((~ main_stage_0_2), main_stage_0_2, COMP_i_0_9_lpi_1_dfm_2);
  assign and_dcpl_123 = main_stage_0_2 & (~ COMP_i_0_10_lpi_1_dfm_2);
  assign and_dcpl_125 = main_stage_0_2 & (~ COMP_i_0_8_lpi_1_dfm_2);
  assign mux_tmp_24 = MUX_s_1_2_2((~ main_stage_0_2), main_stage_0_2, COMP_i_0_10_lpi_1_dfm_2);
  assign mux_tmp_25 = MUX_s_1_2_2((~ main_stage_0_2), main_stage_0_2, COMP_i_0_8_lpi_1_dfm_2);
  assign and_dcpl_134 = main_stage_0_2 & COMP_i_0_7_lpi_1_dfm_2;
  assign and_dcpl_135 = main_stage_0_2 & (~ COMP_i_0_7_lpi_1_dfm_2);
  assign xor_cse = (winy_wy_idx_1_0_sva_1[0]) ^ (winy_wy_idx_1_0_sva_1[1]);
  assign mux_26_nl = MUX_s_1_2_2(mux_tmp_7, mux_tmp_6, or_dcpl_35);
  assign or_62_nl = exit_STEPS_lpi_1_dfm_1 | COMP_and_13_mdf_sva_1 | exit_Ko_lpi_1_dfm_2
      | exit_winy_lpi_1_dfm_2;
  assign mux_27_nl = MUX_s_1_2_2(mux_tmp_7, mux_tmp_6, or_62_nl);
  assign mux_28_nl = MUX_s_1_2_2((mux_27_nl), (mux_26_nl), STEPS_step_4_0_lpi_2[4]);
  assign out_tile_3_value_nand_1_rmff = ~((mux_28_nl) & (~ exitL_exit_Co_sva));
  assign out_tile_3_value_nand_rmff = ~(and_dcpl_29 & (fsm_output[1]));
  assign STEPS_if_3_xor_nl = Ko_k_idx_0_lpi_1_dfm ^ (STEPS_step_4_0_lpi_1_dfm[4]);
  assign nl_STEPS_if_3_acc_nl = ({(STEPS_if_3_xor_nl) , (STEPS_step_4_0_lpi_1_dfm[3:0])})
      + 5'b11001;
  assign STEPS_if_3_acc_nl = nl_STEPS_if_3_acc_nl[4:0];
  assign out_tile_0_value_rsci_addr_d_pff = {(STEPS_if_3_acc_nl) , Ko_k_idx_0_lpi_1_dfm
      , (STEPS_step_4_0_lpi_1_dfm[3:0])};
  assign out_tile_0_value_rsci_re_d = {1'b1 , out_tile_3_value_nand_1_rmff};
  assign out_tile_0_value_rsci_we_d = {out_tile_3_value_nand_rmff , 1'b1};
  assign out_tile_1_value_rsci_re_d = {1'b1 , out_tile_3_value_nand_1_rmff};
  assign out_tile_1_value_rsci_we_d = {out_tile_3_value_nand_rmff , 1'b1};
  assign out_tile_2_value_rsci_re_d = {1'b1 , out_tile_3_value_nand_1_rmff};
  assign out_tile_2_value_rsci_we_d = {out_tile_3_value_nand_rmff , 1'b1};
  assign out_tile_3_value_rsci_re_d = {1'b1 , out_tile_3_value_nand_1_rmff};
  assign out_tile_3_value_rsci_we_d = {out_tile_3_value_nand_rmff , 1'b1};
  assign out_tile_0_value_rsci_data_in_d = {fifo_0_PackedStencil_DTYPE_2U_1U_1U_1U_4_regs_value_2_63_32_sva
      , fifo_0_PackedStencil_DTYPE_2U_1U_1U_1U_4_regs_value_2_31_0_sva};
  assign out_tile_1_value_rsci_data_in_d = {fifo_1_PackedStencil_DTYPE_2U_1U_1U_1U_3_regs_value_1_63_32_sva
      , fifo_1_PackedStencil_DTYPE_2U_1U_1U_1U_3_regs_value_1_31_0_sva};
  assign out_tile_2_value_rsci_data_in_d = {fifo_2_PackedStencil_DTYPE_2U_1U_1U_1U_2_regs_value_0_63_32_sva
      , fifo_2_PackedStencil_DTYPE_2U_1U_1U_1U_2_regs_value_0_31_0_sva};
  assign out_tile_3_value_rsci_data_in_d = {COL_4_ROW_4_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_y_reg_value_64_63_0_ncse_63_32_lpi_1_dfm_mx0
      , COL_4_ROW_4_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_y_reg_value_64_63_0_ncse_31_0_lpi_1_dfm_mx0};
  always @(posedge clk) begin
    if ( rst ) begin
      output_rsci_d_31_0 <= 32'b0;
      output_rsci_d_63_32 <= 32'b0;
      output_rsci_d_95_64 <= 32'b0;
      output_rsci_d_127_96 <= 32'b0;
      output_rsci_d_159_128 <= 32'b0;
      output_rsci_d_191_160 <= 32'b0;
    end
    else if ( output_and_cse ) begin
      output_rsci_d_31_0 <= fifo_0_PackedStencil_DTYPE_2U_1U_1U_1U_4_regs_value_2_31_0_sva;
      output_rsci_d_63_32 <= fifo_0_PackedStencil_DTYPE_2U_1U_1U_1U_4_regs_value_2_63_32_sva;
      output_rsci_d_95_64 <= fifo_1_PackedStencil_DTYPE_2U_1U_1U_1U_3_regs_value_1_31_0_sva;
      output_rsci_d_127_96 <= fifo_1_PackedStencil_DTYPE_2U_1U_1U_1U_3_regs_value_1_63_32_sva;
      output_rsci_d_159_128 <= fifo_2_PackedStencil_DTYPE_2U_1U_1U_1U_2_regs_value_0_31_0_sva;
      output_rsci_d_191_160 <= fifo_2_PackedStencil_DTYPE_2U_1U_1U_1U_2_regs_value_0_63_32_sva;
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      output_rsci_d_223_192 <= 32'b0;
      output_rsci_d_255_224 <= 32'b0;
    end
    else if ( output_and_6_cse ) begin
      output_rsci_d_223_192 <= COL_4_ROW_4_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_y_reg_value_64_63_0_ncse_31_0_lpi_1_dfm_1;
      output_rsci_d_255_224 <= COL_4_ROW_4_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_y_reg_value_64_63_0_ncse_63_32_lpi_1_dfm_1;
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      reg_out_tile_3_value_rsc_cgo_cse <= 1'b0;
      reg_output_rsci_ld_core_psct_cse <= 1'b0;
      reg_weight_rsci_ld_core_psct_cse <= 1'b0;
      reg_input_rsci_ld_core_psct_cse <= 1'b0;
      pe_y_reg_value_3_3_31_0_sva_dfm_1 <= 32'b0;
      COMP_i_0_lpi_1_dfm_2 <= 1'b0;
      COMP_i_0_15_lpi_1_dfm_2 <= 1'b0;
      COMP_i_0_14_lpi_1_dfm_2 <= 1'b0;
      COMP_i_0_13_lpi_1_dfm_2 <= 1'b0;
      COMP_i_0_12_lpi_1_dfm_2 <= 1'b0;
      COMP_i_0_11_lpi_1_dfm_2 <= 1'b0;
      COMP_i_0_10_lpi_1_dfm_2 <= 1'b0;
      COMP_i_0_9_lpi_1_dfm_2 <= 1'b0;
      COMP_i_0_8_lpi_1_dfm_2 <= 1'b0;
      COMP_i_0_7_lpi_1_dfm_2 <= 1'b0;
      COMP_i_0_6_lpi_1_dfm_2 <= 1'b0;
      COMP_i_0_5_lpi_1_dfm_2 <= 1'b0;
      COMP_i_0_4_lpi_1_dfm_2 <= 1'b0;
      COMP_i_0_3_lpi_1_dfm_2 <= 1'b0;
      COMP_i_0_2_lpi_1_dfm_2 <= 1'b0;
      COMP_i_0_1_lpi_1_dfm_2 <= 1'b0;
      COMP_and_13_mdf_sva_st_1 <= 1'b0;
      COL_4_ROW_4_PackedStencil_DTYPE_2U_1U_1U_1U_operator_rshift_itm_1 <= 16'b0;
      STEPS_if_slc_STEPS_if_acc_3_svs_2 <= 1'b0;
      reg_exitL_exit_COL_1_ROW_1_COMP_lpi_1_dfm_3_cse <= 1'b0;
      Ko_k_idx_0_lpi_2 <= 1'b0;
      Co_c_idx_0_lpi_1 <= 1'b0;
      main_stage_0_2 <= 1'b0;
      pe_y_reg_value_3_2_31_0_sva_dfm_1 <= 32'b0;
      pe_y_reg_value_2_3_31_0_sva_dfm_1 <= 32'b0;
      COL_4_ROW_3_PackedStencil_DTYPE_2U_1U_1U_1U_operator_rshift_itm_1 <= 16'b0;
      COL_3_ROW_4_PackedStencil_DTYPE_2U_1U_1U_1U_operator_rshift_itm_1 <= 16'b0;
      pe_y_reg_value_3_1_31_0_sva_dfm_1 <= 32'b0;
      pe_y_reg_value_2_2_31_0_sva_dfm_1 <= 32'b0;
      pe_y_reg_value_1_3_31_0_sva_dfm_1 <= 32'b0;
      COL_4_ROW_2_PackedStencil_DTYPE_2U_1U_1U_1U_operator_rshift_itm_1 <= 16'b0;
      COL_3_ROW_3_PackedStencil_DTYPE_2U_1U_1U_1U_operator_rshift_itm_1 <= 16'b0;
      COL_2_ROW_4_PackedStencil_DTYPE_2U_1U_1U_1U_operator_rshift_itm_1 <= 16'b0;
      pe_y_reg_value_3_0_31_0_sva_dfm_1 <= 32'b0;
      pe_y_reg_value_2_1_31_0_sva_dfm_1 <= 32'b0;
      pe_y_reg_value_1_2_31_0_sva_dfm_1 <= 32'b0;
      pe_y_reg_value_0_3_31_0_sva_dfm_1 <= 32'b0;
      COL_4_ROW_1_PackedStencil_DTYPE_2U_1U_1U_1U_operator_rshift_itm_1 <= 16'b0;
      COL_3_ROW_2_PackedStencil_DTYPE_2U_1U_1U_1U_operator_rshift_itm_1 <= 16'b0;
      COL_2_ROW_3_PackedStencil_DTYPE_2U_1U_1U_1U_operator_rshift_itm_1 <= 16'b0;
      COL_1_ROW_4_PackedStencil_DTYPE_2U_1U_1U_1U_operator_rshift_itm_1 <= 16'b0;
      pe_y_reg_value_2_0_31_0_sva_dfm_1 <= 32'b0;
      pe_y_reg_value_1_1_31_0_sva_dfm_1 <= 32'b0;
      pe_y_reg_value_0_2_31_0_sva_dfm_1 <= 32'b0;
      COL_3_ROW_1_PackedStencil_DTYPE_2U_1U_1U_1U_operator_rshift_itm_1 <= 16'b0;
      COL_2_ROW_2_PackedStencil_DTYPE_2U_1U_1U_1U_operator_rshift_itm_1 <= 16'b0;
      COL_1_ROW_3_PackedStencil_DTYPE_2U_1U_1U_1U_operator_rshift_itm_1 <= 16'b0;
      pe_y_reg_value_1_0_31_0_sva_dfm_1 <= 32'b0;
      pe_y_reg_value_0_1_31_0_sva_dfm_1 <= 32'b0;
      COL_2_ROW_1_PackedStencil_DTYPE_2U_1U_1U_1U_operator_rshift_itm_1 <= 16'b0;
      COL_1_ROW_2_PackedStencil_DTYPE_2U_1U_1U_1U_operator_rshift_itm_1 <= 16'b0;
    end
    else if ( core_wen ) begin
      reg_out_tile_3_value_rsc_cgo_cse <= and_164_rmff;
      reg_output_rsci_ld_core_psct_cse <= Co_c_idx_0_lpi_1_dfm & (winx_wx_idx_1_0_lpi_2==2'b10)
          & (winy_wy_idx_1_0_lpi_2==2'b10) & and_dcpl_29;
      reg_weight_rsci_ld_core_psct_cse <= or_8_cse & STEPS_if_acc_itm_3_1 & (fsm_output[1]);
      reg_input_rsci_ld_core_psct_cse <= or_54_cse & (fsm_output[1]);
      pe_y_reg_value_3_3_31_0_sva_dfm_1 <= MUX1HOT_v_32_3_2(pe_y_reg_value_3_3_31_0_sva_mx0,
          pe_y_reg_value_2_3_63_32_sva_mx0, pe_y_reg_value_3_3_63_32_sva_mx0, {(and_72_nl)
          , or_8_cse , (and_74_nl)});
      COMP_i_0_lpi_1_dfm_2 <= COMP_i_0_lpi_1_dfm;
      COMP_i_0_15_lpi_1_dfm_2 <= COMP_i_0_15_lpi_1_dfm;
      COMP_i_0_14_lpi_1_dfm_2 <= COMP_i_0_14_lpi_1_dfm;
      COMP_i_0_13_lpi_1_dfm_2 <= COMP_i_0_13_lpi_1_dfm;
      COMP_i_0_12_lpi_1_dfm_2 <= COMP_i_0_12_lpi_1_dfm;
      COMP_i_0_11_lpi_1_dfm_2 <= COMP_i_0_11_lpi_1_dfm;
      COMP_i_0_10_lpi_1_dfm_2 <= COMP_i_0_10_lpi_1_dfm;
      COMP_i_0_9_lpi_1_dfm_2 <= COMP_i_0_9_lpi_1_dfm;
      COMP_i_0_8_lpi_1_dfm_2 <= COMP_i_0_8_lpi_1_dfm;
      COMP_i_0_7_lpi_1_dfm_2 <= COMP_i_0_7_lpi_1_dfm;
      COMP_i_0_6_lpi_1_dfm_2 <= COMP_i_0_6_lpi_1_dfm;
      COMP_i_0_5_lpi_1_dfm_2 <= COMP_i_0_5_lpi_1_dfm;
      COMP_i_0_4_lpi_1_dfm_2 <= COMP_i_0_4_lpi_1_dfm;
      COMP_i_0_3_lpi_1_dfm_2 <= COMP_i_0_3_lpi_1_dfm;
      COMP_i_0_2_lpi_1_dfm_2 <= COMP_i_0_2_lpi_1_dfm;
      COMP_i_0_1_lpi_1_dfm_2 <= COMP_i_0_1_lpi_1_dfm;
      COMP_and_13_mdf_sva_st_1 <= COMP_and_13_tmp;
      COL_4_ROW_4_PackedStencil_DTYPE_2U_1U_1U_1U_operator_rshift_itm_1 <= MUX1HOT_v_16_3_2((pe_y_reg_value_3_3_63_32_sva_mx0[15:0]),
          (asn_176_mx0w0[15:0]), (pe_y_reg_value_3_3_31_0_sva_mx0[15:0]), {(~ or_71_tmp)
          , (~ and_dcpl_49) , (PackedStencil_DTYPE_2U_1U_1U_1U_operator_and_29_nl)});
      STEPS_if_slc_STEPS_if_acc_3_svs_2 <= STEPS_if_acc_itm_3_1;
      reg_exitL_exit_COL_1_ROW_1_COMP_lpi_1_dfm_3_cse <= exitL_exit_COL_1_ROW_1_COMP_lpi_1_dfm;
      Ko_k_idx_0_lpi_2 <= MUX_s_1_2_2(Ko_k_idx_0_lpi_1_dfm, (~ Ko_k_idx_0_lpi_1_dfm),
          exit_STEPS_lpi_1_dfm_1_mx0w0);
      Co_c_idx_0_lpi_1 <= MUX_s_1_2_2((~ Co_c_idx_0_lpi_1_dfm), Co_c_idx_0_lpi_1_dfm,
          or_dcpl_64);
      main_stage_0_2 <= fsm_output[1];
      pe_y_reg_value_3_2_31_0_sva_dfm_1 <= MUX1HOT_v_32_3_2(asn_158_mx0w0, pe_y_reg_value_2_2_63_32_sva_mx0,
          asn_161_mx0w2, {(and_83_nl) , or_8_cse , (and_85_nl)});
      pe_y_reg_value_2_3_31_0_sva_dfm_1 <= MUX1HOT_v_32_3_2(asn_176_mx0w0, pe_y_reg_value_1_3_63_32_sva_mx0,
          pe_y_reg_value_2_3_63_32_sva_mx0, {(and_87_nl) , or_8_cse , (and_89_nl)});
      COL_4_ROW_3_PackedStencil_DTYPE_2U_1U_1U_1U_operator_rshift_itm_1 <= MUX1HOT_v_16_3_2((pe_y_reg_value_2_3_63_32_sva_mx0[15:0]),
          (asn_200_mx0w0[15:0]), (asn_176_mx0w0[15:0]), {(~ or_85_tmp) , (~ and_dcpl_49)
          , (PackedStencil_DTYPE_2U_1U_1U_1U_operator_and_27_nl)});
      COL_3_ROW_4_PackedStencil_DTYPE_2U_1U_1U_1U_operator_rshift_itm_1 <= MUX1HOT_v_16_3_2((asn_161_mx0w2[15:0]),
          (asn_182_mx0w0[15:0]), (asn_158_mx0w0[15:0]), {(~ or_87_tmp) , (~ and_dcpl_49)
          , (PackedStencil_DTYPE_2U_1U_1U_1U_operator_and_25_nl)});
      pe_y_reg_value_3_1_31_0_sva_dfm_1 <= MUX1HOT_v_32_3_2(asn_164_mx0w0, pe_y_reg_value_2_1_63_32_sva_mx0,
          asn_167_mx0w2, {(and_97_nl) , or_8_cse , (and_99_nl)});
      pe_y_reg_value_2_2_31_0_sva_dfm_1 <= MUX1HOT_v_32_3_2(asn_182_mx0w0, pe_y_reg_value_1_2_63_32_sva_mx0,
          pe_y_reg_value_2_2_63_32_sva_mx0, {(and_101_nl) , or_8_cse , (and_103_nl)});
      pe_y_reg_value_1_3_31_0_sva_dfm_1 <= MUX1HOT_v_32_3_2(asn_200_mx0w0, pe_y_reg_value_0_3_63_32_sva_mx0,
          pe_y_reg_value_1_3_63_32_sva_mx0, {(and_105_nl) , or_8_cse , (and_107_nl)});
      COL_4_ROW_2_PackedStencil_DTYPE_2U_1U_1U_1U_operator_rshift_itm_1 <= MUX1HOT_v_16_3_2((pe_y_reg_value_1_3_63_32_sva_mx0[15:0]),
          (asn_224_mx0w0[15:0]), (asn_200_mx0w0[15:0]), {(~ or_89_tmp) , (~ and_dcpl_49)
          , (PackedStencil_DTYPE_2U_1U_1U_1U_operator_and_23_nl)});
      COL_3_ROW_3_PackedStencil_DTYPE_2U_1U_1U_1U_operator_rshift_itm_1 <= MUX1HOT_v_16_3_2((pe_y_reg_value_2_2_63_32_sva_mx0[15:0]),
          (asn_206_mx0w0[15:0]), (asn_182_mx0w0[15:0]), {(~ or_91_tmp) , (~ and_dcpl_49)
          , (PackedStencil_DTYPE_2U_1U_1U_1U_operator_and_21_nl)});
      COL_2_ROW_4_PackedStencil_DTYPE_2U_1U_1U_1U_operator_rshift_itm_1 <= MUX1HOT_v_16_3_2((asn_167_mx0w2[15:0]),
          (asn_188_mx0w0[15:0]), (asn_164_mx0w0[15:0]), {(~ or_93_tmp) , (~ and_dcpl_49)
          , (PackedStencil_DTYPE_2U_1U_1U_1U_operator_and_19_nl)});
      pe_y_reg_value_3_0_31_0_sva_dfm_1 <= MUX1HOT_v_32_3_2(asn_170_mx0w0, pe_y_reg_value_2_0_63_32_sva_mx0,
          asn_173_mx0w2, {(and_117_nl) , or_8_cse , (and_119_nl)});
      pe_y_reg_value_2_1_31_0_sva_dfm_1 <= MUX1HOT_v_32_3_2(asn_188_mx0w0, pe_y_reg_value_1_1_63_32_sva_mx0,
          pe_y_reg_value_2_1_63_32_sva_mx0, {(and_121_nl) , or_8_cse , (and_123_nl)});
      pe_y_reg_value_1_2_31_0_sva_dfm_1 <= MUX1HOT_v_32_3_2(asn_206_mx0w0, pe_y_reg_value_0_2_63_32_sva_mx0,
          pe_y_reg_value_1_2_63_32_sva_mx0, {(and_125_nl) , or_8_cse , (and_127_nl)});
      pe_y_reg_value_0_3_31_0_sva_dfm_1 <= MUX1HOT_v_32_3_2(asn_224_mx0w0, (fifo_90003_PackedStencil_DTYPE_2U_1U_1U_1U_4_regs_value_2_sva[63:32]),
          pe_y_reg_value_0_3_63_32_sva_mx0, {(and_129_nl) , or_8_cse , (and_131_nl)});
      COL_4_ROW_1_PackedStencil_DTYPE_2U_1U_1U_1U_operator_rshift_itm_1 <= MUX1HOT_v_16_3_2((pe_y_reg_value_0_3_63_32_sva_mx0[15:0]),
          (fifo_90003_PackedStencil_DTYPE_2U_1U_1U_1U_4_regs_value_2_sva[15:0]),
          (asn_224_mx0w0[15:0]), {(~ or_95_tmp) , (~ and_dcpl_49) , (PackedStencil_DTYPE_2U_1U_1U_1U_operator_and_17_nl)});
      COL_3_ROW_2_PackedStencil_DTYPE_2U_1U_1U_1U_operator_rshift_itm_1 <= MUX1HOT_v_16_3_2((pe_y_reg_value_1_2_63_32_sva_mx0[15:0]),
          (asn_230_mx0w0[15:0]), (asn_206_mx0w0[15:0]), {(~ or_97_tmp) , (~ and_dcpl_49)
          , (PackedStencil_DTYPE_2U_1U_1U_1U_operator_and_15_nl)});
      COL_2_ROW_3_PackedStencil_DTYPE_2U_1U_1U_1U_operator_rshift_itm_1 <= MUX1HOT_v_16_3_2((pe_y_reg_value_2_1_63_32_sva_mx0[15:0]),
          (asn_212_mx0w0[15:0]), (asn_188_mx0w0[15:0]), {(~ or_99_tmp) , (~ and_dcpl_49)
          , (PackedStencil_DTYPE_2U_1U_1U_1U_operator_and_13_nl)});
      COL_1_ROW_4_PackedStencil_DTYPE_2U_1U_1U_1U_operator_rshift_itm_1 <= MUX1HOT_v_16_3_2((asn_173_mx0w2[15:0]),
          (asn_194_mx0w0[15:0]), (asn_170_mx0w0[15:0]), {(~ or_101_tmp) , (~ and_dcpl_49)
          , (PackedStencil_DTYPE_2U_1U_1U_1U_operator_and_11_nl)});
      pe_y_reg_value_2_0_31_0_sva_dfm_1 <= MUX1HOT_v_32_3_2(asn_194_mx0w0, pe_y_reg_value_1_0_63_32_sva_mx0,
          pe_y_reg_value_2_0_63_32_sva_mx0, {(and_139_nl) , or_8_cse , (and_141_nl)});
      pe_y_reg_value_1_1_31_0_sva_dfm_1 <= MUX1HOT_v_32_3_2(asn_212_mx0w0, pe_y_reg_value_0_1_63_32_sva_mx0,
          pe_y_reg_value_1_1_63_32_sva_mx0, {(and_143_nl) , or_8_cse , (and_145_nl)});
      pe_y_reg_value_0_2_31_0_sva_dfm_1 <= MUX1HOT_v_32_3_2(asn_230_mx0w0, (fifo_90002_PackedStencil_DTYPE_2U_1U_1U_1U_3_regs_value_1_sva[63:32]),
          pe_y_reg_value_0_2_63_32_sva_mx0, {(and_147_nl) , or_8_cse , (and_149_nl)});
      COL_3_ROW_1_PackedStencil_DTYPE_2U_1U_1U_1U_operator_rshift_itm_1 <= MUX1HOT_v_16_3_2((pe_y_reg_value_0_2_63_32_sva_mx0[15:0]),
          (fifo_90002_PackedStencil_DTYPE_2U_1U_1U_1U_3_regs_value_1_sva[15:0]),
          (asn_230_mx0w0[15:0]), {(~ or_103_tmp) , (~ and_dcpl_49) , (PackedStencil_DTYPE_2U_1U_1U_1U_operator_and_9_nl)});
      COL_2_ROW_2_PackedStencil_DTYPE_2U_1U_1U_1U_operator_rshift_itm_1 <= MUX1HOT_v_16_3_2((pe_y_reg_value_1_1_63_32_sva_mx0[15:0]),
          (asn_236_mx0w0[15:0]), (asn_212_mx0w0[15:0]), {(~ or_105_tmp) , (~ and_dcpl_49)
          , (PackedStencil_DTYPE_2U_1U_1U_1U_operator_and_7_nl)});
      COL_1_ROW_3_PackedStencil_DTYPE_2U_1U_1U_1U_operator_rshift_itm_1 <= MUX1HOT_v_16_3_2((pe_y_reg_value_2_0_63_32_sva_mx0[15:0]),
          (asn_218_mx0w0[15:0]), (asn_194_mx0w0[15:0]), {(~ or_107_tmp) , (~ and_dcpl_49)
          , (PackedStencil_DTYPE_2U_1U_1U_1U_operator_and_5_nl)});
      pe_y_reg_value_1_0_31_0_sva_dfm_1 <= MUX1HOT_v_32_3_2(asn_218_mx0w0, pe_y_reg_value_0_0_63_32_sva_mx1,
          pe_y_reg_value_1_0_63_32_sva_mx0, {(and_155_nl) , or_8_cse , (and_157_nl)});
      pe_y_reg_value_0_1_31_0_sva_dfm_1 <= MUX1HOT_v_32_3_2(asn_236_mx0w0, fifo_90001_PackedStencil_DTYPE_2U_1U_1U_1U_2_regs_value_0_sva_mx1_63_32,
          pe_y_reg_value_0_1_63_32_sva_mx0, {(and_159_nl) , or_8_cse , (and_161_nl)});
      COL_2_ROW_1_PackedStencil_DTYPE_2U_1U_1U_1U_operator_rshift_itm_1 <= MUX1HOT_v_16_3_2((pe_y_reg_value_0_1_63_32_sva_mx0[15:0]),
          fifo_90001_PackedStencil_DTYPE_2U_1U_1U_1U_2_regs_value_0_sva_mx1_15_0,
          (asn_236_mx0w0[15:0]), {(~ or_109_tmp) , (~ and_dcpl_49) , (PackedStencil_DTYPE_2U_1U_1U_1U_operator_and_3_nl)});
      COL_1_ROW_2_PackedStencil_DTYPE_2U_1U_1U_1U_operator_rshift_itm_1 <= MUX1HOT_v_16_3_2((pe_y_reg_value_1_0_63_32_sva_mx0[15:0]),
          (pe_y_reg_value_0_0_31_0_sva_mx1[15:0]), (asn_218_mx0w0[15:0]), {(~ or_111_tmp)
          , (~ and_dcpl_49) , (PackedStencil_DTYPE_2U_1U_1U_1U_operator_and_1_nl)});
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      reg_STEPS_if_2_land_1_lpi_1_dfm_st_1_cse <= 1'b0;
    end
    else if ( core_wen & or_54_cse ) begin
      reg_STEPS_if_2_land_1_lpi_1_dfm_st_1_cse <= ~((winy_wy_idx_1_0_lpi_1_dfm!=2'b00)
          | (winx_wx_idx_1_0_lpi_1_dfm!=2'b00) | Co_c_idx_0_lpi_1_dfm);
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      STEPS_step_slc_STEPS_step_4_0_4_4_itm_2 <= 1'b0;
    end
    else if ( core_wen & or_8_cse ) begin
      STEPS_step_slc_STEPS_step_4_0_4_4_itm_2 <= STEPS_step_4_0_lpi_1_dfm[4];
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      STEPS_if_3_slc_STEPS_acc_5_5_itm_3 <= 1'b0;
    end
    else if ( core_wen & COMP_and_13_tmp ) begin
      STEPS_if_3_slc_STEPS_acc_5_5_itm_3 <= STEPS_acc_5_itm_5_1;
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      COL_3_ROW_4_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_x_reg_16_15_0_ncse_lpi_1_dfm_1
          <= 16'b0;
      COL_3_ROW_3_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_x_reg_16_15_0_ncse_lpi_1_dfm_1
          <= 16'b0;
      COL_2_ROW_4_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_x_reg_16_15_0_ncse_lpi_1_dfm_1
          <= 16'b0;
      COL_3_ROW_2_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_x_reg_16_15_0_ncse_lpi_1_dfm_1
          <= 16'b0;
      COL_2_ROW_3_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_x_reg_16_15_0_ncse_lpi_1_dfm_1
          <= 16'b0;
      COL_1_ROW_4_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_x_reg_16_15_0_ncse_lpi_1_dfm_1
          <= 16'b0;
      COL_3_ROW_1_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_x_reg_16_15_0_ncse_lpi_1_dfm_1
          <= 16'b0;
      COL_2_ROW_2_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_x_reg_16_15_0_ncse_lpi_1_dfm_1
          <= 16'b0;
      COL_1_ROW_3_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_x_reg_16_15_0_ncse_lpi_1_dfm_1
          <= 16'b0;
      SHIFT_3_1_else_SHIFT_3_else_slc_fifo_60003_DTYPE_4_regs_16_15_0_ncse_lpi_1_dfm_1
          <= 16'b0;
      COL_2_ROW_1_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_x_reg_16_15_0_ncse_lpi_1_dfm_1
          <= 16'b0;
      COL_1_ROW_2_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_x_reg_16_15_0_ncse_lpi_1_dfm_1
          <= 16'b0;
      SHIFT_2_1_else_SHIFT_2_else_slc_fifo_60002_DTYPE_3_regs_16_15_0_ncse_lpi_1_dfm_1
          <= 16'b0;
      COL_1_ROW_1_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_x_reg_16_15_0_ncse_lpi_1_dfm_1
          <= 16'b0;
      SHIFT_1_1_else_SHIFT_1_else_slc_fifo_60001_DTYPE_2_regs_16_15_0_ncse_lpi_1_dfm_1
          <= 16'b0;
    end
    else if ( pe_class_DTYPE_2_exec_and_cse ) begin
      COL_3_ROW_4_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_x_reg_16_15_0_ncse_lpi_1_dfm_1
          <= pe_x_reg_3_2_sva;
      COL_3_ROW_3_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_x_reg_16_15_0_ncse_lpi_1_dfm_1
          <= pe_x_reg_2_2_sva;
      COL_2_ROW_4_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_x_reg_16_15_0_ncse_lpi_1_dfm_1
          <= pe_x_reg_3_1_sva;
      COL_3_ROW_2_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_x_reg_16_15_0_ncse_lpi_1_dfm_1
          <= pe_x_reg_1_2_sva;
      COL_2_ROW_3_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_x_reg_16_15_0_ncse_lpi_1_dfm_1
          <= pe_x_reg_2_1_sva;
      COL_1_ROW_4_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_x_reg_16_15_0_ncse_lpi_1_dfm_1
          <= pe_x_reg_3_0_sva;
      COL_3_ROW_1_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_x_reg_16_15_0_ncse_lpi_1_dfm_1
          <= pe_x_reg_0_2_sva;
      COL_2_ROW_2_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_x_reg_16_15_0_ncse_lpi_1_dfm_1
          <= pe_x_reg_1_1_sva;
      COL_1_ROW_3_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_x_reg_16_15_0_ncse_lpi_1_dfm_1
          <= pe_x_reg_2_0_sva;
      SHIFT_3_1_else_SHIFT_3_else_slc_fifo_60003_DTYPE_4_regs_16_15_0_ncse_lpi_1_dfm_1
          <= fifo_60003_DTYPE_4_regs_2_sva;
      COL_2_ROW_1_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_x_reg_16_15_0_ncse_lpi_1_dfm_1
          <= pe_x_reg_0_1_sva;
      COL_1_ROW_2_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_x_reg_16_15_0_ncse_lpi_1_dfm_1
          <= pe_x_reg_1_0_sva;
      SHIFT_2_1_else_SHIFT_2_else_slc_fifo_60002_DTYPE_3_regs_16_15_0_ncse_lpi_1_dfm_1
          <= fifo_60002_DTYPE_3_regs_1_sva;
      COL_1_ROW_1_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_x_reg_16_15_0_ncse_lpi_1_dfm_1
          <= pe_x_reg_0_0_sva_mx1;
      SHIFT_1_1_else_SHIFT_1_else_slc_fifo_60001_DTYPE_2_regs_16_15_0_ncse_lpi_1_dfm_1
          <= fifo_60001_DTYPE_2_regs_0_sva_mx1;
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      STEPS_if_w_row_value_239_0_lpi_1_dfm_1_207_192 <= 16'b0;
      STEPS_if_w_row_value_239_0_lpi_1_dfm_1_239_224 <= 16'b0;
    end
    else if ( STEPS_if_w_row_value_and_14_cse ) begin
      STEPS_if_w_row_value_239_0_lpi_1_dfm_1_207_192 <= MUX_v_16_2_2((weight_rsci_d_mxwt[111:96]),
          STEPS_if_w_row_value_239_0_lpi_1_dfm_1_207_192, or_dcpl_48);
      STEPS_if_w_row_value_239_0_lpi_1_dfm_1_239_224 <= MUX_v_16_2_2((weight_rsci_d_mxwt[127:112]),
          STEPS_if_w_row_value_239_0_lpi_1_dfm_1_239_224, or_dcpl_48);
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      exit_winx_sva_2 <= 1'b0;
    end
    else if ( core_wen & (~ or_dcpl_56) ) begin
      exit_winx_sva_2 <= ~ winx_acc_tmp_2;
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      exit_winy_sva_2 <= 1'b0;
    end
    else if ( core_wen & (~ or_dcpl_58) ) begin
      exit_winy_sva_2 <= ~ xor_cse;
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      COL_4_ROW_4_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_y_reg_value_64_63_0_ncse_63_32_lpi_1_dfm_1
          <= 32'b0;
      COL_4_ROW_4_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_y_reg_value_64_63_0_ncse_31_0_lpi_1_dfm_1
          <= 32'b0;
      COL_3_ROW_4_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_y_reg_value_64_63_0_ncse_31_0_lpi_1_dfm_1
          <= 32'b0;
      COL_3_ROW_4_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_y_reg_value_64_63_0_ncse_63_32_lpi_1_dfm_1
          <= 32'b0;
      COL_2_ROW_4_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_y_reg_value_64_63_0_ncse_31_0_lpi_1_dfm_1
          <= 32'b0;
      COL_2_ROW_4_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_y_reg_value_64_63_0_ncse_63_32_lpi_1_dfm_1
          <= 32'b0;
      COL_1_ROW_4_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_y_reg_value_64_63_0_ncse_31_0_lpi_1_dfm_1
          <= 32'b0;
      COL_1_ROW_4_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_y_reg_value_64_63_0_ncse_63_32_lpi_1_dfm_1
          <= 32'b0;
    end
    else if ( pe_class_DTYPE_2_exec_and_12_cse ) begin
      COL_4_ROW_4_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_y_reg_value_64_63_0_ncse_63_32_lpi_1_dfm_1
          <= COL_4_ROW_4_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_y_reg_value_64_63_0_ncse_63_32_lpi_1_dfm_mx0;
      COL_4_ROW_4_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_y_reg_value_64_63_0_ncse_31_0_lpi_1_dfm_1
          <= COL_4_ROW_4_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_y_reg_value_64_63_0_ncse_31_0_lpi_1_dfm_mx0;
      COL_3_ROW_4_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_y_reg_value_64_63_0_ncse_31_0_lpi_1_dfm_1
          <= COL_3_ROW_4_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_y_reg_value_64_63_0_ncse_31_0_lpi_1_dfm_mx0;
      COL_3_ROW_4_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_y_reg_value_64_63_0_ncse_63_32_lpi_1_dfm_1
          <= COL_3_ROW_4_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_y_reg_value_64_63_0_ncse_63_32_lpi_1_dfm_mx0;
      COL_2_ROW_4_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_y_reg_value_64_63_0_ncse_31_0_lpi_1_dfm_1
          <= COL_2_ROW_4_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_y_reg_value_64_63_0_ncse_31_0_lpi_1_dfm_mx0;
      COL_2_ROW_4_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_y_reg_value_64_63_0_ncse_63_32_lpi_1_dfm_1
          <= COL_2_ROW_4_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_y_reg_value_64_63_0_ncse_63_32_lpi_1_dfm_mx0;
      COL_1_ROW_4_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_y_reg_value_64_63_0_ncse_31_0_lpi_1_dfm_1
          <= COL_1_ROW_4_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_y_reg_value_64_63_0_ncse_31_0_lpi_1_dfm_mx0;
      COL_1_ROW_4_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_y_reg_value_64_63_0_ncse_63_32_lpi_1_dfm_1
          <= COL_1_ROW_4_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_y_reg_value_64_63_0_ncse_63_32_lpi_1_dfm_mx0;
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      fifo_0_PackedStencil_DTYPE_2U_1U_1U_1U_4_regs_value_2_31_0_sva <= 32'b0;
      fifo_0_PackedStencil_DTYPE_2U_1U_1U_1U_4_regs_value_2_63_32_sva <= 32'b0;
      fifo_2_PackedStencil_DTYPE_2U_1U_1U_1U_2_regs_value_0_63_32_sva <= 32'b0;
      fifo_1_PackedStencil_DTYPE_2U_1U_1U_1U_3_regs_value_1_31_0_sva <= 32'b0;
      fifo_2_PackedStencil_DTYPE_2U_1U_1U_1U_2_regs_value_0_31_0_sva <= 32'b0;
      fifo_1_PackedStencil_DTYPE_2U_1U_1U_1U_3_regs_value_1_63_32_sva <= 32'b0;
      fifo_1_PackedStencil_DTYPE_2U_1U_1U_1U_3_regs_value_0_31_0_sva <= 32'b0;
      fifo_1_PackedStencil_DTYPE_2U_1U_1U_1U_3_regs_value_0_63_32_sva <= 32'b0;
      fifo_0_PackedStencil_DTYPE_2U_1U_1U_1U_4_regs_value_1_31_0_sva <= 32'b0;
      fifo_0_PackedStencil_DTYPE_2U_1U_1U_1U_4_regs_value_1_63_32_sva <= 32'b0;
      fifo_0_PackedStencil_DTYPE_2U_1U_1U_1U_4_regs_value_0_31_0_sva <= 32'b0;
      fifo_0_PackedStencil_DTYPE_2U_1U_1U_1U_4_regs_value_0_63_32_sva <= 32'b0;
    end
    else if ( fifo_0_PackedStencil_DTYPE_2U_1U_1U_1U_4_regs_value_and_cse ) begin
      fifo_0_PackedStencil_DTYPE_2U_1U_1U_1U_4_regs_value_2_31_0_sva <= fifo_0_PackedStencil_DTYPE_2U_1U_1U_1U_4_regs_value_1_31_0_sva;
      fifo_0_PackedStencil_DTYPE_2U_1U_1U_1U_4_regs_value_2_63_32_sva <= fifo_0_PackedStencil_DTYPE_2U_1U_1U_1U_4_regs_value_1_63_32_sva;
      fifo_2_PackedStencil_DTYPE_2U_1U_1U_1U_2_regs_value_0_63_32_sva <= COL_3_ROW_4_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_y_reg_value_64_63_0_ncse_63_32_lpi_1_dfm_mx0;
      fifo_1_PackedStencil_DTYPE_2U_1U_1U_1U_3_regs_value_1_31_0_sva <= fifo_1_PackedStencil_DTYPE_2U_1U_1U_1U_3_regs_value_0_31_0_sva;
      fifo_2_PackedStencil_DTYPE_2U_1U_1U_1U_2_regs_value_0_31_0_sva <= COL_3_ROW_4_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_y_reg_value_64_63_0_ncse_31_0_lpi_1_dfm_mx0;
      fifo_1_PackedStencil_DTYPE_2U_1U_1U_1U_3_regs_value_1_63_32_sva <= fifo_1_PackedStencil_DTYPE_2U_1U_1U_1U_3_regs_value_0_63_32_sva;
      fifo_1_PackedStencil_DTYPE_2U_1U_1U_1U_3_regs_value_0_31_0_sva <= COL_2_ROW_4_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_y_reg_value_64_63_0_ncse_31_0_lpi_1_dfm_mx0;
      fifo_1_PackedStencil_DTYPE_2U_1U_1U_1U_3_regs_value_0_63_32_sva <= COL_2_ROW_4_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_y_reg_value_64_63_0_ncse_63_32_lpi_1_dfm_mx0;
      fifo_0_PackedStencil_DTYPE_2U_1U_1U_1U_4_regs_value_1_31_0_sva <= fifo_0_PackedStencil_DTYPE_2U_1U_1U_1U_4_regs_value_0_31_0_sva;
      fifo_0_PackedStencil_DTYPE_2U_1U_1U_1U_4_regs_value_1_63_32_sva <= fifo_0_PackedStencil_DTYPE_2U_1U_1U_1U_4_regs_value_0_63_32_sva;
      fifo_0_PackedStencil_DTYPE_2U_1U_1U_1U_4_regs_value_0_31_0_sva <= COL_1_ROW_4_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_y_reg_value_64_63_0_ncse_31_0_lpi_1_dfm_mx0;
      fifo_0_PackedStencil_DTYPE_2U_1U_1U_1U_4_regs_value_0_63_32_sva <= COL_1_ROW_4_pe_class_DTYPE_2_exec_pe_class_DTYPE_2_exec_slc_pe_y_reg_value_64_63_0_ncse_63_32_lpi_1_dfm_mx0;
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      exit_winx_lpi_1_dfm_2 <= 1'b0;
      exit_winy_lpi_1_dfm_2 <= 1'b0;
      exit_Ko_lpi_1_dfm_2 <= 1'b0;
      exit_STEPS_lpi_1_dfm_1 <= 1'b0;
      COMP_and_13_mdf_sva_1 <= 1'b0;
      exit_Co_lpi_1_dfm_2 <= 1'b0;
      exitL_exit_Co_sva <= 1'b1;
    end
    else if ( STEPS_if_w_row_value_and_cse ) begin
      exit_winx_lpi_1_dfm_2 <= exit_winx_lpi_1_dfm_2_mx0w0;
      exit_winy_lpi_1_dfm_2 <= exit_winy_lpi_1_dfm_2_mx0w0;
      exit_Ko_lpi_1_dfm_2 <= exit_Ko_lpi_1_dfm_2_mx0w0;
      exit_STEPS_lpi_1_dfm_1 <= exit_STEPS_lpi_1_dfm_1_mx0w0;
      COMP_and_13_mdf_sva_1 <= COMP_and_13_tmp;
      exit_Co_lpi_1_dfm_2 <= exit_Co_lpi_1_dfm_2_mx0w0;
      exitL_exit_Co_sva <= exit_Co_lpi_1_dfm_2_mx0w0;
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      STEPS_step_4_0_lpi_2 <= 5'b0;
    end
    else if ( core_wen & or_dcpl_11 ) begin
      STEPS_step_4_0_lpi_2 <= MUX1HOT_v_5_3_2(({{4{Ko_k_idx_0_lpi_1_dfm}}, Ko_k_idx_0_lpi_1_dfm}),
          STEPS_step_4_0_lpi_1_dfm, STEPS_step_4_0_sva_1, {(~ or_dcpl_54) , (~ COMP_and_13_tmp)
          , (STEPS_and_2_nl)});
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      winy_wy_idx_1_0_lpi_2 <= 2'b0;
    end
    else if ( core_wen & ((~ COMP_and_13_tmp) | STEPS_acc_itm_5_1 | (~ Ko_k_idx_0_lpi_2)
        | or_dcpl_13) ) begin
      winy_wy_idx_1_0_lpi_2 <= MUX1HOT_v_2_3_2((signext_2_1(~ winx_acc_tmp_2)), winy_wy_idx_1_0_sva_1,
          winy_wy_idx_1_0_lpi_1_dfm, {(~ or_dcpl_56) , (winy_and_3_nl) , or_dcpl_58});
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      winx_wx_idx_1_0_lpi_2 <= 2'b0;
    end
    else if ( core_wen & ((~ Co_c_idx_0_lpi_1) | or_dcpl_11 | or_dcpl_13) ) begin
      winx_wx_idx_1_0_lpi_2 <= MUX1HOT_v_2_3_2(({{1{Co_c_idx_0_lpi_1_dfm}}, Co_c_idx_0_lpi_1_dfm}),
          winx_wx_idx_1_0_sva_1, winx_wx_idx_1_0_lpi_1_dfm, {(~ or_dcpl_64) , (winx_and_3_nl)
          , or_dcpl_56});
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      STEPS_if_w_row_value_239_0_lpi_1_dfm_1_143_128 <= 16'b0;
      STEPS_if_w_row_value_239_0_lpi_1_dfm_1_175_160 <= 16'b0;
      STEPS_if_w_row_value_239_0_lpi_1_dfm_1_79_64 <= 16'b0;
      STEPS_if_w_row_value_239_0_lpi_1_dfm_1_111_96 <= 16'b0;
      STEPS_if_w_row_value_239_0_lpi_1_dfm_1_15_0 <= 16'b0;
      STEPS_if_w_row_value_239_0_lpi_1_dfm_1_47_32 <= 16'b0;
    end
    else if ( STEPS_if_w_row_value_and_8_cse ) begin
      STEPS_if_w_row_value_239_0_lpi_1_dfm_1_143_128 <= weight_rsci_d_mxwt[79:64];
      STEPS_if_w_row_value_239_0_lpi_1_dfm_1_175_160 <= weight_rsci_d_mxwt[95:80];
      STEPS_if_w_row_value_239_0_lpi_1_dfm_1_79_64 <= weight_rsci_d_mxwt[47:32];
      STEPS_if_w_row_value_239_0_lpi_1_dfm_1_111_96 <= weight_rsci_d_mxwt[63:48];
      STEPS_if_w_row_value_239_0_lpi_1_dfm_1_15_0 <= weight_rsci_d_mxwt[15:0];
      STEPS_if_w_row_value_239_0_lpi_1_dfm_1_47_32 <= weight_rsci_d_mxwt[31:16];
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      pe_x_reg_3_2_sva <= 16'b0;
      pe_x_reg_3_1_sva <= 16'b0;
      pe_x_reg_2_2_sva <= 16'b0;
      pe_x_reg_3_0_sva <= 16'b0;
      pe_x_reg_2_1_sva <= 16'b0;
      pe_x_reg_1_2_sva <= 16'b0;
      pe_x_reg_2_0_sva <= 16'b0;
      pe_x_reg_1_1_sva <= 16'b0;
      fifo_60003_DTYPE_4_regs_2_sva <= 16'b0;
      fifo_90003_PackedStencil_DTYPE_2U_1U_1U_1U_4_regs_value_2_sva <= 64'b0;
      pe_x_reg_0_2_sva <= 16'b0;
      fifo_90003_PackedStencil_DTYPE_2U_1U_1U_1U_4_regs_value_1_sva <= 64'b0;
      fifo_60003_DTYPE_4_regs_1_sva <= 16'b0;
      pe_x_reg_1_0_sva <= 16'b0;
      pe_x_reg_0_1_sva <= 16'b0;
      fifo_60002_DTYPE_3_regs_1_sva <= 16'b0;
      fifo_90002_PackedStencil_DTYPE_2U_1U_1U_1U_3_regs_value_1_sva <= 64'b0;
    end
    else if ( pe_x_reg_and_cse ) begin
      pe_x_reg_3_2_sva <= pe_x_reg_3_1_sva;
      pe_x_reg_3_1_sva <= pe_x_reg_3_0_sva;
      pe_x_reg_2_2_sva <= pe_x_reg_2_1_sva;
      pe_x_reg_3_0_sva <= fifo_60003_DTYPE_4_regs_2_sva;
      pe_x_reg_2_1_sva <= pe_x_reg_2_0_sva;
      pe_x_reg_1_2_sva <= pe_x_reg_1_1_sva;
      pe_x_reg_2_0_sva <= fifo_60002_DTYPE_3_regs_1_sva;
      pe_x_reg_1_1_sva <= pe_x_reg_1_0_sva;
      fifo_60003_DTYPE_4_regs_2_sva <= fifo_60003_DTYPE_4_regs_1_sva;
      fifo_90003_PackedStencil_DTYPE_2U_1U_1U_1U_4_regs_value_2_sva <= fifo_90003_PackedStencil_DTYPE_2U_1U_1U_1U_4_regs_value_1_sva;
      pe_x_reg_0_2_sva <= pe_x_reg_0_1_sva;
      fifo_90003_PackedStencil_DTYPE_2U_1U_1U_1U_4_regs_value_1_sva <= fifo_90003_PackedStencil_DTYPE_2U_1U_1U_1U_4_regs_value_0_sva_mx1;
      fifo_60003_DTYPE_4_regs_1_sva <= fifo_60003_DTYPE_4_regs_0_sva_mx1;
      pe_x_reg_1_0_sva <= fifo_60001_DTYPE_2_regs_0_sva_mx1;
      pe_x_reg_0_1_sva <= pe_x_reg_0_0_sva_mx1;
      fifo_60002_DTYPE_3_regs_1_sva <= fifo_60002_DTYPE_3_regs_0_sva_mx1;
      fifo_90002_PackedStencil_DTYPE_2U_1U_1U_1U_3_regs_value_1_sva <= fifo_90002_PackedStencil_DTYPE_2U_1U_1U_1U_3_regs_value_0_sva_mx1;
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      pe_y_reg_value_0_0_31_0_sva <= 32'b0;
      pe_y_reg_value_0_0_63_32_sva <= 32'b0;
      fifo_90003_PackedStencil_DTYPE_2U_1U_1U_1U_4_regs_value_0_sva <= 64'b0;
      fifo_90002_PackedStencil_DTYPE_2U_1U_1U_1U_3_regs_value_0_sva <= 64'b0;
      fifo_60003_DTYPE_4_regs_0_sva <= 16'b0;
      fifo_60002_DTYPE_3_regs_0_sva <= 16'b0;
      fifo_60001_DTYPE_2_regs_0_sva <= 16'b0;
      pe_x_reg_0_0_sva <= 16'b0;
      reg_fifo_90001_PackedStencil_DTYPE_2U_1U_1U_1U_2_regs_value_0_tmp <= 32'b0;
      reg_fifo_90001_PackedStencil_DTYPE_2U_1U_1U_1U_2_regs_value_0_tmp_17 <= 16'b0;
    end
    else if ( pe_y_reg_value_and_cse ) begin
      pe_y_reg_value_0_0_31_0_sva <= pe_y_reg_value_0_0_31_0_sva_mx1;
      pe_y_reg_value_0_0_63_32_sva <= pe_y_reg_value_0_0_63_32_sva_mx1;
      fifo_90003_PackedStencil_DTYPE_2U_1U_1U_1U_4_regs_value_0_sva <= fifo_90003_PackedStencil_DTYPE_2U_1U_1U_1U_4_regs_value_0_sva_mx1;
      fifo_90002_PackedStencil_DTYPE_2U_1U_1U_1U_3_regs_value_0_sva <= fifo_90002_PackedStencil_DTYPE_2U_1U_1U_1U_3_regs_value_0_sva_mx1;
      fifo_60003_DTYPE_4_regs_0_sva <= fifo_60003_DTYPE_4_regs_0_sva_mx1;
      fifo_60002_DTYPE_3_regs_0_sva <= fifo_60002_DTYPE_3_regs_0_sva_mx1;
      fifo_60001_DTYPE_2_regs_0_sva <= fifo_60001_DTYPE_2_regs_0_sva_mx1;
      pe_x_reg_0_0_sva <= pe_x_reg_0_0_sva_mx1;
      reg_fifo_90001_PackedStencil_DTYPE_2U_1U_1U_1U_2_regs_value_0_tmp <= fifo_90001_PackedStencil_DTYPE_2U_1U_1U_1U_2_regs_value_0_sva_mx1_63_32;
      reg_fifo_90001_PackedStencil_DTYPE_2U_1U_1U_1U_2_regs_value_0_tmp_17 <= fifo_90001_PackedStencil_DTYPE_2U_1U_1U_1U_2_regs_value_0_sva_mx1_15_0;
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      STEPS_in_col_value_111_0_lpi_1_dfm_1_15_0_1 <= 16'b0;
    end
    else if ( core_wen & (~ or_dcpl_47) & and_dcpl_6 ) begin
      STEPS_in_col_value_111_0_lpi_1_dfm_1_15_0_1 <= input_rsci_d_mxwt[15:0];
    end
  end
  assign and_72_nl = (~ mux_tmp_11) & lfst_exit_Co_lpi_1_dfm & and_dcpl_41;
  assign and_74_nl = mux_tmp_11 & lfst_exit_Co_lpi_1_dfm & and_dcpl_41;
  assign PackedStencil_DTYPE_2U_1U_1U_1U_operator_and_29_nl = and_dcpl_49 & or_71_tmp;
  assign and_83_nl = (~ mux_tmp_12) & lfst_exit_Co_lpi_1_dfm & and_dcpl_41;
  assign and_85_nl = mux_tmp_12 & lfst_exit_Co_lpi_1_dfm & and_dcpl_41;
  assign and_87_nl = (~ mux_tmp_13) & lfst_exit_Co_lpi_1_dfm & and_dcpl_41;
  assign and_89_nl = mux_tmp_13 & lfst_exit_Co_lpi_1_dfm & and_dcpl_41;
  assign PackedStencil_DTYPE_2U_1U_1U_1U_operator_and_27_nl = and_dcpl_49 & or_85_tmp;
  assign PackedStencil_DTYPE_2U_1U_1U_1U_operator_and_25_nl = and_dcpl_49 & or_87_tmp;
  assign and_97_nl = (~ mux_tmp_14) & lfst_exit_Co_lpi_1_dfm & and_dcpl_41;
  assign and_99_nl = mux_tmp_14 & lfst_exit_Co_lpi_1_dfm & and_dcpl_41;
  assign and_101_nl = (~ mux_tmp_15) & lfst_exit_Co_lpi_1_dfm & and_dcpl_41;
  assign and_103_nl = mux_tmp_15 & lfst_exit_Co_lpi_1_dfm & and_dcpl_41;
  assign and_105_nl = (~ mux_tmp_16) & lfst_exit_Co_lpi_1_dfm & and_dcpl_41;
  assign and_107_nl = mux_tmp_16 & lfst_exit_Co_lpi_1_dfm & and_dcpl_41;
  assign PackedStencil_DTYPE_2U_1U_1U_1U_operator_and_23_nl = and_dcpl_49 & or_89_tmp;
  assign PackedStencil_DTYPE_2U_1U_1U_1U_operator_and_21_nl = and_dcpl_49 & or_91_tmp;
  assign PackedStencil_DTYPE_2U_1U_1U_1U_operator_and_19_nl = and_dcpl_49 & or_93_tmp;
  assign and_117_nl = (~ mux_tmp_17) & lfst_exit_Co_lpi_1_dfm & and_dcpl_41;
  assign and_119_nl = mux_tmp_17 & lfst_exit_Co_lpi_1_dfm & and_dcpl_41;
  assign and_121_nl = (~ mux_tmp_18) & lfst_exit_Co_lpi_1_dfm & and_dcpl_41;
  assign and_123_nl = mux_tmp_18 & lfst_exit_Co_lpi_1_dfm & and_dcpl_41;
  assign and_125_nl = (~ mux_tmp_19) & lfst_exit_Co_lpi_1_dfm & and_dcpl_41;
  assign and_127_nl = mux_tmp_19 & lfst_exit_Co_lpi_1_dfm & and_dcpl_41;
  assign and_129_nl = (~ mux_tmp_20) & lfst_exit_Co_lpi_1_dfm & and_dcpl_41;
  assign and_131_nl = mux_tmp_20 & lfst_exit_Co_lpi_1_dfm & and_dcpl_41;
  assign PackedStencil_DTYPE_2U_1U_1U_1U_operator_and_17_nl = and_dcpl_49 & or_95_tmp;
  assign PackedStencil_DTYPE_2U_1U_1U_1U_operator_and_15_nl = and_dcpl_49 & or_97_tmp;
  assign PackedStencil_DTYPE_2U_1U_1U_1U_operator_and_13_nl = and_dcpl_49 & or_99_tmp;
  assign PackedStencil_DTYPE_2U_1U_1U_1U_operator_and_11_nl = and_dcpl_49 & or_101_tmp;
  assign and_139_nl = (~ mux_tmp_21) & lfst_exit_Co_lpi_1_dfm & and_dcpl_41;
  assign and_141_nl = mux_tmp_21 & lfst_exit_Co_lpi_1_dfm & and_dcpl_41;
  assign and_143_nl = (~ mux_tmp_22) & lfst_exit_Co_lpi_1_dfm & and_dcpl_41;
  assign and_145_nl = mux_tmp_22 & lfst_exit_Co_lpi_1_dfm & and_dcpl_41;
  assign and_147_nl = (~ mux_tmp_23) & lfst_exit_Co_lpi_1_dfm & and_dcpl_41;
  assign and_149_nl = mux_tmp_23 & lfst_exit_Co_lpi_1_dfm & and_dcpl_41;
  assign PackedStencil_DTYPE_2U_1U_1U_1U_operator_and_9_nl = and_dcpl_49 & or_103_tmp;
  assign PackedStencil_DTYPE_2U_1U_1U_1U_operator_and_7_nl = and_dcpl_49 & or_105_tmp;
  assign PackedStencil_DTYPE_2U_1U_1U_1U_operator_and_5_nl = and_dcpl_49 & or_107_tmp;
  assign and_155_nl = (~ mux_tmp_24) & lfst_exit_Co_lpi_1_dfm & and_dcpl_41;
  assign and_157_nl = mux_tmp_24 & lfst_exit_Co_lpi_1_dfm & and_dcpl_41;
  assign and_159_nl = (~ mux_tmp_25) & lfst_exit_Co_lpi_1_dfm & and_dcpl_41;
  assign and_161_nl = mux_tmp_25 & lfst_exit_Co_lpi_1_dfm & and_dcpl_41;
  assign PackedStencil_DTYPE_2U_1U_1U_1U_operator_and_3_nl = and_dcpl_49 & or_109_tmp;
  assign PackedStencil_DTYPE_2U_1U_1U_1U_operator_and_1_nl = and_dcpl_49 & or_111_tmp;
  assign STEPS_and_2_nl = COMP_and_13_tmp & or_dcpl_54;
  assign winy_and_3_nl = (~ or_dcpl_58) & or_dcpl_56;
  assign winx_and_3_nl = (~ or_dcpl_56) & or_dcpl_64;

  function [15:0] MUX1HOT_v_16_3_2;
    input [15:0] input_2;
    input [15:0] input_1;
    input [15:0] input_0;
    input [2:0] sel;
    reg [15:0] result;
  begin
    result = input_0 & {16{sel[0]}};
    result = result | ( input_1 & {16{sel[1]}});
    result = result | ( input_2 & {16{sel[2]}});
    MUX1HOT_v_16_3_2 = result;
  end
  endfunction


  function [1:0] MUX1HOT_v_2_3_2;
    input [1:0] input_2;
    input [1:0] input_1;
    input [1:0] input_0;
    input [2:0] sel;
    reg [1:0] result;
  begin
    result = input_0 & {2{sel[0]}};
    result = result | ( input_1 & {2{sel[1]}});
    result = result | ( input_2 & {2{sel[2]}});
    MUX1HOT_v_2_3_2 = result;
  end
  endfunction


  function [31:0] MUX1HOT_v_32_3_2;
    input [31:0] input_2;
    input [31:0] input_1;
    input [31:0] input_0;
    input [2:0] sel;
    reg [31:0] result;
  begin
    result = input_0 & {32{sel[0]}};
    result = result | ( input_1 & {32{sel[1]}});
    result = result | ( input_2 & {32{sel[2]}});
    MUX1HOT_v_32_3_2 = result;
  end
  endfunction


  function [4:0] MUX1HOT_v_5_3_2;
    input [4:0] input_2;
    input [4:0] input_1;
    input [4:0] input_0;
    input [2:0] sel;
    reg [4:0] result;
  begin
    result = input_0 & {5{sel[0]}};
    result = result | ( input_1 & {5{sel[1]}});
    result = result | ( input_2 & {5{sel[2]}});
    MUX1HOT_v_5_3_2 = result;
  end
  endfunction


  function [0:0] MUX_s_1_2_2;
    input [0:0] input_0;
    input [0:0] input_1;
    input [0:0] sel;
    reg [0:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_s_1_2_2 = result;
  end
  endfunction


  function [15:0] MUX_v_16_2_2;
    input [15:0] input_0;
    input [15:0] input_1;
    input [0:0] sel;
    reg [15:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_16_2_2 = result;
  end
  endfunction


  function [1:0] MUX_v_2_2_2;
    input [1:0] input_0;
    input [1:0] input_1;
    input [0:0] sel;
    reg [1:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_2_2_2 = result;
  end
  endfunction


  function [31:0] MUX_v_32_2_2;
    input [31:0] input_0;
    input [31:0] input_1;
    input [0:0] sel;
    reg [31:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_32_2_2 = result;
  end
  endfunction


  function [4:0] MUX_v_5_2_2;
    input [4:0] input_0;
    input [4:0] input_1;
    input [0:0] sel;
    reg [4:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_5_2_2 = result;
  end
  endfunction


  function [63:0] MUX_v_64_2_2;
    input [63:0] input_0;
    input [63:0] input_1;
    input [0:0] sel;
    reg [63:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_64_2_2 = result;
  end
  endfunction


  function [0:0] readslicef_4_1_3;
    input [3:0] vector;
    reg [3:0] tmp;
  begin
    tmp = vector >> 3;
    readslicef_4_1_3 = tmp[0:0];
  end
  endfunction


  function [0:0] readslicef_6_1_5;
    input [5:0] vector;
    reg [5:0] tmp;
  begin
    tmp = vector >> 5;
    readslicef_6_1_5 = tmp[0:0];
  end
  endfunction


  function [1:0] signext_2_1;
    input [0:0] vector;
  begin
    signext_2_1= {{1{vector[0]}}, vector};
  end
  endfunction


  function  [3:0] conv_u2s_3_4 ;
    input [2:0]  vector ;
  begin
    conv_u2s_3_4 =  {1'b0, vector};
  end
  endfunction


  function  [5:0] conv_u2s_5_6 ;
    input [4:0]  vector ;
  begin
    conv_u2s_5_6 =  {1'b0, vector};
  end
  endfunction


  function  [16:0] conv_u2s_16_17 ;
    input [15:0]  vector ;
  begin
    conv_u2s_16_17 =  {1'b0, vector};
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_1
// ------------------------------------------------------------------


module WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_1 (
  clk, rst, din_rsc_z, din_rsc_vz, din_rsc_lz, dout_0_rsc_data_in, dout_0_rsc_addr,
      dout_0_rsc_we, dout_0_rsc_req_vz, dout_0_rsc_rls_lz, dout_1_rsc_data_in, dout_1_rsc_addr,
      dout_1_rsc_we, dout_1_rsc_req_vz, dout_1_rsc_rls_lz, dout_2_rsc_data_in, dout_2_rsc_addr,
      dout_2_rsc_we, dout_2_rsc_req_vz, dout_2_rsc_rls_lz, dout_3_rsc_data_in, dout_3_rsc_addr,
      dout_3_rsc_we, dout_3_rsc_req_vz, dout_3_rsc_rls_lz
);
  input clk;
  input rst;
  input [127:0] din_rsc_z;
  input din_rsc_vz;
  output din_rsc_lz;
  output [31:0] dout_0_rsc_data_in;
  output [13:0] dout_0_rsc_addr;
  output [1:0] dout_0_rsc_we;
  input dout_0_rsc_req_vz;
  output dout_0_rsc_rls_lz;
  output [31:0] dout_1_rsc_data_in;
  output [13:0] dout_1_rsc_addr;
  output [1:0] dout_1_rsc_we;
  input dout_1_rsc_req_vz;
  output dout_1_rsc_rls_lz;
  output [31:0] dout_2_rsc_data_in;
  output [13:0] dout_2_rsc_addr;
  output [1:0] dout_2_rsc_we;
  input dout_2_rsc_req_vz;
  output dout_2_rsc_rls_lz;
  output [31:0] dout_3_rsc_data_in;
  output [13:0] dout_3_rsc_addr;
  output [1:0] dout_3_rsc_we;
  input dout_3_rsc_req_vz;
  output dout_3_rsc_rls_lz;


  // Interconnect Declarations
  wire [15:0] dout_0_rsci_data_in_d;
  wire [6:0] dout_0_rsci_addr_d;
  wire [1:0] dout_0_rsci_we_d;
  wire [15:0] dout_1_rsci_data_in_d;
  wire [6:0] dout_1_rsci_addr_d;
  wire [1:0] dout_1_rsci_we_d;
  wire [15:0] dout_2_rsci_data_in_d;
  wire [6:0] dout_2_rsci_addr_d;
  wire [1:0] dout_2_rsci_we_d;
  wire [15:0] dout_3_rsci_data_in_d;
  wire [6:0] dout_3_rsci_addr_d;
  wire [1:0] dout_3_rsci_we_d;


  // Interconnect Declarations for Component Instantiations 
  wire [31:0] nl_dout_0_rsci_data_in_d;
  assign nl_dout_0_rsci_data_in_d = {16'b0 , dout_0_rsci_data_in_d};
  wire [13:0] nl_dout_0_rsci_addr_d;
  assign nl_dout_0_rsci_addr_d = {7'b0 , dout_0_rsci_addr_d};
  wire [31:0] nl_dout_1_rsci_data_in_d;
  assign nl_dout_1_rsci_data_in_d = {16'b0 , dout_1_rsci_data_in_d};
  wire [13:0] nl_dout_1_rsci_addr_d;
  assign nl_dout_1_rsci_addr_d = {7'b0 , dout_1_rsci_addr_d};
  wire [31:0] nl_dout_2_rsci_data_in_d;
  assign nl_dout_2_rsci_data_in_d = {16'b0 , dout_2_rsci_data_in_d};
  wire [13:0] nl_dout_2_rsci_addr_d;
  assign nl_dout_2_rsci_addr_d = {7'b0 , dout_2_rsci_addr_d};
  wire [31:0] nl_dout_3_rsci_data_in_d;
  assign nl_dout_3_rsci_data_in_d = {16'b0 , dout_3_rsci_data_in_d};
  wire [13:0] nl_dout_3_rsci_addr_d;
  assign nl_dout_3_rsci_addr_d = {7'b0 , dout_3_rsci_addr_d};
  ram_sample_065nm_dualport_beh_dc_RAM_dualRW_wport_2_72_16_7_0_1_0_0_0_1_1_16_72_2_gen
      dout_0_rsci (
      .we(dout_0_rsc_we),
      .addr(dout_0_rsc_addr),
      .data_in(dout_0_rsc_data_in),
      .data_in_d(nl_dout_0_rsci_data_in_d[31:0]),
      .addr_d(nl_dout_0_rsci_addr_d[13:0]),
      .we_d(dout_0_rsci_we_d)
    );
  ram_sample_065nm_dualport_beh_dc_RAM_dualRW_wport_3_72_16_7_0_1_0_0_0_1_1_16_72_2_gen
      dout_1_rsci (
      .we(dout_1_rsc_we),
      .addr(dout_1_rsc_addr),
      .data_in(dout_1_rsc_data_in),
      .data_in_d(nl_dout_1_rsci_data_in_d[31:0]),
      .addr_d(nl_dout_1_rsci_addr_d[13:0]),
      .we_d(dout_1_rsci_we_d)
    );
  ram_sample_065nm_dualport_beh_dc_RAM_dualRW_wport_4_72_16_7_0_1_0_0_0_1_1_16_72_2_gen
      dout_2_rsci (
      .we(dout_2_rsc_we),
      .addr(dout_2_rsc_addr),
      .data_in(dout_2_rsc_data_in),
      .data_in_d(nl_dout_2_rsci_data_in_d[31:0]),
      .addr_d(nl_dout_2_rsci_addr_d[13:0]),
      .we_d(dout_2_rsci_we_d)
    );
  ram_sample_065nm_dualport_beh_dc_RAM_dualRW_wport_5_72_16_7_0_1_0_0_0_1_1_16_72_2_gen
      dout_3_rsci (
      .we(dout_3_rsc_we),
      .addr(dout_3_rsc_addr),
      .data_in(dout_3_rsc_data_in),
      .data_in_d(nl_dout_3_rsci_data_in_d[31:0]),
      .addr_d(nl_dout_3_rsci_addr_d[13:0]),
      .we_d(dout_3_rsci_we_d)
    );
  WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_core_inst
      (
      .clk(clk),
      .rst(rst),
      .din_rsc_z(din_rsc_z),
      .din_rsc_vz(din_rsc_vz),
      .din_rsc_lz(din_rsc_lz),
      .dout_0_rsc_req_vz(dout_0_rsc_req_vz),
      .dout_0_rsc_rls_lz(dout_0_rsc_rls_lz),
      .dout_1_rsc_req_vz(dout_1_rsc_req_vz),
      .dout_1_rsc_rls_lz(dout_1_rsc_rls_lz),
      .dout_2_rsc_req_vz(dout_2_rsc_req_vz),
      .dout_2_rsc_rls_lz(dout_2_rsc_rls_lz),
      .dout_3_rsc_req_vz(dout_3_rsc_req_vz),
      .dout_3_rsc_rls_lz(dout_3_rsc_rls_lz),
      .dout_0_rsci_data_in_d(dout_0_rsci_data_in_d),
      .dout_0_rsci_addr_d(dout_0_rsci_addr_d),
      .dout_0_rsci_we_d(dout_0_rsci_we_d),
      .dout_1_rsci_data_in_d(dout_1_rsci_data_in_d),
      .dout_1_rsci_addr_d(dout_1_rsci_addr_d),
      .dout_1_rsci_we_d(dout_1_rsci_we_d),
      .dout_2_rsci_data_in_d(dout_2_rsci_data_in_d),
      .dout_2_rsci_addr_d(dout_2_rsci_addr_d),
      .dout_2_rsci_we_d(dout_2_rsci_we_d),
      .dout_3_rsci_data_in_d(dout_3_rsci_data_in_d),
      .dout_3_rsci_addr_d(dout_3_rsci_addr_d),
      .dout_3_rsci_we_d(dout_3_rsci_we_d)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_1
// ------------------------------------------------------------------


module READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_1 (
  clk, rst, din_0_rsc_addr, din_0_rsc_re, din_0_rsc_data_out, din_0_rsc_req_vz, din_0_rsc_rls_lz,
      din_1_rsc_addr, din_1_rsc_re, din_1_rsc_data_out, din_1_rsc_req_vz, din_1_rsc_rls_lz,
      din_2_rsc_addr, din_2_rsc_re, din_2_rsc_data_out, din_2_rsc_req_vz, din_2_rsc_rls_lz,
      din_3_rsc_addr, din_3_rsc_re, din_3_rsc_data_out, din_3_rsc_req_vz, din_3_rsc_rls_lz,
      dout_rsc_z, dout_rsc_vz, dout_rsc_lz
);
  input clk;
  input rst;
  output [13:0] din_0_rsc_addr;
  output [1:0] din_0_rsc_re;
  input [31:0] din_0_rsc_data_out;
  input din_0_rsc_req_vz;
  output din_0_rsc_rls_lz;
  output [13:0] din_1_rsc_addr;
  output [1:0] din_1_rsc_re;
  input [31:0] din_1_rsc_data_out;
  input din_1_rsc_req_vz;
  output din_1_rsc_rls_lz;
  output [13:0] din_2_rsc_addr;
  output [1:0] din_2_rsc_re;
  input [31:0] din_2_rsc_data_out;
  input din_2_rsc_req_vz;
  output din_2_rsc_rls_lz;
  output [13:0] din_3_rsc_addr;
  output [1:0] din_3_rsc_re;
  input [31:0] din_3_rsc_data_out;
  input din_3_rsc_req_vz;
  output din_3_rsc_rls_lz;
  output [127:0] dout_rsc_z;
  input dout_rsc_vz;
  output dout_rsc_lz;


  // Interconnect Declarations
  wire [6:0] din_0_rsci_addr_d;
  wire [1:0] din_0_rsci_re_d;
  wire [31:0] din_0_rsci_data_out_d;
  wire [6:0] din_1_rsci_addr_d;
  wire [1:0] din_1_rsci_re_d;
  wire [31:0] din_1_rsci_data_out_d;
  wire [6:0] din_2_rsci_addr_d;
  wire [1:0] din_2_rsci_re_d;
  wire [31:0] din_2_rsci_data_out_d;
  wire [6:0] din_3_rsci_addr_d;
  wire [1:0] din_3_rsci_re_d;
  wire [31:0] din_3_rsci_data_out_d;


  // Interconnect Declarations for Component Instantiations 
  wire [13:0] nl_din_0_rsci_addr_d;
  assign nl_din_0_rsci_addr_d = {7'b0 , din_0_rsci_addr_d};
  wire [13:0] nl_din_1_rsci_addr_d;
  assign nl_din_1_rsci_addr_d = {7'b0 , din_1_rsci_addr_d};
  wire [13:0] nl_din_2_rsci_addr_d;
  assign nl_din_2_rsci_addr_d = {7'b0 , din_2_rsci_addr_d};
  wire [13:0] nl_din_3_rsci_addr_d;
  assign nl_din_3_rsci_addr_d = {7'b0 , din_3_rsci_addr_d};
  ram_sample_065nm_dualport_beh_dc_RAM_dualRW_rport_10_72_16_7_0_1_0_0_0_1_1_16_72_2_gen
      din_0_rsci (
      .data_out(din_0_rsc_data_out),
      .re(din_0_rsc_re),
      .addr(din_0_rsc_addr),
      .addr_d(nl_din_0_rsci_addr_d[13:0]),
      .re_d(din_0_rsci_re_d),
      .data_out_d(din_0_rsci_data_out_d)
    );
  ram_sample_065nm_dualport_beh_dc_RAM_dualRW_rport_11_72_16_7_0_1_0_0_0_1_1_16_72_2_gen
      din_1_rsci (
      .data_out(din_1_rsc_data_out),
      .re(din_1_rsc_re),
      .addr(din_1_rsc_addr),
      .addr_d(nl_din_1_rsci_addr_d[13:0]),
      .re_d(din_1_rsci_re_d),
      .data_out_d(din_1_rsci_data_out_d)
    );
  ram_sample_065nm_dualport_beh_dc_RAM_dualRW_rport_12_72_16_7_0_1_0_0_0_1_1_16_72_2_gen
      din_2_rsci (
      .data_out(din_2_rsc_data_out),
      .re(din_2_rsc_re),
      .addr(din_2_rsc_addr),
      .addr_d(nl_din_2_rsci_addr_d[13:0]),
      .re_d(din_2_rsci_re_d),
      .data_out_d(din_2_rsci_data_out_d)
    );
  ram_sample_065nm_dualport_beh_dc_RAM_dualRW_rport_13_72_16_7_0_1_0_0_0_1_1_16_72_2_gen
      din_3_rsci (
      .data_out(din_3_rsc_data_out),
      .re(din_3_rsc_re),
      .addr(din_3_rsc_addr),
      .addr_d(nl_din_3_rsci_addr_d[13:0]),
      .re_d(din_3_rsci_re_d),
      .data_out_d(din_3_rsci_data_out_d)
    );
  READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_core_inst
      (
      .clk(clk),
      .rst(rst),
      .din_0_rsc_req_vz(din_0_rsc_req_vz),
      .din_0_rsc_rls_lz(din_0_rsc_rls_lz),
      .din_1_rsc_req_vz(din_1_rsc_req_vz),
      .din_1_rsc_rls_lz(din_1_rsc_rls_lz),
      .din_2_rsc_req_vz(din_2_rsc_req_vz),
      .din_2_rsc_rls_lz(din_2_rsc_rls_lz),
      .din_3_rsc_req_vz(din_3_rsc_req_vz),
      .din_3_rsc_rls_lz(din_3_rsc_rls_lz),
      .dout_rsc_z(dout_rsc_z),
      .dout_rsc_vz(dout_rsc_vz),
      .dout_rsc_lz(dout_rsc_lz),
      .din_0_rsci_addr_d(din_0_rsci_addr_d),
      .din_0_rsci_re_d(din_0_rsci_re_d),
      .din_0_rsci_data_out_d(din_0_rsci_data_out_d),
      .din_1_rsci_addr_d(din_1_rsci_addr_d),
      .din_1_rsci_re_d(din_1_rsci_re_d),
      .din_1_rsci_data_out_d(din_1_rsci_data_out_d),
      .din_2_rsci_addr_d(din_2_rsci_addr_d),
      .din_2_rsci_re_d(din_2_rsci_re_d),
      .din_2_rsci_data_out_d(din_2_rsci_data_out_d),
      .din_3_rsci_addr_d(din_3_rsci_addr_d),
      .din_3_rsci_re_d(din_3_rsci_re_d),
      .din_3_rsci_data_out_d(din_3_rsci_data_out_d)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_1
// ------------------------------------------------------------------


module WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_1 (
  clk, rst, din_rsc_z, din_rsc_vz, din_rsc_lz, dout_0_rsc_data_in, dout_0_rsc_addr,
      dout_0_rsc_we, dout_0_rsc_req_vz, dout_0_rsc_rls_lz, dout_1_rsc_data_in, dout_1_rsc_addr,
      dout_1_rsc_we, dout_1_rsc_req_vz, dout_1_rsc_rls_lz, dout_2_rsc_data_in, dout_2_rsc_addr,
      dout_2_rsc_we, dout_2_rsc_req_vz, dout_2_rsc_rls_lz, dout_3_rsc_data_in, dout_3_rsc_addr,
      dout_3_rsc_we, dout_3_rsc_req_vz, dout_3_rsc_rls_lz
);
  input clk;
  input rst;
  input [255:0] din_rsc_z;
  input din_rsc_vz;
  output din_rsc_lz;
  output [127:0] dout_0_rsc_data_in;
  output [15:0] dout_0_rsc_addr;
  output [1:0] dout_0_rsc_we;
  input dout_0_rsc_req_vz;
  output dout_0_rsc_rls_lz;
  output [127:0] dout_1_rsc_data_in;
  output [15:0] dout_1_rsc_addr;
  output [1:0] dout_1_rsc_we;
  input dout_1_rsc_req_vz;
  output dout_1_rsc_rls_lz;
  output [127:0] dout_2_rsc_data_in;
  output [15:0] dout_2_rsc_addr;
  output [1:0] dout_2_rsc_we;
  input dout_2_rsc_req_vz;
  output dout_2_rsc_rls_lz;
  output [127:0] dout_3_rsc_data_in;
  output [15:0] dout_3_rsc_addr;
  output [1:0] dout_3_rsc_we;
  input dout_3_rsc_req_vz;
  output dout_3_rsc_rls_lz;


  // Interconnect Declarations
  wire [63:0] dout_0_rsci_data_in_d;
  wire [7:0] dout_0_rsci_addr_d;
  wire [1:0] dout_0_rsci_we_d;
  wire [63:0] dout_1_rsci_data_in_d;
  wire [7:0] dout_1_rsci_addr_d;
  wire [1:0] dout_1_rsci_we_d;
  wire [63:0] dout_2_rsci_data_in_d;
  wire [7:0] dout_2_rsci_addr_d;
  wire [1:0] dout_2_rsci_we_d;
  wire [63:0] dout_3_rsci_data_in_d;
  wire [7:0] dout_3_rsci_addr_d;
  wire [1:0] dout_3_rsci_we_d;


  // Interconnect Declarations for Component Instantiations 
  wire [127:0] nl_dout_0_rsci_data_in_d;
  assign nl_dout_0_rsci_data_in_d = {64'b0 , dout_0_rsci_data_in_d};
  wire [15:0] nl_dout_0_rsci_addr_d;
  assign nl_dout_0_rsci_addr_d = {8'b0 , dout_0_rsci_addr_d};
  wire [127:0] nl_dout_1_rsci_data_in_d;
  assign nl_dout_1_rsci_data_in_d = {64'b0 , dout_1_rsci_data_in_d};
  wire [15:0] nl_dout_1_rsci_addr_d;
  assign nl_dout_1_rsci_addr_d = {8'b0 , dout_1_rsci_addr_d};
  wire [127:0] nl_dout_2_rsci_data_in_d;
  assign nl_dout_2_rsci_data_in_d = {64'b0 , dout_2_rsci_data_in_d};
  wire [15:0] nl_dout_2_rsci_addr_d;
  assign nl_dout_2_rsci_addr_d = {8'b0 , dout_2_rsci_addr_d};
  wire [127:0] nl_dout_3_rsci_data_in_d;
  assign nl_dout_3_rsci_data_in_d = {64'b0 , dout_3_rsci_data_in_d};
  wire [15:0] nl_dout_3_rsci_addr_d;
  assign nl_dout_3_rsci_addr_d = {8'b0 , dout_3_rsci_addr_d};
  ram_sample_065nm_dualport_beh_dc_RAM_dualRW_wport_26_144_64_8_0_1_0_0_0_1_1_64_144_2_gen
      dout_0_rsci (
      .we(dout_0_rsc_we),
      .addr(dout_0_rsc_addr),
      .data_in(dout_0_rsc_data_in),
      .data_in_d(nl_dout_0_rsci_data_in_d[127:0]),
      .addr_d(nl_dout_0_rsci_addr_d[15:0]),
      .we_d(dout_0_rsci_we_d)
    );
  ram_sample_065nm_dualport_beh_dc_RAM_dualRW_wport_27_144_64_8_0_1_0_0_0_1_1_64_144_2_gen
      dout_1_rsci (
      .we(dout_1_rsc_we),
      .addr(dout_1_rsc_addr),
      .data_in(dout_1_rsc_data_in),
      .data_in_d(nl_dout_1_rsci_data_in_d[127:0]),
      .addr_d(nl_dout_1_rsci_addr_d[15:0]),
      .we_d(dout_1_rsci_we_d)
    );
  ram_sample_065nm_dualport_beh_dc_RAM_dualRW_wport_28_144_64_8_0_1_0_0_0_1_1_64_144_2_gen
      dout_2_rsci (
      .we(dout_2_rsc_we),
      .addr(dout_2_rsc_addr),
      .data_in(dout_2_rsc_data_in),
      .data_in_d(nl_dout_2_rsci_data_in_d[127:0]),
      .addr_d(nl_dout_2_rsci_addr_d[15:0]),
      .we_d(dout_2_rsci_we_d)
    );
  ram_sample_065nm_dualport_beh_dc_RAM_dualRW_wport_29_144_64_8_0_1_0_0_0_1_1_64_144_2_gen
      dout_3_rsci (
      .we(dout_3_rsc_we),
      .addr(dout_3_rsc_addr),
      .data_in(dout_3_rsc_data_in),
      .data_in_d(nl_dout_3_rsci_data_in_d[127:0]),
      .addr_d(nl_dout_3_rsci_addr_d[15:0]),
      .we_d(dout_3_rsci_we_d)
    );
  WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_core_inst
      (
      .clk(clk),
      .rst(rst),
      .din_rsc_z(din_rsc_z),
      .din_rsc_vz(din_rsc_vz),
      .din_rsc_lz(din_rsc_lz),
      .dout_0_rsc_req_vz(dout_0_rsc_req_vz),
      .dout_0_rsc_rls_lz(dout_0_rsc_rls_lz),
      .dout_1_rsc_req_vz(dout_1_rsc_req_vz),
      .dout_1_rsc_rls_lz(dout_1_rsc_rls_lz),
      .dout_2_rsc_req_vz(dout_2_rsc_req_vz),
      .dout_2_rsc_rls_lz(dout_2_rsc_rls_lz),
      .dout_3_rsc_req_vz(dout_3_rsc_req_vz),
      .dout_3_rsc_rls_lz(dout_3_rsc_rls_lz),
      .dout_0_rsci_data_in_d(dout_0_rsci_data_in_d),
      .dout_0_rsci_addr_d(dout_0_rsci_addr_d),
      .dout_0_rsci_we_d(dout_0_rsci_we_d),
      .dout_1_rsci_data_in_d(dout_1_rsci_data_in_d),
      .dout_1_rsci_addr_d(dout_1_rsci_addr_d),
      .dout_1_rsci_we_d(dout_1_rsci_we_d),
      .dout_2_rsci_data_in_d(dout_2_rsci_data_in_d),
      .dout_2_rsci_addr_d(dout_2_rsci_addr_d),
      .dout_2_rsci_we_d(dout_2_rsci_we_d),
      .dout_3_rsci_data_in_d(dout_3_rsci_data_in_d),
      .dout_3_rsci_addr_d(dout_3_rsci_addr_d),
      .dout_3_rsci_we_d(dout_3_rsci_we_d)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_1
// ------------------------------------------------------------------


module READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_1 (
  clk, rst, din_0_rsc_addr, din_0_rsc_re, din_0_rsc_data_out, din_0_rsc_req_vz, din_0_rsc_rls_lz,
      din_1_rsc_addr, din_1_rsc_re, din_1_rsc_data_out, din_1_rsc_req_vz, din_1_rsc_rls_lz,
      din_2_rsc_addr, din_2_rsc_re, din_2_rsc_data_out, din_2_rsc_req_vz, din_2_rsc_rls_lz,
      din_3_rsc_addr, din_3_rsc_re, din_3_rsc_data_out, din_3_rsc_req_vz, din_3_rsc_rls_lz,
      dout_rsc_z, dout_rsc_vz, dout_rsc_lz
);
  input clk;
  input rst;
  output [15:0] din_0_rsc_addr;
  output [1:0] din_0_rsc_re;
  input [127:0] din_0_rsc_data_out;
  input din_0_rsc_req_vz;
  output din_0_rsc_rls_lz;
  output [15:0] din_1_rsc_addr;
  output [1:0] din_1_rsc_re;
  input [127:0] din_1_rsc_data_out;
  input din_1_rsc_req_vz;
  output din_1_rsc_rls_lz;
  output [15:0] din_2_rsc_addr;
  output [1:0] din_2_rsc_re;
  input [127:0] din_2_rsc_data_out;
  input din_2_rsc_req_vz;
  output din_2_rsc_rls_lz;
  output [15:0] din_3_rsc_addr;
  output [1:0] din_3_rsc_re;
  input [127:0] din_3_rsc_data_out;
  input din_3_rsc_req_vz;
  output din_3_rsc_rls_lz;
  output [255:0] dout_rsc_z;
  input dout_rsc_vz;
  output dout_rsc_lz;


  // Interconnect Declarations
  wire [7:0] din_0_rsci_addr_d;
  wire [1:0] din_0_rsci_re_d;
  wire [127:0] din_0_rsci_data_out_d;
  wire [7:0] din_1_rsci_addr_d;
  wire [1:0] din_1_rsci_re_d;
  wire [127:0] din_1_rsci_data_out_d;
  wire [7:0] din_2_rsci_addr_d;
  wire [1:0] din_2_rsci_re_d;
  wire [127:0] din_2_rsci_data_out_d;
  wire [7:0] din_3_rsci_addr_d;
  wire [1:0] din_3_rsci_re_d;
  wire [127:0] din_3_rsci_data_out_d;


  // Interconnect Declarations for Component Instantiations 
  wire [15:0] nl_din_0_rsci_addr_d;
  assign nl_din_0_rsci_addr_d = {8'b0 , din_0_rsci_addr_d};
  wire [15:0] nl_din_1_rsci_addr_d;
  assign nl_din_1_rsci_addr_d = {8'b0 , din_1_rsci_addr_d};
  wire [15:0] nl_din_2_rsci_addr_d;
  assign nl_din_2_rsci_addr_d = {8'b0 , din_2_rsci_addr_d};
  wire [15:0] nl_din_3_rsci_addr_d;
  assign nl_din_3_rsci_addr_d = {8'b0 , din_3_rsci_addr_d};
  ram_sample_065nm_dualport_beh_dc_RAM_dualRW_rport_34_144_64_8_0_1_0_0_0_1_1_64_144_2_gen
      din_0_rsci (
      .data_out(din_0_rsc_data_out),
      .re(din_0_rsc_re),
      .addr(din_0_rsc_addr),
      .addr_d(nl_din_0_rsci_addr_d[15:0]),
      .re_d(din_0_rsci_re_d),
      .data_out_d(din_0_rsci_data_out_d)
    );
  ram_sample_065nm_dualport_beh_dc_RAM_dualRW_rport_35_144_64_8_0_1_0_0_0_1_1_64_144_2_gen
      din_1_rsci (
      .data_out(din_1_rsc_data_out),
      .re(din_1_rsc_re),
      .addr(din_1_rsc_addr),
      .addr_d(nl_din_1_rsci_addr_d[15:0]),
      .re_d(din_1_rsci_re_d),
      .data_out_d(din_1_rsci_data_out_d)
    );
  ram_sample_065nm_dualport_beh_dc_RAM_dualRW_rport_36_144_64_8_0_1_0_0_0_1_1_64_144_2_gen
      din_2_rsci (
      .data_out(din_2_rsc_data_out),
      .re(din_2_rsc_re),
      .addr(din_2_rsc_addr),
      .addr_d(nl_din_2_rsci_addr_d[15:0]),
      .re_d(din_2_rsci_re_d),
      .data_out_d(din_2_rsci_data_out_d)
    );
  ram_sample_065nm_dualport_beh_dc_RAM_dualRW_rport_37_144_64_8_0_1_0_0_0_1_1_64_144_2_gen
      din_3_rsci (
      .data_out(din_3_rsc_data_out),
      .re(din_3_rsc_re),
      .addr(din_3_rsc_addr),
      .addr_d(nl_din_3_rsci_addr_d[15:0]),
      .re_d(din_3_rsci_re_d),
      .data_out_d(din_3_rsci_data_out_d)
    );
  READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_core_inst
      (
      .clk(clk),
      .rst(rst),
      .din_0_rsc_req_vz(din_0_rsc_req_vz),
      .din_0_rsc_rls_lz(din_0_rsc_rls_lz),
      .din_1_rsc_req_vz(din_1_rsc_req_vz),
      .din_1_rsc_rls_lz(din_1_rsc_rls_lz),
      .din_2_rsc_req_vz(din_2_rsc_req_vz),
      .din_2_rsc_rls_lz(din_2_rsc_rls_lz),
      .din_3_rsc_req_vz(din_3_rsc_req_vz),
      .din_3_rsc_rls_lz(din_3_rsc_rls_lz),
      .dout_rsc_z(dout_rsc_z),
      .dout_rsc_vz(dout_rsc_vz),
      .dout_rsc_lz(dout_rsc_lz),
      .din_0_rsci_addr_d(din_0_rsci_addr_d),
      .din_0_rsci_re_d(din_0_rsci_re_d),
      .din_0_rsci_data_out_d(din_0_rsci_data_out_d),
      .din_1_rsci_addr_d(din_1_rsci_addr_d),
      .din_1_rsci_re_d(din_1_rsci_re_d),
      .din_1_rsci_data_out_d(din_1_rsci_data_out_d),
      .din_2_rsci_addr_d(din_2_rsci_addr_d),
      .din_2_rsci_re_d(din_2_rsci_re_d),
      .din_2_rsci_data_out_d(din_2_rsci_data_out_d),
      .din_3_rsci_addr_d(din_3_rsci_addr_d),
      .din_3_rsci_re_d(din_3_rsci_re_d),
      .din_3_rsci_data_out_d(din_3_rsci_data_out_d)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    systolic_array_DTYPE_2_4_16_4_2_2_3
// ------------------------------------------------------------------


module systolic_array_DTYPE_2_4_16_4_2_2_3 (
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


  // Interconnect Declarations
  wire out_tile_0_value_rsc_cge;
  wire [63:0] out_tile_0_value_rsci_data_in_d;
  wire [1:0] out_tile_0_value_rsci_re_d;
  wire [1:0] out_tile_0_value_rsci_we_d;
  wire [127:0] out_tile_0_value_rsci_data_out_d;
  wire [63:0] out_tile_1_value_rsci_data_in_d;
  wire [1:0] out_tile_1_value_rsci_re_d;
  wire [1:0] out_tile_1_value_rsci_we_d;
  wire [127:0] out_tile_1_value_rsci_data_out_d;
  wire [63:0] out_tile_2_value_rsci_data_in_d;
  wire [1:0] out_tile_2_value_rsci_re_d;
  wire [1:0] out_tile_2_value_rsci_we_d;
  wire [127:0] out_tile_2_value_rsci_data_out_d;
  wire [63:0] out_tile_3_value_rsci_data_in_d;
  wire [1:0] out_tile_3_value_rsci_re_d;
  wire [1:0] out_tile_3_value_rsci_we_d;
  wire [127:0] out_tile_3_value_rsci_data_out_d;
  wire out_tile_0_value_rsc_en;
  wire [127:0] out_tile_0_value_rsc_data_out;
  wire [1:0] out_tile_0_value_rsc_we;
  wire [1:0] out_tile_0_value_rsc_re;
  wire [9:0] out_tile_0_value_rsc_addr;
  wire [127:0] out_tile_0_value_rsc_data_in;
  wire out_tile_1_value_rsc_en;
  wire [127:0] out_tile_1_value_rsc_data_out;
  wire [1:0] out_tile_1_value_rsc_we;
  wire [1:0] out_tile_1_value_rsc_re;
  wire [9:0] out_tile_1_value_rsc_addr;
  wire [127:0] out_tile_1_value_rsc_data_in;
  wire out_tile_2_value_rsc_en;
  wire [127:0] out_tile_2_value_rsc_data_out;
  wire [1:0] out_tile_2_value_rsc_we;
  wire [1:0] out_tile_2_value_rsc_re;
  wire [9:0] out_tile_2_value_rsc_addr;
  wire [127:0] out_tile_2_value_rsc_data_in;
  wire out_tile_3_value_rsc_en;
  wire [127:0] out_tile_3_value_rsc_data_out;
  wire [1:0] out_tile_3_value_rsc_we;
  wire [1:0] out_tile_3_value_rsc_re;
  wire [9:0] out_tile_3_value_rsc_addr;
  wire [127:0] out_tile_3_value_rsc_data_in;
  wire [9:0] out_tile_0_value_rsci_addr_d_iff;


  // Interconnect Declarations for Component Instantiations 
  wire [127:0] nl_out_tile_0_value_rsci_data_in_d;
  assign nl_out_tile_0_value_rsci_data_in_d = {out_tile_0_value_rsci_data_in_d ,
      64'b0};
  wire [0:0] nl_out_tile_0_value_rsci_en_d;
  assign nl_out_tile_0_value_rsci_en_d = ~ out_tile_0_value_rsc_cge;
  wire [127:0] nl_out_tile_1_value_rsci_data_in_d;
  assign nl_out_tile_1_value_rsci_data_in_d = {out_tile_1_value_rsci_data_in_d ,
      64'b0};
  wire [0:0] nl_out_tile_1_value_rsci_en_d;
  assign nl_out_tile_1_value_rsci_en_d = ~ out_tile_0_value_rsc_cge;
  wire [127:0] nl_out_tile_2_value_rsci_data_in_d;
  assign nl_out_tile_2_value_rsci_data_in_d = {out_tile_2_value_rsci_data_in_d ,
      64'b0};
  wire [0:0] nl_out_tile_2_value_rsci_en_d;
  assign nl_out_tile_2_value_rsci_en_d = ~ out_tile_0_value_rsc_cge;
  wire [127:0] nl_out_tile_3_value_rsci_data_in_d;
  assign nl_out_tile_3_value_rsci_data_in_d = {out_tile_3_value_rsci_data_in_d ,
      64'b0};
  wire [0:0] nl_out_tile_3_value_rsci_en_d;
  assign nl_out_tile_3_value_rsci_en_d = ~ out_tile_0_value_rsc_cge;
  ram_sync_dualRW_be #(.ram_id(32'sd54),
  .words(32'sd32),
  .width(32'sd64),
  .addr_width(32'sd5),
  .a_reset_active(32'sd0),
  .s_reset_active(32'sd1),
  .enable_active(32'sd0),
  .re_active(32'sd0),
  .we_active(32'sd0),
  .num_byte_enables(32'sd1),
  .clock_edge(32'sd1),
  .no_of_RAM_dualRW_readwrite_port(32'sd2)) out_tile_0_value_rsc_comp (
      .data_in(out_tile_0_value_rsc_data_in),
      .addr(out_tile_0_value_rsc_addr),
      .re(out_tile_0_value_rsc_re),
      .we(out_tile_0_value_rsc_we),
      .data_out(out_tile_0_value_rsc_data_out),
      .clk(clk),
      .a_rst(1'b1),
      .s_rst(rst),
      .en(out_tile_0_value_rsc_en)
    );
  ram_sync_dualRW_be #(.ram_id(32'sd55),
  .words(32'sd32),
  .width(32'sd64),
  .addr_width(32'sd5),
  .a_reset_active(32'sd0),
  .s_reset_active(32'sd1),
  .enable_active(32'sd0),
  .re_active(32'sd0),
  .we_active(32'sd0),
  .num_byte_enables(32'sd1),
  .clock_edge(32'sd1),
  .no_of_RAM_dualRW_readwrite_port(32'sd2)) out_tile_1_value_rsc_comp (
      .data_in(out_tile_1_value_rsc_data_in),
      .addr(out_tile_1_value_rsc_addr),
      .re(out_tile_1_value_rsc_re),
      .we(out_tile_1_value_rsc_we),
      .data_out(out_tile_1_value_rsc_data_out),
      .clk(clk),
      .a_rst(1'b1),
      .s_rst(rst),
      .en(out_tile_1_value_rsc_en)
    );
  ram_sync_dualRW_be #(.ram_id(32'sd56),
  .words(32'sd32),
  .width(32'sd64),
  .addr_width(32'sd5),
  .a_reset_active(32'sd0),
  .s_reset_active(32'sd1),
  .enable_active(32'sd0),
  .re_active(32'sd0),
  .we_active(32'sd0),
  .num_byte_enables(32'sd1),
  .clock_edge(32'sd1),
  .no_of_RAM_dualRW_readwrite_port(32'sd2)) out_tile_2_value_rsc_comp (
      .data_in(out_tile_2_value_rsc_data_in),
      .addr(out_tile_2_value_rsc_addr),
      .re(out_tile_2_value_rsc_re),
      .we(out_tile_2_value_rsc_we),
      .data_out(out_tile_2_value_rsc_data_out),
      .clk(clk),
      .a_rst(1'b1),
      .s_rst(rst),
      .en(out_tile_2_value_rsc_en)
    );
  ram_sync_dualRW_be #(.ram_id(32'sd57),
  .words(32'sd32),
  .width(32'sd64),
  .addr_width(32'sd5),
  .a_reset_active(32'sd0),
  .s_reset_active(32'sd1),
  .enable_active(32'sd0),
  .re_active(32'sd0),
  .we_active(32'sd0),
  .num_byte_enables(32'sd1),
  .clock_edge(32'sd1),
  .no_of_RAM_dualRW_readwrite_port(32'sd2)) out_tile_3_value_rsc_comp (
      .data_in(out_tile_3_value_rsc_data_in),
      .addr(out_tile_3_value_rsc_addr),
      .re(out_tile_3_value_rsc_re),
      .we(out_tile_3_value_rsc_we),
      .data_out(out_tile_3_value_rsc_data_out),
      .clk(clk),
      .a_rst(1'b1),
      .s_rst(rst),
      .en(out_tile_3_value_rsc_en)
    );
  ram_sample_065nm_dualport_beh_dc_RAM_dualRW_rwport_en_54_32_64_5_0_1_0_0_0_1_1_64_32_2_gen
      out_tile_0_value_rsci (
      .en(out_tile_0_value_rsc_en),
      .data_out(out_tile_0_value_rsc_data_out),
      .we(out_tile_0_value_rsc_we),
      .re(out_tile_0_value_rsc_re),
      .addr(out_tile_0_value_rsc_addr),
      .data_in(out_tile_0_value_rsc_data_in),
      .data_in_d(nl_out_tile_0_value_rsci_data_in_d[127:0]),
      .addr_d(out_tile_0_value_rsci_addr_d_iff),
      .re_d(out_tile_0_value_rsci_re_d),
      .we_d(out_tile_0_value_rsci_we_d),
      .data_out_d(out_tile_0_value_rsci_data_out_d),
      .en_d(nl_out_tile_0_value_rsci_en_d[0:0])
    );
  ram_sample_065nm_dualport_beh_dc_RAM_dualRW_rwport_en_55_32_64_5_0_1_0_0_0_1_1_64_32_2_gen
      out_tile_1_value_rsci (
      .en(out_tile_1_value_rsc_en),
      .data_out(out_tile_1_value_rsc_data_out),
      .we(out_tile_1_value_rsc_we),
      .re(out_tile_1_value_rsc_re),
      .addr(out_tile_1_value_rsc_addr),
      .data_in(out_tile_1_value_rsc_data_in),
      .data_in_d(nl_out_tile_1_value_rsci_data_in_d[127:0]),
      .addr_d(out_tile_0_value_rsci_addr_d_iff),
      .re_d(out_tile_1_value_rsci_re_d),
      .we_d(out_tile_1_value_rsci_we_d),
      .data_out_d(out_tile_1_value_rsci_data_out_d),
      .en_d(nl_out_tile_1_value_rsci_en_d[0:0])
    );
  ram_sample_065nm_dualport_beh_dc_RAM_dualRW_rwport_en_56_32_64_5_0_1_0_0_0_1_1_64_32_2_gen
      out_tile_2_value_rsci (
      .en(out_tile_2_value_rsc_en),
      .data_out(out_tile_2_value_rsc_data_out),
      .we(out_tile_2_value_rsc_we),
      .re(out_tile_2_value_rsc_re),
      .addr(out_tile_2_value_rsc_addr),
      .data_in(out_tile_2_value_rsc_data_in),
      .data_in_d(nl_out_tile_2_value_rsci_data_in_d[127:0]),
      .addr_d(out_tile_0_value_rsci_addr_d_iff),
      .re_d(out_tile_2_value_rsci_re_d),
      .we_d(out_tile_2_value_rsci_we_d),
      .data_out_d(out_tile_2_value_rsci_data_out_d),
      .en_d(nl_out_tile_2_value_rsci_en_d[0:0])
    );
  ram_sample_065nm_dualport_beh_dc_RAM_dualRW_rwport_en_57_32_64_5_0_1_0_0_0_1_1_64_32_2_gen
      out_tile_3_value_rsci (
      .en(out_tile_3_value_rsc_en),
      .data_out(out_tile_3_value_rsc_data_out),
      .we(out_tile_3_value_rsc_we),
      .re(out_tile_3_value_rsc_re),
      .addr(out_tile_3_value_rsc_addr),
      .data_in(out_tile_3_value_rsc_data_in),
      .data_in_d(nl_out_tile_3_value_rsci_data_in_d[127:0]),
      .addr_d(out_tile_0_value_rsci_addr_d_iff),
      .re_d(out_tile_3_value_rsci_re_d),
      .we_d(out_tile_3_value_rsci_we_d),
      .data_out_d(out_tile_3_value_rsci_data_out_d),
      .en_d(nl_out_tile_3_value_rsci_en_d[0:0])
    );
  systolic_array_DTYPE_2_4_16_4_2_2_3_core systolic_array_DTYPE_2_4_16_4_2_2_3_core_inst
      (
      .clk(clk),
      .rst(rst),
      .input_rsc_z(input_rsc_z),
      .input_rsc_vz(input_rsc_vz),
      .input_rsc_lz(input_rsc_lz),
      .weight_rsc_z(weight_rsc_z),
      .weight_rsc_vz(weight_rsc_vz),
      .weight_rsc_lz(weight_rsc_lz),
      .output_rsc_z(output_rsc_z),
      .output_rsc_vz(output_rsc_vz),
      .output_rsc_lz(output_rsc_lz),
      .out_tile_0_value_rsc_cge(out_tile_0_value_rsc_cge),
      .out_tile_0_value_rsci_data_in_d(out_tile_0_value_rsci_data_in_d),
      .out_tile_0_value_rsci_re_d(out_tile_0_value_rsci_re_d),
      .out_tile_0_value_rsci_we_d(out_tile_0_value_rsci_we_d),
      .out_tile_0_value_rsci_data_out_d(out_tile_0_value_rsci_data_out_d),
      .out_tile_1_value_rsci_data_in_d(out_tile_1_value_rsci_data_in_d),
      .out_tile_1_value_rsci_re_d(out_tile_1_value_rsci_re_d),
      .out_tile_1_value_rsci_we_d(out_tile_1_value_rsci_we_d),
      .out_tile_1_value_rsci_data_out_d(out_tile_1_value_rsci_data_out_d),
      .out_tile_2_value_rsci_data_in_d(out_tile_2_value_rsci_data_in_d),
      .out_tile_2_value_rsci_re_d(out_tile_2_value_rsci_re_d),
      .out_tile_2_value_rsci_we_d(out_tile_2_value_rsci_we_d),
      .out_tile_2_value_rsci_data_out_d(out_tile_2_value_rsci_data_out_d),
      .out_tile_3_value_rsci_data_in_d(out_tile_3_value_rsci_data_in_d),
      .out_tile_3_value_rsci_re_d(out_tile_3_value_rsci_re_d),
      .out_tile_3_value_rsci_we_d(out_tile_3_value_rsci_we_d),
      .out_tile_3_value_rsci_data_out_d(out_tile_3_value_rsci_data_out_d),
      .out_tile_0_value_rsci_addr_d_pff(out_tile_0_value_rsci_addr_d_iff)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    double_buffer_input_DTYPE_4_4_4_4_2_2_3
// ------------------------------------------------------------------


module double_buffer_input_DTYPE_4_4_4_4_2_2_3 (
  clk, rst, din_rsc_z, din_rsc_vz, din_rsc_lz, dout_rsc_z, dout_rsc_vz, dout_rsc_lz
);
  input clk;
  input rst;
  input [127:0] din_rsc_z;
  input din_rsc_vz;
  output din_rsc_lz;
  output [127:0] dout_rsc_z;
  input dout_rsc_vz;
  output dout_rsc_lz;


  // Interconnect Declarations
  wire din_rsc_lz_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst;
  wire [31:0] dout_0_rsc_data_in_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst;
  wire [13:0] dout_0_rsc_addr_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst;
  wire [1:0] dout_0_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst;
  wire dout_0_rsc_req_vz_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst;
  wire [31:0] dout_1_rsc_data_in_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst;
  wire [13:0] dout_1_rsc_addr_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst;
  wire [1:0] dout_1_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst;
  wire dout_1_rsc_req_vz_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst;
  wire [31:0] dout_2_rsc_data_in_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst;
  wire [13:0] dout_2_rsc_addr_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst;
  wire [1:0] dout_2_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst;
  wire dout_2_rsc_req_vz_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst;
  wire [31:0] dout_3_rsc_data_in_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst;
  wire [13:0] dout_3_rsc_addr_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst;
  wire [1:0] dout_3_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst;
  wire dout_3_rsc_req_vz_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst;
  wire [1:0] dout_1_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz;
  wire [1:0] dout_2_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz;
  wire [1:0] dout_3_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz;
  wire [13:0] din_0_rsc_addr_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst;
  wire [1:0] din_0_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst;
  wire [31:0] din_0_rsc_data_out_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst;
  wire din_0_rsc_req_vz_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst;
  wire [13:0] din_1_rsc_addr_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst;
  wire [1:0] din_1_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst;
  wire [31:0] din_1_rsc_data_out_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst;
  wire din_1_rsc_req_vz_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst;
  wire [13:0] din_2_rsc_addr_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst;
  wire [1:0] din_2_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst;
  wire [31:0] din_2_rsc_data_out_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst;
  wire din_2_rsc_req_vz_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst;
  wire [13:0] din_3_rsc_addr_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst;
  wire [1:0] din_3_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst;
  wire [31:0] din_3_rsc_data_out_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst;
  wire din_3_rsc_req_vz_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst;
  wire [127:0] dout_rsc_z_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst;
  wire dout_rsc_lz_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst;
  wire [1:0] din_1_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz;
  wire [1:0] din_2_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz;
  wire [1:0] din_3_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz;
  wire din_rsc_lz_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_bud;
  wire dout_0_rsc_rls_lz_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_bud;
  wire din_0_rsc_rls_lz_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_bud;
  wire [1:0] dout_1_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_bud;
  wire dout_1_rsc_rls_lz_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_bud;
  wire [1:0] din_1_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_bud;
  wire din_1_rsc_rls_lz_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_bud;
  wire [1:0] dout_2_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_bud;
  wire dout_2_rsc_rls_lz_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_bud;
  wire [1:0] din_2_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_bud;
  wire din_2_rsc_rls_lz_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_bud;
  wire [1:0] dout_3_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_bud;
  wire dout_3_rsc_rls_lz_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_bud;
  wire [1:0] din_3_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_bud;
  wire din_3_rsc_rls_lz_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_bud;
  wire dout_rsc_lz_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_bud;
  wire shr_mem_0_cns_R0;
  wire shr_mem_0_cns_R1;
  wire [31:0] shr_mem_0_cns_data_in_shi0;
  wire [31:0] shr_mem_0_cns_data_in_shi1;
  wire [13:0] shr_mem_0_cns_addr_shi0;
  wire [13:0] shr_mem_0_cns_addr_shi1;
  wire [1:0] shr_mem_0_cns_re_shi0;
  wire [1:0] shr_mem_0_cns_re_shi1;
  wire [1:0] shr_mem_0_cns_we_shi0;
  wire [1:0] shr_mem_0_cns_we_shi1;
  wire [31:0] shr_mem_0_cns_data_out_sho0;
  wire [31:0] shr_mem_0_cns_data_out_sho1;
  wire shr_mem_1_cns_R0;
  wire shr_mem_1_cns_R1;
  wire [31:0] shr_mem_1_cns_data_in_shi0;
  wire [31:0] shr_mem_1_cns_data_in_shi1;
  wire [13:0] shr_mem_1_cns_addr_shi0;
  wire [13:0] shr_mem_1_cns_addr_shi1;
  wire [1:0] shr_mem_1_cns_re_shi0;
  wire [1:0] shr_mem_1_cns_re_shi1;
  wire [1:0] shr_mem_1_cns_we_shi0;
  wire [1:0] shr_mem_1_cns_we_shi1;
  wire [31:0] shr_mem_1_cns_data_out_sho0;
  wire [31:0] shr_mem_1_cns_data_out_sho1;
  wire shr_mem_2_cns_R0;
  wire shr_mem_2_cns_R1;
  wire [31:0] shr_mem_2_cns_data_in_shi0;
  wire [31:0] shr_mem_2_cns_data_in_shi1;
  wire [13:0] shr_mem_2_cns_addr_shi0;
  wire [13:0] shr_mem_2_cns_addr_shi1;
  wire [1:0] shr_mem_2_cns_re_shi0;
  wire [1:0] shr_mem_2_cns_re_shi1;
  wire [1:0] shr_mem_2_cns_we_shi0;
  wire [1:0] shr_mem_2_cns_we_shi1;
  wire [31:0] shr_mem_2_cns_data_out_sho0;
  wire [31:0] shr_mem_2_cns_data_out_sho1;
  wire shr_mem_3_cns_R0;
  wire shr_mem_3_cns_R1;
  wire [31:0] shr_mem_3_cns_data_in_shi0;
  wire [31:0] shr_mem_3_cns_data_in_shi1;
  wire [13:0] shr_mem_3_cns_addr_shi0;
  wire [13:0] shr_mem_3_cns_addr_shi1;
  wire [1:0] shr_mem_3_cns_re_shi0;
  wire [1:0] shr_mem_3_cns_re_shi1;
  wire [1:0] shr_mem_3_cns_we_shi0;
  wire [1:0] shr_mem_3_cns_we_shi1;
  wire [31:0] shr_mem_3_cns_data_out_sho0;
  wire [31:0] shr_mem_3_cns_data_out_sho1;
  wire shr_mem_0_cns_S1_iff;
  wire shr_mem_0_cns_S0_iff;
  wire shr_mem_1_cns_S1_iff;
  wire [1:0] din_1_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_iff;
  wire [1:0] din_1_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_bud_iff;
  wire [1:0] dout_1_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_iff;
  wire [1:0] dout_1_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_bud_iff;
  wire shr_mem_1_cns_S0_iff;
  wire shr_mem_2_cns_S1_iff;
  wire [1:0] din_2_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_iff;
  wire [1:0] din_2_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_bud_iff;
  wire [1:0] dout_2_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_iff;
  wire [1:0] dout_2_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_bud_iff;
  wire shr_mem_2_cns_S0_iff;
  wire shr_mem_3_cns_S1_iff;
  wire [1:0] din_3_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_iff;
  wire [1:0] din_3_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_bud_iff;
  wire [1:0] dout_3_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_iff;
  wire [1:0] dout_3_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_bud_iff;
  wire shr_mem_3_cns_S0_iff;
  wire shr_mem_0_cns_S0_dmo;
  wire shr_mem_0_cns_S1_dmo;
  wire shr_mem_1_cns_S0_dmo;
  wire shr_mem_1_cns_S1_dmo;
  wire shr_mem_2_cns_S0_dmo;
  wire shr_mem_2_cns_S1_dmo;
  wire shr_mem_3_cns_S0_dmo;
  wire shr_mem_3_cns_S1_dmo;


  // Interconnect Declarations for Component Instantiations 
  ram_sync_dualRW_be #(.ram_id(32'sd10),
  .words(32'sd72),
  .width(32'sd16),
  .addr_width(32'sd7),
  .a_reset_active(32'sd0),
  .s_reset_active(32'sd1),
  .enable_active(32'sd0),
  .re_active(32'sd0),
  .we_active(32'sd0),
  .num_byte_enables(32'sd1),
  .clock_edge(32'sd1),
  .no_of_RAM_dualRW_readwrite_port(32'sd2)) shr_mem_0_cns_comp (
      .data_in(shr_mem_0_cns_data_in_shi0),
      .addr(shr_mem_0_cns_addr_shi0),
      .re(shr_mem_0_cns_re_shi0),
      .we(shr_mem_0_cns_we_shi0),
      .data_out(shr_mem_0_cns_data_out_sho0),
      .clk(clk),
      .a_rst(1'b1),
      .s_rst(rst),
      .en(1'b0)
    );
  ram_sync_dualRW_be #(.ram_id(32'sd10),
  .words(32'sd72),
  .width(32'sd16),
  .addr_width(32'sd7),
  .a_reset_active(32'sd0),
  .s_reset_active(32'sd1),
  .enable_active(32'sd0),
  .re_active(32'sd0),
  .we_active(32'sd0),
  .num_byte_enables(32'sd1),
  .clock_edge(32'sd1),
  .no_of_RAM_dualRW_readwrite_port(32'sd2)) shr_mem_0_cns_comp_1 (
      .data_in(shr_mem_0_cns_data_in_shi1),
      .addr(shr_mem_0_cns_addr_shi1),
      .re(shr_mem_0_cns_re_shi1),
      .we(shr_mem_0_cns_we_shi1),
      .data_out(shr_mem_0_cns_data_out_sho1),
      .clk(clk),
      .a_rst(1'b1),
      .s_rst(rst),
      .en(1'b0)
    );
  ram_sync_dualRW_be #(.ram_id(32'sd11),
  .words(32'sd72),
  .width(32'sd16),
  .addr_width(32'sd7),
  .a_reset_active(32'sd0),
  .s_reset_active(32'sd1),
  .enable_active(32'sd0),
  .re_active(32'sd0),
  .we_active(32'sd0),
  .num_byte_enables(32'sd1),
  .clock_edge(32'sd1),
  .no_of_RAM_dualRW_readwrite_port(32'sd2)) shr_mem_1_cns_comp (
      .data_in(shr_mem_1_cns_data_in_shi0),
      .addr(shr_mem_1_cns_addr_shi0),
      .re(shr_mem_1_cns_re_shi0),
      .we(shr_mem_1_cns_we_shi0),
      .data_out(shr_mem_1_cns_data_out_sho0),
      .clk(clk),
      .a_rst(1'b1),
      .s_rst(rst),
      .en(1'b0)
    );
  ram_sync_dualRW_be #(.ram_id(32'sd11),
  .words(32'sd72),
  .width(32'sd16),
  .addr_width(32'sd7),
  .a_reset_active(32'sd0),
  .s_reset_active(32'sd1),
  .enable_active(32'sd0),
  .re_active(32'sd0),
  .we_active(32'sd0),
  .num_byte_enables(32'sd1),
  .clock_edge(32'sd1),
  .no_of_RAM_dualRW_readwrite_port(32'sd2)) shr_mem_1_cns_comp_1 (
      .data_in(shr_mem_1_cns_data_in_shi1),
      .addr(shr_mem_1_cns_addr_shi1),
      .re(shr_mem_1_cns_re_shi1),
      .we(shr_mem_1_cns_we_shi1),
      .data_out(shr_mem_1_cns_data_out_sho1),
      .clk(clk),
      .a_rst(1'b1),
      .s_rst(rst),
      .en(1'b0)
    );
  ram_sync_dualRW_be #(.ram_id(32'sd12),
  .words(32'sd72),
  .width(32'sd16),
  .addr_width(32'sd7),
  .a_reset_active(32'sd0),
  .s_reset_active(32'sd1),
  .enable_active(32'sd0),
  .re_active(32'sd0),
  .we_active(32'sd0),
  .num_byte_enables(32'sd1),
  .clock_edge(32'sd1),
  .no_of_RAM_dualRW_readwrite_port(32'sd2)) shr_mem_2_cns_comp (
      .data_in(shr_mem_2_cns_data_in_shi0),
      .addr(shr_mem_2_cns_addr_shi0),
      .re(shr_mem_2_cns_re_shi0),
      .we(shr_mem_2_cns_we_shi0),
      .data_out(shr_mem_2_cns_data_out_sho0),
      .clk(clk),
      .a_rst(1'b1),
      .s_rst(rst),
      .en(1'b0)
    );
  ram_sync_dualRW_be #(.ram_id(32'sd12),
  .words(32'sd72),
  .width(32'sd16),
  .addr_width(32'sd7),
  .a_reset_active(32'sd0),
  .s_reset_active(32'sd1),
  .enable_active(32'sd0),
  .re_active(32'sd0),
  .we_active(32'sd0),
  .num_byte_enables(32'sd1),
  .clock_edge(32'sd1),
  .no_of_RAM_dualRW_readwrite_port(32'sd2)) shr_mem_2_cns_comp_1 (
      .data_in(shr_mem_2_cns_data_in_shi1),
      .addr(shr_mem_2_cns_addr_shi1),
      .re(shr_mem_2_cns_re_shi1),
      .we(shr_mem_2_cns_we_shi1),
      .data_out(shr_mem_2_cns_data_out_sho1),
      .clk(clk),
      .a_rst(1'b1),
      .s_rst(rst),
      .en(1'b0)
    );
  ram_sync_dualRW_be #(.ram_id(32'sd13),
  .words(32'sd72),
  .width(32'sd16),
  .addr_width(32'sd7),
  .a_reset_active(32'sd0),
  .s_reset_active(32'sd1),
  .enable_active(32'sd0),
  .re_active(32'sd0),
  .we_active(32'sd0),
  .num_byte_enables(32'sd1),
  .clock_edge(32'sd1),
  .no_of_RAM_dualRW_readwrite_port(32'sd2)) shr_mem_3_cns_comp (
      .data_in(shr_mem_3_cns_data_in_shi0),
      .addr(shr_mem_3_cns_addr_shi0),
      .re(shr_mem_3_cns_re_shi0),
      .we(shr_mem_3_cns_we_shi0),
      .data_out(shr_mem_3_cns_data_out_sho0),
      .clk(clk),
      .a_rst(1'b1),
      .s_rst(rst),
      .en(1'b0)
    );
  ram_sync_dualRW_be #(.ram_id(32'sd13),
  .words(32'sd72),
  .width(32'sd16),
  .addr_width(32'sd7),
  .a_reset_active(32'sd0),
  .s_reset_active(32'sd1),
  .enable_active(32'sd0),
  .re_active(32'sd0),
  .we_active(32'sd0),
  .num_byte_enables(32'sd1),
  .clock_edge(32'sd1),
  .no_of_RAM_dualRW_readwrite_port(32'sd2)) shr_mem_3_cns_comp_1 (
      .data_in(shr_mem_3_cns_data_in_shi1),
      .addr(shr_mem_3_cns_addr_shi1),
      .re(shr_mem_3_cns_re_shi1),
      .we(shr_mem_3_cns_we_shi1),
      .data_out(shr_mem_3_cns_data_out_sho1),
      .clk(clk),
      .a_rst(1'b1),
      .s_rst(rst),
      .en(1'b0)
    );
  WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_1 WRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst (
      .clk(clk),
      .rst(rst),
      .din_rsc_z(din_rsc_z),
      .din_rsc_vz(din_rsc_vz),
      .din_rsc_lz(din_rsc_lz_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_bud),
      .dout_0_rsc_data_in(dout_0_rsc_data_in_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst),
      .dout_0_rsc_addr(dout_0_rsc_addr_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst),
      .dout_0_rsc_we(dout_0_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst),
      .dout_0_rsc_req_vz(dout_0_rsc_req_vz_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst),
      .dout_0_rsc_rls_lz(dout_0_rsc_rls_lz_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_bud),
      .dout_1_rsc_data_in(dout_1_rsc_data_in_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst),
      .dout_1_rsc_addr(dout_1_rsc_addr_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst),
      .dout_1_rsc_we(dout_1_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst),
      .dout_1_rsc_req_vz(dout_1_rsc_req_vz_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst),
      .dout_1_rsc_rls_lz(dout_1_rsc_rls_lz_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_bud),
      .dout_2_rsc_data_in(dout_2_rsc_data_in_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst),
      .dout_2_rsc_addr(dout_2_rsc_addr_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst),
      .dout_2_rsc_we(dout_2_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst),
      .dout_2_rsc_req_vz(dout_2_rsc_req_vz_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst),
      .dout_2_rsc_rls_lz(dout_2_rsc_rls_lz_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_bud),
      .dout_3_rsc_data_in(dout_3_rsc_data_in_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst),
      .dout_3_rsc_addr(dout_3_rsc_addr_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst),
      .dout_3_rsc_we(dout_3_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst),
      .dout_3_rsc_req_vz(dout_3_rsc_req_vz_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst),
      .dout_3_rsc_rls_lz(dout_3_rsc_rls_lz_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_bud)
    );
  READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_1 READ_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst (
      .clk(clk),
      .rst(rst),
      .din_0_rsc_addr(din_0_rsc_addr_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst),
      .din_0_rsc_re(din_0_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst),
      .din_0_rsc_data_out(din_0_rsc_data_out_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst),
      .din_0_rsc_req_vz(din_0_rsc_req_vz_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst),
      .din_0_rsc_rls_lz(din_0_rsc_rls_lz_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_bud),
      .din_1_rsc_addr(din_1_rsc_addr_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst),
      .din_1_rsc_re(din_1_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst),
      .din_1_rsc_data_out(din_1_rsc_data_out_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst),
      .din_1_rsc_req_vz(din_1_rsc_req_vz_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst),
      .din_1_rsc_rls_lz(din_1_rsc_rls_lz_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_bud),
      .din_2_rsc_addr(din_2_rsc_addr_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst),
      .din_2_rsc_re(din_2_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst),
      .din_2_rsc_data_out(din_2_rsc_data_out_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst),
      .din_2_rsc_req_vz(din_2_rsc_req_vz_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst),
      .din_2_rsc_rls_lz(din_2_rsc_rls_lz_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_bud),
      .din_3_rsc_addr(din_3_rsc_addr_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst),
      .din_3_rsc_re(din_3_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst),
      .din_3_rsc_data_out(din_3_rsc_data_out_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst),
      .din_3_rsc_req_vz(din_3_rsc_req_vz_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst),
      .din_3_rsc_rls_lz(din_3_rsc_rls_lz_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_bud),
      .dout_rsc_z(dout_rsc_z_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst),
      .dout_rsc_vz(dout_rsc_vz),
      .dout_rsc_lz(dout_rsc_lz_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_bud)
    );
  unreg_hier_15 unreg (
      .in_0(shr_mem_0_cns_S0_iff),
      .out_0(shr_mem_0_cns_R0)
    );
  unreg_hier_15 unreg_1 (
      .in_0(shr_mem_0_cns_S1_iff),
      .out_0(shr_mem_0_cns_R1)
    );
  unreg_hier_15 unreg_2 (
      .in_0(shr_mem_1_cns_S0_iff),
      .out_0(shr_mem_1_cns_R0)
    );
  unreg_hier_15 unreg_3 (
      .in_0(shr_mem_1_cns_S1_iff),
      .out_0(shr_mem_1_cns_R1)
    );
  unreg_hier_15 unreg_4 (
      .in_0(shr_mem_2_cns_S0_iff),
      .out_0(shr_mem_2_cns_R0)
    );
  unreg_hier_15 unreg_5 (
      .in_0(shr_mem_2_cns_S1_iff),
      .out_0(shr_mem_2_cns_R1)
    );
  unreg_hier_15 unreg_6 (
      .in_0(shr_mem_3_cns_S0_iff),
      .out_0(shr_mem_3_cns_R0)
    );
  unreg_hier_15 unreg_7 (
      .in_0(shr_mem_3_cns_S1_iff),
      .out_0(shr_mem_3_cns_R1)
    );
  double_buffetmobz_0_cns_bctl double_buffetmobz_0_cns_bctl_inst (
      .clk(clk),
      .rst(rst),
      .din_rsc_lz_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst(din_rsc_lz_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst),
      .dout_0_rsc_data_in_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst(dout_0_rsc_data_in_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst),
      .dout_0_rsc_addr_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst(dout_0_rsc_addr_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst),
      .dout_0_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst(dout_0_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst),
      .dout_0_rsc_req_vz_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst(dout_0_rsc_req_vz_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst),
      .dout_1_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz(dout_1_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz),
      .dout_2_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz(dout_2_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz),
      .dout_3_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz(dout_3_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz),
      .din_0_rsc_addr_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst(din_0_rsc_addr_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst),
      .din_0_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst(din_0_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst),
      .din_0_rsc_data_out_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst(din_0_rsc_data_out_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst),
      .din_0_rsc_req_vz_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst(din_0_rsc_req_vz_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst),
      .dout_rsc_lz_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst(dout_rsc_lz_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst),
      .din_1_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz(din_1_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz),
      .din_2_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz(din_2_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz),
      .din_3_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz(din_3_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz),
      .din_rsc_lz_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_bud(din_rsc_lz_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_bud),
      .dout_0_rsc_rls_lz_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_bud(dout_0_rsc_rls_lz_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_bud),
      .din_0_rsc_rls_lz_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_bud(din_0_rsc_rls_lz_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_bud),
      .dout_1_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_bud(dout_1_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_bud),
      .dout_1_rsc_rls_lz_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_bud(1'b0),
      .din_1_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_bud(din_1_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_bud),
      .din_1_rsc_rls_lz_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_bud(1'b0),
      .dout_2_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_bud(dout_2_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_bud),
      .dout_2_rsc_rls_lz_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_bud(1'b0),
      .din_2_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_bud(din_2_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_bud),
      .din_2_rsc_rls_lz_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_bud(1'b0),
      .dout_3_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_bud(dout_3_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_bud),
      .dout_3_rsc_rls_lz_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_bud(1'b0),
      .din_3_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_bud(din_3_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_bud),
      .din_3_rsc_rls_lz_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_bud(1'b0),
      .dout_rsc_lz_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_bud(dout_rsc_lz_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_bud),
      .shr_mem_0_cns_S0(shr_mem_0_cns_S0_dmo),
      .shr_mem_0_cns_R0(shr_mem_0_cns_R0),
      .shr_mem_0_cns_S1(shr_mem_0_cns_S1_dmo),
      .shr_mem_0_cns_R1(shr_mem_0_cns_R1),
      .shr_mem_0_cns_data_in_shi0(shr_mem_0_cns_data_in_shi0),
      .shr_mem_0_cns_data_in_shi1(shr_mem_0_cns_data_in_shi1),
      .shr_mem_0_cns_addr_shi0(shr_mem_0_cns_addr_shi0),
      .shr_mem_0_cns_addr_shi1(shr_mem_0_cns_addr_shi1),
      .shr_mem_0_cns_re_shi0(shr_mem_0_cns_re_shi0),
      .shr_mem_0_cns_re_shi1(shr_mem_0_cns_re_shi1),
      .shr_mem_0_cns_we_shi0(shr_mem_0_cns_we_shi0),
      .shr_mem_0_cns_we_shi1(shr_mem_0_cns_we_shi1),
      .shr_mem_0_cns_data_out_sho0(shr_mem_0_cns_data_out_sho0),
      .shr_mem_0_cns_data_out_sho1(shr_mem_0_cns_data_out_sho1),
      .shr_mem_0_cns_S1_pff(shr_mem_0_cns_S1_iff),
      .shr_mem_0_cns_S0_pff(shr_mem_0_cns_S0_iff),
      .din_1_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_pff(din_1_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_iff),
      .din_1_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_bud_pff(din_1_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_bud_iff),
      .dout_1_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_pff(dout_1_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_iff),
      .dout_1_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_bud_pff(dout_1_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_bud_iff),
      .din_2_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_pff(din_2_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_iff),
      .din_2_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_bud_pff(din_2_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_bud_iff),
      .dout_2_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_pff(dout_2_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_iff),
      .dout_2_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_bud_pff(dout_2_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_bud_iff),
      .din_3_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_pff(din_3_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_iff),
      .din_3_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_bud_pff(din_3_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_bud_iff),
      .dout_3_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_pff(dout_3_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_iff),
      .dout_3_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_bud_pff(dout_3_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_bud_iff)
    );
  double_buffetmobz_1_cns_bctl double_buffetmobz_1_cns_bctl_inst (
      .clk(clk),
      .rst(rst),
      .dout_1_rsc_data_in_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst(dout_1_rsc_data_in_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst),
      .dout_1_rsc_addr_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst(dout_1_rsc_addr_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst),
      .dout_1_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst(dout_1_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst),
      .dout_1_rsc_req_vz_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst(dout_1_rsc_req_vz_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst),
      .dout_1_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz(2'b0),
      .din_1_rsc_addr_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst(din_1_rsc_addr_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst),
      .din_1_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst(din_1_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst),
      .din_1_rsc_data_out_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst(din_1_rsc_data_out_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst),
      .din_1_rsc_req_vz_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst(din_1_rsc_req_vz_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst),
      .din_1_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz(2'b0),
      .dout_1_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_bud(dout_1_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_bud),
      .dout_1_rsc_rls_lz_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_bud(dout_1_rsc_rls_lz_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_bud),
      .din_1_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_bud(din_1_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_bud),
      .din_1_rsc_rls_lz_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_bud(din_1_rsc_rls_lz_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_bud),
      .shr_mem_1_cns_S0(shr_mem_1_cns_S0_dmo),
      .shr_mem_1_cns_R0(shr_mem_1_cns_R0),
      .shr_mem_1_cns_S1(shr_mem_1_cns_S1_dmo),
      .shr_mem_1_cns_R1(shr_mem_1_cns_R1),
      .shr_mem_1_cns_data_in_shi0(shr_mem_1_cns_data_in_shi0),
      .shr_mem_1_cns_data_in_shi1(shr_mem_1_cns_data_in_shi1),
      .shr_mem_1_cns_addr_shi0(shr_mem_1_cns_addr_shi0),
      .shr_mem_1_cns_addr_shi1(shr_mem_1_cns_addr_shi1),
      .shr_mem_1_cns_re_shi0(shr_mem_1_cns_re_shi0),
      .shr_mem_1_cns_re_shi1(shr_mem_1_cns_re_shi1),
      .shr_mem_1_cns_we_shi0(shr_mem_1_cns_we_shi0),
      .shr_mem_1_cns_we_shi1(shr_mem_1_cns_we_shi1),
      .shr_mem_1_cns_data_out_sho0(shr_mem_1_cns_data_out_sho0),
      .shr_mem_1_cns_data_out_sho1(shr_mem_1_cns_data_out_sho1),
      .shr_mem_1_cns_S1_pff(shr_mem_1_cns_S1_iff),
      .din_1_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_pff(din_1_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_iff),
      .din_1_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_bud_pff(din_1_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_bud_iff),
      .dout_1_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_pff(dout_1_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_iff),
      .dout_1_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_bud_pff(dout_1_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_bud_iff),
      .shr_mem_1_cns_S0_pff(shr_mem_1_cns_S0_iff)
    );
  double_buffetmobz_2_cns_bctl double_buffetmobz_2_cns_bctl_inst (
      .clk(clk),
      .rst(rst),
      .dout_2_rsc_data_in_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst(dout_2_rsc_data_in_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst),
      .dout_2_rsc_addr_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst(dout_2_rsc_addr_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst),
      .dout_2_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst(dout_2_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst),
      .dout_2_rsc_req_vz_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst(dout_2_rsc_req_vz_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst),
      .dout_2_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz(2'b0),
      .din_2_rsc_addr_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst(din_2_rsc_addr_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst),
      .din_2_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst(din_2_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst),
      .din_2_rsc_data_out_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst(din_2_rsc_data_out_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst),
      .din_2_rsc_req_vz_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst(din_2_rsc_req_vz_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst),
      .din_2_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz(2'b0),
      .dout_2_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_bud(dout_2_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_bud),
      .dout_2_rsc_rls_lz_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_bud(dout_2_rsc_rls_lz_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_bud),
      .din_2_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_bud(din_2_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_bud),
      .din_2_rsc_rls_lz_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_bud(din_2_rsc_rls_lz_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_bud),
      .shr_mem_2_cns_S0(shr_mem_2_cns_S0_dmo),
      .shr_mem_2_cns_R0(shr_mem_2_cns_R0),
      .shr_mem_2_cns_S1(shr_mem_2_cns_S1_dmo),
      .shr_mem_2_cns_R1(shr_mem_2_cns_R1),
      .shr_mem_2_cns_data_in_shi0(shr_mem_2_cns_data_in_shi0),
      .shr_mem_2_cns_data_in_shi1(shr_mem_2_cns_data_in_shi1),
      .shr_mem_2_cns_addr_shi0(shr_mem_2_cns_addr_shi0),
      .shr_mem_2_cns_addr_shi1(shr_mem_2_cns_addr_shi1),
      .shr_mem_2_cns_re_shi0(shr_mem_2_cns_re_shi0),
      .shr_mem_2_cns_re_shi1(shr_mem_2_cns_re_shi1),
      .shr_mem_2_cns_we_shi0(shr_mem_2_cns_we_shi0),
      .shr_mem_2_cns_we_shi1(shr_mem_2_cns_we_shi1),
      .shr_mem_2_cns_data_out_sho0(shr_mem_2_cns_data_out_sho0),
      .shr_mem_2_cns_data_out_sho1(shr_mem_2_cns_data_out_sho1),
      .shr_mem_2_cns_S1_pff(shr_mem_2_cns_S1_iff),
      .din_2_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_pff(din_2_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_iff),
      .din_2_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_bud_pff(din_2_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_bud_iff),
      .dout_2_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_pff(dout_2_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_iff),
      .dout_2_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_bud_pff(dout_2_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_bud_iff),
      .shr_mem_2_cns_S0_pff(shr_mem_2_cns_S0_iff)
    );
  double_buffetmobz_3_cns_bctl double_buffetmobz_3_cns_bctl_inst (
      .clk(clk),
      .rst(rst),
      .dout_3_rsc_data_in_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst(dout_3_rsc_data_in_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst),
      .dout_3_rsc_addr_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst(dout_3_rsc_addr_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst),
      .dout_3_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst(dout_3_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst),
      .dout_3_rsc_req_vz_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst(dout_3_rsc_req_vz_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst),
      .dout_3_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz(2'b0),
      .din_3_rsc_addr_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst(din_3_rsc_addr_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst),
      .din_3_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst(din_3_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst),
      .din_3_rsc_data_out_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst(din_3_rsc_data_out_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst),
      .din_3_rsc_req_vz_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst(din_3_rsc_req_vz_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst),
      .din_3_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz(2'b0),
      .dout_3_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_bud(dout_3_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_bud),
      .dout_3_rsc_rls_lz_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_bud(dout_3_rsc_rls_lz_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_bud),
      .din_3_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_bud(din_3_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_bud),
      .din_3_rsc_rls_lz_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_bud(din_3_rsc_rls_lz_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_bud),
      .shr_mem_3_cns_S0(shr_mem_3_cns_S0_dmo),
      .shr_mem_3_cns_R0(shr_mem_3_cns_R0),
      .shr_mem_3_cns_S1(shr_mem_3_cns_S1_dmo),
      .shr_mem_3_cns_R1(shr_mem_3_cns_R1),
      .shr_mem_3_cns_data_in_shi0(shr_mem_3_cns_data_in_shi0),
      .shr_mem_3_cns_data_in_shi1(shr_mem_3_cns_data_in_shi1),
      .shr_mem_3_cns_addr_shi0(shr_mem_3_cns_addr_shi0),
      .shr_mem_3_cns_addr_shi1(shr_mem_3_cns_addr_shi1),
      .shr_mem_3_cns_re_shi0(shr_mem_3_cns_re_shi0),
      .shr_mem_3_cns_re_shi1(shr_mem_3_cns_re_shi1),
      .shr_mem_3_cns_we_shi0(shr_mem_3_cns_we_shi0),
      .shr_mem_3_cns_we_shi1(shr_mem_3_cns_we_shi1),
      .shr_mem_3_cns_data_out_sho0(shr_mem_3_cns_data_out_sho0),
      .shr_mem_3_cns_data_out_sho1(shr_mem_3_cns_data_out_sho1),
      .shr_mem_3_cns_S1_pff(shr_mem_3_cns_S1_iff),
      .din_3_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_pff(din_3_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_iff),
      .din_3_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_bud_pff(din_3_rsc_re_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst_buz_bud_iff),
      .dout_3_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_pff(dout_3_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_iff),
      .dout_3_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_bud_pff(dout_3_rsc_we_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst_buz_bud_iff),
      .shr_mem_3_cns_S0_pff(shr_mem_3_cns_S0_iff)
    );
  assign din_rsc_lz = din_rsc_lz_nWRITE_BLOCK_INPUT_DTYPE_4_36_2_3_inst;
  assign dout_rsc_lz = dout_rsc_lz_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst;
  assign dout_rsc_z = dout_rsc_z_nREAD_BLOCK_INPUT_DTYPE_4_4_4_2_2_3_inst;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    double_buffer_weights_DTYPE_2_4_16_4_2_2_3
// ------------------------------------------------------------------


module double_buffer_weights_DTYPE_2_4_16_4_2_2_3 (
  clk, rst, din_rsc_z, din_rsc_vz, din_rsc_lz, dout_rsc_z, dout_rsc_vz, dout_rsc_lz
);
  input clk;
  input rst;
  input [255:0] din_rsc_z;
  input din_rsc_vz;
  output din_rsc_lz;
  output [255:0] dout_rsc_z;
  input dout_rsc_vz;
  output dout_rsc_lz;


  // Interconnect Declarations
  wire din_rsc_lz_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst;
  wire [127:0] dout_0_rsc_data_in_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst;
  wire [15:0] dout_0_rsc_addr_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst;
  wire [1:0] dout_0_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst;
  wire dout_0_rsc_req_vz_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst;
  wire [127:0] dout_1_rsc_data_in_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst;
  wire [15:0] dout_1_rsc_addr_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst;
  wire [1:0] dout_1_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst;
  wire dout_1_rsc_req_vz_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst;
  wire [127:0] dout_2_rsc_data_in_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst;
  wire [15:0] dout_2_rsc_addr_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst;
  wire [1:0] dout_2_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst;
  wire dout_2_rsc_req_vz_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst;
  wire [127:0] dout_3_rsc_data_in_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst;
  wire [15:0] dout_3_rsc_addr_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst;
  wire [1:0] dout_3_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst;
  wire dout_3_rsc_req_vz_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst;
  wire [1:0] dout_1_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz;
  wire [1:0] dout_2_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz;
  wire [1:0] dout_3_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz;
  wire [15:0] din_0_rsc_addr_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst;
  wire [1:0] din_0_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst;
  wire [127:0] din_0_rsc_data_out_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst;
  wire din_0_rsc_req_vz_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst;
  wire [15:0] din_1_rsc_addr_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst;
  wire [1:0] din_1_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst;
  wire [127:0] din_1_rsc_data_out_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst;
  wire din_1_rsc_req_vz_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst;
  wire [15:0] din_2_rsc_addr_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst;
  wire [1:0] din_2_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst;
  wire [127:0] din_2_rsc_data_out_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst;
  wire din_2_rsc_req_vz_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst;
  wire [15:0] din_3_rsc_addr_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst;
  wire [1:0] din_3_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst;
  wire [127:0] din_3_rsc_data_out_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst;
  wire din_3_rsc_req_vz_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst;
  wire [255:0] dout_rsc_z_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst;
  wire dout_rsc_lz_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst;
  wire [1:0] din_1_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz;
  wire [1:0] din_2_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz;
  wire [1:0] din_3_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz;
  wire din_rsc_lz_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_bud;
  wire dout_0_rsc_rls_lz_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_bud;
  wire din_0_rsc_rls_lz_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_bud;
  wire [1:0] dout_1_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_bud;
  wire dout_1_rsc_rls_lz_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_bud;
  wire [1:0] din_1_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_bud;
  wire din_1_rsc_rls_lz_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_bud;
  wire [1:0] dout_2_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_bud;
  wire dout_2_rsc_rls_lz_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_bud;
  wire [1:0] din_2_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_bud;
  wire din_2_rsc_rls_lz_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_bud;
  wire [1:0] dout_3_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_bud;
  wire dout_3_rsc_rls_lz_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_bud;
  wire [1:0] din_3_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_bud;
  wire din_3_rsc_rls_lz_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_bud;
  wire dout_rsc_lz_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_bud;
  wire shr_mem_0_cns_R0;
  wire shr_mem_0_cns_R1;
  wire [127:0] shr_mem_0_cns_data_in_shi0;
  wire [127:0] shr_mem_0_cns_data_in_shi1;
  wire [15:0] shr_mem_0_cns_addr_shi0;
  wire [15:0] shr_mem_0_cns_addr_shi1;
  wire [1:0] shr_mem_0_cns_re_shi0;
  wire [1:0] shr_mem_0_cns_re_shi1;
  wire [1:0] shr_mem_0_cns_we_shi0;
  wire [1:0] shr_mem_0_cns_we_shi1;
  wire [127:0] shr_mem_0_cns_data_out_sho0;
  wire [127:0] shr_mem_0_cns_data_out_sho1;
  wire shr_mem_1_cns_R0;
  wire shr_mem_1_cns_R1;
  wire [127:0] shr_mem_1_cns_data_in_shi0;
  wire [127:0] shr_mem_1_cns_data_in_shi1;
  wire [15:0] shr_mem_1_cns_addr_shi0;
  wire [15:0] shr_mem_1_cns_addr_shi1;
  wire [1:0] shr_mem_1_cns_re_shi0;
  wire [1:0] shr_mem_1_cns_re_shi1;
  wire [1:0] shr_mem_1_cns_we_shi0;
  wire [1:0] shr_mem_1_cns_we_shi1;
  wire [127:0] shr_mem_1_cns_data_out_sho0;
  wire [127:0] shr_mem_1_cns_data_out_sho1;
  wire shr_mem_2_cns_R0;
  wire shr_mem_2_cns_R1;
  wire [127:0] shr_mem_2_cns_data_in_shi0;
  wire [127:0] shr_mem_2_cns_data_in_shi1;
  wire [15:0] shr_mem_2_cns_addr_shi0;
  wire [15:0] shr_mem_2_cns_addr_shi1;
  wire [1:0] shr_mem_2_cns_re_shi0;
  wire [1:0] shr_mem_2_cns_re_shi1;
  wire [1:0] shr_mem_2_cns_we_shi0;
  wire [1:0] shr_mem_2_cns_we_shi1;
  wire [127:0] shr_mem_2_cns_data_out_sho0;
  wire [127:0] shr_mem_2_cns_data_out_sho1;
  wire shr_mem_3_cns_R0;
  wire shr_mem_3_cns_R1;
  wire [127:0] shr_mem_3_cns_data_in_shi0;
  wire [127:0] shr_mem_3_cns_data_in_shi1;
  wire [15:0] shr_mem_3_cns_addr_shi0;
  wire [15:0] shr_mem_3_cns_addr_shi1;
  wire [1:0] shr_mem_3_cns_re_shi0;
  wire [1:0] shr_mem_3_cns_re_shi1;
  wire [1:0] shr_mem_3_cns_we_shi0;
  wire [1:0] shr_mem_3_cns_we_shi1;
  wire [127:0] shr_mem_3_cns_data_out_sho0;
  wire [127:0] shr_mem_3_cns_data_out_sho1;
  wire shr_mem_0_cns_S1_iff;
  wire shr_mem_0_cns_S0_iff;
  wire shr_mem_1_cns_S1_iff;
  wire [1:0] din_1_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_iff;
  wire [1:0] din_1_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_bud_iff;
  wire [1:0] dout_1_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_iff;
  wire [1:0] dout_1_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_bud_iff;
  wire shr_mem_1_cns_S0_iff;
  wire shr_mem_2_cns_S1_iff;
  wire [1:0] din_2_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_iff;
  wire [1:0] din_2_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_bud_iff;
  wire [1:0] dout_2_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_iff;
  wire [1:0] dout_2_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_bud_iff;
  wire shr_mem_2_cns_S0_iff;
  wire shr_mem_3_cns_S1_iff;
  wire [1:0] din_3_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_iff;
  wire [1:0] din_3_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_bud_iff;
  wire [1:0] dout_3_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_iff;
  wire [1:0] dout_3_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_bud_iff;
  wire shr_mem_3_cns_S0_iff;
  wire shr_mem_0_cns_S0_dmo;
  wire shr_mem_0_cns_S1_dmo;
  wire shr_mem_1_cns_S0_dmo;
  wire shr_mem_1_cns_S1_dmo;
  wire shr_mem_2_cns_S0_dmo;
  wire shr_mem_2_cns_S1_dmo;
  wire shr_mem_3_cns_S0_dmo;
  wire shr_mem_3_cns_S1_dmo;


  // Interconnect Declarations for Component Instantiations 
  ram_sync_dualRW_be #(.ram_id(32'sd34),
  .words(32'sd144),
  .width(32'sd64),
  .addr_width(32'sd8),
  .a_reset_active(32'sd0),
  .s_reset_active(32'sd1),
  .enable_active(32'sd0),
  .re_active(32'sd0),
  .we_active(32'sd0),
  .num_byte_enables(32'sd1),
  .clock_edge(32'sd1),
  .no_of_RAM_dualRW_readwrite_port(32'sd2)) shr_mem_0_cns_comp (
      .data_in(shr_mem_0_cns_data_in_shi0),
      .addr(shr_mem_0_cns_addr_shi0),
      .re(shr_mem_0_cns_re_shi0),
      .we(shr_mem_0_cns_we_shi0),
      .data_out(shr_mem_0_cns_data_out_sho0),
      .clk(clk),
      .a_rst(1'b1),
      .s_rst(rst),
      .en(1'b0)
    );
  ram_sync_dualRW_be #(.ram_id(32'sd34),
  .words(32'sd144),
  .width(32'sd64),
  .addr_width(32'sd8),
  .a_reset_active(32'sd0),
  .s_reset_active(32'sd1),
  .enable_active(32'sd0),
  .re_active(32'sd0),
  .we_active(32'sd0),
  .num_byte_enables(32'sd1),
  .clock_edge(32'sd1),
  .no_of_RAM_dualRW_readwrite_port(32'sd2)) shr_mem_0_cns_comp_1 (
      .data_in(shr_mem_0_cns_data_in_shi1),
      .addr(shr_mem_0_cns_addr_shi1),
      .re(shr_mem_0_cns_re_shi1),
      .we(shr_mem_0_cns_we_shi1),
      .data_out(shr_mem_0_cns_data_out_sho1),
      .clk(clk),
      .a_rst(1'b1),
      .s_rst(rst),
      .en(1'b0)
    );
  ram_sync_dualRW_be #(.ram_id(32'sd35),
  .words(32'sd144),
  .width(32'sd64),
  .addr_width(32'sd8),
  .a_reset_active(32'sd0),
  .s_reset_active(32'sd1),
  .enable_active(32'sd0),
  .re_active(32'sd0),
  .we_active(32'sd0),
  .num_byte_enables(32'sd1),
  .clock_edge(32'sd1),
  .no_of_RAM_dualRW_readwrite_port(32'sd2)) shr_mem_1_cns_comp (
      .data_in(shr_mem_1_cns_data_in_shi0),
      .addr(shr_mem_1_cns_addr_shi0),
      .re(shr_mem_1_cns_re_shi0),
      .we(shr_mem_1_cns_we_shi0),
      .data_out(shr_mem_1_cns_data_out_sho0),
      .clk(clk),
      .a_rst(1'b1),
      .s_rst(rst),
      .en(1'b0)
    );
  ram_sync_dualRW_be #(.ram_id(32'sd35),
  .words(32'sd144),
  .width(32'sd64),
  .addr_width(32'sd8),
  .a_reset_active(32'sd0),
  .s_reset_active(32'sd1),
  .enable_active(32'sd0),
  .re_active(32'sd0),
  .we_active(32'sd0),
  .num_byte_enables(32'sd1),
  .clock_edge(32'sd1),
  .no_of_RAM_dualRW_readwrite_port(32'sd2)) shr_mem_1_cns_comp_1 (
      .data_in(shr_mem_1_cns_data_in_shi1),
      .addr(shr_mem_1_cns_addr_shi1),
      .re(shr_mem_1_cns_re_shi1),
      .we(shr_mem_1_cns_we_shi1),
      .data_out(shr_mem_1_cns_data_out_sho1),
      .clk(clk),
      .a_rst(1'b1),
      .s_rst(rst),
      .en(1'b0)
    );
  ram_sync_dualRW_be #(.ram_id(32'sd36),
  .words(32'sd144),
  .width(32'sd64),
  .addr_width(32'sd8),
  .a_reset_active(32'sd0),
  .s_reset_active(32'sd1),
  .enable_active(32'sd0),
  .re_active(32'sd0),
  .we_active(32'sd0),
  .num_byte_enables(32'sd1),
  .clock_edge(32'sd1),
  .no_of_RAM_dualRW_readwrite_port(32'sd2)) shr_mem_2_cns_comp (
      .data_in(shr_mem_2_cns_data_in_shi0),
      .addr(shr_mem_2_cns_addr_shi0),
      .re(shr_mem_2_cns_re_shi0),
      .we(shr_mem_2_cns_we_shi0),
      .data_out(shr_mem_2_cns_data_out_sho0),
      .clk(clk),
      .a_rst(1'b1),
      .s_rst(rst),
      .en(1'b0)
    );
  ram_sync_dualRW_be #(.ram_id(32'sd36),
  .words(32'sd144),
  .width(32'sd64),
  .addr_width(32'sd8),
  .a_reset_active(32'sd0),
  .s_reset_active(32'sd1),
  .enable_active(32'sd0),
  .re_active(32'sd0),
  .we_active(32'sd0),
  .num_byte_enables(32'sd1),
  .clock_edge(32'sd1),
  .no_of_RAM_dualRW_readwrite_port(32'sd2)) shr_mem_2_cns_comp_1 (
      .data_in(shr_mem_2_cns_data_in_shi1),
      .addr(shr_mem_2_cns_addr_shi1),
      .re(shr_mem_2_cns_re_shi1),
      .we(shr_mem_2_cns_we_shi1),
      .data_out(shr_mem_2_cns_data_out_sho1),
      .clk(clk),
      .a_rst(1'b1),
      .s_rst(rst),
      .en(1'b0)
    );
  ram_sync_dualRW_be #(.ram_id(32'sd37),
  .words(32'sd144),
  .width(32'sd64),
  .addr_width(32'sd8),
  .a_reset_active(32'sd0),
  .s_reset_active(32'sd1),
  .enable_active(32'sd0),
  .re_active(32'sd0),
  .we_active(32'sd0),
  .num_byte_enables(32'sd1),
  .clock_edge(32'sd1),
  .no_of_RAM_dualRW_readwrite_port(32'sd2)) shr_mem_3_cns_comp (
      .data_in(shr_mem_3_cns_data_in_shi0),
      .addr(shr_mem_3_cns_addr_shi0),
      .re(shr_mem_3_cns_re_shi0),
      .we(shr_mem_3_cns_we_shi0),
      .data_out(shr_mem_3_cns_data_out_sho0),
      .clk(clk),
      .a_rst(1'b1),
      .s_rst(rst),
      .en(1'b0)
    );
  ram_sync_dualRW_be #(.ram_id(32'sd37),
  .words(32'sd144),
  .width(32'sd64),
  .addr_width(32'sd8),
  .a_reset_active(32'sd0),
  .s_reset_active(32'sd1),
  .enable_active(32'sd0),
  .re_active(32'sd0),
  .we_active(32'sd0),
  .num_byte_enables(32'sd1),
  .clock_edge(32'sd1),
  .no_of_RAM_dualRW_readwrite_port(32'sd2)) shr_mem_3_cns_comp_1 (
      .data_in(shr_mem_3_cns_data_in_shi1),
      .addr(shr_mem_3_cns_addr_shi1),
      .re(shr_mem_3_cns_re_shi1),
      .we(shr_mem_3_cns_we_shi1),
      .data_out(shr_mem_3_cns_data_out_sho1),
      .clk(clk),
      .a_rst(1'b1),
      .s_rst(rst),
      .en(1'b0)
    );
  WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_1 WRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst
      (
      .clk(clk),
      .rst(rst),
      .din_rsc_z(din_rsc_z),
      .din_rsc_vz(din_rsc_vz),
      .din_rsc_lz(din_rsc_lz_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_bud),
      .dout_0_rsc_data_in(dout_0_rsc_data_in_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst),
      .dout_0_rsc_addr(dout_0_rsc_addr_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst),
      .dout_0_rsc_we(dout_0_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst),
      .dout_0_rsc_req_vz(dout_0_rsc_req_vz_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst),
      .dout_0_rsc_rls_lz(dout_0_rsc_rls_lz_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_bud),
      .dout_1_rsc_data_in(dout_1_rsc_data_in_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst),
      .dout_1_rsc_addr(dout_1_rsc_addr_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst),
      .dout_1_rsc_we(dout_1_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst),
      .dout_1_rsc_req_vz(dout_1_rsc_req_vz_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst),
      .dout_1_rsc_rls_lz(dout_1_rsc_rls_lz_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_bud),
      .dout_2_rsc_data_in(dout_2_rsc_data_in_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst),
      .dout_2_rsc_addr(dout_2_rsc_addr_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst),
      .dout_2_rsc_we(dout_2_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst),
      .dout_2_rsc_req_vz(dout_2_rsc_req_vz_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst),
      .dout_2_rsc_rls_lz(dout_2_rsc_rls_lz_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_bud),
      .dout_3_rsc_data_in(dout_3_rsc_data_in_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst),
      .dout_3_rsc_addr(dout_3_rsc_addr_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst),
      .dout_3_rsc_we(dout_3_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst),
      .dout_3_rsc_req_vz(dout_3_rsc_req_vz_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst),
      .dout_3_rsc_rls_lz(dout_3_rsc_rls_lz_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_bud)
    );
  READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_1 READ_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst
      (
      .clk(clk),
      .rst(rst),
      .din_0_rsc_addr(din_0_rsc_addr_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst),
      .din_0_rsc_re(din_0_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst),
      .din_0_rsc_data_out(din_0_rsc_data_out_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst),
      .din_0_rsc_req_vz(din_0_rsc_req_vz_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst),
      .din_0_rsc_rls_lz(din_0_rsc_rls_lz_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_bud),
      .din_1_rsc_addr(din_1_rsc_addr_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst),
      .din_1_rsc_re(din_1_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst),
      .din_1_rsc_data_out(din_1_rsc_data_out_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst),
      .din_1_rsc_req_vz(din_1_rsc_req_vz_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst),
      .din_1_rsc_rls_lz(din_1_rsc_rls_lz_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_bud),
      .din_2_rsc_addr(din_2_rsc_addr_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst),
      .din_2_rsc_re(din_2_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst),
      .din_2_rsc_data_out(din_2_rsc_data_out_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst),
      .din_2_rsc_req_vz(din_2_rsc_req_vz_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst),
      .din_2_rsc_rls_lz(din_2_rsc_rls_lz_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_bud),
      .din_3_rsc_addr(din_3_rsc_addr_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst),
      .din_3_rsc_re(din_3_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst),
      .din_3_rsc_data_out(din_3_rsc_data_out_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst),
      .din_3_rsc_req_vz(din_3_rsc_req_vz_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst),
      .din_3_rsc_rls_lz(din_3_rsc_rls_lz_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_bud),
      .dout_rsc_z(dout_rsc_z_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst),
      .dout_rsc_vz(dout_rsc_vz),
      .dout_rsc_lz(dout_rsc_lz_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_bud)
    );
  unreg_hier_7 unreg (
      .in_0(shr_mem_0_cns_S0_iff),
      .out_0(shr_mem_0_cns_R0)
    );
  unreg_hier_7 unreg_1 (
      .in_0(shr_mem_0_cns_S1_iff),
      .out_0(shr_mem_0_cns_R1)
    );
  unreg_hier_7 unreg_2 (
      .in_0(shr_mem_1_cns_S0_iff),
      .out_0(shr_mem_1_cns_R0)
    );
  unreg_hier_7 unreg_3 (
      .in_0(shr_mem_1_cns_S1_iff),
      .out_0(shr_mem_1_cns_R1)
    );
  unreg_hier_7 unreg_4 (
      .in_0(shr_mem_2_cns_S0_iff),
      .out_0(shr_mem_2_cns_R0)
    );
  unreg_hier_7 unreg_5 (
      .in_0(shr_mem_2_cns_S1_iff),
      .out_0(shr_mem_2_cns_R1)
    );
  unreg_hier_7 unreg_6 (
      .in_0(shr_mem_3_cns_S0_iff),
      .out_0(shr_mem_3_cns_R0)
    );
  unreg_hier_7 unreg_7 (
      .in_0(shr_mem_3_cns_S1_iff),
      .out_0(shr_mem_3_cns_R1)
    );
  double_buffeHLhBe_0_cns_bctl double_buffeHLhBe_0_cns_bctl_inst (
      .clk(clk),
      .rst(rst),
      .din_rsc_lz_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst(din_rsc_lz_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst),
      .dout_0_rsc_data_in_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst(dout_0_rsc_data_in_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst),
      .dout_0_rsc_addr_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst(dout_0_rsc_addr_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst),
      .dout_0_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst(dout_0_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst),
      .dout_0_rsc_req_vz_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst(dout_0_rsc_req_vz_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst),
      .dout_1_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz(dout_1_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz),
      .dout_2_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz(dout_2_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz),
      .dout_3_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz(dout_3_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz),
      .din_0_rsc_addr_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst(din_0_rsc_addr_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst),
      .din_0_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst(din_0_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst),
      .din_0_rsc_data_out_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst(din_0_rsc_data_out_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst),
      .din_0_rsc_req_vz_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst(din_0_rsc_req_vz_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst),
      .dout_rsc_lz_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst(dout_rsc_lz_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst),
      .din_1_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz(din_1_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz),
      .din_2_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz(din_2_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz),
      .din_3_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz(din_3_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz),
      .din_rsc_lz_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_bud(din_rsc_lz_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_bud),
      .dout_0_rsc_rls_lz_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_bud(dout_0_rsc_rls_lz_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_bud),
      .din_0_rsc_rls_lz_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_bud(din_0_rsc_rls_lz_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_bud),
      .dout_1_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_bud(dout_1_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_bud),
      .dout_1_rsc_rls_lz_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_bud(1'b0),
      .din_1_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_bud(din_1_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_bud),
      .din_1_rsc_rls_lz_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_bud(1'b0),
      .dout_2_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_bud(dout_2_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_bud),
      .dout_2_rsc_rls_lz_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_bud(1'b0),
      .din_2_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_bud(din_2_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_bud),
      .din_2_rsc_rls_lz_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_bud(1'b0),
      .dout_3_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_bud(dout_3_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_bud),
      .dout_3_rsc_rls_lz_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_bud(1'b0),
      .din_3_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_bud(din_3_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_bud),
      .din_3_rsc_rls_lz_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_bud(1'b0),
      .dout_rsc_lz_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_bud(dout_rsc_lz_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_bud),
      .shr_mem_0_cns_S0(shr_mem_0_cns_S0_dmo),
      .shr_mem_0_cns_R0(shr_mem_0_cns_R0),
      .shr_mem_0_cns_S1(shr_mem_0_cns_S1_dmo),
      .shr_mem_0_cns_R1(shr_mem_0_cns_R1),
      .shr_mem_0_cns_data_in_shi0(shr_mem_0_cns_data_in_shi0),
      .shr_mem_0_cns_data_in_shi1(shr_mem_0_cns_data_in_shi1),
      .shr_mem_0_cns_addr_shi0(shr_mem_0_cns_addr_shi0),
      .shr_mem_0_cns_addr_shi1(shr_mem_0_cns_addr_shi1),
      .shr_mem_0_cns_re_shi0(shr_mem_0_cns_re_shi0),
      .shr_mem_0_cns_re_shi1(shr_mem_0_cns_re_shi1),
      .shr_mem_0_cns_we_shi0(shr_mem_0_cns_we_shi0),
      .shr_mem_0_cns_we_shi1(shr_mem_0_cns_we_shi1),
      .shr_mem_0_cns_data_out_sho0(shr_mem_0_cns_data_out_sho0),
      .shr_mem_0_cns_data_out_sho1(shr_mem_0_cns_data_out_sho1),
      .shr_mem_0_cns_S1_pff(shr_mem_0_cns_S1_iff),
      .shr_mem_0_cns_S0_pff(shr_mem_0_cns_S0_iff),
      .din_1_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_pff(din_1_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_iff),
      .din_1_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_bud_pff(din_1_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_bud_iff),
      .dout_1_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_pff(dout_1_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_iff),
      .dout_1_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_bud_pff(dout_1_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_bud_iff),
      .din_2_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_pff(din_2_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_iff),
      .din_2_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_bud_pff(din_2_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_bud_iff),
      .dout_2_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_pff(dout_2_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_iff),
      .dout_2_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_bud_pff(dout_2_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_bud_iff),
      .din_3_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_pff(din_3_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_iff),
      .din_3_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_bud_pff(din_3_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_bud_iff),
      .dout_3_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_pff(dout_3_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_iff),
      .dout_3_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_bud_pff(dout_3_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_bud_iff)
    );
  double_buffeHLhBe_1_cns_bctl double_buffeHLhBe_1_cns_bctl_inst (
      .clk(clk),
      .rst(rst),
      .dout_1_rsc_data_in_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst(dout_1_rsc_data_in_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst),
      .dout_1_rsc_addr_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst(dout_1_rsc_addr_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst),
      .dout_1_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst(dout_1_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst),
      .dout_1_rsc_req_vz_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst(dout_1_rsc_req_vz_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst),
      .dout_1_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz(2'b0),
      .din_1_rsc_addr_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst(din_1_rsc_addr_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst),
      .din_1_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst(din_1_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst),
      .din_1_rsc_data_out_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst(din_1_rsc_data_out_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst),
      .din_1_rsc_req_vz_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst(din_1_rsc_req_vz_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst),
      .din_1_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz(2'b0),
      .dout_1_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_bud(dout_1_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_bud),
      .dout_1_rsc_rls_lz_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_bud(dout_1_rsc_rls_lz_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_bud),
      .din_1_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_bud(din_1_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_bud),
      .din_1_rsc_rls_lz_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_bud(din_1_rsc_rls_lz_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_bud),
      .shr_mem_1_cns_S0(shr_mem_1_cns_S0_dmo),
      .shr_mem_1_cns_R0(shr_mem_1_cns_R0),
      .shr_mem_1_cns_S1(shr_mem_1_cns_S1_dmo),
      .shr_mem_1_cns_R1(shr_mem_1_cns_R1),
      .shr_mem_1_cns_data_in_shi0(shr_mem_1_cns_data_in_shi0),
      .shr_mem_1_cns_data_in_shi1(shr_mem_1_cns_data_in_shi1),
      .shr_mem_1_cns_addr_shi0(shr_mem_1_cns_addr_shi0),
      .shr_mem_1_cns_addr_shi1(shr_mem_1_cns_addr_shi1),
      .shr_mem_1_cns_re_shi0(shr_mem_1_cns_re_shi0),
      .shr_mem_1_cns_re_shi1(shr_mem_1_cns_re_shi1),
      .shr_mem_1_cns_we_shi0(shr_mem_1_cns_we_shi0),
      .shr_mem_1_cns_we_shi1(shr_mem_1_cns_we_shi1),
      .shr_mem_1_cns_data_out_sho0(shr_mem_1_cns_data_out_sho0),
      .shr_mem_1_cns_data_out_sho1(shr_mem_1_cns_data_out_sho1),
      .shr_mem_1_cns_S1_pff(shr_mem_1_cns_S1_iff),
      .din_1_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_pff(din_1_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_iff),
      .din_1_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_bud_pff(din_1_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_bud_iff),
      .dout_1_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_pff(dout_1_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_iff),
      .dout_1_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_bud_pff(dout_1_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_bud_iff),
      .shr_mem_1_cns_S0_pff(shr_mem_1_cns_S0_iff)
    );
  double_buffeHLhBe_2_cns_bctl double_buffeHLhBe_2_cns_bctl_inst (
      .clk(clk),
      .rst(rst),
      .dout_2_rsc_data_in_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst(dout_2_rsc_data_in_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst),
      .dout_2_rsc_addr_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst(dout_2_rsc_addr_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst),
      .dout_2_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst(dout_2_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst),
      .dout_2_rsc_req_vz_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst(dout_2_rsc_req_vz_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst),
      .dout_2_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz(2'b0),
      .din_2_rsc_addr_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst(din_2_rsc_addr_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst),
      .din_2_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst(din_2_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst),
      .din_2_rsc_data_out_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst(din_2_rsc_data_out_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst),
      .din_2_rsc_req_vz_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst(din_2_rsc_req_vz_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst),
      .din_2_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz(2'b0),
      .dout_2_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_bud(dout_2_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_bud),
      .dout_2_rsc_rls_lz_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_bud(dout_2_rsc_rls_lz_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_bud),
      .din_2_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_bud(din_2_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_bud),
      .din_2_rsc_rls_lz_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_bud(din_2_rsc_rls_lz_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_bud),
      .shr_mem_2_cns_S0(shr_mem_2_cns_S0_dmo),
      .shr_mem_2_cns_R0(shr_mem_2_cns_R0),
      .shr_mem_2_cns_S1(shr_mem_2_cns_S1_dmo),
      .shr_mem_2_cns_R1(shr_mem_2_cns_R1),
      .shr_mem_2_cns_data_in_shi0(shr_mem_2_cns_data_in_shi0),
      .shr_mem_2_cns_data_in_shi1(shr_mem_2_cns_data_in_shi1),
      .shr_mem_2_cns_addr_shi0(shr_mem_2_cns_addr_shi0),
      .shr_mem_2_cns_addr_shi1(shr_mem_2_cns_addr_shi1),
      .shr_mem_2_cns_re_shi0(shr_mem_2_cns_re_shi0),
      .shr_mem_2_cns_re_shi1(shr_mem_2_cns_re_shi1),
      .shr_mem_2_cns_we_shi0(shr_mem_2_cns_we_shi0),
      .shr_mem_2_cns_we_shi1(shr_mem_2_cns_we_shi1),
      .shr_mem_2_cns_data_out_sho0(shr_mem_2_cns_data_out_sho0),
      .shr_mem_2_cns_data_out_sho1(shr_mem_2_cns_data_out_sho1),
      .shr_mem_2_cns_S1_pff(shr_mem_2_cns_S1_iff),
      .din_2_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_pff(din_2_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_iff),
      .din_2_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_bud_pff(din_2_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_bud_iff),
      .dout_2_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_pff(dout_2_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_iff),
      .dout_2_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_bud_pff(dout_2_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_bud_iff),
      .shr_mem_2_cns_S0_pff(shr_mem_2_cns_S0_iff)
    );
  double_buffeHLhBe_3_cns_bctl double_buffeHLhBe_3_cns_bctl_inst (
      .clk(clk),
      .rst(rst),
      .dout_3_rsc_data_in_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst(dout_3_rsc_data_in_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst),
      .dout_3_rsc_addr_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst(dout_3_rsc_addr_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst),
      .dout_3_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst(dout_3_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst),
      .dout_3_rsc_req_vz_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst(dout_3_rsc_req_vz_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst),
      .dout_3_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz(2'b0),
      .din_3_rsc_addr_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst(din_3_rsc_addr_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst),
      .din_3_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst(din_3_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst),
      .din_3_rsc_data_out_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst(din_3_rsc_data_out_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst),
      .din_3_rsc_req_vz_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst(din_3_rsc_req_vz_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst),
      .din_3_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz(2'b0),
      .dout_3_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_bud(dout_3_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_bud),
      .dout_3_rsc_rls_lz_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_bud(dout_3_rsc_rls_lz_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_bud),
      .din_3_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_bud(din_3_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_bud),
      .din_3_rsc_rls_lz_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_bud(din_3_rsc_rls_lz_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_bud),
      .shr_mem_3_cns_S0(shr_mem_3_cns_S0_dmo),
      .shr_mem_3_cns_R0(shr_mem_3_cns_R0),
      .shr_mem_3_cns_S1(shr_mem_3_cns_S1_dmo),
      .shr_mem_3_cns_R1(shr_mem_3_cns_R1),
      .shr_mem_3_cns_data_in_shi0(shr_mem_3_cns_data_in_shi0),
      .shr_mem_3_cns_data_in_shi1(shr_mem_3_cns_data_in_shi1),
      .shr_mem_3_cns_addr_shi0(shr_mem_3_cns_addr_shi0),
      .shr_mem_3_cns_addr_shi1(shr_mem_3_cns_addr_shi1),
      .shr_mem_3_cns_re_shi0(shr_mem_3_cns_re_shi0),
      .shr_mem_3_cns_re_shi1(shr_mem_3_cns_re_shi1),
      .shr_mem_3_cns_we_shi0(shr_mem_3_cns_we_shi0),
      .shr_mem_3_cns_we_shi1(shr_mem_3_cns_we_shi1),
      .shr_mem_3_cns_data_out_sho0(shr_mem_3_cns_data_out_sho0),
      .shr_mem_3_cns_data_out_sho1(shr_mem_3_cns_data_out_sho1),
      .shr_mem_3_cns_S1_pff(shr_mem_3_cns_S1_iff),
      .din_3_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_pff(din_3_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_iff),
      .din_3_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_bud_pff(din_3_rsc_re_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst_buz_bud_iff),
      .dout_3_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_pff(dout_3_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_iff),
      .dout_3_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_bud_pff(dout_3_rsc_we_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst_buz_bud_iff),
      .shr_mem_3_cns_S0_pff(shr_mem_3_cns_S0_iff)
    );
  assign din_rsc_lz = din_rsc_lz_nWRITE_BLOCK_WEIGHTS_DTYPE_4_4_2_2_3_2_inst;
  assign dout_rsc_lz = dout_rsc_lz_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst;
  assign dout_rsc_z = dout_rsc_z_nREAD_BLOCK_WEIGHTS_DTYPE_4_16_4_2_2_3_2_inst;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    gemm
// ------------------------------------------------------------------


module gemm (
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


  // Interconnect Declarations
  wire [127:0] dout_rsc_z_ndouble_buffer_input_DTYPE_4_4_4_4_2_2_3_inst;
  wire dout_rsc_vz_ndouble_buffer_input_DTYPE_4_4_4_4_2_2_3_inst;
  wire [255:0] dout_rsc_z_ndouble_buffer_weights_DTYPE_2_4_16_4_2_2_3_inst;
  wire dout_rsc_vz_ndouble_buffer_weights_DTYPE_2_4_16_4_2_2_3_inst;
  wire [127:0] input_rsc_z_nsystolic_array_DTYPE_2_4_16_4_2_2_3_inst;
  wire input_rsc_vz_nsystolic_array_DTYPE_2_4_16_4_2_2_3_inst;
  wire [255:0] weight_rsc_z_nsystolic_array_DTYPE_2_4_16_4_2_2_3_inst;
  wire weight_rsc_vz_nsystolic_array_DTYPE_2_4_16_4_2_2_3_inst;
  wire [255:0] output_rsc_z_nsystolic_array_DTYPE_2_4_16_4_2_2_3_inst;
  wire din_rsc_lz_ndouble_buffer_input_DTYPE_4_4_4_4_2_2_3_inst_bud;
  wire dout_rsc_lz_ndouble_buffer_input_DTYPE_4_4_4_4_2_2_3_inst_bud;
  wire input_rsc_lz_nsystolic_array_DTYPE_2_4_16_4_2_2_3_inst_bud;
  wire din_rsc_lz_ndouble_buffer_weights_DTYPE_2_4_16_4_2_2_3_inst_bud;
  wire dout_rsc_lz_ndouble_buffer_weights_DTYPE_2_4_16_4_2_2_3_inst_bud;
  wire weight_rsc_lz_nsystolic_array_DTYPE_2_4_16_4_2_2_3_inst_bud;
  wire output_rsc_lz_nsystolic_array_DTYPE_2_4_16_4_2_2_3_inst_bud;
  wire input_copy_unc_2;
  wire weight_copy_unc_2;


  // Interconnect Declarations for Component Instantiations 
  mgc_pipe_v10 #(.rscid(32'sd73),
  .width(32'sd128),
  .sz_width(32'sd1),
  .fifo_sz(32'sd1),
  .log2_sz(32'sd0),
  .ph_clk(32'sd1),
  .ph_en(32'sd0),
  .ph_arst(32'sd0),
  .ph_srst(32'sd1)) input_copy_cns_pipe (
      .clk(clk),
      .en(1'b0),
      .arst(1'b1),
      .srst(rst),
      .ldin(input_rsc_lz_nsystolic_array_DTYPE_2_4_16_4_2_2_3_inst_bud),
      .vdin(input_rsc_vz_nsystolic_array_DTYPE_2_4_16_4_2_2_3_inst),
      .din(input_rsc_z_nsystolic_array_DTYPE_2_4_16_4_2_2_3_inst),
      .ldout(dout_rsc_lz_ndouble_buffer_input_DTYPE_4_4_4_4_2_2_3_inst_bud),
      .vdout(dout_rsc_vz_ndouble_buffer_input_DTYPE_4_4_4_4_2_2_3_inst),
      .dout(dout_rsc_z_ndouble_buffer_input_DTYPE_4_4_4_4_2_2_3_inst),
      .sd(input_copy_unc_2)
    );
  mgc_pipe_v10 #(.rscid(32'sd74),
  .width(32'sd256),
  .sz_width(32'sd1),
  .fifo_sz(32'sd1),
  .log2_sz(32'sd0),
  .ph_clk(32'sd1),
  .ph_en(32'sd0),
  .ph_arst(32'sd0),
  .ph_srst(32'sd1)) weight_copy_cns_pipe (
      .clk(clk),
      .en(1'b0),
      .arst(1'b1),
      .srst(rst),
      .ldin(weight_rsc_lz_nsystolic_array_DTYPE_2_4_16_4_2_2_3_inst_bud),
      .vdin(weight_rsc_vz_nsystolic_array_DTYPE_2_4_16_4_2_2_3_inst),
      .din(weight_rsc_z_nsystolic_array_DTYPE_2_4_16_4_2_2_3_inst),
      .ldout(dout_rsc_lz_ndouble_buffer_weights_DTYPE_2_4_16_4_2_2_3_inst_bud),
      .vdout(dout_rsc_vz_ndouble_buffer_weights_DTYPE_2_4_16_4_2_2_3_inst),
      .dout(dout_rsc_z_ndouble_buffer_weights_DTYPE_2_4_16_4_2_2_3_inst),
      .sd(weight_copy_unc_2)
    );
  double_buffer_input_DTYPE_4_4_4_4_2_2_3 double_buffer_input_DTYPE_4_4_4_4_2_2_3_inst
      (
      .clk(clk),
      .rst(rst),
      .din_rsc_z(input_rsc_z),
      .din_rsc_vz(input_rsc_vz),
      .din_rsc_lz(din_rsc_lz_ndouble_buffer_input_DTYPE_4_4_4_4_2_2_3_inst_bud),
      .dout_rsc_z(dout_rsc_z_ndouble_buffer_input_DTYPE_4_4_4_4_2_2_3_inst),
      .dout_rsc_vz(dout_rsc_vz_ndouble_buffer_input_DTYPE_4_4_4_4_2_2_3_inst),
      .dout_rsc_lz(dout_rsc_lz_ndouble_buffer_input_DTYPE_4_4_4_4_2_2_3_inst_bud)
    );
  double_buffer_weights_DTYPE_2_4_16_4_2_2_3 double_buffer_weights_DTYPE_2_4_16_4_2_2_3_inst
      (
      .clk(clk),
      .rst(rst),
      .din_rsc_z(weight_rsc_z),
      .din_rsc_vz(weight_rsc_vz),
      .din_rsc_lz(din_rsc_lz_ndouble_buffer_weights_DTYPE_2_4_16_4_2_2_3_inst_bud),
      .dout_rsc_z(dout_rsc_z_ndouble_buffer_weights_DTYPE_2_4_16_4_2_2_3_inst),
      .dout_rsc_vz(dout_rsc_vz_ndouble_buffer_weights_DTYPE_2_4_16_4_2_2_3_inst),
      .dout_rsc_lz(dout_rsc_lz_ndouble_buffer_weights_DTYPE_2_4_16_4_2_2_3_inst_bud)
    );
  systolic_array_DTYPE_2_4_16_4_2_2_3 systolic_array_DTYPE_2_4_16_4_2_2_3_inst (
      .clk(clk),
      .rst(rst),
      .input_rsc_z(input_rsc_z_nsystolic_array_DTYPE_2_4_16_4_2_2_3_inst),
      .input_rsc_vz(input_rsc_vz_nsystolic_array_DTYPE_2_4_16_4_2_2_3_inst),
      .input_rsc_lz(input_rsc_lz_nsystolic_array_DTYPE_2_4_16_4_2_2_3_inst_bud),
      .weight_rsc_z(weight_rsc_z_nsystolic_array_DTYPE_2_4_16_4_2_2_3_inst),
      .weight_rsc_vz(weight_rsc_vz_nsystolic_array_DTYPE_2_4_16_4_2_2_3_inst),
      .weight_rsc_lz(weight_rsc_lz_nsystolic_array_DTYPE_2_4_16_4_2_2_3_inst_bud),
      .output_rsc_z(output_rsc_z_nsystolic_array_DTYPE_2_4_16_4_2_2_3_inst),
      .output_rsc_vz(output_rsc_vz),
      .output_rsc_lz(output_rsc_lz_nsystolic_array_DTYPE_2_4_16_4_2_2_3_inst_bud)
    );
  assign input_rsc_lz = din_rsc_lz_ndouble_buffer_input_DTYPE_4_4_4_4_2_2_3_inst_bud;
  assign weight_rsc_lz = din_rsc_lz_ndouble_buffer_weights_DTYPE_2_4_16_4_2_2_3_inst_bud;
  assign output_rsc_lz = output_rsc_lz_nsystolic_array_DTYPE_2_4_16_4_2_2_3_inst_bud;
  assign output_rsc_z = output_rsc_z_nsystolic_array_DTYPE_2_4_16_4_2_2_3_inst;
endmodule



