`default_nettype none

`define MUXIT

module pwm_music (
    input wire clk,
    input wire rst_n,

    output wire pwm
);

    // The PWM module converts the sample of our sine wave to a PWM output
    wire [7:0] sample [0:3];
    wire [11:0] cdivider;
`ifdef MUXIT
    reg [9:0] vdivider [1:3];
`else
    wire [9:0] vdivider [1:3];
`endif
    reg [9:0] sample_for_pwm = {2'b0, sample[0]} + 
        ((vdivider[1] == 0) ? 10'h80 : {2'b0, sample[1]}) +
        ((vdivider[2] == 0) ? 10'h80 : {2'b0, sample[2]}) +
        ((vdivider[3] == 0) ? 10'h80 : {2'b0, sample[3]});

    pwm_audio i_pwm(
        .clk(clk),
        .rst_n(rst_n),

        .sample(sample_for_pwm[9:2]),

        .pwm(pwm)
    );
    wire _unused = &{sample_for_pwm[1:0], 1'b0};

    pwm_sample i_sample(
        .clk(clk),
        .rst_n(rst_n),

        .divider1(cdivider),
        .divider2({2'b00, vdivider[1]}),
        .divider3({2'b00, vdivider[2]}),
        .divider4({2'b00, vdivider[3]}),

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
    function [11:0] cello_rom(input [2:0] idx);
        case (idx)
0: cello_rom = 12'd797;
1: cello_rom = 12'd1064;
2: cello_rom = 12'd948;
3: cello_rom = 12'd1265;
4: cello_rom = 12'd1194;
5: cello_rom = 12'd1595;
6: cello_rom = 12'd1194;
7: cello_rom = 12'd1064;
        endcase
    endfunction

    // Violin line for Canon, 30MHz project clock
    function automatic [9:0] violin_rom(input [8:0] idx);
        case (idx)
        default: violin_rom = 10'd0;
8: violin_rom = 10'd157;
9: violin_rom = 10'd176;
10: violin_rom = 10'd198;
11: violin_rom = 10'd210;
12: violin_rom = 10'd236;
13: violin_rom = 10'd265;
14: violin_rom = 10'd236;
15: violin_rom = 10'd210;
16: violin_rom = 10'd198;
17: violin_rom = 10'd210;
18: violin_rom = 10'd236;
19: violin_rom = 10'd265;
20: violin_rom = 10'd297;
21: violin_rom = 10'd315;
22: violin_rom = 10'd297;
23: violin_rom = 10'd354;
24: violin_rom = 10'd398;
25: violin_rom = 10'd315;
26: violin_rom = 10'd265;
27: violin_rom = 10'd297;
28: violin_rom = 10'd315;
29: violin_rom = 10'd398;
30: violin_rom = 10'd315;
31: violin_rom = 10'd354;
32: violin_rom = 10'd398;
33: violin_rom = 10'd473;
34: violin_rom = 10'd398;
35: violin_rom = 10'd265;
36: violin_rom = 10'd297;
37: violin_rom = 10'd236;
38: violin_rom = 10'd265;
39: violin_rom = 10'd297;
40: violin_rom = 10'd315;
41: violin_rom = 10'd398;
42: violin_rom = 10'd354;
43: violin_rom = 10'd210;
44: violin_rom = 10'd198;
45: violin_rom = 10'd157;
46: violin_rom = 10'd132;
47: violin_rom = 10'd265;
48: violin_rom = 10'd236;
49: violin_rom = 10'd297;
50: violin_rom = 10'd265;
51: violin_rom = 10'd315;
52: violin_rom = 10'd398;
53: violin_rom = 10'd198;
54: violin_rom = 10'd198;
55: violin_rom = 10'd198;
56: violin_rom = 10'd210;
57: violin_rom = 10'd198;
58: violin_rom = 10'd210;
59: violin_rom = 10'd198;
60: violin_rom = 10'd398;
61: violin_rom = 10'd421;
62: violin_rom = 10'd265;
63: violin_rom = 10'd354;
64: violin_rom = 10'd315;
65: violin_rom = 10'd398;
66: violin_rom = 10'd198;
67: violin_rom = 10'd210;
68: violin_rom = 10'd236;
69: violin_rom = 10'd210;
70: violin_rom = 10'd157;
71: violin_rom = 10'd132;
72: violin_rom = 10'd117;
73: violin_rom = 10'd148;
74: violin_rom = 10'd157;
75: violin_rom = 10'd176;
76: violin_rom = 10'd148;
77: violin_rom = 10'd157;
78: violin_rom = 10'd176;
79: violin_rom = 10'd198;
80: violin_rom = 10'd210;
81: violin_rom = 10'd236;
82: violin_rom = 10'd265;
83: violin_rom = 10'd297;
84: violin_rom = 10'd315;
85: violin_rom = 10'd354;
86: violin_rom = 10'd297;
87: violin_rom = 10'd315;
88: violin_rom = 10'd354;
89: violin_rom = 10'd398;
90: violin_rom = 10'd354;
91: violin_rom = 10'd315;
92: violin_rom = 10'd297;
93: violin_rom = 10'd265;
94: violin_rom = 10'd354;
95: violin_rom = 10'd265;
96: violin_rom = 10'd297;
97: violin_rom = 10'd315;
98: violin_rom = 10'd236;
99: violin_rom = 10'd265;
100: violin_rom = 10'd297;
101: violin_rom = 10'd265;
102: violin_rom = 10'd297;
103: violin_rom = 10'd315;
104: violin_rom = 10'd354;
105: violin_rom = 10'd398;
106: violin_rom = 10'd473;
107: violin_rom = 10'd236;
108: violin_rom = 10'd210;
109: violin_rom = 10'd198;
110: violin_rom = 10'd210;
111: violin_rom = 10'd236;
112: violin_rom = 10'd265;
113: violin_rom = 10'd297;
114: violin_rom = 10'd315;
115: violin_rom = 10'd354;
116: violin_rom = 10'd236;
117: violin_rom = 10'd265;
118: violin_rom = 10'd236;
119: violin_rom = 10'd265;
120: violin_rom = 10'd297;
121: violin_rom = 10'd315;
122: violin_rom = 10'd157;
123: violin_rom = 10'd176;
124: violin_rom = 10'd176;
125: violin_rom = 10'd0;
126: violin_rom = 10'd198;
127: violin_rom = 10'd157;
128: violin_rom = 10'd117;
129: violin_rom = 10'd132;
130: violin_rom = 10'd117;
131: violin_rom = 10'd104;
132: violin_rom = 10'd98;
133: violin_rom = 10'd198;
134: violin_rom = 10'd210;
135: violin_rom = 10'd210;
136: violin_rom = 10'd0;
137: violin_rom = 10'd236;
138: violin_rom = 10'd198;
139: violin_rom = 10'd198;
140: violin_rom = 10'd198;
141: violin_rom = 10'd198;
142: violin_rom = 10'd198;
143: violin_rom = 10'd198;
144: violin_rom = 10'd198;
145: violin_rom = 10'd148;
146: violin_rom = 10'd176;
147: violin_rom = 10'd132;
148: violin_rom = 10'd132;
149: violin_rom = 10'd132;
150: violin_rom = 10'd157;
151: violin_rom = 10'd148;
152: violin_rom = 10'd132;
153: violin_rom = 10'd132;
154: violin_rom = 10'd157;
155: violin_rom = 10'd148;
156: violin_rom = 10'd132;
157: violin_rom = 10'd265;
158: violin_rom = 10'd236;
159: violin_rom = 10'd210;
160: violin_rom = 10'd198;
161: violin_rom = 10'd176;
162: violin_rom = 10'd157;
163: violin_rom = 10'd148;
164: violin_rom = 10'd157;
165: violin_rom = 10'd157;
166: violin_rom = 10'd198;
167: violin_rom = 10'd176;
168: violin_rom = 10'd157;
169: violin_rom = 10'd157;
170: violin_rom = 10'd315;
171: violin_rom = 10'd297;
172: violin_rom = 10'd265;
173: violin_rom = 10'd236;
174: violin_rom = 10'd265;
175: violin_rom = 10'd297;
176: violin_rom = 10'd265;
177: violin_rom = 10'd315;
178: violin_rom = 10'd297;
179: violin_rom = 10'd265;
180: violin_rom = 10'd297;
181: violin_rom = 10'd297;
182: violin_rom = 10'd236;
183: violin_rom = 10'd265;
184: violin_rom = 10'd297;
185: violin_rom = 10'd297;
186: violin_rom = 10'd315;
187: violin_rom = 10'd354;
188: violin_rom = 10'd315;
189: violin_rom = 10'd354;
190: violin_rom = 10'd398;
191: violin_rom = 10'd354;
192: violin_rom = 10'd315;
193: violin_rom = 10'd297;
194: violin_rom = 10'd265;
195: violin_rom = 10'd236;
196: violin_rom = 10'd297;
197: violin_rom = 10'd297;
198: violin_rom = 10'd236;
199: violin_rom = 10'd265;
200: violin_rom = 10'd236;
201: violin_rom = 10'd236;
202: violin_rom = 10'd210;
203: violin_rom = 10'd198;
204: violin_rom = 10'd265;
205: violin_rom = 10'd236;
206: violin_rom = 10'd210;
207: violin_rom = 10'd198;
208: violin_rom = 10'd176;
209: violin_rom = 10'd157;
210: violin_rom = 10'd148;
211: violin_rom = 10'd132;
212: violin_rom = 10'd157;
213: violin_rom = 10'd157;
214: violin_rom = 10'd198;
215: violin_rom = 10'd176;
216: violin_rom = 10'd157;
217: violin_rom = 10'd157;
218: violin_rom = 10'd176;
219: violin_rom = 10'd198;
220: violin_rom = 10'd176;
221: violin_rom = 10'd210;
222: violin_rom = 10'd198;
223: violin_rom = 10'd176;
224: violin_rom = 10'd157;
225: violin_rom = 10'd176;
226: violin_rom = 10'd198;
227: violin_rom = 10'd210;
228: violin_rom = 10'd198;
229: violin_rom = 10'd198;
230: violin_rom = 10'd236;
231: violin_rom = 10'd210;
232: violin_rom = 10'd198;
233: violin_rom = 10'd198;
234: violin_rom = 10'd398;
235: violin_rom = 10'd354;
236: violin_rom = 10'd315;
237: violin_rom = 10'd297;
238: violin_rom = 10'd315;
239: violin_rom = 10'd354;
240: violin_rom = 10'd315;
241: violin_rom = 10'd198;
242: violin_rom = 10'd210;
243: violin_rom = 10'd198;
244: violin_rom = 10'd236;
245: violin_rom = 10'd236;
246: violin_rom = 10'd198;
247: violin_rom = 10'd210;
248: violin_rom = 10'd236;
249: violin_rom = 10'd236;
250: violin_rom = 10'd265;
251: violin_rom = 10'd297;
252: violin_rom = 10'd265;
253: violin_rom = 10'd297;
254: violin_rom = 10'd315;
255: violin_rom = 10'd297;
256: violin_rom = 10'd265;
257: violin_rom = 10'd236;
258: violin_rom = 10'd210;
259: violin_rom = 10'd198;
260: violin_rom = 10'd236;
261: violin_rom = 10'd236;
262: violin_rom = 10'd198;
263: violin_rom = 10'd210;
264: violin_rom = 10'd198;
265: violin_rom = 10'd198;
266: violin_rom = 10'd210;
267: violin_rom = 10'd236;
268: violin_rom = 10'd210;
269: violin_rom = 10'd198;
270: violin_rom = 10'd176;
271: violin_rom = 10'd198;
272: violin_rom = 10'd210;
273: violin_rom = 10'd198;
274: violin_rom = 10'd236;
275: violin_rom = 10'd210;
276: violin_rom = 10'd198;
277: violin_rom = 10'd0;
278: violin_rom = 10'd210;
279: violin_rom = 10'd0;
280: violin_rom = 10'd236;
281: violin_rom = 10'd0;
282: violin_rom = 10'd198;
283: violin_rom = 10'd0;
284: violin_rom = 10'd398;
285: violin_rom = 10'd0;
286: violin_rom = 10'd398;
287: violin_rom = 10'd0;
288: violin_rom = 10'd398;
289: violin_rom = 10'd0;
290: violin_rom = 10'd398;
291: violin_rom = 10'd0;
292: violin_rom = 10'd0;
293: violin_rom = 10'd265;
294: violin_rom = 10'd0;
295: violin_rom = 10'd265;
296: violin_rom = 10'd0;
297: violin_rom = 10'd315;
298: violin_rom = 10'd0;
299: violin_rom = 10'd265;
300: violin_rom = 10'd0;
301: violin_rom = 10'd297;
302: violin_rom = 10'd0;
303: violin_rom = 10'd315;
304: violin_rom = 10'd0;
305: violin_rom = 10'd297;
306: violin_rom = 10'd0;
307: violin_rom = 10'd176;
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

    wire [9:0] violin_divider_mux = violin_rom(vnote_idx);

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
