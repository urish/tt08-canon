// SPDX-FileCopyrightText: © 2024 Michael Bell
// SPDX-License-Identifier: Apache-2.0

`default_nettype none

module display (
    input logic clk,
    input logic rst_n,

    input logic [6:0] crotchet,
    input logic crotchet_pulse,

    output logic       hsync,
    output logic       vsync,
    output logic       blank,
    output logic [5:0] colour

);

    logic [9:0] x_pos;
    logic [9:0] y_pos;
    logic next_frame;
    logic next_row;
    logic hblank;

  vga i_vga (
    .clk        (clk),
    .reset_n    (rst_n),
    .hsync      (hsync),
    .vsync      (vsync),
    .blank      (blank),
    .x_pos      (x_pos),
    .y_pos      (y_pos),
    .vsync_pulse(next_frame),
    .next_row   (next_row),
    .hblank     (hblank)
  );

    // Frame control data - this controls the overall sequence.  There are
    // 13 phrases of 8 crotchets in total.
    function [6:0] y_idx_reset_value(input [6:0] idx);
        case (idx)
        default: y_idx_reset_value = 7'd0;
        endcase
    endfunction

    function frame_reset_ctrl(input [6:0] idx);
        case (idx)
        default: frame_reset_ctrl = 1'b0;
        0: frame_reset_ctrl = 1'b1;
        8: frame_reset_ctrl = 1'b1;
        16: frame_reset_ctrl = 1'b1;
        24: frame_reset_ctrl = 1'b1;
        32: frame_reset_ctrl = 1'b1;
        40: frame_reset_ctrl = 1'b1;
        48: frame_reset_ctrl = 1'b1;
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
        case (idx[2:0])
        default: frame_count_ctrl = 1'b1;
        0: frame_count_ctrl = 1'b0;
        5,6,7: frame_count_ctrl = 1'b0;
        endcase
    endfunction


    logic reset_at_next_frame;
    logic [8:0] frame;  // Around 416 frames per phrase

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            frame <= 0;
            reset_at_next_frame <= 0;
        end
        else if (crotchet_pulse && frame_reset_ctrl(crotchet)) begin
            reset_at_next_frame <= 1;
        end
        else if (next_frame) begin
            if (reset_at_next_frame) frame <= 0;
            else frame <= frame + frame_count_ctrl(crotchet);
            reset_at_next_frame <= 0;
        end
    end


    //  -----------------------------------
    //  Line Renderer

    logic in_line;

    // Line data ROM: Y start/end values - Y coord / 4
    function [7:0] y_value(input [6:0] idx);
        case (idx)
 0: y_value = 8'd74;  // 45
 1: y_value = 8'd74;  // 55
 2: y_value = 8'd74;  // 64
 3: y_value = 8'd74;  // 74
 4: y_value = 8'd74;  // 82
 5: y_value = 8'd74; // 102
 6: y_value = 8'd255;
default: y_value = 8'dx;
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
default: y_offset = 8'dx;
        endcase
    endfunction

    // Line data ROM: X start/end values, 4 per line - X coord / 4
    function [7:0] x_value(input [8:0] idx);
        case (idx)
  4: x_value = 8'd100;
  5: x_value = 8'd100;
  6: x_value = 8'd255;
  7: x_value = 8'd255;
  8: x_value = 8'd100;
  9: x_value = 8'd100;
 10: x_value = 8'd255;
 11: x_value = 8'd255;
 12: x_value = 8'd100;
 13: x_value = 8'd100;
 14: x_value = 8'd255;
 15: x_value = 8'd255;
 16: x_value = 8'd100;
 17: x_value = 8'd100;
 18: x_value = 8'd100;
 19: x_value = 8'd100;
 20: x_value = 8'd100;
 21: x_value = 8'd100;
 22: x_value = 8'd255;
 23: x_value = 8'd255;
default: x_value = 8'd255;
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
default: x_offset = 8'd0;
        endcase
    endfunction

    logic [6:0] y_idx;
    logic [1:0] x_idx_r;
    logic [8:0] x_idx;
    assign x_idx = {y_idx, x_idx_r};

    logic y_sel;
    logic signed [2:-5] offset_in;
    logic signed [12:-5] scaled_offset;
    logic [10:0] next_offset;
    logic idx_match;

    assign y_sel = next_row || hblank;
    assign offset_in = y_sel ? y_offset(y_idx) : x_offset(x_idx);
    assign scaled_offset = $signed(offset_in) * $signed({1'b0,frame});
    assign next_offset = (y_sel ? {1'b0, y_value(y_idx), 2'b00} : {1'b0, x_value(x_idx), 1'b0, x_idx[0]}) + scaled_offset[10:0];

    assign idx_match = next_offset[9:0] == (y_sel ? y_pos : x_pos);

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


    always_ff @(posedge clk) begin
        if (!rst_n) begin
            colour <= 0;
        end
        else begin
            colour <= in_line ? 6'h3c : 6'h01;
        end
    end

endmodule
