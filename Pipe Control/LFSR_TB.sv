`timescale 1 ns/10 ps

module LFSR_TB();

localparam T = 10;
logic i_Clk, i_Reset;
logic [4:0] o_LFSR_Data;

LFSR_5 uut (.*);

always
    begin
        i_Clk = 1'b1;
        #(T/2);
        i_Clk = 1'b0;
        #(T/2);
    end

initial
    begin
        i_Reset = 1'b1;
        #(T/2);
        i_Reset = 1'b0;
    end

initial
    begin
        repeat (20) @(negedge i_Clk);
        $stop;
    end

endmodule