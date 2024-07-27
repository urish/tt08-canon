// SPDX-FileCopyrightText: © 2024 Michael Bell
// SPDX-License-Identifier: Apache-2.0

`default_nettype none

module display (
    input logic clk,
    input logic rst_n,

    input logic [9:0] low_count,
    input logic [6:0] crotchet,

    output logic       hsync,
    output logic       vsync,
    output logic       blank,
    output logic [5:0] colour

);

    logic [9:0] x_pos;
    logic [9:0] y_pos;
    logic next_frame;
    logic next_row;

  vga i_vga (
    .clk        (clk),
    .reset_n    (rst_n),
    .low_count  (low_count),
    .hsync      (hsync),
    .vsync      (vsync),
    .blank      (blank),
    .x_pos      (x_pos),
    .y_pos      (y_pos),
    .vsync_pulse(next_frame),
    .next_row   (next_row)
  );

    // Frame control data - this controls the overall sequence.  There are
    // 13 phrases of 8 crotchets in total.
    function [6:0] y_idx_reset_value(input [6:0] idx);
        case (idx[5:0])
        0,1,2,3,4: y_idx_reset_value = 7'd0;
        5,6,7: y_idx_reset_value = 7'd8;
        8: y_idx_reset_value = 7'd23;
        9: y_idx_reset_value = 7'd22;
        10: y_idx_reset_value = 7'd21;
        11: y_idx_reset_value = 7'd20;
        12: y_idx_reset_value = 7'd19;
        13: y_idx_reset_value = 7'd18;
        14: y_idx_reset_value = 7'd17;
        15: y_idx_reset_value = 7'd16;
        16,17,18,19,20,21,22,23: y_idx_reset_value = 7'd7;
        48,49,50,51: y_idx_reset_value = 7'd0;
        52,53,54,55: y_idx_reset_value = 7'd8;
        56: y_idx_reset_value = 7'd23;
        57: y_idx_reset_value = 7'd22;
        58: y_idx_reset_value = 7'd21;
        59: y_idx_reset_value = 7'd20;
        60: y_idx_reset_value = 7'd19;
        61: y_idx_reset_value = 7'd18;
        62: y_idx_reset_value = 7'd17;
        63: y_idx_reset_value = 7'd16;
        default: y_idx_reset_value = 7'd15;
        endcase
    endfunction

    function frame_reset_ctrl(input [6:0] idx);
        case (idx)
        default: frame_reset_ctrl = 1'b0;
        0: frame_reset_ctrl = 1'b1;
        8: frame_reset_ctrl = 1'b1;
        16: frame_reset_ctrl = 1'b1;
        //24: frame_reset_ctrl = 1'b1;
        32: frame_reset_ctrl = 1'b1;
        //40: frame_reset_ctrl = 1'b1;
        48: frame_reset_ctrl = 1'b1;
        52: frame_reset_ctrl = 1'b1;
        56: frame_reset_ctrl = 1'b1;
        64: frame_reset_ctrl = 1'b1;
        72: frame_reset_ctrl = 1'b1;
        80: frame_reset_ctrl = 1'b1;
        88: frame_reset_ctrl = 1'b1;
        96: frame_reset_ctrl = 1'b1;
        104: frame_reset_ctrl = 1'b1;
        112: frame_reset_ctrl = 1'b1;
        120: frame_reset_ctrl = 1'b1;
        endcase
    endfunction

    function frame_count_ctrl(input [6:0] idx);
        case (idx[5:0])
        default: frame_count_ctrl = 1'b1;
        0: frame_count_ctrl = 1'b0;
        endcase
    endfunction

    logic [6:0] frame_crotchet;

    logic [9:0] frame;  // Around 416 frames per phrase

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            frame <= 0;
        end
        else if (next_frame) begin
            frame_crotchet <= crotchet;
            frame <= frame + {8'h0, frame_count_ctrl(crotchet)};
            if (frame_crotchet != crotchet) begin
                if (frame_reset_ctrl(crotchet)) frame <= 0;
            end
        end
    end


    //  -----------------------------------
    //  Line Renderer

    logic in_line;

    // Line data ROM: Y start/end values - Y coord / 2
    function [9:0] y_value(input [6:0] idx);
        case (idx)

// Zooming T
 0: y_value = 10'd148;
 1: y_value = 10'd148;
 2: y_value = 10'd148;
 3: y_value = 10'd148;
 4: y_value = 10'd148;
 5: y_value = 10'd148;
 6: y_value = 10'h1ff;

// Curtains
 7: y_value = 10'h1ff;

// Static T
 8: y_value = 10'd52;
 9: y_value = 10'd86;
10: y_value = 10'd115;
11: y_value = 10'd148;
12: y_value = 10'd174;
13: y_value = 10'd239;
14: y_value = 10'h1ff;

// All inside
15: y_value = 10'h1ff;

// Descending blocks + scrolling T
16: y_value = 10'd540;
17: y_value = 10'd610;
18: y_value = 10'd680;
19: y_value = 10'd750;
20: y_value = 10'd820;
21: y_value = 10'd890;
22: y_value = 10'd960;
23: y_value = 10'd0;
24: y_value = 10'd52;
25: y_value = 10'd86;
26: y_value = 10'd115;
27: y_value = 10'd148;
28: y_value = 10'd174;
29: y_value = 10'd239;
30: y_value = 10'h1ff;
default: y_value = 10'dx;
        endcase
    endfunction

    // Line data ROM: Y time offset values - signed 2.5 fixed point
    function signed [2:-5] y_offset(input [6:0] idx);
        case (idx)
 0: y_offset = -8'd29;
 1: y_offset = -8'd19;
 2: y_offset = -8'd10;
 3: y_offset = 8'd0;
 4: y_offset = 8'd8;
 5: y_offset = 8'd28;
 6: y_offset = 8'd0;

 7: y_offset = 8'd0;
 
 8: y_offset = 8'd0;
 9: y_offset = 8'd0;
10: y_offset = 8'd0;
11: y_offset = 8'd0;
12: y_offset = 8'd0;
13: y_offset = 8'd0;
14: y_offset = 8'd0;
16: y_offset = 8'd120;
17: y_offset = 8'd114;
18: y_offset = 8'd108;
19: y_offset = 8'd102;
20: y_offset = 8'd96;
21: y_offset = 8'd90;
22: y_offset = 8'd84;
23: y_offset = 8'd78;
24: y_offset = 8'd78;
25: y_offset = 8'd78;
26: y_offset = 8'd78;
27: y_offset = 8'd78;
28: y_offset = 8'd78;
29: y_offset = 8'd78;
30: y_offset = 8'd78;
default: y_offset = 8'dx;
        endcase
    endfunction

    // Line data ROM: X start/end values, 4 per line - X coord / 2
    function [9:0] x_value(input [8:0] idx);
        case (idx)
  4: x_value = 10'd199;
  5: x_value = 10'd199;
  6: x_value = 10'h1ff;
  7: x_value = 10'h1ff;
  8: x_value = 10'd199;
  9: x_value = 10'd199;
 10: x_value = 10'h1ff;
 11: x_value = 10'h1ff;
 12: x_value = 10'd199;
 13: x_value = 10'd199;
 14: x_value = 10'h1ff;
 15: x_value = 10'h1ff;
 16: x_value = 10'd199;
 17: x_value = 10'd199;
 18: x_value = 10'd199;
 19: x_value = 10'd199;
 20: x_value = 10'd199;
 21: x_value = 10'd199;
 22: x_value = 10'h1ff;
 23: x_value = 10'h1ff;

 28: x_value = 10'd199;
 29: x_value = 10'd199;
 30: x_value = 10'h1ff;
 31: x_value = 10'h1ff;

 36: x_value = 10'd110;
 37: x_value = 10'd221;
 38: x_value = 10'h1ff;
 39: x_value = 10'h1ff;
 40: x_value = 10'd150;
 41: x_value = 10'd183;
 42: x_value = 10'h1ff;
 43: x_value = 10'h1ff;
 44: x_value = 10'd150;
 45: x_value = 10'd284;
 46: x_value = 10'h1ff;
 47: x_value = 10'h1ff;
 48: x_value = 10'd150;
 49: x_value = 10'd183;
 50: x_value = 10'd212;
 51: x_value = 10'd245;
 52: x_value = 10'd212;
 53: x_value = 10'd245;
 54: x_value = 10'h1ff;
 55: x_value = 10'h1ff;

 60: x_value = 10'd0;
 61: x_value = 10'h1ff;
 62: x_value = 10'h1ff;
 63: x_value = 10'h1ff;

 64: x_value = 10'd0;
 65: x_value = 10'h1ff;
 66: x_value = 10'h1ff;
 67: x_value = 10'h1ff;
 68: x_value = 10'd0;
 69: x_value = 10'd349;
 70: x_value = 10'h1ff;
 71: x_value = 10'h1ff;
 72: x_value = 10'd0;
 73: x_value = 10'd299;
 74: x_value = 10'h1ff;
 75: x_value = 10'h1ff;
 76: x_value = 10'd0;
 77: x_value = 10'd249;
 78: x_value = 10'h1ff;
 79: x_value = 10'h1ff;
 80: x_value = 10'd0;
 81: x_value = 10'd199;
 82: x_value = 10'h1ff;
 83: x_value = 10'h1ff;
 84: x_value = 10'd0;
 85: x_value = 10'd149;
 86: x_value = 10'h1ff;
 87: x_value = 10'h1ff;
 88: x_value = 10'd0;
 89: x_value = 10'd99;
 90: x_value = 10'h1ff;
 91: x_value = 10'h1ff;
 92: x_value = 10'd0;
 93: x_value = 10'd49;
 94: x_value = 10'h1ff;
 95: x_value = 10'h1ff;

100: x_value = 10'd110;
101: x_value = 10'd221;
102: x_value = 10'h1ff;
103: x_value = 10'h1ff;
104: x_value = 10'd150;
105: x_value = 10'd183;
106: x_value = 10'h1ff;
107: x_value = 10'h1ff;
108: x_value = 10'd150;
109: x_value = 10'd284;
110: x_value = 10'h1ff;
111: x_value = 10'h1ff;
112: x_value = 10'd150;
113: x_value = 10'd183;
114: x_value = 10'd212;
115: x_value = 10'd245;
116: x_value = 10'd212;
117: x_value = 10'd245;
118: x_value = 10'h1ff;
119: x_value = 10'h1ff;
default: x_value = 10'h1ff;
        endcase
    endfunction    

    // Line data ROM: X time offset values - signed 2.5 fixed point
    function signed [2:-5] x_offset(input [8:0] idx);
        case (idx)
  4: x_offset = -8'd27;
  5: x_offset = 8'd7;
  6: x_offset = 8'd0;
  7: x_offset = 8'd0;
  8: x_offset = -8'd15;
  9: x_offset = -8'd5;
 10: x_offset = 8'd0;
 11: x_offset = 8'd0;
 12: x_offset = -8'd15;
 13: x_offset = 8'd26;
 14: x_offset = 8'd0;
 15: x_offset = 8'd0;
 16: x_offset = -8'd15;
 17: x_offset = -8'd5;
 18: x_offset = 8'd4;
 19: x_offset = 8'd14;
 20: x_offset = 8'd4;
 21: x_offset = 8'd14;
 22: x_offset = 8'd0;
 23: x_offset = 8'd0;

 28: x_offset = -8'd30;
 29: x_offset = 8'd30;

default: x_offset = 8'd0;
        endcase
    endfunction

    logic [6:0] y_idx;
    logic [1:0] x_idx_r;
    logic [8:0] x_idx;
    assign x_idx = {y_idx, x_idx_r};

    logic y_sel;
    logic signed [2:-5] offset_in;

    /* verilator lint_off UNUSEDSIGNAL */
    logic signed [12:-5] scaled_offset;
    /* verilator lint_on UNUSEDSIGNAL */
    logic [10:0] xy_value;
    logic [10:0] next_offset;
    logic idx_match;

    assign y_sel = next_row || hsync;
    assign offset_in = y_sel ? y_offset(y_idx) : x_offset(x_idx);
    assign scaled_offset = $signed(offset_in) * $signed({1'b0,frame});
    assign xy_value = y_sel ? {y_value(y_idx), 1'b0} : {x_value(x_idx), x_idx[0]};
    assign next_offset = xy_value + scaled_offset[10:0];

    assign idx_match = next_offset == {1'b0, (y_sel ? y_pos : x_pos)};

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            y_idx <= 0;
        end
        else if (next_frame) begin
            y_idx <= y_idx_reset_value(crotchet);
        end
        else if (y_sel) begin
            if (idx_match) y_idx <= y_idx + 1;
        end
    end

    always_ff @(posedge clk) begin
        if (!rst_n || next_frame) begin
            x_idx_r <= 0;
            in_line <= 0;
        end
        else if (y_sel) begin
            x_idx_r[1:0] <= 2'b00;
            in_line <= 0;
        end
        else if (idx_match) begin
            x_idx_r[1:0] <= x_idx_r[1:0] + 1;
            in_line <= !in_line;
        end
    end    

    function [5:0] outside_colour(input [6:0] idx);
        case (idx[5:0])
         0, 1, 2, 3, 4, 5, 6, 7: outside_colour = 6'h01;
         8, 9,10,11,12,13,14,15: outside_colour = 6'h01;
        16,17,18,19,20,21,22,23: outside_colour = 6'h3c;
        24,25,26,27,28,29,30,31: outside_colour = 6'h3c;
        default: outside_colour = 6'h01;
        endcase
    endfunction

    function [5:0] inside_colour(input [6:0] idx);
        case (idx[5:0])
         0, 1, 2, 3, 4, 5, 6, 7: inside_colour = 6'h3c;
         8, 9,10,11,12,13,14,15: inside_colour = 6'h3c;
        16,17,18,19,20,21,22,23: inside_colour = 6'h00;
        24,25,26,27,28,29,30,31: inside_colour = 6'h00;
        default: inside_colour = 6'h01;
        endcase
    endfunction

    logic [9:0] abs_x;
    logic [9:0] abs_y;
    logic [9:0] diamond_dist;

    always_comb begin : compute_abs
        abs_x = x_pos - 400;
        if (abs_x[9]) abs_x = -abs_x;

        abs_y = y_pos - 300;
        if (abs_y[9]) abs_y = -abs_y;

        diamond_dist = abs_x + abs_y;
    end

    logic [6:1] frame_plus_dist = diamond_dist[6:1] - frame[6:1];

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            colour <= 0;
        end
        else begin
            colour <= in_line ? inside_colour(frame_crotchet) : outside_colour(frame_crotchet);
            if (frame_crotchet[4]) begin
                if (diamond_dist < {1'b0, frame[9:1]}) begin
                    colour <= {1'b0, frame_crotchet[3], 1'b0, frame_crotchet[2], 1'b0, frame_crotchet[1]} * diamond_dist[3:2];
                end
            end
            if (frame_crotchet[5]) begin
                if (!frame_crotchet[4]) begin
                    if (diamond_dist < 416) begin
                        colour <= {1'b0, 1'b1, 1'b0, frame_crotchet[2], 1'b0, frame_crotchet[1]} * frame_plus_dist[3:2];
                    end
                end else begin
                    if (in_line) colour <= (frame_crotchet[3:2] == 1) ? frame_plus_dist : diamond_dist[6:1];
                    else colour <= 0;
                end
            end
        end
    end

endmodule
