module pad_out#(parameter w=1)(output [w-1:0] PAD, input [w-1:0] I);
    genvar g;
    generate for (g=0; g<w; g=g+1) begin: p
        PRDW08DGZ_H_G p (.PAD(PAD[g]), .I(I[g]), .OEN(1'b0), .REN(1'b1), .C());
    end
    endgenerate
endmodule
