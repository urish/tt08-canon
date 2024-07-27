// SPDX-FileCopyrightText: © 2022 Leo Moser <leo.moser@pm.me>, 2024 Michael Bell
// SPDX-License-Identifier: Apache-2.0

`default_nettype none

    /*
        Default parameters are SVGA 800x600
        clock = 36MHz for 56.25 Hz (a VESA standard DMT mode)
    */

module vga #(
    parameter WIDTH=800,    // display width
    parameter HEIGHT=600,   // display height
    parameter HFRONT=24,    // horizontal front porch
    parameter HSYNC=72,     // horizontal sync
    parameter HBACK=128,    // horizontal back porch
    parameter VFRONT=1,     // vertical front porch
    parameter VSYNC=2,      // vertical sync
    parameter VBACK=22      // vertical back porch
)(
    input  logic clk,       // clock
    input  logic reset_n,   // reset
    output logic hsync,     // 1'b1 if in hsync region
    output logic vsync,     // 1'b1 if in vsync region
    output logic blank,     // 1'b1 if in blank region
    output logic [9:0] x_pos,
    output logic [9:0] y_pos,
    output logic vsync_pulse,
    output logic next_row,
    output logic hblank
);

    localparam HTOTAL = WIDTH + HFRONT + HSYNC + HBACK;
    localparam VTOTAL = HEIGHT + VFRONT + VSYNC + VBACK;

    logic signed [$clog2(HTOTAL) : 0] x_pos_internal;
    logic signed [$clog2(VTOTAL) : 0] y_pos_internal;

    /* Horizontal and Vertical Timing */
    
    logic vblank;
    logic vblank_w;
    logic next_frame;
     
    // Horizontal timing
    timing #(
        .RESOLUTION     (WIDTH),
        .FRONT_PORCH    (HFRONT),
        .SYNC_PULSE     (HSYNC),
        .BACK_PORCH     (HBACK),
        .TOTAL          (HTOTAL),
        .POLARITY       (1'b1)
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
        .enable     (next_row),
        .reset_n    (reset_n),
        .sync       (vsync),
        .blank      (vblank_w),
        .next       (next_frame),
        .counter    (y_pos_internal)
    );

    assign blank = hblank || vblank;
    assign vsync_pulse = next_row && (y_pos_internal == -VBACK - VSYNC + 1);

    assign x_pos = blank ? 10'd0 : x_pos_internal[9:0];
    assign y_pos = vblank ? 10'd0 : y_pos_internal[9:0];

    always_ff @(posedge clk) vblank <= vblank_w;

    wire _unused = &{next_frame, 1'b0};

endmodule
