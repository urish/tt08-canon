// SPDX-FileCopyrightText: © 2024 Michael Bell
// SPDX-License-Identifier: Apache-2.0

`default_nettype none

module display (
    input logic clk,
    input logic rst_n,

    input logic crotchet,
    input logic phrase,

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
    .hsync      (hsync),
    .vsync      (vsync),
    .blank      (blank),
    .x_pos      (x_pos),
    .y_pos      (y_pos),
    .vsync_pulse(next_frame),
    .next_row   (next_row)
  );

    logic [3:0] mode;
    logic [9:0] frame;  // Around 836 frames per mode

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            mode <= 0;
            frame <= 0;
        end
        else if (phrase) begin
            frame <= 0;
            mode <= mode + 1;
            if (mode == 4'd13) mode <= 0;
        end
        else if (next_frame) begin
            frame <= frame + 1;
        end
    end

    logic in_line;
    line_render i_lr (
        .clk(clk),
        .rst_n(rst_n),
        .mode(mode),
        .frame(frame),
        .x_pos(x_pos),
        .y_pos(y_pos),
        .next_frame(next_frame),
        .next_row(next_row),
        .in_line(in_line)
    );

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            colour <= 0;
        end
        else begin
            colour <= in_line ? 6'h3c : 6'h01;
        end
    end

endmodule
