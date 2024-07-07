`default_nettype none

module pwm_sample (
    input wire clk,
    input wire rst_n,

    input wire [12:0] divider1,  // Ouput frequency is clk / (128 * (divider+1)), giving a minimum frequency of ~47Hz at a 50MHz clock
    input wire [10:0] divider2,
    input wire [10:0] divider3,
    input wire [10:0] divider4,

    output reg [6:0] sample1,
    output reg [6:0] sample2,
    output reg [6:0] sample3,
    output reg [6:0] sample4
);

    // The sample is a complete wave over 256 entries.
    // Every divider+1 clocks, we move to the next entry in the table.
    reg [12:0] count1;
    reg [10:0] count2;
    reg [10:0] count3;
    reg [10:0] count4;
    reg [6:0] sample_idx1;
    reg [6:0] sample_idx2;
    reg [6:0] sample_idx3;
    reg [6:0] sample_idx4;

    always @(posedge clk) begin
        if (!rst_n) begin
            count1 <= 0;
            count2 <= 0;
            count3 <= 0;
            count4 <= 0;
            sample_idx1 <= 0;
            sample_idx2 <= 0;
            sample_idx3 <= 0;
            sample_idx4 <= 0;
        end
        else begin
            count1 <= count1 - 1;
            count2 <= count2 - 1;
            count3 <= count3 - 1;
            count4 <= count4 - 1;
            if (count1 == 0) begin
                count1 <= divider1;
                sample_idx1 <= sample_idx1 + 1;
            end
            if (count2 == 0) begin
                count2 <= divider2;
                sample_idx2 <= sample_idx2 + 1;
            end
            if (count3 == 0) begin
                count3 <= divider3;
                sample_idx3 <= sample_idx3 + 1;
            end
            if (count4 == 0) begin
                count4 <= divider4;
                sample_idx4 <= sample_idx4 + 1;
            end
        end
    end

    // From a cello
    function [6:0] sample_rom(input [6:0] val);
        case (val)
0: sample_rom = 7'd117;
1: sample_rom = 7'd115;
2: sample_rom = 7'd109;
3: sample_rom = 7'd106;
4: sample_rom = 7'd106;
5: sample_rom = 7'd100;
6: sample_rom = 7'd94;
7: sample_rom = 7'd89;
8: sample_rom = 7'd83;
9: sample_rom = 7'd79;
10: sample_rom = 7'd68;
11: sample_rom = 7'd63;
12: sample_rom = 7'd62;
13: sample_rom = 7'd54;
14: sample_rom = 7'd36;
15: sample_rom = 7'd26;
16: sample_rom = 7'd22;
17: sample_rom = 7'd25;
18: sample_rom = 7'd8;
19: sample_rom = 7'd4;
20: sample_rom = 7'd7;
21: sample_rom = 7'd2;
22: sample_rom = 7'd3;
23: sample_rom = 7'd10;
24: sample_rom = 7'd20;
25: sample_rom = 7'd37;
26: sample_rom = 7'd39;
27: sample_rom = 7'd40;
28: sample_rom = 7'd42;
29: sample_rom = 7'd35;
30: sample_rom = 7'd50;
31: sample_rom = 7'd61;
32: sample_rom = 7'd63;
33: sample_rom = 7'd56;
34: sample_rom = 7'd42;
35: sample_rom = 7'd50;
36: sample_rom = 7'd63;
37: sample_rom = 7'd72;
38: sample_rom = 7'd74;
39: sample_rom = 7'd63;
40: sample_rom = 7'd59;
41: sample_rom = 7'd61;
42: sample_rom = 7'd62;
43: sample_rom = 7'd65;
44: sample_rom = 7'd70;
45: sample_rom = 7'd74;
46: sample_rom = 7'd87;
47: sample_rom = 7'd95;
48: sample_rom = 7'd100;
49: sample_rom = 7'd104;
50: sample_rom = 7'd101;
51: sample_rom = 7'd97;
52: sample_rom = 7'd95;
53: sample_rom = 7'd93;
54: sample_rom = 7'd90;
55: sample_rom = 7'd77;
56: sample_rom = 7'd67;
57: sample_rom = 7'd65;
58: sample_rom = 7'd61;
59: sample_rom = 7'd56;
60: sample_rom = 7'd43;
61: sample_rom = 7'd32;
62: sample_rom = 7'd28;
63: sample_rom = 7'd24;
64: sample_rom = 7'd23;
65: sample_rom = 7'd17;
66: sample_rom = 7'd11;
67: sample_rom = 7'd10;
68: sample_rom = 7'd15;
69: sample_rom = 7'd28;
70: sample_rom = 7'd37;
71: sample_rom = 7'd46;
72: sample_rom = 7'd42;
73: sample_rom = 7'd45;
74: sample_rom = 7'd63;
75: sample_rom = 7'd79;
76: sample_rom = 7'd97;
77: sample_rom = 7'd92;
78: sample_rom = 7'd82;
79: sample_rom = 7'd81;
80: sample_rom = 7'd85;
81: sample_rom = 7'd97;
82: sample_rom = 7'd107;
83: sample_rom = 7'd100;
84: sample_rom = 7'd85;
85: sample_rom = 7'd80;
86: sample_rom = 7'd80;
87: sample_rom = 7'd80;
88: sample_rom = 7'd71;
89: sample_rom = 7'd59;
90: sample_rom = 7'd56;
91: sample_rom = 7'd59;
92: sample_rom = 7'd66;
93: sample_rom = 7'd65;
94: sample_rom = 7'd52;
95: sample_rom = 7'd43;
96: sample_rom = 7'd41;
97: sample_rom = 7'd48;
98: sample_rom = 7'd55;
99: sample_rom = 7'd54;
100: sample_rom = 7'd50;
101: sample_rom = 7'd50;
102: sample_rom = 7'd52;
103: sample_rom = 7'd58;
104: sample_rom = 7'd63;
105: sample_rom = 7'd67;
106: sample_rom = 7'd69;
107: sample_rom = 7'd69;
108: sample_rom = 7'd68;
109: sample_rom = 7'd66;
110: sample_rom = 7'd65;
111: sample_rom = 7'd67;
112: sample_rom = 7'd70;
113: sample_rom = 7'd77;
114: sample_rom = 7'd79;
115: sample_rom = 7'd78;
116: sample_rom = 7'd77;
117: sample_rom = 7'd82;
118: sample_rom = 7'd87;
119: sample_rom = 7'd93;
120: sample_rom = 7'd90;
121: sample_rom = 7'd89;
122: sample_rom = 7'd90;
123: sample_rom = 7'd100;
124: sample_rom = 7'd104;
125: sample_rom = 7'd110;
126: sample_rom = 7'd116;
127: sample_rom = 7'd119;
        endcase
    endfunction

    reg [6:0] sample_val;
    always @* begin
        case(count1[1:0])
        0: sample_val = sample_idx1;
        1: sample_val = sample_idx2;
        2: sample_val = sample_idx3;
        3: sample_val = sample_idx4;
        endcase
    end

    wire [6:0] sample_mux = sample_rom(sample_val);

    always @(posedge clk) begin
        case(count1[1:0])
        0: sample1 <= sample_mux;
        1: sample2 <= sample_mux;
        2: sample3 <= sample_mux;
        3: sample4 <= sample_mux;
        endcase
    end

endmodule
