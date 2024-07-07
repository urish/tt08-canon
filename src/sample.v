`default_nettype none

module pwm_sample (
    input wire clk,
    input wire rst_n,

    input wire [11:0] divider1,  // Ouput frequency is clk / (256 * (divider+1)), giving a minimum frequency of ~47Hz at a 50MHz clock
    input wire [9:0] divider2,
    input wire [9:0] divider3,
    input wire [9:0] divider4,

    output reg [6:0] sample1,
    output reg [6:0] sample2,
    output reg [6:0] sample3,
    output reg [6:0] sample4
);

    // The sample is a complete wave over 256 entries.
    // Every divider+1 clocks, we move to the next entry in the table.
    reg [11:0] count1;
    reg [9:0] count2;
    reg [9:0] count3;
    reg [9:0] count4;
    reg [7:0] sample_idx1;
    reg [7:0] sample_idx2;
    reg [7:0] sample_idx3;
    reg [7:0] sample_idx4;

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
    function [6:0] sample_rom(input [7:0] val);
        case (val)
0: sample_rom = 7'd117;
1: sample_rom = 7'd116;
2: sample_rom = 7'd115;
3: sample_rom = 7'd110;
4: sample_rom = 7'd109;
5: sample_rom = 7'd106;
6: sample_rom = 7'd106;
7: sample_rom = 7'd106;
8: sample_rom = 7'd106;
9: sample_rom = 7'd105;
10: sample_rom = 7'd99;
11: sample_rom = 7'd96;
12: sample_rom = 7'd94;
13: sample_rom = 7'd90;
14: sample_rom = 7'd89;
15: sample_rom = 7'd84;
16: sample_rom = 7'd83;
17: sample_rom = 7'd82;
18: sample_rom = 7'd78;
19: sample_rom = 7'd76;
20: sample_rom = 7'd67;
21: sample_rom = 7'd65;
22: sample_rom = 7'd63;
23: sample_rom = 7'd63;
24: sample_rom = 7'd62;
25: sample_rom = 7'd56;
26: sample_rom = 7'd53;
27: sample_rom = 7'd49;
28: sample_rom = 7'd36;
29: sample_rom = 7'd33;
30: sample_rom = 7'd25;
31: sample_rom = 7'd23;
32: sample_rom = 7'd22;
33: sample_rom = 7'd25;
34: sample_rom = 7'd25;
35: sample_rom = 7'd12;
36: sample_rom = 7'd7;
37: sample_rom = 7'd3;
38: sample_rom = 7'd5;
39: sample_rom = 7'd6;
40: sample_rom = 7'd7;
41: sample_rom = 7'd5;
42: sample_rom = 7'd2;
43: sample_rom = 7'd2;
44: sample_rom = 7'd3;
45: sample_rom = 7'd9;
46: sample_rom = 7'd10;
47: sample_rom = 7'd17;
48: sample_rom = 7'd21;
49: sample_rom = 7'd26;
50: sample_rom = 7'd37;
51: sample_rom = 7'd38;
52: sample_rom = 7'd39;
53: sample_rom = 7'd40;
54: sample_rom = 7'd41;
55: sample_rom = 7'd43;
56: sample_rom = 7'd42;
57: sample_rom = 7'd36;
58: sample_rom = 7'd35;
59: sample_rom = 7'd36;
60: sample_rom = 7'd51;
61: sample_rom = 7'd55;
62: sample_rom = 7'd61;
63: sample_rom = 7'd62;
64: sample_rom = 7'd63;
65: sample_rom = 7'd59;
66: sample_rom = 7'd55;
67: sample_rom = 7'd43;
68: sample_rom = 7'd42;
69: sample_rom = 7'd48;
70: sample_rom = 7'd51;
71: sample_rom = 7'd54;
72: sample_rom = 7'd64;
73: sample_rom = 7'd66;
74: sample_rom = 7'd73;
75: sample_rom = 7'd74;
76: sample_rom = 7'd74;
77: sample_rom = 7'd66;
78: sample_rom = 7'd63;
79: sample_rom = 7'd59;
80: sample_rom = 7'd59;
81: sample_rom = 7'd59;
82: sample_rom = 7'd61;
83: sample_rom = 7'd61;
84: sample_rom = 7'd62;
85: sample_rom = 7'd64;
86: sample_rom = 7'd65;
87: sample_rom = 7'd70;
88: sample_rom = 7'd70;
89: sample_rom = 7'd73;
90: sample_rom = 7'd75;
91: sample_rom = 7'd78;
92: sample_rom = 7'd87;
93: sample_rom = 7'd89;
94: sample_rom = 7'd96;
95: sample_rom = 7'd98;
96: sample_rom = 7'd100;
97: sample_rom = 7'd103;
98: sample_rom = 7'd104;
99: sample_rom = 7'd102;
100: sample_rom = 7'd101;
101: sample_rom = 7'd97;
102: sample_rom = 7'd96;
103: sample_rom = 7'd96;
104: sample_rom = 7'd95;
105: sample_rom = 7'd95;
106: sample_rom = 7'd93;
107: sample_rom = 7'd91;
108: sample_rom = 7'd90;
109: sample_rom = 7'd80;
110: sample_rom = 7'd77;
111: sample_rom = 7'd68;
112: sample_rom = 7'd67;
113: sample_rom = 7'd66;
114: sample_rom = 7'd65;
115: sample_rom = 7'd64;
116: sample_rom = 7'd60;
117: sample_rom = 7'd58;
118: sample_rom = 7'd56;
119: sample_rom = 7'd46;
120: sample_rom = 7'd42;
121: sample_rom = 7'd33;
122: sample_rom = 7'd32;
123: sample_rom = 7'd31;
124: sample_rom = 7'd28;
125: sample_rom = 7'd27;
126: sample_rom = 7'd24;
127: sample_rom = 7'd23;
128: sample_rom = 7'd23;
129: sample_rom = 7'd18;
130: sample_rom = 7'd17;
131: sample_rom = 7'd12;
132: sample_rom = 7'd11;
133: sample_rom = 7'd9;
134: sample_rom = 7'd10;
135: sample_rom = 7'd10;
136: sample_rom = 7'd16;
137: sample_rom = 7'd18;
138: sample_rom = 7'd29;
139: sample_rom = 7'd33;
140: sample_rom = 7'd37;
141: sample_rom = 7'd45;
142: sample_rom = 7'd46;
143: sample_rom = 7'd43;
144: sample_rom = 7'd42;
145: sample_rom = 7'd41;
146: sample_rom = 7'd46;
147: sample_rom = 7'd49;
148: sample_rom = 7'd66;
149: sample_rom = 7'd73;
150: sample_rom = 7'd79;
151: sample_rom = 7'd95;
152: sample_rom = 7'd97;
153: sample_rom = 7'd94;
154: sample_rom = 7'd91;
155: sample_rom = 7'd89;
156: sample_rom = 7'd81;
157: sample_rom = 7'd80;
158: sample_rom = 7'd81;
159: sample_rom = 7'd83;
160: sample_rom = 7'd85;
161: sample_rom = 7'd94;
162: sample_rom = 7'd97;
163: sample_rom = 7'd106;
164: sample_rom = 7'd107;
165: sample_rom = 7'd102;
166: sample_rom = 7'd99;
167: sample_rom = 7'd95;
168: sample_rom = 7'd84;
169: sample_rom = 7'd82;
170: sample_rom = 7'd80;
171: sample_rom = 7'd80;
172: sample_rom = 7'd80;
173: sample_rom = 7'd80;
174: sample_rom = 7'd80;
175: sample_rom = 7'd73;
176: sample_rom = 7'd70;
177: sample_rom = 7'd67;
178: sample_rom = 7'd59;
179: sample_rom = 7'd57;
180: sample_rom = 7'd57;
181: sample_rom = 7'd58;
182: sample_rom = 7'd59;
183: sample_rom = 7'd65;
184: sample_rom = 7'd66;
185: sample_rom = 7'd66;
186: sample_rom = 7'd65;
187: sample_rom = 7'd62;
188: sample_rom = 7'd52;
189: sample_rom = 7'd49;
190: sample_rom = 7'd42;
191: sample_rom = 7'd42;
192: sample_rom = 7'd41;
193: sample_rom = 7'd46;
194: sample_rom = 7'd48;
195: sample_rom = 7'd54;
196: sample_rom = 7'd55;
197: sample_rom = 7'd55;
198: sample_rom = 7'd54;
199: sample_rom = 7'd53;
200: sample_rom = 7'd50;
201: sample_rom = 7'd50;
202: sample_rom = 7'd50;
203: sample_rom = 7'd51;
204: sample_rom = 7'd52;
205: sample_rom = 7'd56;
206: sample_rom = 7'd58;
207: sample_rom = 7'd62;
208: sample_rom = 7'd64;
209: sample_rom = 7'd65;
210: sample_rom = 7'd68;
211: sample_rom = 7'd68;
212: sample_rom = 7'd69;
213: sample_rom = 7'd69;
214: sample_rom = 7'd69;
215: sample_rom = 7'd68;
216: sample_rom = 7'd68;
217: sample_rom = 7'd66;
218: sample_rom = 7'd66;
219: sample_rom = 7'd65;
220: sample_rom = 7'd65;
221: sample_rom = 7'd65;
222: sample_rom = 7'd67;
223: sample_rom = 7'd68;
224: sample_rom = 7'd70;
225: sample_rom = 7'd76;
226: sample_rom = 7'd77;
227: sample_rom = 7'd78;
228: sample_rom = 7'd79;
229: sample_rom = 7'd78;
230: sample_rom = 7'd78;
231: sample_rom = 7'd78;
232: sample_rom = 7'd78;
233: sample_rom = 7'd78;
234: sample_rom = 7'd83;
235: sample_rom = 7'd85;
236: sample_rom = 7'd87;
237: sample_rom = 7'd92;
238: sample_rom = 7'd93;
239: sample_rom = 7'd91;
240: sample_rom = 7'd90;
241: sample_rom = 7'd90;
242: sample_rom = 7'd89;
243: sample_rom = 7'd88;
244: sample_rom = 7'd91;
245: sample_rom = 7'd95;
246: sample_rom = 7'd100;
247: sample_rom = 7'd104;
248: sample_rom = 7'd104;
249: sample_rom = 7'd108;
250: sample_rom = 7'd110;
251: sample_rom = 7'd112;
252: sample_rom = 7'd116;
253: sample_rom = 7'd117;
254: sample_rom = 7'd119;
255: sample_rom = 7'd119;
        endcase
    endfunction

    reg [7:0] sample_val;
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
