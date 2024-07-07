`default_nettype none

module pwm_music (
    input wire clk,
    input wire rst_n,

    output wire pwm
);

    // The PWM module converts the sample of our sine wave to a PWM output
    wire [7:0] sample;
    wire [11:0] divider;

    pwm_audio i_pwm(
        .clk(clk),
        .rst_n(rst_n),

        .sample(sample),

        .pwm(pwm)
    );

    pwm_sample i_sample(
        .clk(clk),
        .rst_n(rst_n),

        .divider(divider),

        .sample(sample)
    );

    reg [25:0] count;
    reg [2:0] note_idx;

    always @(posedge clk) begin
        if (!rst_n) begin
            count <= 0;
            note_idx <= 3'd7;
        end
        else begin
            count <= count + 1;
            if (count == 0) note_idx <= note_idx + 1;
        end
    end

    // Cello line for Canon, 48MHz project clock
    function [11:0] cello_rom(input [2:0] idx);
        case (idx)
0: cello_rom = 12'd1276;
1: cello_rom = 12'd1703;
2: cello_rom = 12'd1517;
3: cello_rom = 12'd2026;
4: cello_rom = 12'd1912;
5: cello_rom = 12'd2553;
6: cello_rom = 12'd1912;
7: cello_rom = 12'd1703;
        endcase
    endfunction

    assign divider = cello_rom(note_idx);

endmodule
