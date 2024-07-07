`default_nettype none

`define MUXIT

module pwm_music (
    input wire clk,
    input wire rst_n,

    output wire pwm
);

    // The PWM module converts the sample of our sine wave to a PWM output
    wire [6:0] sample [0:3];
    wire [12:0] cdivider;
`ifdef MUXIT
    reg [10:0] vdivider [1:3];
`else
    wire [10:0] vdivider [1:3];
`endif
    reg [8:0] sample_for_pwm = {2'b0, sample[0]} + 
        ((vdivider[1] == 0) ? 9'h40 : {2'b0, sample[1]}) +
        ((vdivider[2] == 0) ? 9'h40 : {2'b0, sample[2]}) +
        ((vdivider[3] == 0) ? 9'h40 : {2'b0, sample[3]});

    pwm_audio i_pwm(
        .clk(clk),
        .rst_n(rst_n),

        .sample(sample_for_pwm[8:1]),

        .pwm(pwm)
    );
    wire _unused = &{sample_for_pwm[0], 1'b0};

    pwm_sample i_sample(
        .clk(clk),
        .rst_n(rst_n),

        .divider1(cdivider),
        .divider2(vdivider[1]),
        .divider3(vdivider[2]),
        .divider4(vdivider[3]),

        .sample1(sample[0]),
        .sample2(sample[1]),
        .sample3(sample[2]),
        .sample4(sample[3])
    );

    reg [25:0] count;
    reg [2:0] cello_note_idx;
    reg [8:0] violin_note_idx [0:2];
    reg [2:0] violin_duration_mask [0:2];

    always @(posedge clk) begin
        if (!rst_n) begin
            count <= 0;
            cello_note_idx <= 3'd7;
        end
        else begin
            count <= count + 2;
            if (count == 0) begin
                cello_note_idx <= cello_note_idx + 1;
            end
        end
    end

    genvar i;
    generate
        for (i = 0; i < 3; i = i+1) begin
            always @(posedge clk) begin
                if (!rst_n) begin
                    violin_note_idx[i] <= 9'd511 - 8*i;
                    violin_duration_mask[i] <= 3'b111;
                end
                else begin
                    if (count[22:0] == 0 && (count[25:23] & violin_duration_mask[i]) == 0) begin
                        violin_note_idx[i] <= violin_note_idx[i] + 1;
                        case (violin_note_idx[i])
                        23: violin_duration_mask[i] <= 3'b011;
                        54: violin_duration_mask[i] <= 3'b001;
                        120: violin_duration_mask[i] <= 3'b011;
                        126: violin_duration_mask[i] <= 3'b111;
                        131: violin_duration_mask[i] <= 3'b011;
                        147: violin_duration_mask[i] <= 3'b000;
                        275: violin_duration_mask[i] <= 3'b011;
                        endcase
                        if (violin_note_idx[i] == 307 - 16*i) begin 
                            violin_duration_mask[i] <= 3'b111;
                            violin_note_idx[i] <= -8*i;
                        end
                    end
                end
            end
        end
    endgenerate

    // Cello line for Canon, 30MHz project clock
    function [12:0] cello_rom(input [2:0] idx);
        case (idx)
0: cello_rom = 13'd1595;
1: cello_rom = 13'd2129;
2: cello_rom = 13'd1897;
3: cello_rom = 13'd2532;
4: cello_rom = 13'd2390;
5: cello_rom = 13'd3191;
6: cello_rom = 13'd2390;
7: cello_rom = 13'd2129;
        endcase
    endfunction

    // Violin line for Canon, 30MHz project clock
    function automatic [4:0] violin_rom(input [8:0] idx);
        case (idx)
        default: violin_rom = 5'd0;
8: violin_rom = 5'd12;
9: violin_rom = 5'd11;
10: violin_rom = 5'd10;
11: violin_rom = 5'd9;
12: violin_rom = 5'd8;
13: violin_rom = 5'd7;
14: violin_rom = 5'd8;
15: violin_rom = 5'd9;
16: violin_rom = 5'd10;
17: violin_rom = 5'd9;
18: violin_rom = 5'd8;
19: violin_rom = 5'd7;
20: violin_rom = 5'd6;
21: violin_rom = 5'd5;
22: violin_rom = 5'd6;
23: violin_rom = 5'd4;
24: violin_rom = 5'd3;
25: violin_rom = 5'd5;
26: violin_rom = 5'd7;
27: violin_rom = 5'd6;
28: violin_rom = 5'd5;
29: violin_rom = 5'd3;
30: violin_rom = 5'd5;
31: violin_rom = 5'd4;
32: violin_rom = 5'd3;
33: violin_rom = 5'd1;
34: violin_rom = 5'd3;
35: violin_rom = 5'd7;
36: violin_rom = 5'd6;
37: violin_rom = 5'd8;
38: violin_rom = 5'd7;
39: violin_rom = 5'd6;
40: violin_rom = 5'd5;
41: violin_rom = 5'd3;
42: violin_rom = 5'd4;
43: violin_rom = 5'd9;
44: violin_rom = 5'd10;
45: violin_rom = 5'd12;
46: violin_rom = 5'd14;
47: violin_rom = 5'd7;
48: violin_rom = 5'd8;
49: violin_rom = 5'd6;
50: violin_rom = 5'd7;
51: violin_rom = 5'd5;
52: violin_rom = 5'd3;
53: violin_rom = 5'd10;
54: violin_rom = 5'd10;
55: violin_rom = 5'd10;
56: violin_rom = 5'd9;
57: violin_rom = 5'd10;
58: violin_rom = 5'd9;
59: violin_rom = 5'd10;
60: violin_rom = 5'd3;
61: violin_rom = 5'd2;
62: violin_rom = 5'd7;
63: violin_rom = 5'd4;
64: violin_rom = 5'd5;
65: violin_rom = 5'd3;
66: violin_rom = 5'd10;
67: violin_rom = 5'd9;
68: violin_rom = 5'd8;
69: violin_rom = 5'd9;
70: violin_rom = 5'd12;
71: violin_rom = 5'd14;
72: violin_rom = 5'd15;
73: violin_rom = 5'd13;
74: violin_rom = 5'd12;
75: violin_rom = 5'd11;
76: violin_rom = 5'd13;
77: violin_rom = 5'd12;
78: violin_rom = 5'd11;
79: violin_rom = 5'd10;
80: violin_rom = 5'd9;
81: violin_rom = 5'd8;
82: violin_rom = 5'd7;
83: violin_rom = 5'd6;
84: violin_rom = 5'd5;
85: violin_rom = 5'd4;
86: violin_rom = 5'd6;
87: violin_rom = 5'd5;
88: violin_rom = 5'd4;
89: violin_rom = 5'd3;
90: violin_rom = 5'd4;
91: violin_rom = 5'd5;
92: violin_rom = 5'd6;
93: violin_rom = 5'd7;
94: violin_rom = 5'd4;
95: violin_rom = 5'd7;
96: violin_rom = 5'd6;
97: violin_rom = 5'd5;
98: violin_rom = 5'd8;
99: violin_rom = 5'd7;
100: violin_rom = 5'd6;
101: violin_rom = 5'd7;
102: violin_rom = 5'd6;
103: violin_rom = 5'd5;
104: violin_rom = 5'd4;
105: violin_rom = 5'd3;
106: violin_rom = 5'd1;
107: violin_rom = 5'd8;
108: violin_rom = 5'd9;
109: violin_rom = 5'd10;
110: violin_rom = 5'd9;
111: violin_rom = 5'd8;
112: violin_rom = 5'd7;
113: violin_rom = 5'd6;
114: violin_rom = 5'd5;
115: violin_rom = 5'd4;
116: violin_rom = 5'd8;
117: violin_rom = 5'd7;
118: violin_rom = 5'd8;
119: violin_rom = 5'd7;
120: violin_rom = 5'd6;
121: violin_rom = 5'd5;
122: violin_rom = 5'd12;
123: violin_rom = 5'd11;
124: violin_rom = 5'd11;
125: violin_rom = 5'd0;
126: violin_rom = 5'd10;
127: violin_rom = 5'd12;
128: violin_rom = 5'd15;
129: violin_rom = 5'd14;
130: violin_rom = 5'd15;
131: violin_rom = 5'd16;
132: violin_rom = 5'd17;
133: violin_rom = 5'd10;
134: violin_rom = 5'd9;
135: violin_rom = 5'd9;
136: violin_rom = 5'd0;
137: violin_rom = 5'd8;
138: violin_rom = 5'd10;
139: violin_rom = 5'd10;
140: violin_rom = 5'd10;
141: violin_rom = 5'd10;
142: violin_rom = 5'd10;
143: violin_rom = 5'd10;
144: violin_rom = 5'd10;
145: violin_rom = 5'd13;
146: violin_rom = 5'd11;
147: violin_rom = 5'd14;
148: violin_rom = 5'd14;
149: violin_rom = 5'd14;
150: violin_rom = 5'd12;
151: violin_rom = 5'd13;
152: violin_rom = 5'd14;
153: violin_rom = 5'd14;
154: violin_rom = 5'd12;
155: violin_rom = 5'd13;
156: violin_rom = 5'd14;
157: violin_rom = 5'd7;
158: violin_rom = 5'd8;
159: violin_rom = 5'd9;
160: violin_rom = 5'd10;
161: violin_rom = 5'd11;
162: violin_rom = 5'd12;
163: violin_rom = 5'd13;
164: violin_rom = 5'd12;
165: violin_rom = 5'd12;
166: violin_rom = 5'd10;
167: violin_rom = 5'd11;
168: violin_rom = 5'd12;
169: violin_rom = 5'd12;
170: violin_rom = 5'd5;
171: violin_rom = 5'd6;
172: violin_rom = 5'd7;
173: violin_rom = 5'd8;
174: violin_rom = 5'd7;
175: violin_rom = 5'd6;
176: violin_rom = 5'd7;
177: violin_rom = 5'd5;
178: violin_rom = 5'd6;
179: violin_rom = 5'd7;
180: violin_rom = 5'd6;
181: violin_rom = 5'd6;
182: violin_rom = 5'd8;
183: violin_rom = 5'd7;
184: violin_rom = 5'd6;
185: violin_rom = 5'd6;
186: violin_rom = 5'd5;
187: violin_rom = 5'd4;
188: violin_rom = 5'd5;
189: violin_rom = 5'd4;
190: violin_rom = 5'd3;
191: violin_rom = 5'd4;
192: violin_rom = 5'd5;
193: violin_rom = 5'd6;
194: violin_rom = 5'd7;
195: violin_rom = 5'd8;
196: violin_rom = 5'd6;
197: violin_rom = 5'd6;
198: violin_rom = 5'd8;
199: violin_rom = 5'd7;
200: violin_rom = 5'd8;
201: violin_rom = 5'd8;
202: violin_rom = 5'd9;
203: violin_rom = 5'd10;
204: violin_rom = 5'd7;
205: violin_rom = 5'd8;
206: violin_rom = 5'd9;
207: violin_rom = 5'd10;
208: violin_rom = 5'd11;
209: violin_rom = 5'd12;
210: violin_rom = 5'd13;
211: violin_rom = 5'd14;
212: violin_rom = 5'd12;
213: violin_rom = 5'd12;
214: violin_rom = 5'd10;
215: violin_rom = 5'd11;
216: violin_rom = 5'd12;
217: violin_rom = 5'd12;
218: violin_rom = 5'd11;
219: violin_rom = 5'd10;
220: violin_rom = 5'd11;
221: violin_rom = 5'd9;
222: violin_rom = 5'd10;
223: violin_rom = 5'd11;
224: violin_rom = 5'd12;
225: violin_rom = 5'd11;
226: violin_rom = 5'd10;
227: violin_rom = 5'd9;
228: violin_rom = 5'd10;
229: violin_rom = 5'd10;
230: violin_rom = 5'd8;
231: violin_rom = 5'd9;
232: violin_rom = 5'd10;
233: violin_rom = 5'd10;
234: violin_rom = 5'd3;
235: violin_rom = 5'd4;
236: violin_rom = 5'd5;
237: violin_rom = 5'd6;
238: violin_rom = 5'd5;
239: violin_rom = 5'd4;
240: violin_rom = 5'd5;
241: violin_rom = 5'd10;
242: violin_rom = 5'd9;
243: violin_rom = 5'd10;
244: violin_rom = 5'd8;
245: violin_rom = 5'd8;
246: violin_rom = 5'd10;
247: violin_rom = 5'd9;
248: violin_rom = 5'd8;
249: violin_rom = 5'd8;
250: violin_rom = 5'd7;
251: violin_rom = 5'd6;
252: violin_rom = 5'd7;
253: violin_rom = 5'd6;
254: violin_rom = 5'd5;
255: violin_rom = 5'd6;
256: violin_rom = 5'd7;
257: violin_rom = 5'd8;
258: violin_rom = 5'd9;
259: violin_rom = 5'd10;
260: violin_rom = 5'd8;
261: violin_rom = 5'd8;
262: violin_rom = 5'd10;
263: violin_rom = 5'd9;
264: violin_rom = 5'd10;
265: violin_rom = 5'd10;
266: violin_rom = 5'd9;
267: violin_rom = 5'd8;
268: violin_rom = 5'd9;
269: violin_rom = 5'd10;
270: violin_rom = 5'd11;
271: violin_rom = 5'd10;
272: violin_rom = 5'd9;
273: violin_rom = 5'd10;
274: violin_rom = 5'd8;
275: violin_rom = 5'd9;
276: violin_rom = 5'd10;
277: violin_rom = 5'd0;
278: violin_rom = 5'd9;
279: violin_rom = 5'd0;
280: violin_rom = 5'd8;
281: violin_rom = 5'd0;
282: violin_rom = 5'd10;
283: violin_rom = 5'd0;
284: violin_rom = 5'd3;
285: violin_rom = 5'd0;
286: violin_rom = 5'd3;
287: violin_rom = 5'd0;
288: violin_rom = 5'd3;
289: violin_rom = 5'd0;
290: violin_rom = 5'd3;
291: violin_rom = 5'd0;
292: violin_rom = 5'd0;
293: violin_rom = 5'd7;
294: violin_rom = 5'd0;
295: violin_rom = 5'd7;
296: violin_rom = 5'd0;
297: violin_rom = 5'd5;
298: violin_rom = 5'd0;
299: violin_rom = 5'd7;
300: violin_rom = 5'd0;
301: violin_rom = 5'd6;
302: violin_rom = 5'd0;
303: violin_rom = 5'd5;
304: violin_rom = 5'd0;
305: violin_rom = 5'd6;
306: violin_rom = 5'd0;
307: violin_rom = 5'd11;
        endcase
    endfunction

    function [10:0] violin_freq(input [4:0] note);
        case (note)
        default: violin_freq = 11'd0;
1: violin_freq = 11'd948;
2: violin_freq = 11'd844;
3: violin_freq = 11'd797;
4: violin_freq = 11'd710;
5: violin_freq = 11'd632;
6: violin_freq = 11'd596;
7: violin_freq = 11'd531;
8: violin_freq = 11'd473;
9: violin_freq = 11'd421;
10: violin_freq = 11'd398;
11: violin_freq = 11'd354;
12: violin_freq = 11'd315;
13: violin_freq = 11'd297;
14: violin_freq = 11'd265;
15: violin_freq = 11'd236;
16: violin_freq = 11'd210;
17: violin_freq = 11'd198;          
        endcase
    endfunction

    assign cdivider = cello_rom(cello_note_idx);

`ifdef MUXIT
    reg [8:0] vnote_idx;
    always @* begin
        case(count[2:1])
        0: vnote_idx = violin_note_idx[0];
        1: vnote_idx = violin_note_idx[0];
        2: vnote_idx = violin_note_idx[1];
        3: vnote_idx = violin_note_idx[2];
        endcase
    end

    wire [10:0] violin_divider_mux = violin_freq(violin_rom(vnote_idx));

    always @(posedge clk) begin
        case(count[2:1])
        0: vdivider[1] <= violin_divider_mux;
        1: vdivider[1] <= violin_divider_mux;
        2: vdivider[2] <= violin_divider_mux;
        3: vdivider[3] <= violin_divider_mux;
        endcase
    end
`else

    generate
        for (i = 0; i < 3; i = i+1) begin
            assign vdivider[i+1] = violin_rom(violin_note_idx[i]);
        end
    endgenerate

`endif

endmodule
