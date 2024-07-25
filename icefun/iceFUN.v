/*
 * Copyright (c) 2024 Michael Bell
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module pwm_audio_top (
        input clk12MHz,

        output pwm,

        output [7:0] uo_out

);
    wire locked;
    wire clk;

    // 39.75 MHz PLL
    SB_PLL40_CORE #(
    .FEEDBACK_PATH("SIMPLE"),
    .DIVR(4'b0000),         // DIVR =  0
    .DIVF(7'd56),
    .DIVQ(3'b100),          // DIVQ =  4
    .FILTER_RANGE(3'b001)   // FILTER_RANGE = 1
    ) uut (
    .LOCK(locked),
    .RESETB(1'b1),
    .BYPASS(1'b0),
    .REFERENCECLK(clk12MHz),
    .PLLOUTCORE(clk)
    );


    wire crotchet;
    wire phrase;

    pwm_music i_music(
        .clk(clk),
        .rst_n(locked),

        .pwm(pwm),

        .crotchet(crotchet),
        .phrase(phrase)
    );

    wire [5:0] video_colour;
    wire vga_blank;
    display i_display(
        .clk(clk),
        .rst_n(locked),

        .crotchet(crotchet),
        .phrase(phrase),

        .hsync(uo_out[7]),
        .vsync(uo_out[3]),
        .blank(vga_blank),
        .colour(video_colour)
    );

  assign uo_out[0] = vga_blank ? 1'b0 : video_colour[5];
  assign uo_out[1] = vga_blank ? 1'b0 : video_colour[3];
  assign uo_out[2] = vga_blank ? 1'b0 : video_colour[1];
  assign uo_out[4] = vga_blank ? 1'b0 : video_colour[4];
  assign uo_out[5] = vga_blank ? 1'b0 : video_colour[2];
  assign uo_out[6] = vga_blank ? 1'b0 : video_colour[0];    

endmodule
