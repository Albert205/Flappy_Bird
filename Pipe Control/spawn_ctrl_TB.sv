`timescale 1 ns/10 ps

module spawn_ctrl_TB();
    localparam T = 10;
    localparam SPAWN_SPEED = 3;

    logic i_Clk, i_Reset;
    logic i_Start;
    logic o_Pipe1_Start;
    logic o_Pipe2_Start;
    logic o_Pipe3_Start;

    spawn_ctrl_fsm #(.SPAWN_SPEED(SPAWN_SPEED)) uut (.*);

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
            @(negedge i_Reset);
            @(negedge i_Clk);

            i_Start = 1'b1;

            repeat (30) @(negedge i_Clk);
            $stop;
        end

endmodule