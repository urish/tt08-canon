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

  vga i_vga (
    .clk        (clk),
    .reset_n    (rst_n),
    .hsync      (hsync),
    .vsync      (vsync),
    .blank      (blank),
    .x_pos      (x_pos),
    .y_pos      (y_pos),
    .vsync_pulse(next_frame)
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

    logic [1:0] shift;
    assign shift = (mode < 4) ? 2 : 
                   (mode < 10) ? 1 : 0;

    always_ff @(posedge clk) begin
        //if (y_pos == 418) colour = 6'h3f;
        //else if (x_pos < (mode << 3) || y_pos < (frame >> 1)) colour <= 0;
        //else colour <= x_pos + y_pos;
        if (mode == 0) colour <= 1;
        else colour <= x_pos + y_pos + (frame >> shift);
    end

endmodule