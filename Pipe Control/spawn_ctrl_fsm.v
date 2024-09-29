module spawn_ctrl_fsm
#(
    parameter SPAWN_SPEED = 35000000
)

(
    input i_Clk, i_Reset,
    input i_Start,
    output o_Pipe1_Start, o_Pipe2_Start, o_Pipe3_Start
);

    localparam s_Idle = 0;
    localparam s_Spawning = 1;

    reg r_State, r_State_Next;

    reg r_Pipe1, r_Pipe1_Next;
    reg r_Pipe2, r_Pipe2_Next;
    reg r_Pipe3, r_Pipe3_Next;

    reg [$clog2(3*SPAWN_SPEED)-1:0] r_Spawn_Clk, r_Spawn_Clk_Next;

    assign o_Pipe1_Start = r_Pipe1;
    assign o_Pipe2_Start = r_Pipe2;
    assign o_Pipe3_Start = r_Pipe3;

    always @(posedge i_Clk, posedge i_Reset)
        begin
            if(i_Reset)
                begin
                    r_State <= s_Idle;
                    r_Pipe1 <= 1'b0;
                    r_Pipe2 <= 1'b0;
                    r_Pipe3 <= 1'b0;
                    r_Spawn_Clk <= 0;
                end
            else
                begin
                    r_State <= r_State_Next;
                    r_Pipe1 <= r_Pipe1_Next;
                    r_Pipe2 <= r_Pipe2_Next;
                    r_Pipe3 <= r_Pipe3_Next;
                    r_Spawn_Clk <= r_Spawn_Clk_Next;
                end
        end
    
    always @(*)
        begin
            r_State_Next = r_State;
            r_Pipe1_Next = r_Pipe1;
            r_Pipe2_Next = r_Pipe2;
            r_Pipe3_Next = r_Pipe3;
            r_Spawn_Clk_Next = r_Spawn_Clk;

            case(r_State)
                s_Idle:
                    begin
                        if(i_Start)
                            r_State_Next = s_Spawning;
                    end
                s_Spawning:
                    begin
                        if(r_Spawn_Clk < 3*SPAWN_SPEED - 1)
                            begin
                                r_Spawn_Clk_Next = r_Spawn_Clk + 1;
                            end
                        else if (r_Spawn_Clk == 3*SPAWN_SPEED - 1)
                            begin
                                r_Spawn_Clk_Next = 0;
                            end
                        
                        if(r_Spawn_Clk == SPAWN_SPEED - 1)
                            begin
                                r_Pipe1_Next = 1'b1;
                            end
                        else if(r_Spawn_Clk == 2*SPAWN_SPEED - 1)
                            begin
                                r_Pipe2_Next = 1'b1;
                            end
                        else if(r_Spawn_Clk == 3*SPAWN_SPEED - 1)
                            begin
                                r_Pipe3_Next = 1'b1;
                            end
                        else
                            begin
                                r_Pipe1_Next = 1'b0;
                                r_Pipe2_Next = 1'b0;
                                r_Pipe3_Next = 1'b0;
                            end  
                    end                    
                default: r_State_Next = s_Idle;
            endcase
        end

endmodule
