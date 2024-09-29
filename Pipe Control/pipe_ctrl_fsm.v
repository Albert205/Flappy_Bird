module pipe_ctrl_fsm
#(parameter XMAX = 800,
  parameter YMAX = 525,
  parameter WIDTH = 40,
  parameter HEIGHT = 30,
  parameter X_INIT = 40,
  parameter GAP_SIZE = 10,
  parameter PIPE_WIDTH = 5,
  parameter PIXEL_SIZE = 16,
  parameter MOVE_SPEED = 1250000)

(input i_Clk, i_Reset,
 input [$clog2(XMAX)-1:0] i_X_Count,
 input [$clog2(YMAX)-1:0] i_Y_Count,
 input [$clog2(HEIGHT)-1:0] i_Y_Pos,
 input i_Start,
 output o_Draw_Pipe,
 output o_Done_Tick);

    localparam s_Idle = 0;
    localparam s_Entry = 1;
    localparam s_Moving = 2;
    localparam s_Exit = 3;

    reg [2:0] r_State, r_State_Next;

    reg[$clog2(WIDTH)-1:0] r_X_Pos, r_X_Pos_Next;
    reg[$clog2(HEIGHT)-1:0] r_Y_Pos, r_Y_Pos_Next;

    reg [$clog2(MOVE_SPEED)-1:0] r_Move_Clk, r_Move_Clk_Next;

    reg[$clog2(PIPE_WIDTH)-1:0] r_Width_Count, r_Width_Count_Next;

    reg r_Draw_Pipe;
    reg r_Done_Tick;

    assign o_Draw_Pipe = r_Draw_Pipe;
    assign o_Done_Tick = r_Done_Tick;

    always @(posedge i_Clk, posedge i_Reset)
        begin
            if(i_Reset)
                begin
                    r_State <= s_Idle;
                    r_Y_Pos <= i_Y_Count;
                    r_X_Pos <= X_INIT;
                    r_Move_Clk <= 0;
                    r_Width_Count <= 0;
                end
            else
                begin
                    r_State <= r_State_Next;
                    r_Y_Pos <= r_Y_Pos_Next;
                    r_X_Pos <= r_X_Pos_Next;
                    r_Move_Clk <= r_Move_Clk_Next;
                    r_Width_Count <= r_Width_Count_Next;
                end
        end
    
    always @(*)
        begin
            r_Move_Clk_Next = r_Move_Clk;
            if(r_State == s_Entry || r_State == s_Moving || r_State == s_Exit)
                begin
                    if(r_Move_Clk < MOVE_SPEED - 1)
                            begin
                                r_Move_Clk_Next = r_Move_Clk + 1;
                            end
                        else if(r_Move_Clk == MOVE_SPEED - 1)
                            begin
                                r_Move_Clk_Next = 0;
                            end
                end
        end

    
    always @(*)
        begin
            r_State_Next = r_State;
            r_Y_Pos_Next = r_Y_Pos;
            r_X_Pos_Next = r_X_Pos;
            r_Width_Count_Next = r_Width_Count;
            r_Draw_Pipe = 1'b0;
            r_Done_Tick = 1'b0;

            case(r_State)
                s_Idle:
                    begin
                        r_Y_Pos_Next = i_Y_Pos;
                        if(i_Start)
                            r_State_Next = s_Entry;
                    end
                s_Entry:
                    begin
                        if(i_X_Count < (X_INIT+1) * PIXEL_SIZE && i_X_Count > (r_X_Pos)*PIXEL_SIZE && (i_Y_Count < r_Y_Pos * PIXEL_SIZE || i_Y_Count > (GAP_SIZE + r_Y_Pos) * PIXEL_SIZE))
                            r_Draw_Pipe = 1'b1;

                        if(r_Width_Count < PIPE_WIDTH && r_Move_Clk == MOVE_SPEED - 1)
                            begin
                                r_Width_Count_Next = r_Width_Count + 1;
                                r_X_Pos_Next = r_X_Pos - 1;
                            end
                        else if(r_Width_Count == PIPE_WIDTH)
                            begin
                                r_State_Next = s_Moving;
                                r_Width_Count_Next = 0;
                            end
                    end
                s_Moving:
                    begin
                        if(i_X_Count < (r_X_Pos + PIPE_WIDTH) * PIXEL_SIZE && i_X_Count > (r_X_Pos)*PIXEL_SIZE && (i_Y_Count < r_Y_Pos * PIXEL_SIZE || i_Y_Count > (GAP_SIZE + r_Y_Pos) * PIXEL_SIZE))
                            r_Draw_Pipe = 1'b1;
                        
                        if(r_X_Pos > 0 && r_Move_Clk == MOVE_SPEED - 1)
                            r_X_Pos_Next = r_X_Pos - 1;
                        else if(r_X_Pos == 0)
                            begin
                                r_State_Next = s_Exit;
                                r_X_Pos_Next = PIPE_WIDTH;
                            end
                    end
                s_Exit:
                    begin
                        if(i_X_Count < r_X_Pos * PIXEL_SIZE && i_X_Count > 0 && (i_Y_Count < r_Y_Pos * PIXEL_SIZE || i_Y_Count > (GAP_SIZE + r_Y_Pos) * PIXEL_SIZE))
                            r_Draw_Pipe = 1'b1;
                        
                        if(r_X_Pos > 0 && r_Move_Clk == MOVE_SPEED - 1)
                            r_X_Pos_Next = r_X_Pos - 1;
                        else if(r_X_Pos == 0)
                            begin
                                r_State_Next = s_Idle;
                                r_Done_Tick = 1'b1;
                            end

                    end
                default: r_State_Next = s_Idle;
            endcase
        end

endmodule
