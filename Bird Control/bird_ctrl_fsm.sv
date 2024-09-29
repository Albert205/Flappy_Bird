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
  parameter RISE_SPEED = 2000000)

(input logic i_Clk, i_Reset,
 input logic [$clog2(XMAX)-1:0] i_X_Count,
 input logic [$clog2(YMAX)-1:0] i_Y_Count,
 input logic i_Start,
 input logic i_Bounce,
//input i_Pipe_Pos -> need to consider this for later...
 output logic o_Draw_Bird,
 output logic o_Dead);
    
    typedef enum {s_Idle, s_Falling, s_Rising} statetype;
    statetype r_State, r_State_next;
    logic [$clog2(YMAX)-1:0] r_Y_Pos, r_Y_Pos_Next;
    logic [$clog2(FALL_SPEED)-1:0] r_Fall_Clk, r_Fall_Clk_Next;
    logic [$clog2(RISE_SPEED)-1:0] r_Rise_Clk, r_Rise_Clk_Next;

    always_ff @(posedge i_Clk, posedge i_Reset)
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

    always_comb
        begin
            r_State_next = r_State;
            r_Y_Pos_Next = r_Y_Pos;
            r_Fall_Clk_Next = r_Fall_Clk;
            r_Rise_Clk_Next = r_Rise_Clk;
            o_Draw_Bird = 1'b0;
            o_Dead = 1'b0;

            case(r_State)
                s_Idle:
                    if(i_Start)
                        r_State_next = s_Falling;
                s_Falling:
                    begin
                        
                        if(i_X_Count < X_POS * PIXEL_SIZE && i_X_Count > (X_POS - 1) * PIXEL_SIZE && i_Y_Count < r_Y_Pos * PIXEL_SIZE && i_Y_Count > (r_Y_Pos - 1) * PIXEL_SIZE)
                            o_Draw_Bird = 1'b1;

                        if(r_Fall_Clk < FALL_SPEED - 1)
                            begin
                                r_Fall_Clk_Next = r_Fall_Clk + 1;
                            end
                        else if(r_Fall_Clk == FALL_SPEED - 1)
                            begin
                                r_Fall_Clk_Next = 0;
                                r_Y_Pos_Next = r_Y_Pos + 1;
                            end
                        else if(i_Bounce)
                            begin
                                r_Fall_Clk_Next = 0;
                                r_State_next = s_Rising;
                            end
                        else if(r_Y_Pos == Y_OUT_TOP || r_Y_Pos == Y_OUT_BOT)
                            begin
                                o_Dead = 1'b1;
                                r_State_next = s_Idle;
                            end
                    end                    
                s_Rising:
                    begin

                        if(i_X_Count < X_POS * PIXEL_SIZE && i_X_Count > (X_POS - 1) * PIXEL_SIZE && i_Y_Count < r_Y_Pos * PIXEL_SIZE && i_Y_Count > (r_Y_Pos - 1) * PIXEL_SIZE)
                            o_Draw_Bird = 1'b1;
                            
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
                        else if(i_Bounce)
                            begin
                                r_Rise_Clk_Next = 0;
                            end
                        else if(r_Y_Pos == Y_OUT_TOP || r_Y_Pos == Y_OUT_BOT)
                            begin
                                o_Dead = 1'b1;
                                r_State_next = s_Idle;
                            end
                    end
                default: r_State_next = s_Idle;
            endcase
        end

endmodule