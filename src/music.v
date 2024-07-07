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
            count <= count + 1;
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
                end
                else begin
                    if (count[22:0] == 0 && (count[25:23] & violin_duration_mask[i]) == 0) begin
                        violin_note_idx[i] <= violin_note_idx[i] + 1;
                        if (violin_note_idx[i] == 307 - 16*i) begin 
                            violin_note_idx[i] <= -8*i;
                        end
                    end
                end
            end
        end
    endgenerate

    // Cello line for Canon, 25MHz project clock
    function [12:0] cello_rom(input [2:0] idx);
        case (idx)
0: cello_rom = 13'd2672;
1: cello_rom = 13'd3567;
2: cello_rom = 13'd3178;
3: cello_rom = 13'd4243;
4: cello_rom = 13'd4004;
5: cello_rom = 13'd5346;
6: cello_rom = 13'd4004;
7: cello_rom = 13'd3567;
        endcase
    endfunction

    // Violin line for Canon
    function automatic [7:0] violin_rom(input [8:0] idx);
        case (idx)
        default: violin_rom = 8'he0;
8: violin_rom = 8'd236;
9: violin_rom = 8'd235;
10: violin_rom = 8'd234;
11: violin_rom = 8'd233;
12: violin_rom = 8'd232;
13: violin_rom = 8'd231;
14: violin_rom = 8'd232;
15: violin_rom = 8'd233;
16: violin_rom = 8'd234;
17: violin_rom = 8'd233;
18: violin_rom = 8'd232;
19: violin_rom = 8'd231;
20: violin_rom = 8'd230;
21: violin_rom = 8'd229;
22: violin_rom = 8'd230;
23: violin_rom = 8'd228;
24: violin_rom = 8'd99;
25: violin_rom = 8'd101;
26: violin_rom = 8'd103;
27: violin_rom = 8'd102;
28: violin_rom = 8'd101;
29: violin_rom = 8'd99;
30: violin_rom = 8'd101;
31: violin_rom = 8'd100;
32: violin_rom = 8'd99;
33: violin_rom = 8'd97;
34: violin_rom = 8'd99;
35: violin_rom = 8'd103;
36: violin_rom = 8'd102;
37: violin_rom = 8'd104;
38: violin_rom = 8'd103;
39: violin_rom = 8'd102;
40: violin_rom = 8'd101;
41: violin_rom = 8'd99;
42: violin_rom = 8'd100;
43: violin_rom = 8'd105;
44: violin_rom = 8'd106;
45: violin_rom = 8'd108;
46: violin_rom = 8'd110;
47: violin_rom = 8'd103;
48: violin_rom = 8'd104;
49: violin_rom = 8'd102;
50: violin_rom = 8'd103;
51: violin_rom = 8'd101;
52: violin_rom = 8'd99;
53: violin_rom = 8'd106;
54: violin_rom = 8'd106;
55: violin_rom = 8'd42;
56: violin_rom = 8'd41;
57: violin_rom = 8'd42;
58: violin_rom = 8'd41;
59: violin_rom = 8'd42;
60: violin_rom = 8'd35;
61: violin_rom = 8'd34;
62: violin_rom = 8'd39;
63: violin_rom = 8'd36;
64: violin_rom = 8'd37;
65: violin_rom = 8'd35;
66: violin_rom = 8'd42;
67: violin_rom = 8'd41;
68: violin_rom = 8'd40;
69: violin_rom = 8'd41;
70: violin_rom = 8'd44;
71: violin_rom = 8'd46;
72: violin_rom = 8'd47;
73: violin_rom = 8'd45;
74: violin_rom = 8'd44;
75: violin_rom = 8'd43;
76: violin_rom = 8'd45;
77: violin_rom = 8'd44;
78: violin_rom = 8'd43;
79: violin_rom = 8'd42;
80: violin_rom = 8'd41;
81: violin_rom = 8'd40;
82: violin_rom = 8'd39;
83: violin_rom = 8'd38;
84: violin_rom = 8'd37;
85: violin_rom = 8'd36;
86: violin_rom = 8'd38;
87: violin_rom = 8'd37;
88: violin_rom = 8'd36;
89: violin_rom = 8'd35;
90: violin_rom = 8'd36;
91: violin_rom = 8'd37;
92: violin_rom = 8'd38;
93: violin_rom = 8'd39;
94: violin_rom = 8'd36;
95: violin_rom = 8'd39;
96: violin_rom = 8'd38;
97: violin_rom = 8'd37;
98: violin_rom = 8'd40;
99: violin_rom = 8'd39;
100: violin_rom = 8'd38;
101: violin_rom = 8'd39;
102: violin_rom = 8'd38;
103: violin_rom = 8'd37;
104: violin_rom = 8'd36;
105: violin_rom = 8'd35;
106: violin_rom = 8'd33;
107: violin_rom = 8'd40;
108: violin_rom = 8'd41;
109: violin_rom = 8'd42;
110: violin_rom = 8'd41;
111: violin_rom = 8'd40;
112: violin_rom = 8'd39;
113: violin_rom = 8'd38;
114: violin_rom = 8'd37;
115: violin_rom = 8'd36;
116: violin_rom = 8'd40;
117: violin_rom = 8'd39;
118: violin_rom = 8'd40;
119: violin_rom = 8'd39;
120: violin_rom = 8'd38;
121: violin_rom = 8'd101;
122: violin_rom = 8'd108;
123: violin_rom = 8'd107;
124: violin_rom = 8'd107;
125: violin_rom = 8'd96;
126: violin_rom = 8'd106;
127: violin_rom = 8'd236;
128: violin_rom = 8'd239;
129: violin_rom = 8'd238;
130: violin_rom = 8'd239;
131: violin_rom = 8'd240;
132: violin_rom = 8'd113;
133: violin_rom = 8'd106;
134: violin_rom = 8'd105;
135: violin_rom = 8'd105;
136: violin_rom = 8'd96;
137: violin_rom = 8'd104;
138: violin_rom = 8'd106;
139: violin_rom = 8'd106;
140: violin_rom = 8'd106;
141: violin_rom = 8'd106;
142: violin_rom = 8'd106;
143: violin_rom = 8'd106;
144: violin_rom = 8'd106;
145: violin_rom = 8'd109;
146: violin_rom = 8'd107;
147: violin_rom = 8'd110;
148: violin_rom = 8'd14;
149: violin_rom = 8'd14;
150: violin_rom = 8'd12;
151: violin_rom = 8'd13;
152: violin_rom = 8'd14;
153: violin_rom = 8'd14;
154: violin_rom = 8'd12;
155: violin_rom = 8'd13;
156: violin_rom = 8'd14;
157: violin_rom = 8'd7;
158: violin_rom = 8'd8;
159: violin_rom = 8'd9;
160: violin_rom = 8'd10;
161: violin_rom = 8'd11;
162: violin_rom = 8'd12;
163: violin_rom = 8'd13;
164: violin_rom = 8'd12;
165: violin_rom = 8'd12;
166: violin_rom = 8'd10;
167: violin_rom = 8'd11;
168: violin_rom = 8'd12;
169: violin_rom = 8'd12;
170: violin_rom = 8'd5;
171: violin_rom = 8'd6;
172: violin_rom = 8'd7;
173: violin_rom = 8'd8;
174: violin_rom = 8'd7;
175: violin_rom = 8'd6;
176: violin_rom = 8'd7;
177: violin_rom = 8'd5;
178: violin_rom = 8'd6;
179: violin_rom = 8'd7;
180: violin_rom = 8'd6;
181: violin_rom = 8'd6;
182: violin_rom = 8'd8;
183: violin_rom = 8'd7;
184: violin_rom = 8'd6;
185: violin_rom = 8'd6;
186: violin_rom = 8'd5;
187: violin_rom = 8'd4;
188: violin_rom = 8'd5;
189: violin_rom = 8'd4;
190: violin_rom = 8'd3;
191: violin_rom = 8'd4;
192: violin_rom = 8'd5;
193: violin_rom = 8'd6;
194: violin_rom = 8'd7;
195: violin_rom = 8'd8;
196: violin_rom = 8'd6;
197: violin_rom = 8'd6;
198: violin_rom = 8'd8;
199: violin_rom = 8'd7;
200: violin_rom = 8'd8;
201: violin_rom = 8'd8;
202: violin_rom = 8'd9;
203: violin_rom = 8'd10;
204: violin_rom = 8'd7;
205: violin_rom = 8'd8;
206: violin_rom = 8'd9;
207: violin_rom = 8'd10;
208: violin_rom = 8'd11;
209: violin_rom = 8'd12;
210: violin_rom = 8'd13;
211: violin_rom = 8'd14;
212: violin_rom = 8'd12;
213: violin_rom = 8'd12;
214: violin_rom = 8'd10;
215: violin_rom = 8'd11;
216: violin_rom = 8'd12;
217: violin_rom = 8'd12;
218: violin_rom = 8'd11;
219: violin_rom = 8'd10;
220: violin_rom = 8'd11;
221: violin_rom = 8'd9;
222: violin_rom = 8'd10;
223: violin_rom = 8'd11;
224: violin_rom = 8'd12;
225: violin_rom = 8'd11;
226: violin_rom = 8'd10;
227: violin_rom = 8'd9;
228: violin_rom = 8'd10;
229: violin_rom = 8'd10;
230: violin_rom = 8'd8;
231: violin_rom = 8'd9;
232: violin_rom = 8'd10;
233: violin_rom = 8'd10;
234: violin_rom = 8'd3;
235: violin_rom = 8'd4;
236: violin_rom = 8'd5;
237: violin_rom = 8'd6;
238: violin_rom = 8'd5;
239: violin_rom = 8'd4;
240: violin_rom = 8'd5;
241: violin_rom = 8'd10;
242: violin_rom = 8'd9;
243: violin_rom = 8'd10;
244: violin_rom = 8'd8;
245: violin_rom = 8'd8;
246: violin_rom = 8'd10;
247: violin_rom = 8'd9;
248: violin_rom = 8'd8;
249: violin_rom = 8'd8;
250: violin_rom = 8'd7;
251: violin_rom = 8'd6;
252: violin_rom = 8'd7;
253: violin_rom = 8'd6;
254: violin_rom = 8'd5;
255: violin_rom = 8'd6;
256: violin_rom = 8'd7;
257: violin_rom = 8'd8;
258: violin_rom = 8'd9;
259: violin_rom = 8'd10;
260: violin_rom = 8'd8;
261: violin_rom = 8'd8;
262: violin_rom = 8'd10;
263: violin_rom = 8'd9;
264: violin_rom = 8'd10;
265: violin_rom = 8'd10;
266: violin_rom = 8'd9;
267: violin_rom = 8'd8;
268: violin_rom = 8'd9;
269: violin_rom = 8'd10;
270: violin_rom = 8'd11;
271: violin_rom = 8'd10;
272: violin_rom = 8'd9;
273: violin_rom = 8'd10;
274: violin_rom = 8'd8;
275: violin_rom = 8'd9;
276: violin_rom = 8'd106;
277: violin_rom = 8'd96;
278: violin_rom = 8'd105;
279: violin_rom = 8'd96;
280: violin_rom = 8'd104;
281: violin_rom = 8'd96;
282: violin_rom = 8'd106;
283: violin_rom = 8'd96;
284: violin_rom = 8'd99;
285: violin_rom = 8'd96;
286: violin_rom = 8'd99;
287: violin_rom = 8'd96;
288: violin_rom = 8'd99;
289: violin_rom = 8'd96;
290: violin_rom = 8'd99;
291: violin_rom = 8'd96;
292: violin_rom = 8'd96;
293: violin_rom = 8'd103;
294: violin_rom = 8'd96;
295: violin_rom = 8'd103;
296: violin_rom = 8'd96;
297: violin_rom = 8'd101;
298: violin_rom = 8'd96;
299: violin_rom = 8'd103;
300: violin_rom = 8'd96;
301: violin_rom = 8'd102;
302: violin_rom = 8'd96;
303: violin_rom = 8'd101;
304: violin_rom = 8'd96;
305: violin_rom = 8'd102;
306: violin_rom = 8'd96;
307: violin_rom = 8'd107;
        endcase
    endfunction

    function [10:0] violin_freq(input [4:0] note);
        case (note)
        default: violin_freq = 11'd0;
1: violin_freq = 11'd1588;
2: violin_freq = 11'd1415;
3: violin_freq = 11'd1335;
4: violin_freq = 11'd1189;
5: violin_freq = 11'd1060;
6: violin_freq = 11'd1000;
7: violin_freq = 11'd891;
8: violin_freq = 11'd793;
9: violin_freq = 11'd707;
10: violin_freq = 11'd667;
11: violin_freq = 11'd594;
12: violin_freq = 11'd529;
13: violin_freq = 11'd499;
14: violin_freq = 11'd445;
15: violin_freq = 11'd396;
16: violin_freq = 11'd353;
17: violin_freq = 11'd333;      
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

    wire [7:0] violin_note_mux = violin_rom(vnote_idx);
    wire [10:0] violin_divider_mux = violin_freq(violin_note_mux[4:0]);

    always @(posedge clk) begin
        case(count[2:1])
        0,1: begin
            vdivider[1] <= violin_divider_mux;
            violin_duration_mask[0] <= violin_note_mux[7:5];
        end
        2: begin
            vdivider[2] <= violin_divider_mux;
            violin_duration_mask[1] <= violin_note_mux[7:5];
        end
        3: begin
            vdivider[3] <= violin_divider_mux;
            violin_duration_mask[2] <= violin_note_mux[7:5];
        end
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
