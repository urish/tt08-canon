// SPDX-FileCopyrightText: © 2024 Michael Bell
// SPDX-License-Identifier: Apache-2.0

`default_nettype none

module line_render (
    input logic clk,
    input logic rst_n,

    input logic [3:0] mode,
    input logic [9:0] frame,
    input logic [9:0] x_pos,
    input logic [9:0] y_pos,
    input logic next_frame,
    input logic next_row,

    output logic in_line
);

    // Line data ROM: Y start/end values - Y coord / 4
    function [7:0] y_value(input [2:0] idx);
        case (idx)
0: y_value = 8'd45;
1: y_value = 8'd55;
2: y_value = 8'd64;
3: y_value = 8'd74;
4: y_value = 8'd82;
5: y_value = 8'd102;
6: y_value = 8'd255;
default: y_value = 8'dx;
        endcase
    endfunction

    // Line data ROM: Y time offset values - signed 2.5 fixed point
    function signed [2:-5] y_offset(input [2:0] idx);
        case (idx)
0: y_offset = -8'd0;
1: y_offset = -8'd0;
2: y_offset = 8'd0;
3: y_offset = 8'd0;
4: y_offset = 8'd0;
5: y_offset = 8'd0;
6: y_offset = 8'd0;
default: y_offset = 8'dx;
        endcase
    endfunction

    // Line data ROM: X start/end values, 4 per line - X coord / 4
    function [7:0] x_value(input [4:0] idx);
        case (idx)
  4: x_value = 8'd73;
  5: x_value = 8'd107;
  6: x_value = 8'd255;
  7: x_value = 8'd255;
  8: x_value = 8'd85;
  9: x_value = 8'd95;
 10: x_value = 8'd255;
 11: x_value = 8'd255;
 12: x_value = 8'd85;
 13: x_value = 8'd126;
 14: x_value = 8'd255;
 15: x_value = 8'd255;
 16: x_value = 8'd85;
 17: x_value = 8'd95;
 18: x_value = 8'd104;
 19: x_value = 8'd114;
 20: x_value = 8'd104;
 21: x_value = 8'd114;
 22: x_value = 8'd255;
 23: x_value = 8'd255;
default: x_value = 8'd255;
        endcase
    endfunction    

    logic signed [12:-5] scaled_y_offset = $signed(y_offset(y_idx)) * $signed({1'b0,frame});
    logic [10:0] next_y_with_offset = {y_value(y_idx), 2'b00} + scaled_y_offset[10:0];

    logic [2:0] y_idx;
    logic [4:0] x_idx;

    logic y_idx_match = next_y_with_offset[9:0] == y_pos;
    logic x_idx_match = {x_value(x_idx), 2'b00} == x_pos;

    always_ff @(posedge clk) begin
        if (!rst_n || next_frame) begin
            y_idx <= 0;
        end
        else begin
            if (y_idx_match) y_idx <= y_idx + 1;
        end
    end

    always_ff @(posedge clk) begin
        if (!rst_n || next_frame) begin
            x_idx <= 0;
            in_line <= 0;
        end
        else if (y_idx_match) begin
            x_idx <= {x_idx[4:2] + 1'b1, 2'b00};
            in_line <= 0;
        end
        else if (next_row) begin
            x_idx[1:0] <= 2'b00;
            in_line <= 0;
        end
        else if (x_idx_match) begin
            x_idx[1:0] <= x_idx[1:0] + 1;
            in_line <= !in_line;
        end
    end    

endmodule
