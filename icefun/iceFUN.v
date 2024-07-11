/*
 * Copyright (c) 2024 Michael Bell
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module pwm_audio_top (
        input clk12MHz,

        output pwm

);
    wire locked;
    wire clk;

    // 39.75 MHz PLL
    SB_PLL40_CORE #(
    .FEEDBACK_PATH("SIMPLE"),
    .DIVR(4'b0000),         // DIVR =  0
    .DIVF(7'd52),
    .DIVQ(3'b100),          // DIVQ =  4
    .FILTER_RANGE(3'b001)   // FILTER_RANGE = 1
    ) uut (
    .LOCK(locked),
    .RESETB(1'b1),
    .BYPASS(1'b0),
    .REFERENCECLK(clk12MHz),
    .PLLOUTCORE(clk)
    );

    pwm_music i_music(
        .clk(clk),
        .rst_n(locked),

        .pwm(pwm)
    );

endmodule
