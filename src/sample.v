`default_nettype none

module pwm_sample (
    input wire clk,
    input wire rst_n,

    input wire [11:0] divider1,  // Ouput frequency is clk / (256 * (divider+1)), giving a minimum frequency of ~47Hz at a 50MHz clock
    input wire [11:0] divider2,
    input wire [11:0] divider3,
    input wire [11:0] divider4,

    output reg [7:0] sample1,
    output reg [7:0] sample2,
    output reg [7:0] sample3,
    output reg [7:0] sample4
);

    // The sample is a complete wave over 256 entries.
    // Every divider+1 clocks, we move to the next entry in the table.
    reg [11:0] count1;
    reg [11:0] count2;
    reg [11:0] count3;
    reg [11:0] count4;
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
    function [7:0] sample_rom(input [7:0] val);
        case (val)
0: sample_rom = 8'd234;
1: sample_rom = 8'd232;
2: sample_rom = 8'd230;
3: sample_rom = 8'd220;
4: sample_rom = 8'd217;
5: sample_rom = 8'd212;
6: sample_rom = 8'd212;
7: sample_rom = 8'd212;
8: sample_rom = 8'd211;
9: sample_rom = 8'd210;
10: sample_rom = 8'd198;
11: sample_rom = 8'd193;
12: sample_rom = 8'd188;
13: sample_rom = 8'd179;
14: sample_rom = 8'd177;
15: sample_rom = 8'd168;
16: sample_rom = 8'd166;
17: sample_rom = 8'd164;
18: sample_rom = 8'd156;
19: sample_rom = 8'd152;
20: sample_rom = 8'd134;
21: sample_rom = 8'd130;
22: sample_rom = 8'd127;
23: sample_rom = 8'd125;
24: sample_rom = 8'd125;
25: sample_rom = 8'd113;
26: sample_rom = 8'd106;
27: sample_rom = 8'd97;
28: sample_rom = 8'd71;
29: sample_rom = 8'd66;
30: sample_rom = 8'd50;
31: sample_rom = 8'd47;
32: sample_rom = 8'd44;
33: sample_rom = 8'd50;
34: sample_rom = 8'd50;
35: sample_rom = 8'd23;
36: sample_rom = 8'd14;
37: sample_rom = 8'd7;
38: sample_rom = 8'd10;
39: sample_rom = 8'd13;
40: sample_rom = 8'd13;
41: sample_rom = 8'd10;
42: sample_rom = 8'd4;
43: sample_rom = 8'd4;
44: sample_rom = 8'd6;
45: sample_rom = 8'd18;
46: sample_rom = 8'd21;
47: sample_rom = 8'd33;
48: sample_rom = 8'd42;
49: sample_rom = 8'd51;
50: sample_rom = 8'd74;
51: sample_rom = 8'd76;
52: sample_rom = 8'd78;
53: sample_rom = 8'd79;
54: sample_rom = 8'd81;
55: sample_rom = 8'd85;
56: sample_rom = 8'd84;
57: sample_rom = 8'd71;
58: sample_rom = 8'd70;
59: sample_rom = 8'd72;
60: sample_rom = 8'd102;
61: sample_rom = 8'd110;
62: sample_rom = 8'd122;
63: sample_rom = 8'd125;
64: sample_rom = 8'd127;
65: sample_rom = 8'd118;
66: sample_rom = 8'd111;
67: sample_rom = 8'd86;
68: sample_rom = 8'd84;
69: sample_rom = 8'd95;
70: sample_rom = 8'd102;
71: sample_rom = 8'd109;
72: sample_rom = 8'd128;
73: sample_rom = 8'd133;
74: sample_rom = 8'd145;
75: sample_rom = 8'd147;
76: sample_rom = 8'd147;
77: sample_rom = 8'd132;
78: sample_rom = 8'd126;
79: sample_rom = 8'd117;
80: sample_rom = 8'd118;
81: sample_rom = 8'd118;
82: sample_rom = 8'd121;
83: sample_rom = 8'd122;
84: sample_rom = 8'd124;
85: sample_rom = 8'd127;
86: sample_rom = 8'd130;
87: sample_rom = 8'd140;
88: sample_rom = 8'd141;
89: sample_rom = 8'd146;
90: sample_rom = 8'd150;
91: sample_rom = 8'd156;
92: sample_rom = 8'd174;
93: sample_rom = 8'd179;
94: sample_rom = 8'd192;
95: sample_rom = 8'd196;
96: sample_rom = 8'd200;
97: sample_rom = 8'd207;
98: sample_rom = 8'd207;
99: sample_rom = 8'd204;
100: sample_rom = 8'd202;
101: sample_rom = 8'd195;
102: sample_rom = 8'd193;
103: sample_rom = 8'd191;
104: sample_rom = 8'd189;
105: sample_rom = 8'd189;
106: sample_rom = 8'd185;
107: sample_rom = 8'd183;
108: sample_rom = 8'd180;
109: sample_rom = 8'd160;
110: sample_rom = 8'd153;
111: sample_rom = 8'd136;
112: sample_rom = 8'd134;
113: sample_rom = 8'd133;
114: sample_rom = 8'd130;
115: sample_rom = 8'd129;
116: sample_rom = 8'd120;
117: sample_rom = 8'd117;
118: sample_rom = 8'd112;
119: sample_rom = 8'd92;
120: sample_rom = 8'd85;
121: sample_rom = 8'd67;
122: sample_rom = 8'd63;
123: sample_rom = 8'd61;
124: sample_rom = 8'd56;
125: sample_rom = 8'd54;
126: sample_rom = 8'd48;
127: sample_rom = 8'd46;
128: sample_rom = 8'd45;
129: sample_rom = 8'd37;
130: sample_rom = 8'd34;
131: sample_rom = 8'd25;
132: sample_rom = 8'd22;
133: sample_rom = 8'd19;
134: sample_rom = 8'd20;
135: sample_rom = 8'd21;
136: sample_rom = 8'd31;
137: sample_rom = 8'd36;
138: sample_rom = 8'd59;
139: sample_rom = 8'd66;
140: sample_rom = 8'd74;
141: sample_rom = 8'd90;
142: sample_rom = 8'd91;
143: sample_rom = 8'd86;
144: sample_rom = 8'd84;
145: sample_rom = 8'd83;
146: sample_rom = 8'd91;
147: sample_rom = 8'd97;
148: sample_rom = 8'd132;
149: sample_rom = 8'd145;
150: sample_rom = 8'd159;
151: sample_rom = 8'd191;
152: sample_rom = 8'd194;
153: sample_rom = 8'd187;
154: sample_rom = 8'd183;
155: sample_rom = 8'd178;
156: sample_rom = 8'd162;
157: sample_rom = 8'd160;
158: sample_rom = 8'd163;
159: sample_rom = 8'd166;
160: sample_rom = 8'd169;
161: sample_rom = 8'd188;
162: sample_rom = 8'd194;
163: sample_rom = 8'd211;
164: sample_rom = 8'd213;
165: sample_rom = 8'd205;
166: sample_rom = 8'd198;
167: sample_rom = 8'd191;
168: sample_rom = 8'd167;
169: sample_rom = 8'd163;
170: sample_rom = 8'd160;
171: sample_rom = 8'd160;
172: sample_rom = 8'd160;
173: sample_rom = 8'd160;
174: sample_rom = 8'd160;
175: sample_rom = 8'd147;
176: sample_rom = 8'd141;
177: sample_rom = 8'd135;
178: sample_rom = 8'd117;
179: sample_rom = 8'd114;
180: sample_rom = 8'd113;
181: sample_rom = 8'd116;
182: sample_rom = 8'd119;
183: sample_rom = 8'd130;
184: sample_rom = 8'd132;
185: sample_rom = 8'd133;
186: sample_rom = 8'd129;
187: sample_rom = 8'd125;
188: sample_rom = 8'd103;
189: sample_rom = 8'd97;
190: sample_rom = 8'd84;
191: sample_rom = 8'd83;
192: sample_rom = 8'd83;
193: sample_rom = 8'd92;
194: sample_rom = 8'd96;
195: sample_rom = 8'd108;
196: sample_rom = 8'd110;
197: sample_rom = 8'd110;
198: sample_rom = 8'd108;
199: sample_rom = 8'd107;
200: sample_rom = 8'd100;
201: sample_rom = 8'd99;
202: sample_rom = 8'd101;
203: sample_rom = 8'd102;
204: sample_rom = 8'd104;
205: sample_rom = 8'd113;
206: sample_rom = 8'd116;
207: sample_rom = 8'd125;
208: sample_rom = 8'd127;
209: sample_rom = 8'd130;
210: sample_rom = 8'd135;
211: sample_rom = 8'd136;
212: sample_rom = 8'd138;
213: sample_rom = 8'd138;
214: sample_rom = 8'd138;
215: sample_rom = 8'd136;
216: sample_rom = 8'd135;
217: sample_rom = 8'd132;
218: sample_rom = 8'd132;
219: sample_rom = 8'd131;
220: sample_rom = 8'd129;
221: sample_rom = 8'd130;
222: sample_rom = 8'd134;
223: sample_rom = 8'd137;
224: sample_rom = 8'd140;
225: sample_rom = 8'd152;
226: sample_rom = 8'd155;
227: sample_rom = 8'd157;
228: sample_rom = 8'd157;
229: sample_rom = 8'd157;
230: sample_rom = 8'd156;
231: sample_rom = 8'd156;
232: sample_rom = 8'd155;
233: sample_rom = 8'd156;
234: sample_rom = 8'd166;
235: sample_rom = 8'd170;
236: sample_rom = 8'd174;
237: sample_rom = 8'd185;
238: sample_rom = 8'd185;
239: sample_rom = 8'd181;
240: sample_rom = 8'd180;
241: sample_rom = 8'd180;
242: sample_rom = 8'd178;
243: sample_rom = 8'd176;
244: sample_rom = 8'd183;
245: sample_rom = 8'd190;
246: sample_rom = 8'd199;
247: sample_rom = 8'd209;
248: sample_rom = 8'd207;
249: sample_rom = 8'd215;
250: sample_rom = 8'd220;
251: sample_rom = 8'd224;
252: sample_rom = 8'd232;
253: sample_rom = 8'd235;
254: sample_rom = 8'd238;
255: sample_rom = 8'd237;
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

    wire [7:0] sample_mux = sample_rom(sample_val);

    always @(posedge clk) begin
        case(count1[1:0])
        0: sample1 <= sample_mux;
        1: sample2 <= sample_mux;
        2: sample3 <= sample_mux;
        3: sample4 <= sample_mux;
        endcase
    end

endmodule
