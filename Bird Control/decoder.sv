module decoder
#(parameter HMAX = 800,
            VMAX = 525,
            HDISPLAY = 640,
            VDISPLAY = 480,
            H_front_porch = 16,
            H_retrace = 96,
            H_back_porch = 48,
            V_front_porch = 10,
            V_retrace = 2,
            V_back_porch = 33)
(input logic i_Clk,
input logic [$clog2(HMAX)-1:0] i_H_count,
input logic [$clog2(VMAX)-1:0] i_V_count,
output logic o_hsync,
output logic o_vsync,
output logic o_video_on);

    logic w_hsync;
    logic w_vsync;
    logic w_video_on;

    logic r_hsync;
    logic r_vsync;
    logic r_video_on;

    assign w_hsync = (i_H_count < HDISPLAY + H_front_porch || (i_H_count >= HMAX - H_back_porch && i_H_count < HMAX)) ? 1'b1 : 1'b0;

    assign w_vsync = (i_V_count < VDISPLAY + V_front_porch || (i_V_count >= VMAX - V_back_porch && i_V_count < VMAX)) ? 1'b1 : 1'b0;

    assign w_video_on = (i_H_count < HMAX && i_V_count < VMAX) ? 1'b1 : 1'b0; 


    always @(posedge i_Clk) begin
        r_hsync <= w_hsync;
        r_vsync <= w_vsync;
        r_video_on <= w_video_on;
    end

    assign o_hsync = r_hsync;
    assign o_vsync = r_vsync;
    assign o_video_on = r_video_on;

endmodule