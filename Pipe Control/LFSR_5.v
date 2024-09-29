module LFSR_5
(
    input i_Clk,
    input i_Reset,
    output [4:0] o_LFSR_Data
);

    wire w_XNOR;
    reg [4:0] r_LFSR_Data;

    assign o_LFSR_Data = (r_LFSR_Data < 5'd2) ? r_LFSR_Data + 5'd2 :
                         (r_LFSR_Data > 5'd19) ? r_LFSR_Data - 5'd12 : r_LFSR_Data;
    
    always @(posedge i_Clk, posedge i_Reset)
        begin
            if(i_Reset)
                r_LFSR_Data <= 5'd0;
            else
                r_LFSR_Data <= {r_LFSR_Data[3:0], w_XNOR};
        end
    
    assign w_XNOR = r_LFSR_Data[4] ^~ r_LFSR_Data[3];
    
endmodule
    
