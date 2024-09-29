module bird_ctrl_fsm
#(parameter XMAX = 800,
  parameter YMAX = 525,
  parameter WIDTH = 40,
  parameter HEIGHT = 30,
  parameter PIXEL_SIZE = 16,
  parameter X_POS = 10,
  parameter Y_INIT = 15,
  parameter Y_OUT_TOP = 1,
  parameter Y_OUT_BOT = 30,
  parameter FALL_SPEED = 1250000,
  parameter RISE_SPEED = 1250000)

(input i_Clk, i_Reset,
 input [$clog2(XMAX)-1:0] i_X_Count,
 input [$clog2(YMAX)-1:0] i_Y_Count,
 input i_Start,
 input i_Bounce,
//input i_Pipe_Pos -> need to consider this for later...
 output o_Draw_Bird,
 output o_Dead);
    
    localparam s_Idle = 0;
    localparam s_Falling = 1;
    localparam s_Rising = 2;

    reg [2:0] r_State, r_State_next;

    reg [$clog2(YMAX)-1:0] r_Y_Pos, r_Y_Pos_Next;
    reg [$clog2(FALL_SPEED)-1:0] r_Fall_Clk, r_Fall_Clk_Next;
    reg [$clog2(RISE_SPEED)-1:0] r_Rise_Clk, r_Rise_Clk_Next;

    reg r_Dead, r_Draw_Bird;

    assign o_Draw_Bird = r_Draw_Bird;
    assign o_Dead = r_Dead;

    always @(posedge i_Clk, posedge i_Reset)
        begin
            if(i_Reset)
                begin
                    r_State <= s_Idle;
                    r_Y_Pos <= Y_INIT;
                    r_Fall_Clk <= 0;
                    r_Rise_Clk <= 0;
                end
            else
                begin
                    r_State <= r_State_next;
                    r_Y_Pos <= r_Y_Pos_Next;
                    r_Fall_Clk <= r_Fall_Clk_Next;
                    r_Rise_Clk <= r_Rise_Clk_Next;
                end
        end

    always @(*)
        begin
            r_State_next = r_State;
            r_Y_Pos_Next = r_Y_Pos;
            r_Fall_Clk_Next = r_Fall_Clk;
            r_Rise_Clk_Next = r_Rise_Clk;
            r_Draw_Bird = 1'b0;
            r_Dead = 1'b0;

            case(r_State)
                s_Idle:
                    begin
                        if(i_Start)
                            r_State_next = s_Falling;

                        if(i_X_Count < X_POS * PIXEL_SIZE && i_X_Count > (X_POS - 1) * PIXEL_SIZE && i_Y_Count < Y_INIT * PIXEL_SIZE && i_Y_Count > (Y_INIT - 1) * PIXEL_SIZE)
                            r_Draw_Bird = 1'b1;

                        r_Y_Pos_Next = Y_INIT;
                    end
                s_Falling:
                    begin
                        
                        if(i_X_Count < X_POS * PIXEL_SIZE && i_X_Count > (X_POS - 1) * PIXEL_SIZE && i_Y_Count < r_Y_Pos * PIXEL_SIZE && i_Y_Count > (r_Y_Pos - 1) * PIXEL_SIZE)
                            r_Draw_Bird = 1'b1;

                        if(r_Fall_Clk < FALL_SPEED - 1)
                            begin
                                r_Fall_Clk_Next = r_Fall_Clk + 1;
                            end
                        else if(r_Fall_Clk == FALL_SPEED - 1)
                            begin
                                r_Fall_Clk_Next = 0;
                                r_Y_Pos_Next = r_Y_Pos + 1;
                            end
                        
                        if(i_Bounce)
                            begin
                                r_State_next = s_Rising;
                            end
                        else if(r_Y_Pos == Y_OUT_TOP || r_Y_Pos == Y_OUT_BOT)
                            begin
                                r_Dead = 1'b1;
                                r_State_next = s_Idle;
                            end
                    end                    
                s_Rising:
                    begin

                        if(i_X_Count < X_POS * PIXEL_SIZE && i_X_Count > (X_POS - 1) * PIXEL_SIZE && i_Y_Count < r_Y_Pos * PIXEL_SIZE && i_Y_Count > (r_Y_Pos - 1) * PIXEL_SIZE)
                            r_Draw_Bird = 1'b1;
                            
                        if(i_Bounce)
                            begin
                                r_Rise_Clk_Next = 0;
                            end
                        if(r_Rise_Clk < RISE_SPEED - 1)
                            begin
                                r_Rise_Clk_Next = r_Rise_Clk + 1;
                                if(r_Rise_Clk == RISE_SPEED/2 - 1)
                                    begin
                                        r_Y_Pos_Next = r_Y_Pos - 1;
                                    end
                            end
                        else if(r_Rise_Clk == RISE_SPEED - 1)
                            begin
                                r_Rise_Clk_Next = 0;
                                r_Y_Pos_Next = r_Y_Pos - 1;
                                r_State_next = s_Falling;
                            end
                        else if(r_Y_Pos == Y_OUT_TOP || r_Y_Pos == Y_OUT_BOT)
                            begin
                                r_Dead = 1'b1;
                                r_State_next = s_Idle;
                            end
                    end
                default: r_State_next = s_Idle;
            endcase
        end

endmodule