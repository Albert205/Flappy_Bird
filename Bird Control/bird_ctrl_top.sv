module bird_ctrl_top
(input logic i_Clk,
 input logic i_Switch_1,
 input logic i_Switch_2,

input logic i_UART_RX,
output logic o_UART_TX,

output logic o_Segment1_A,
output logic o_Segment1_B,
output logic o_Segment1_C,
output logic o_Segment1_D,
output logic o_Segment1_E,
output logic o_Segment1_F,
output logic o_Segment1_G,

output logic o_Segment2_A,
output logic o_Segment2_B,
output logic o_Segment2_C,
output logic o_Segment2_D,
output logic o_Segment2_E,
output logic o_Segment2_F,
output logic o_Segment2_G,

output logic o_VGA_HSync,
output logic o_VGA_VSync,
output logic o_VGA_Red_0,
output logic o_VGA_Red_1,
output logic o_VGA_Red_2,
output logic o_VGA_Green_0,
output logic o_VGA_Green_1,
output logic o_VGA_Green_2,
output logic o_VGA_Blue_0,
output logic o_VGA_Blue_1,
output logic o_VGA_Blue_2);

    localparam DEBOUNCE_LIMIT = 250000;
    localparam HMAX = 800;
    localparam VMAX = 525;
    localparam HEIGHT = 30;
    localparam VIDEO_WIDTH = 3;
    localparam BIT_PERIOD_CLKs = 217;

    logic w_Switch_1, w_Switch_2;

    logic [7:0] w_RX_Byte;
    logic w_RX_DV;
    logic w_TX_Active;
    logic w_TX_Serial;

    logic [$clog2(HMAX)-1:0] w_H_count;
    logic [$clog2(VMAX)-1:0] w_V_count;

    logic [$clog2(HEIGHT)-1:0] w_V_pos;

    logic w_Reset;
    logic w_Start;

    logic w_Draw_Bird;

    logic w_Segment1_A, w_Segment1_B, w_Segment1_C, w_Segment1_D, w_Segment1_E, w_Segment1_F, w_Segment1_G;

    assign o_Segment1_A = !w_Segment1_A;
    assign o_Segment1_B = !w_Segment1_B;
    assign o_Segment1_C = !w_Segment1_C;
    assign o_Segment1_D = !w_Segment1_D;
    assign o_Segment1_E = !w_Segment1_E;
    assign o_Segment1_F = !w_Segment1_F;
    assign o_Segment1_G = !w_Segment1_G;

    logic w_Segment2_A, w_Segment2_B, w_Segment2_C, w_Segment2_D, w_Segment2_E, w_Segment2_F, w_Segment2_G;

    assign o_Segment2_A = !w_Segment2_A;
    assign o_Segment2_B = !w_Segment2_B;
    assign o_Segment2_C = !w_Segment2_C;
    assign o_Segment2_D = !w_Segment2_D;
    assign o_Segment2_E = !w_Segment2_E;
    assign o_Segment2_F = !w_Segment2_F;
    assign o_Segment2_G = !w_Segment2_G;

    UART_RX #(.BIT_PERIOD(BIT_PERIOD_CLKs)) UART_RX_INST
    (.i_Clk(i_Clk),
    .i_RX_Serial(i_UART_RX),
    .o_RX_DV(w_RX_DV),
    .o_RX_byte(w_RX_Byte));

    UART_TX #(.BIT_PERIOD(BIT_PERIOD_CLKs)) UART_TX_INST
    (.i_Clk(i_Clk),
    .i_TX_DV(w_RX_DV),
    .i_TX_Byte(w_RX_Byte),
    .o_TX_Active(w_TX_Active),
    .o_TX_Serial(w_TX_Serial),
    .o_TX_Done());

    assign o_UART_TX = w_TX_Active ? w_TX_Serial : 1'b1;

    Binary_To_7Segment Left_Display
    (.i_Clk(i_Clk),
    .i_Binary_Num(w_RX_Byte[3:0]),
    .o_Segment_A(w_Segment2_A),
    .o_Segment_B(w_Segment2_B),
    .o_Segment_C(w_Segment2_C),
    .o_Segment_D(w_Segment2_D),
    .o_Segment_E(w_Segment2_E),
    .o_Segment_F(w_Segment2_F),
    .o_Segment_G(w_Segment2_G));

    Binary_To_7Segment Right_Display
    (.i_Clk(i_Clk),
    .i_Binary_Num(w_RX_Byte[7:4]),
    .o_Segment_A(w_Segment1_A),
    .o_Segment_B(w_Segment1_B),
    .o_Segment_C(w_Segment1_C),
    .o_Segment_D(w_Segment1_D),
    .o_Segment_E(w_Segment1_E),
    .o_Segment_F(w_Segment1_F),
    .o_Segment_G(w_Segment1_G));

    Debounce_Filter #(.DEBOUNCE_LIMIT(DEBOUNCE_LIMIT)) Debounce_Switch_1
    (.i_Clk(i_Clk),
    .i_Bouncy(i_Switch_1),
    .o_Debounced(w_Switch_1));

     Debounce_Filter #(.DEBOUNCE_LIMIT(DEBOUNCE_LIMIT)) Debounce_Switch_2
    (.i_Clk(i_Clk),
    .i_Bouncy(i_Switch_2),
    .o_Debounced(w_Switch_2));

    SW_toggle Toggle_Reset
    (.i_Switch(w_Switch_1),
    .i_Clk(i_Clk),
    .o_Toggle(w_Reset));

    SW_toggle Toggle_Start
    (.i_Switch(w_Switch_2),
    .i_Clk(i_Clk),
    .o_Toggle(w_Start));

    bird_ctrl_fsm bird_ctrl_Inst
    (.i_Clk(i_Clk),
     .i_Reset(w_Reset),
     .i_X_Count(w_H_count),
     .i_Y_Count(w_V_count),
     .i_Start(w_Start),
     .i_Bounce(w_Start),
     .o_Draw_Bird(w_Draw_Bird),
     .o_Dead());

    assign o_VGA_Red_0 = w_Draw_Bird ? 1'b1 : 1'b0;
    assign o_VGA_Red_1 = w_Draw_Bird ? 1'b1 : 1'b0;
    assign o_VGA_Red_2 = w_Draw_Bird ? 1'b1 : 1'b0;

    assign o_VGA_Green_0 = w_Draw_Bird ? 1'b1 : 1'b0;
    assign o_VGA_Green_1 = w_Draw_Bird ? 1'b1 : 1'b0;
    assign o_VGA_Green_2 = w_Draw_Bird ? 1'b1 : 1'b0;

    assign o_VGA_Blue_0 = w_Draw_Bird ? 1'b1 : 1'b0;
    assign o_VGA_Blue_1 = w_Draw_Bird ? 1'b1 : 1'b0;
    assign o_VGA_Blue_2 = w_Draw_Bird ? 1'b1 : 1'b0;

     frame_counter frame_counter_Inst
    (.i_Clk(i_Clk),
    .o_H_count(w_H_count),
    .o_V_count(w_V_count),
    .o_Frame_end(),
    .o_Frame_start());

    decoder decoder_Inst
    (.i_Clk(i_Clk),
    .i_H_count(w_H_count),
    .i_V_count(w_V_count),
    .o_hsync(o_VGA_HSync),
    .o_vsync(o_VGA_VSync),
    .o_video_on());

endmodule