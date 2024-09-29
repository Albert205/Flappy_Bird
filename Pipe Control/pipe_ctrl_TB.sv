`timescale 1 ns/10 ps

module pipe_ctrl_TB();

    localparam T = 10;
    localparam MOVE_SPEED = 2;
    localparam XMAX = 800;
    localparam YMAX = 525;
    localparam HEIGHT = 30;

    logic i_Clk, i_Reset;
    logic [$clog2(XMAX)-1:0] i_X_Count = 20;
    logic [$clog2(YMAX)-1:0] i_Y_Count = 20;
    logic [$clog2(HEIGHT)-1:0] i_Y_Pos = 15;
    logic i_Start;

    logic o_Draw_Pipe;
    logic o_Done_Tick;

    pipe_ctrl_fsm #(.MOVE_SPEED(MOVE_SPEED)) uut (.*);

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

            repeat (3) @(negedge i_Clk);

            i_Start = 1'b0;

            wait(o_Done_Tick == 1'b1);

            repeat (5) @(negedge i_Clk);

            $stop;
        end 

endmodule
