module pad_in#(parameter w=1)(output [w-1:0] C, input [w-1:0] PAD);
    genvar g;
    generate for (g=0; g<w; g=g+1) begin: p
        PRDW08DGZ_H_G p (.C(C[g]), .PAD(PAD[g]), .I(1'b0), .OEN(1'b1), .REN(1'b1));
    end
    endgenerate
endmodule
