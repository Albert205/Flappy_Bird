module frame_counter
#(parameter HMAX = 800,
            VMAX = 525)
(input logic i_Clk,
output logic [$clog2(HMAX)-1:0] o_H_count,
output logic [$clog2(VMAX)-1:0] o_V_count,
output logic o_Frame_end,
output logic o_Frame_start);

    logic [$clog2(HMAX)-1:0] r_H_count = 0;
    logic [$clog2(VMAX)-1:0] r_V_count = 0;

    always_ff @(posedge i_Clk) begin
        if(r_H_count == HMAX - 1) begin
            r_H_count <= 0;
            if(r_V_count == VMAX - 1)
                r_V_count <= 0;
            else
                r_V_count <= r_V_count + 1;
        end else
            r_H_count <= r_H_count + 1;    
    end

    assign o_H_count = r_H_count;
    assign o_V_count = r_V_count;

    assign o_Frame_end = (r_H_count == HMAX - 1) && (r_V_count == VMAX - 1);
    assign o_Frame_start = (r_H_count == 0) && (r_V_count == 0);

endmodule  