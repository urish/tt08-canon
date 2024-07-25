// SPDX-FileCopyrightText: © 2022 Leo Moser <leo.moser@pm.me>, 2024 Michael Bell
// SPDX-License-Identifier: Apache-2.0

`default_nettype none

    /*
        Default parameters are SVGA 800x600
        clock = 42.75MHz for 66.58 Hz
    */

module vga #(
    parameter WIDTH=800,    // display width
    parameter HEIGHT=600,   // display height
    parameter HFRONT=32,    // horizontal front porch
    parameter HSYNC=80,     // horizontal sync
    parameter HBACK=112,     // horizontal back porch
    parameter VFRONT=3,    // vertical front porch
    parameter VSYNC=4,      // vertical sync
    parameter VBACK=20      // vertical back porch
)(
    input  logic clk,       // clock
    input  logic reset_n,   // reset
    output logic hsync,     // 1'b1 if in hsync region
    output logic vsync,     // 1'b1 if in vsync region
    output logic blank,     // 1'b1 if in blank region
    output logic [9:0] x_pos,
    output logic [9:0] y_pos,
    output logic vsync_pulse
);

    localparam HTOTAL = WIDTH + HFRONT + HSYNC + HBACK;
    localparam VTOTAL = HEIGHT + VFRONT + VSYNC + VBACK;

    logic signed [$clog2(HTOTAL-1) : 0] x_pos_internal;
    logic signed [$clog2(VTOTAL-1) : 0] y_pos_internal;

    /* Horizontal and Vertical Timing */
    
    logic hblank;
    logic vblank;
    logic vblank_w;
    logic next_row;
    logic next_frame;
     
    // Horizontal timing
    timing #(
        .RESOLUTION     (WIDTH),
        .FRONT_PORCH    (HFRONT),
        .SYNC_PULSE     (HSYNC),
        .BACK_PORCH     (HBACK),
        .TOTAL          (HTOTAL),
        .POLARITY       (1'b0)
    ) timing_hor (
        .clk        (clk),
        .enable     (1'b1),
        .reset_n    (reset_n),
        .sync       (hsync),
        .blank      (hblank),
        .next       (next_row),
        .counter    (x_pos_internal)
    );

    // Vertical timing
    timing #(
        .RESOLUTION     (HEIGHT),
        .FRONT_PORCH    (VFRONT),
        .SYNC_PULSE     (VSYNC),
        .BACK_PORCH     (VBACK),
        .TOTAL          (VTOTAL),
        .POLARITY       (1'b1)
    ) timing_ver (
        .clk        (clk),
        .enable     (x_pos_internal == WIDTH - 1),
        .reset_n    (reset_n),
        .sync       (vsync),
        .blank      (vblank_w),
        .next       (next_frame),
        .counter    (y_pos_internal)
    );

    assign blank = hblank || vblank;
    assign vsync_pulse = next_row && (y_pos_internal == -VBACK - VSYNC + 1);
    //assign hsync_pulse = x_pos_internal == -HBACK;

    assign x_pos = x_pos_internal[9:0];
    assign y_pos = y_pos_internal[9:0];

    always_ff @(posedge clk) vblank <= vblank_w;

endmodule