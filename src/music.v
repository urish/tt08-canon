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
    function automatic [10:0] violin_rom(input [8:0] idx);
        case (idx)
        default: violin_rom = 11'd0;
8: violin_rom = 11'd315;
9: violin_rom = 11'd354;
10: violin_rom = 11'd398;
11: violin_rom = 11'd421;
12: violin_rom = 11'd473;
13: violin_rom = 11'd531;
14: violin_rom = 11'd473;
15: violin_rom = 11'd421;
16: violin_rom = 11'd398;
17: violin_rom = 11'd421;
18: violin_rom = 11'd473;
19: violin_rom = 11'd531;
20: violin_rom = 11'd596;
21: violin_rom = 11'd632;
22: violin_rom = 11'd596;
23: violin_rom = 11'd710;
24: violin_rom = 11'd797;
25: violin_rom = 11'd632;
26: violin_rom = 11'd531;
27: violin_rom = 11'd596;
28: violin_rom = 11'd632;
29: violin_rom = 11'd797;
30: violin_rom = 11'd632;
31: violin_rom = 11'd710;
32: violin_rom = 11'd797;
33: violin_rom = 11'd948;
34: violin_rom = 11'd797;
35: violin_rom = 11'd531;
36: violin_rom = 11'd596;
37: violin_rom = 11'd473;
38: violin_rom = 11'd531;
39: violin_rom = 11'd596;
40: violin_rom = 11'd632;
41: violin_rom = 11'd797;
42: violin_rom = 11'd710;
43: violin_rom = 11'd421;
44: violin_rom = 11'd398;
45: violin_rom = 11'd315;
46: violin_rom = 11'd265;
47: violin_rom = 11'd531;
48: violin_rom = 11'd473;
49: violin_rom = 11'd596;
50: violin_rom = 11'd531;
51: violin_rom = 11'd632;
52: violin_rom = 11'd797;
53: violin_rom = 11'd398;
54: violin_rom = 11'd398;
55: violin_rom = 11'd398;
56: violin_rom = 11'd421;
57: violin_rom = 11'd398;
58: violin_rom = 11'd421;
59: violin_rom = 11'd398;
60: violin_rom = 11'd797;
61: violin_rom = 11'd844;
62: violin_rom = 11'd531;
63: violin_rom = 11'd710;
64: violin_rom = 11'd632;
65: violin_rom = 11'd797;
66: violin_rom = 11'd398;
67: violin_rom = 11'd421;
68: violin_rom = 11'd473;
69: violin_rom = 11'd421;
70: violin_rom = 11'd315;
71: violin_rom = 11'd265;
72: violin_rom = 11'd236;
73: violin_rom = 11'd297;
74: violin_rom = 11'd315;
75: violin_rom = 11'd354;
76: violin_rom = 11'd297;
77: violin_rom = 11'd315;
78: violin_rom = 11'd354;
79: violin_rom = 11'd398;
80: violin_rom = 11'd421;
81: violin_rom = 11'd473;
82: violin_rom = 11'd531;
83: violin_rom = 11'd596;
84: violin_rom = 11'd632;
85: violin_rom = 11'd710;
86: violin_rom = 11'd596;
87: violin_rom = 11'd632;
88: violin_rom = 11'd710;
89: violin_rom = 11'd797;
90: violin_rom = 11'd710;
91: violin_rom = 11'd632;
92: violin_rom = 11'd596;
93: violin_rom = 11'd531;
94: violin_rom = 11'd710;
95: violin_rom = 11'd531;
96: violin_rom = 11'd596;
97: violin_rom = 11'd632;
98: violin_rom = 11'd473;
99: violin_rom = 11'd531;
100: violin_rom = 11'd596;
101: violin_rom = 11'd531;
102: violin_rom = 11'd596;
103: violin_rom = 11'd632;
104: violin_rom = 11'd710;
105: violin_rom = 11'd797;
106: violin_rom = 11'd948;
107: violin_rom = 11'd473;
108: violin_rom = 11'd421;
109: violin_rom = 11'd398;
110: violin_rom = 11'd421;
111: violin_rom = 11'd473;
112: violin_rom = 11'd531;
113: violin_rom = 11'd596;
114: violin_rom = 11'd632;
115: violin_rom = 11'd710;
116: violin_rom = 11'd473;
117: violin_rom = 11'd531;
118: violin_rom = 11'd473;
119: violin_rom = 11'd531;
120: violin_rom = 11'd596;
121: violin_rom = 11'd632;
122: violin_rom = 11'd315;
123: violin_rom = 11'd354;
124: violin_rom = 11'd354;
125: violin_rom = 11'd0;
126: violin_rom = 11'd398;
127: violin_rom = 11'd315;
128: violin_rom = 11'd236;
129: violin_rom = 11'd265;
130: violin_rom = 11'd236;
131: violin_rom = 11'd210;
132: violin_rom = 11'd198;
133: violin_rom = 11'd398;
134: violin_rom = 11'd421;
135: violin_rom = 11'd421;
136: violin_rom = 11'd0;
137: violin_rom = 11'd473;
138: violin_rom = 11'd398;
139: violin_rom = 11'd398;
140: violin_rom = 11'd398;
141: violin_rom = 11'd398;
142: violin_rom = 11'd398;
143: violin_rom = 11'd398;
144: violin_rom = 11'd398;
145: violin_rom = 11'd297;
146: violin_rom = 11'd354;
147: violin_rom = 11'd265;
148: violin_rom = 11'd265;
149: violin_rom = 11'd265;
150: violin_rom = 11'd315;
151: violin_rom = 11'd297;
152: violin_rom = 11'd265;
153: violin_rom = 11'd265;
154: violin_rom = 11'd315;
155: violin_rom = 11'd297;
156: violin_rom = 11'd265;
157: violin_rom = 11'd531;
158: violin_rom = 11'd473;
159: violin_rom = 11'd421;
160: violin_rom = 11'd398;
161: violin_rom = 11'd354;
162: violin_rom = 11'd315;
163: violin_rom = 11'd297;
164: violin_rom = 11'd315;
165: violin_rom = 11'd315;
166: violin_rom = 11'd398;
167: violin_rom = 11'd354;
168: violin_rom = 11'd315;
169: violin_rom = 11'd315;
170: violin_rom = 11'd632;
171: violin_rom = 11'd596;
172: violin_rom = 11'd531;
173: violin_rom = 11'd473;
174: violin_rom = 11'd531;
175: violin_rom = 11'd596;
176: violin_rom = 11'd531;
177: violin_rom = 11'd632;
178: violin_rom = 11'd596;
179: violin_rom = 11'd531;
180: violin_rom = 11'd596;
181: violin_rom = 11'd596;
182: violin_rom = 11'd473;
183: violin_rom = 11'd531;
184: violin_rom = 11'd596;
185: violin_rom = 11'd596;
186: violin_rom = 11'd632;
187: violin_rom = 11'd710;
188: violin_rom = 11'd632;
189: violin_rom = 11'd710;
190: violin_rom = 11'd797;
191: violin_rom = 11'd710;
192: violin_rom = 11'd632;
193: violin_rom = 11'd596;
194: violin_rom = 11'd531;
195: violin_rom = 11'd473;
196: violin_rom = 11'd596;
197: violin_rom = 11'd596;
198: violin_rom = 11'd473;
199: violin_rom = 11'd531;
200: violin_rom = 11'd473;
201: violin_rom = 11'd473;
202: violin_rom = 11'd421;
203: violin_rom = 11'd398;
204: violin_rom = 11'd531;
205: violin_rom = 11'd473;
206: violin_rom = 11'd421;
207: violin_rom = 11'd398;
208: violin_rom = 11'd354;
209: violin_rom = 11'd315;
210: violin_rom = 11'd297;
211: violin_rom = 11'd265;
212: violin_rom = 11'd315;
213: violin_rom = 11'd315;
214: violin_rom = 11'd398;
215: violin_rom = 11'd354;
216: violin_rom = 11'd315;
217: violin_rom = 11'd315;
218: violin_rom = 11'd354;
219: violin_rom = 11'd398;
220: violin_rom = 11'd354;
221: violin_rom = 11'd421;
222: violin_rom = 11'd398;
223: violin_rom = 11'd354;
224: violin_rom = 11'd315;
225: violin_rom = 11'd354;
226: violin_rom = 11'd398;
227: violin_rom = 11'd421;
228: violin_rom = 11'd398;
229: violin_rom = 11'd398;
230: violin_rom = 11'd473;
231: violin_rom = 11'd421;
232: violin_rom = 11'd398;
233: violin_rom = 11'd398;
234: violin_rom = 11'd797;
235: violin_rom = 11'd710;
236: violin_rom = 11'd632;
237: violin_rom = 11'd596;
238: violin_rom = 11'd632;
239: violin_rom = 11'd710;
240: violin_rom = 11'd632;
241: violin_rom = 11'd398;
242: violin_rom = 11'd421;
243: violin_rom = 11'd398;
244: violin_rom = 11'd473;
245: violin_rom = 11'd473;
246: violin_rom = 11'd398;
247: violin_rom = 11'd421;
248: violin_rom = 11'd473;
249: violin_rom = 11'd473;
250: violin_rom = 11'd531;
251: violin_rom = 11'd596;
252: violin_rom = 11'd531;
253: violin_rom = 11'd596;
254: violin_rom = 11'd632;
255: violin_rom = 11'd596;
256: violin_rom = 11'd531;
257: violin_rom = 11'd473;
258: violin_rom = 11'd421;
259: violin_rom = 11'd398;
260: violin_rom = 11'd473;
261: violin_rom = 11'd473;
262: violin_rom = 11'd398;
263: violin_rom = 11'd421;
264: violin_rom = 11'd398;
265: violin_rom = 11'd398;
266: violin_rom = 11'd421;
267: violin_rom = 11'd473;
268: violin_rom = 11'd421;
269: violin_rom = 11'd398;
270: violin_rom = 11'd354;
271: violin_rom = 11'd398;
272: violin_rom = 11'd421;
273: violin_rom = 11'd398;
274: violin_rom = 11'd473;
275: violin_rom = 11'd421;
276: violin_rom = 11'd398;
277: violin_rom = 11'd0;
278: violin_rom = 11'd421;
279: violin_rom = 11'd0;
280: violin_rom = 11'd473;
281: violin_rom = 11'd0;
282: violin_rom = 11'd398;
283: violin_rom = 11'd0;
284: violin_rom = 11'd797;
285: violin_rom = 11'd0;
286: violin_rom = 11'd797;
287: violin_rom = 11'd0;
288: violin_rom = 11'd797;
289: violin_rom = 11'd0;
290: violin_rom = 11'd797;
291: violin_rom = 11'd0;
292: violin_rom = 11'd0;
293: violin_rom = 11'd531;
294: violin_rom = 11'd0;
295: violin_rom = 11'd531;
296: violin_rom = 11'd0;
297: violin_rom = 11'd632;
298: violin_rom = 11'd0;
299: violin_rom = 11'd531;
300: violin_rom = 11'd0;
301: violin_rom = 11'd596;
302: violin_rom = 11'd0;
303: violin_rom = 11'd632;
304: violin_rom = 11'd0;
305: violin_rom = 11'd596;
306: violin_rom = 11'd0;
307: violin_rom = 11'd354;
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

    wire [10:0] violin_divider_mux = violin_rom(vnote_idx);

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
