/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Ultra(TM) in wire load mode
// Version   : U-2022.12-SP7
// Date      : Sat Jun 27 21:38:32 2026
/////////////////////////////////////////////////////////////


module fft_controller ( clk, rstn, start, data_dout, tw_dout, core_done, 
        core_start, core_x0, core_x1, core_w, core_x0_out, core_x1_out, stage, 
        group, bfly, x0_addr, x1_addr, w_addr, data_cen, data_wen, data_addr, 
        data_din, tw_cen, tw_addr, sram_tb_sel, busy, done );
  input [15:0] data_dout;
  input [15:0] tw_dout;
  output [15:0] core_x0;
  output [15:0] core_x1;
  output [15:0] core_w;
  input [15:0] core_x0_out;
  input [15:0] core_x1_out;
  output [2:0] stage;
  output [5:0] group;
  output [5:0] bfly;
  input [6:0] x0_addr;
  input [6:0] x1_addr;
  input [5:0] w_addr;
  output [6:0] data_addr;
  output [15:0] data_din;
  output [5:0] tw_addr;
  input clk, rstn, start, core_done;
  output core_start, data_cen, data_wen, tw_cen, sram_tb_sel, busy, done;
  wire   n285, n286, n287, N142, n74, n75, n76, n77, n78, n79, n87, n88, n89,
         n90, n91, n92, n93, n94, n95, n96, n97, n98, n99, n100, n101, n102,
         n103, n104, n105, n106, n107, n108, n109, n110, n111, n112, n113,
         n115, n116, n117, n118, n119, n120, n121, n122, n124, n125, n126,
         n127, n128, n129, n130, n131, n132, n133, n134, n136, n138, n139,
         n140, n141, n1420, n143, n144, n145, n146, n147, n148, n149, n150,
         n151, n152, n153, n154, n155, n156, n157, n158, n159, n160, n161,
         n162, n163, n164, n165, n166, n167, n168, n169, n170, n171, n172,
         n173, n174, n175, n176, n177, n178, n179, n180, n181, n182, n183,
         n184, n185, n186, n187, n188, n189, n190, n191, n192, n193, n194,
         n195, n196, n197, n198, n199, n200, n201, n202, n203, n204, n205,
         n206, n207, n208, n209, n210, n211, n212, n213, n214, n215, n216,
         n217, n218, n219, n220, n221, n222, n223, n224, n225, n226, n227,
         n228, n229, n230, n231, n232, n233, n234, n235, n236, n237, n238,
         n239, n240, n241, n242, n243, n244, n245, n246, n247, n248, n249,
         n250, n251, n252, n253, n254, n255, n256, n257, n258, n259, n260,
         n261, n262, n263, n264, n265, n266, n267, n268, n269, n270, n271,
         n273, n274, n275, n276, n277, n278, n279, n280, n281, n282, n283,
         n284;
  wire   [2:0] state;
  wire   [6:0] x0_addr_l;
  wire   [6:0] x1_addr_l;

  DFCNQD1 stage_reg_0_ ( .D(n103), .CP(clk), .CDN(n273), .Q(n286) );
  DFCNQD1 state_reg_2_ ( .D(n98), .CP(clk), .CDN(n273), .Q(state[2]) );
  DFCNQD1 state_reg_1_ ( .D(n100), .CP(clk), .CDN(n273), .Q(state[1]) );
  DFCNQD1 state_reg_0_ ( .D(n99), .CP(clk), .CDN(n273), .Q(state[0]) );
  DFCNQD1 stage_reg_1_ ( .D(n102), .CP(clk), .CDN(n274), .Q(stage[1]) );
  DFCNQD1 stage_reg_2_ ( .D(n101), .CP(clk), .CDN(n274), .Q(n285) );
  DFCNQD1 bfly_reg_5_ ( .D(n104), .CP(clk), .CDN(n274), .Q(bfly[5]) );
  DFCNQD1 bfly_reg_4_ ( .D(n93), .CP(clk), .CDN(n274), .Q(bfly[4]) );
  DFCNQD1 bfly_reg_3_ ( .D(n94), .CP(clk), .CDN(n275), .Q(bfly[3]) );
  DFCNQD1 bfly_reg_2_ ( .D(n95), .CP(clk), .CDN(n275), .Q(bfly[2]) );
  DFCNQD1 bfly_reg_1_ ( .D(n96), .CP(clk), .CDN(n275), .Q(bfly[1]) );
  DFCNQD1 bfly_reg_0_ ( .D(n97), .CP(clk), .CDN(n275), .Q(bfly[0]) );
  DFCNQD1 group_reg_5_ ( .D(n88), .CP(clk), .CDN(n276), .Q(group[5]) );
  DFCNQD1 group_reg_4_ ( .D(n89), .CP(clk), .CDN(n276), .Q(group[4]) );
  DFCNQD1 group_reg_3_ ( .D(n90), .CP(clk), .CDN(n276), .Q(group[3]) );
  DFCNQD1 group_reg_2_ ( .D(n91), .CP(clk), .CDN(n276), .Q(group[2]) );
  DFCNQD1 group_reg_1_ ( .D(n92), .CP(clk), .CDN(n277), .Q(group[1]) );
  DFCNQD1 group_reg_0_ ( .D(n105), .CP(clk), .CDN(n277), .Q(group[0]) );
  DFCNQD1 x0_addr_l_reg_0_ ( .D(n87), .CP(clk), .CDN(n277), .Q(x0_addr_l[0])
         );
  DFCNQD1 x0_addr_l_reg_6_ ( .D(n79), .CP(clk), .CDN(n279), .Q(x0_addr_l[6])
         );
  DFCNQD1 x0_addr_l_reg_5_ ( .D(n78), .CP(clk), .CDN(n279), .Q(x0_addr_l[5])
         );
  DFCNQD1 x0_addr_l_reg_4_ ( .D(n77), .CP(clk), .CDN(n280), .Q(x0_addr_l[4])
         );
  DFCNQD1 x0_addr_l_reg_3_ ( .D(n76), .CP(clk), .CDN(n280), .Q(x0_addr_l[3])
         );
  DFCNQD1 x0_addr_l_reg_2_ ( .D(n75), .CP(clk), .CDN(n280), .Q(x0_addr_l[2])
         );
  DFCNQD1 x0_addr_l_reg_1_ ( .D(n74), .CP(clk), .CDN(n280), .Q(x0_addr_l[1])
         );
  EDFCNQD1 x0_latched_reg_3_ ( .D(data_dout[3]), .E(n284), .CP(clk), .CDN(n283), .Q(core_x0[3]) );
  EDFCNQD1 x0_latched_reg_4_ ( .D(data_dout[4]), .E(n271), .CP(clk), .CDN(n282), .Q(core_x0[4]) );
  EDFCNQD1 x0_latched_reg_2_ ( .D(data_dout[2]), .E(n270), .CP(clk), .CDN(n283), .Q(core_x0[2]) );
  EDFCNQD1 x0_latched_reg_1_ ( .D(data_dout[1]), .E(n270), .CP(clk), .CDN(n283), .Q(core_x0[1]) );
  EDFCNQD1 x0_latched_reg_15_ ( .D(data_dout[15]), .E(n269), .CP(clk), .CDN(
        n241), .Q(core_x0[15]) );
  EDFCNQD1 x0_latched_reg_14_ ( .D(data_dout[14]), .E(n269), .CP(clk), .CDN(
        n242), .Q(core_x0[14]) );
  EDFCNQD1 x0_latched_reg_13_ ( .D(data_dout[13]), .E(n269), .CP(clk), .CDN(
        n243), .Q(core_x0[13]) );
  EDFCNQD1 x0_latched_reg_12_ ( .D(data_dout[12]), .E(n269), .CP(clk), .CDN(
        n242), .Q(core_x0[12]) );
  EDFCNQD1 x0_latched_reg_11_ ( .D(data_dout[11]), .E(n268), .CP(clk), .CDN(
        n281), .Q(core_x0[11]) );
  EDFCNQD1 x0_latched_reg_10_ ( .D(data_dout[10]), .E(n268), .CP(clk), .CDN(
        n281), .Q(core_x0[10]) );
  EDFCNQD1 x0_latched_reg_9_ ( .D(data_dout[9]), .E(n268), .CP(clk), .CDN(n281), .Q(core_x0[9]) );
  EDFCNQD1 x0_latched_reg_0_ ( .D(data_dout[0]), .E(n268), .CP(clk), .CDN(n283), .Q(core_x0[0]) );
  EDFCNQD1 x0_latched_reg_8_ ( .D(data_dout[8]), .E(n267), .CP(clk), .CDN(n281), .Q(core_x0[8]) );
  EDFCNQD1 x0_latched_reg_7_ ( .D(data_dout[7]), .E(n267), .CP(clk), .CDN(n282), .Q(core_x0[7]) );
  EDFCNQD1 x0_latched_reg_6_ ( .D(data_dout[6]), .E(n267), .CP(clk), .CDN(n282), .Q(core_x0[6]) );
  EDFCNQD1 x0_latched_reg_5_ ( .D(data_dout[5]), .E(n267), .CP(clk), .CDN(n282), .Q(core_x0[5]) );
  EDFCNQD1 x1_addr_l_reg_6_ ( .D(x1_addr[6]), .E(n140), .CP(clk), .CDN(n277), 
        .Q(x1_addr_l[6]) );
  EDFCNQD1 x1_addr_l_reg_5_ ( .D(x1_addr[5]), .E(n139), .CP(clk), .CDN(n278), 
        .Q(x1_addr_l[5]) );
  EDFCNQD1 x1_addr_l_reg_4_ ( .D(x1_addr[4]), .E(n138), .CP(clk), .CDN(n278), 
        .Q(x1_addr_l[4]) );
  EDFCNQD1 x1_addr_l_reg_3_ ( .D(x1_addr[3]), .E(tw_cen), .CP(clk), .CDN(n278), 
        .Q(x1_addr_l[3]) );
  EDFCNQD1 x1_addr_l_reg_2_ ( .D(x1_addr[2]), .E(n140), .CP(clk), .CDN(n278), 
        .Q(x1_addr_l[2]) );
  EDFCNQD1 x1_addr_l_reg_1_ ( .D(x1_addr[1]), .E(n139), .CP(clk), .CDN(n279), 
        .Q(x1_addr_l[1]) );
  EDFCNQD1 x1_addr_l_reg_0_ ( .D(x1_addr[0]), .E(n138), .CP(clk), .CDN(n279), 
        .Q(x1_addr_l[0]) );
  NR2D0 U184 ( .A1(n217), .A2(n259), .ZN(n208) );
  INVD0 U185 ( .I(n152), .ZN(n111) );
  INVD0 U186 ( .I(bfly[0]), .ZN(n162) );
  INVD0 U187 ( .I(n285), .ZN(n260) );
  CKND2D0 U188 ( .A1(n265), .A2(n108), .ZN(n220) );
  INVD0 U189 ( .I(n255), .ZN(n129) );
  OR2D0 U190 ( .A1(n112), .A2(state[1]), .Z(n287) );
  INVD0 U191 ( .I(N142), .ZN(tw_cen) );
  INVD0 U192 ( .I(n287), .ZN(data_wen) );
  INVD0 U193 ( .I(state[1]), .ZN(n115) );
  INVD0 U194 ( .I(n115), .ZN(n116) );
  OR2D0 U195 ( .A1(n111), .A2(n149), .Z(n211) );
  INVD0 U196 ( .I(n107), .ZN(n108) );
  INVD0 U197 ( .I(n206), .ZN(n121) );
  INVD0 U198 ( .I(n121), .ZN(n122) );
  CKND2D0 U199 ( .A1(n215), .A2(n214), .ZN(n99) );
  INVD0 U200 ( .I(n208), .ZN(n119) );
  INVD0 U201 ( .I(n208), .ZN(n120) );
  AN3D0 U202 ( .A1(n218), .A2(n217), .A3(n216), .Z(n262) );
  INVD0 U203 ( .I(n167), .ZN(n172) );
  CKAN2D1 U204 ( .A1(n131), .A2(n253), .Z(n174) );
  CKBD1 U205 ( .I(n144), .Z(n221) );
  OR2D1 U206 ( .A1(n224), .A2(tw_cen), .Z(n252) );
  NR2D1 U207 ( .A1(n149), .A2(state[0]), .ZN(n144) );
  NR2D0 U208 ( .A1(n254), .A2(n285), .ZN(n192) );
  BUFFD0 U209 ( .I(tw_cen), .Z(n251) );
  NR2D0 U210 ( .A1(n258), .A2(stage[2]), .ZN(n196) );
  NR2D0 U211 ( .A1(n258), .A2(n260), .ZN(n185) );
  NR2D0 U212 ( .A1(n154), .A2(n171), .ZN(n155) );
  CKND2D1 U213 ( .A1(n116), .A2(n110), .ZN(n212) );
  ND2D0 U214 ( .A1(n136), .A2(group[1]), .ZN(n181) );
  CKND2D1 U215 ( .A1(n116), .A2(n113), .ZN(n141) );
  ND2D0 U216 ( .A1(stage[0]), .A2(n256), .ZN(n258) );
  OAI32D0 U217 ( .A1(n262), .A2(n259), .A3(n219), .B1(n286), .B2(n106), .ZN(
        n103) );
  OAI22D0 U218 ( .A1(n203), .A2(n120), .B1(n202), .B2(n206), .ZN(n88) );
  OAI22D0 U219 ( .A1(n201), .A2(n120), .B1(n200), .B2(n122), .ZN(n90) );
  OAI22D0 U220 ( .A1(n205), .A2(n119), .B1(n204), .B2(n122), .ZN(n92) );
  OAI22D0 U221 ( .A1(n209), .A2(n120), .B1(n207), .B2(n206), .ZN(n91) );
  CKND2D0 U222 ( .A1(n106), .A2(n253), .ZN(n257) );
  AOI22D0 U223 ( .A1(group[0]), .A2(n119), .B1(n122), .B2(n197), .ZN(n105) );
  OAI22D0 U224 ( .A1(n199), .A2(n119), .B1(n198), .B2(n122), .ZN(n89) );
  MOAI22D0 U225 ( .A1(n171), .A2(n117), .B1(n170), .B2(n172), .ZN(n94) );
  INVD0 U226 ( .I(n262), .ZN(n106) );
  OAI22D0 U227 ( .A1(n166), .A2(n117), .B1(n165), .B2(n167), .ZN(n96) );
  MOAI22D0 U228 ( .A1(n175), .A2(n118), .B1(n173), .B2(n172), .ZN(n93) );
  OAI22D0 U229 ( .A1(n164), .A2(n118), .B1(n163), .B2(n167), .ZN(n95) );
  AOI22D0 U230 ( .A1(bfly[0]), .A2(n117), .B1(n167), .B2(n162), .ZN(n97) );
  MOAI22D0 U231 ( .A1(n169), .A2(n118), .B1(n168), .B2(n172), .ZN(n104) );
  INVD0 U232 ( .I(n174), .ZN(n117) );
  INVD0 U233 ( .I(n174), .ZN(n118) );
  IND2D0 U234 ( .A1(n218), .B1(n217), .ZN(n206) );
  INVD0 U235 ( .I(n220), .ZN(done) );
  OAI211D0 U236 ( .A1(start), .A2(n212), .B(n128), .C(n220), .ZN(n100) );
  AOI211D0 U237 ( .A1(n124), .A2(n213), .B(n224), .C(n264), .ZN(n215) );
  INVD0 U238 ( .I(n255), .ZN(n131) );
  AOI211D0 U239 ( .A1(n265), .A2(data_wen), .B(n264), .C(n263), .ZN(n266) );
  AOI22D0 U240 ( .A1(n237), .A2(x1_addr[0]), .B1(n264), .B2(x0_addr_l[0]), 
        .ZN(n232) );
  INR2D0 U241 ( .A1(w_addr[0]), .B1(n127), .ZN(tw_addr[0]) );
  INR2D0 U242 ( .A1(w_addr[4]), .B1(n127), .ZN(tw_addr[4]) );
  INR2D0 U243 ( .A1(w_addr[1]), .B1(n128), .ZN(tw_addr[1]) );
  AOI22D0 U244 ( .A1(n270), .A2(x1_addr[4]), .B1(n229), .B2(x0_addr_l[4]), 
        .ZN(n227) );
  AOI22D0 U245 ( .A1(n224), .A2(x1_addr[5]), .B1(n229), .B2(x0_addr_l[5]), 
        .ZN(n225) );
  INR2D0 U246 ( .A1(w_addr[2]), .B1(n128), .ZN(tw_addr[2]) );
  CKBD1 U247 ( .I(n132), .Z(n255) );
  AOI22D0 U248 ( .A1(n237), .A2(x1_addr[2]), .B1(n264), .B2(x0_addr_l[2]), 
        .ZN(n234) );
  AOI22D0 U249 ( .A1(n237), .A2(x1_addr[3]), .B1(n229), .B2(x0_addr_l[3]), 
        .ZN(n230) );
  INR2D0 U250 ( .A1(w_addr[3]), .B1(n127), .ZN(tw_addr[3]) );
  AOI22D0 U251 ( .A1(n237), .A2(x1_addr[1]), .B1(n236), .B2(x0_addr_l[1]), 
        .ZN(n238) );
  AOI22D0 U252 ( .A1(n224), .A2(x1_addr[6]), .B1(n229), .B2(x0_addr_l[6]), 
        .ZN(n222) );
  INR2D0 U253 ( .A1(w_addr[5]), .B1(n128), .ZN(tw_addr[5]) );
  CKND2D1 U254 ( .A1(n134), .A2(n210), .ZN(n167) );
  INVD0 U255 ( .I(n211), .ZN(n134) );
  BUFFD0 U256 ( .I(n221), .Z(n229) );
  OAI21D0 U257 ( .A1(n196), .A2(n202), .B(n193), .ZN(n194) );
  OAI22D0 U258 ( .A1(n191), .A2(n200), .B1(n192), .B2(n198), .ZN(n190) );
  BUFFD1 U259 ( .I(n176), .Z(core_start) );
  AOI22D0 U260 ( .A1(n173), .A2(n182), .B1(n168), .B2(n157), .ZN(n159) );
  BUFFD0 U261 ( .I(n271), .Z(n237) );
  AOI22D0 U262 ( .A1(n170), .A2(n261), .B1(bfly[5]), .B2(n216), .ZN(n160) );
  CKND2D0 U263 ( .A1(n140), .A2(x0_addr[1]), .ZN(n249) );
  CKND2D0 U264 ( .A1(n139), .A2(x0_addr[2]), .ZN(n248) );
  IND2D0 U265 ( .A1(n188), .B1(group[4]), .ZN(n180) );
  CKND2D0 U266 ( .A1(n138), .A2(x0_addr[0]), .ZN(n244) );
  OAI21D0 U267 ( .A1(n189), .A2(group[3]), .B(n188), .ZN(n200) );
  OAI22D0 U268 ( .A1(n185), .A2(n204), .B1(n207), .B2(n184), .ZN(n183) );
  INVD0 U269 ( .I(n287), .ZN(n124) );
  CKND2D0 U270 ( .A1(tw_cen), .A2(x0_addr[3]), .ZN(n247) );
  CKND2D0 U271 ( .A1(n140), .A2(x0_addr[4]), .ZN(n246) );
  OAI22D0 U272 ( .A1(n196), .A2(n165), .B1(n192), .B2(n163), .ZN(n161) );
  CKND2D0 U273 ( .A1(n139), .A2(x0_addr[5]), .ZN(n250) );
  BUFFD1 U274 ( .I(n284), .Z(n271) );
  CKND2D0 U275 ( .A1(n138), .A2(x0_addr[6]), .ZN(n245) );
  AO21D0 U276 ( .A1(n181), .A2(n209), .B(n189), .Z(n207) );
  CKND2D1 U277 ( .A1(group[3]), .A2(n189), .ZN(n188) );
  CKND2D0 U278 ( .A1(n155), .A2(bfly[4]), .ZN(n156) );
  NR2XD0 U279 ( .A1(n254), .A2(n260), .ZN(n187) );
  NR2XD0 U280 ( .A1(n181), .A2(n209), .ZN(n189) );
  OAI21D0 U281 ( .A1(n153), .A2(bfly[2]), .B(n154), .ZN(n163) );
  CKND2D0 U282 ( .A1(start), .A2(n110), .ZN(n214) );
  ND3D0 U283 ( .A1(n256), .A2(n219), .A3(n285), .ZN(n182) );
  CKND2D1 U284 ( .A1(stage[1]), .A2(n219), .ZN(n254) );
  OAI21D0 U285 ( .A1(group[0]), .A2(group[1]), .B(n181), .ZN(n204) );
  INVD0 U286 ( .I(n286), .ZN(n219) );
  CKND2D1 U287 ( .A1(n153), .A2(bfly[2]), .ZN(n154) );
  OAI31D0 U288 ( .A1(stage[2]), .A2(stage[1]), .A3(stage[0]), .B(n162), .ZN(
        n158) );
  ND3D0 U289 ( .A1(n260), .A2(stage[1]), .A3(n286), .ZN(n261) );
  NR2XD0 U290 ( .A1(n162), .A2(n166), .ZN(n153) );
  INVD0 U291 ( .I(group[0]), .ZN(n197) );
  CKBD1 U292 ( .I(state[0]), .Z(n152) );
  BUFFD1 U293 ( .I(n285), .Z(stage[2]) );
  INVD0 U294 ( .I(group[2]), .ZN(n209) );
  INVD0 U295 ( .I(bfly[1]), .ZN(n166) );
  INVD0 U296 ( .I(stage[1]), .ZN(n256) );
  INVD0 U297 ( .I(bfly[3]), .ZN(n171) );
  INVD1 U298 ( .I(n133), .ZN(n107) );
  INVD0 U299 ( .I(n107), .ZN(n109) );
  INVD1 U300 ( .I(n152), .ZN(n110) );
  INVD1 U301 ( .I(state[2]), .ZN(n112) );
  INVD1 U302 ( .I(state[2]), .ZN(n113) );
  INVD1 U303 ( .I(n219), .ZN(stage[0]) );
  INVD0 U304 ( .I(n251), .ZN(n125) );
  INVD0 U305 ( .I(n251), .ZN(n126) );
  INVD1 U306 ( .I(n252), .ZN(n127) );
  INVD1 U307 ( .I(n252), .ZN(n128) );
  INVD0 U308 ( .I(n255), .ZN(n130) );
  INVD1 U309 ( .I(n211), .ZN(n132) );
  INVD1 U310 ( .I(n211), .ZN(n133) );
  INVD0 U311 ( .I(n197), .ZN(n136) );
  OR3D1 U312 ( .A1(state[2]), .A2(n116), .A3(n111), .Z(N142) );
  INVD1 U313 ( .I(N142), .ZN(n138) );
  INVD1 U314 ( .I(N142), .ZN(n139) );
  INVD1 U315 ( .I(N142), .ZN(n140) );
  NR2D1 U316 ( .A1(n212), .A2(state[2]), .ZN(n284) );
  NR2D1 U317 ( .A1(n141), .A2(n110), .ZN(n146) );
  CKBD1 U318 ( .I(n146), .Z(n176) );
  INVD1 U319 ( .I(data_wen), .ZN(n149) );
  AO22D0 U320 ( .A1(n109), .A2(core_x1_out[15]), .B1(n144), .B2(
        core_x0_out[15]), .Z(data_din[15]) );
  BUFFD1 U321 ( .I(n144), .Z(n1420) );
  AO22D0 U322 ( .A1(n133), .A2(core_x1_out[6]), .B1(n1420), .B2(core_x0_out[6]), .Z(data_din[6]) );
  AO22D0 U323 ( .A1(n133), .A2(core_x1_out[7]), .B1(n1420), .B2(core_x0_out[7]), .Z(data_din[7]) );
  BUFFD1 U324 ( .I(n144), .Z(n143) );
  AO22D0 U325 ( .A1(n133), .A2(core_x1_out[11]), .B1(n143), .B2(
        core_x0_out[11]), .Z(data_din[11]) );
  AO22D0 U326 ( .A1(n108), .A2(core_x1_out[10]), .B1(n143), .B2(
        core_x0_out[10]), .Z(data_din[10]) );
  AO22D0 U327 ( .A1(n132), .A2(core_x1_out[0]), .B1(n1420), .B2(core_x0_out[0]), .Z(data_din[0]) );
  AO22D0 U328 ( .A1(n132), .A2(core_x1_out[9]), .B1(n143), .B2(core_x0_out[9]), 
        .Z(data_din[9]) );
  AO22D0 U329 ( .A1(n132), .A2(core_x1_out[5]), .B1(n1420), .B2(core_x0_out[5]), .Z(data_din[5]) );
  AO22D0 U330 ( .A1(n109), .A2(core_x1_out[8]), .B1(n143), .B2(core_x0_out[8]), 
        .Z(data_din[8]) );
  BUFFD1 U331 ( .I(n221), .Z(n145) );
  AO22D0 U332 ( .A1(n134), .A2(core_x1_out[2]), .B1(n145), .B2(core_x0_out[2]), 
        .Z(data_din[2]) );
  AO22D0 U333 ( .A1(n134), .A2(core_x1_out[4]), .B1(n145), .B2(core_x0_out[4]), 
        .Z(data_din[4]) );
  AO22D0 U334 ( .A1(n134), .A2(core_x1_out[3]), .B1(n145), .B2(core_x0_out[3]), 
        .Z(data_din[3]) );
  AO22D0 U335 ( .A1(n108), .A2(core_x1_out[1]), .B1(n145), .B2(core_x0_out[1]), 
        .Z(data_din[1]) );
  BUFFD1 U336 ( .I(n221), .Z(n236) );
  AO22D0 U337 ( .A1(n108), .A2(core_x1_out[13]), .B1(n236), .B2(
        core_x0_out[13]), .Z(data_din[13]) );
  AO22D0 U338 ( .A1(n109), .A2(core_x1_out[12]), .B1(n236), .B2(
        core_x0_out[12]), .Z(data_din[12]) );
  AO22D0 U339 ( .A1(n109), .A2(core_x1_out[14]), .B1(n236), .B2(
        core_x0_out[14]), .Z(data_din[14]) );
  OAI32D0 U340 ( .A1(state[0]), .A2(n124), .A3(state[1]), .B1(n112), .B2(
        data_wen), .ZN(sram_tb_sel) );
  INVD0 U341 ( .I(sram_tb_sel), .ZN(busy) );
  BUFFD1 U342 ( .I(n146), .Z(n147) );
  CKAN2D0 U343 ( .A1(data_dout[9]), .A2(n147), .Z(core_x1[9]) );
  CKAN2D0 U344 ( .A1(data_dout[8]), .A2(n147), .Z(core_x1[8]) );
  CKAN2D0 U345 ( .A1(data_dout[7]), .A2(n147), .Z(core_x1[7]) );
  BUFFD1 U346 ( .I(n146), .Z(n148) );
  CKAN2D0 U347 ( .A1(data_dout[12]), .A2(n148), .Z(core_x1[12]) );
  CKAN2D0 U348 ( .A1(data_dout[10]), .A2(n147), .Z(core_x1[10]) );
  CKAN2D0 U349 ( .A1(data_dout[3]), .A2(n148), .Z(core_x1[3]) );
  CKAN2D0 U350 ( .A1(data_dout[4]), .A2(n148), .Z(core_x1[4]) );
  CKAN2D0 U351 ( .A1(data_dout[5]), .A2(n148), .Z(core_x1[5]) );
  BUFFD1 U352 ( .I(n271), .Z(n224) );
  CKND2D0 U353 ( .A1(n127), .A2(n149), .ZN(data_cen) );
  BUFFD1 U354 ( .I(n176), .Z(n150) );
  CKAN2D0 U355 ( .A1(n150), .A2(tw_dout[8]), .Z(core_w[8]) );
  BUFFD1 U356 ( .I(n176), .Z(n151) );
  CKAN2D0 U357 ( .A1(n151), .A2(tw_dout[13]), .Z(core_w[13]) );
  CKAN2D0 U358 ( .A1(n150), .A2(tw_dout[11]), .Z(core_w[11]) );
  CKAN2D0 U359 ( .A1(n150), .A2(tw_dout[10]), .Z(core_w[10]) );
  CKAN2D0 U360 ( .A1(n150), .A2(tw_dout[9]), .Z(core_w[9]) );
  CKAN2D0 U361 ( .A1(n151), .A2(tw_dout[15]), .Z(core_w[15]) );
  CKAN2D0 U362 ( .A1(n151), .A2(tw_dout[14]), .Z(core_w[14]) );
  CKAN2D0 U363 ( .A1(n151), .A2(tw_dout[12]), .Z(core_w[12]) );
  CKAN2D0 U364 ( .A1(data_dout[11]), .A2(core_start), .Z(core_x1[11]) );
  CKAN2D0 U365 ( .A1(data_dout[14]), .A2(core_start), .Z(core_x1[14]) );
  CKAN2D0 U366 ( .A1(data_dout[13]), .A2(core_start), .Z(core_x1[13]) );
  CKAN2D0 U367 ( .A1(data_dout[15]), .A2(core_start), .Z(core_x1[15]) );
  AOI211XD0 U368 ( .A1(n116), .A2(n113), .B(n124), .C(n214), .ZN(n259) );
  INVD0 U369 ( .I(n259), .ZN(n253) );
  AO21D0 U370 ( .A1(n162), .A2(n166), .B(n153), .Z(n165) );
  MUX2ND0 U371 ( .I0(bfly[3]), .I1(n171), .S(n154), .ZN(n170) );
  INVD1 U372 ( .I(n187), .ZN(n216) );
  INVD0 U373 ( .I(bfly[4]), .ZN(n175) );
  MUX2ND0 U374 ( .I0(n175), .I1(bfly[4]), .S(n155), .ZN(n173) );
  INVD0 U375 ( .I(bfly[5]), .ZN(n169) );
  MUX2ND0 U376 ( .I0(bfly[5]), .I1(n169), .S(n156), .ZN(n168) );
  INVD0 U377 ( .I(n185), .ZN(n157) );
  IND4D1 U378 ( .A1(n161), .B1(n160), .B2(n159), .B3(n158), .ZN(n210) );
  INVD0 U379 ( .I(bfly[2]), .ZN(n164) );
  CKBD1 U380 ( .I(n176), .Z(n263) );
  BUFFD1 U381 ( .I(n263), .Z(n178) );
  CKAN2D0 U382 ( .A1(n178), .A2(tw_dout[7]), .Z(core_w[7]) );
  CKAN2D0 U383 ( .A1(n178), .A2(tw_dout[6]), .Z(core_w[6]) );
  BUFFD1 U384 ( .I(n263), .Z(n177) );
  CKAN2D0 U385 ( .A1(n177), .A2(tw_dout[1]), .Z(core_w[1]) );
  CKAN2D0 U386 ( .A1(n177), .A2(tw_dout[0]), .Z(core_w[0]) );
  CKAN2D0 U387 ( .A1(n177), .A2(tw_dout[2]), .Z(core_w[2]) );
  CKAN2D0 U388 ( .A1(n177), .A2(tw_dout[3]), .Z(core_w[3]) );
  CKAN2D0 U389 ( .A1(n178), .A2(tw_dout[4]), .Z(core_w[4]) );
  CKAN2D0 U390 ( .A1(n178), .A2(tw_dout[5]), .Z(core_w[5]) );
  BUFFD1 U391 ( .I(n263), .Z(n179) );
  CKAN2D0 U392 ( .A1(data_dout[0]), .A2(n179), .Z(core_x1[0]) );
  CKAN2D0 U393 ( .A1(data_dout[1]), .A2(n179), .Z(core_x1[1]) );
  CKAN2D0 U394 ( .A1(data_dout[6]), .A2(n179), .Z(core_x1[6]) );
  CKAN2D0 U395 ( .A1(data_dout[2]), .A2(n179), .Z(core_x1[2]) );
  NR2D1 U396 ( .A1(n210), .A2(n129), .ZN(n217) );
  INVD0 U397 ( .I(group[5]), .ZN(n203) );
  MUX2ND0 U398 ( .I0(n203), .I1(group[5]), .S(n180), .ZN(n202) );
  INVD0 U399 ( .I(n182), .ZN(n184) );
  AOI221D0 U400 ( .A1(n204), .A2(n185), .B1(n207), .B2(n184), .C(n183), .ZN(
        n186) );
  OAI221D0 U401 ( .A1(n187), .A2(group[0]), .B1(n216), .B2(n197), .C(n186), 
        .ZN(n195) );
  INVD0 U402 ( .I(group[4]), .ZN(n199) );
  MUX2ND0 U403 ( .I0(n199), .I1(group[4]), .S(n188), .ZN(n198) );
  INVD0 U404 ( .I(n261), .ZN(n191) );
  AOI221D0 U405 ( .A1(n198), .A2(n192), .B1(n200), .B2(n191), .C(n190), .ZN(
        n193) );
  AOI211XD0 U406 ( .A1(n196), .A2(n202), .B(n195), .C(n194), .ZN(n218) );
  INVD0 U407 ( .I(group[3]), .ZN(n201) );
  INVD0 U408 ( .I(group[1]), .ZN(n205) );
  INR3D0 U409 ( .A1(n218), .B1(n210), .B2(n216), .ZN(n265) );
  INVD0 U410 ( .I(n265), .ZN(n213) );
  BUFFD1 U411 ( .I(n221), .Z(n264) );
  INVD0 U412 ( .I(x1_addr_l[6]), .ZN(n223) );
  OAI211D0 U413 ( .A1(n130), .A2(n223), .B(n222), .C(n245), .ZN(data_addr[6])
         );
  INVD0 U414 ( .I(x1_addr_l[5]), .ZN(n226) );
  OAI211D0 U415 ( .A1(n131), .A2(n226), .B(n225), .C(n250), .ZN(data_addr[5])
         );
  BUFFD1 U416 ( .I(n284), .Z(n270) );
  INVD0 U417 ( .I(x1_addr_l[4]), .ZN(n228) );
  OAI211D0 U418 ( .A1(n129), .A2(n228), .B(n227), .C(n246), .ZN(data_addr[4])
         );
  INVD0 U419 ( .I(x1_addr_l[3]), .ZN(n231) );
  OAI211D0 U420 ( .A1(n130), .A2(n231), .B(n230), .C(n247), .ZN(data_addr[3])
         );
  INVD0 U421 ( .I(x1_addr_l[0]), .ZN(n233) );
  OAI211D0 U422 ( .A1(n131), .A2(n233), .B(n232), .C(n244), .ZN(data_addr[0])
         );
  INVD0 U423 ( .I(x1_addr_l[2]), .ZN(n235) );
  OAI211D0 U424 ( .A1(n129), .A2(n235), .B(n234), .C(n248), .ZN(data_addr[2])
         );
  INVD0 U425 ( .I(x1_addr_l[1]), .ZN(n239) );
  OAI211D0 U426 ( .A1(n130), .A2(n239), .B(n238), .C(n249), .ZN(data_addr[1])
         );
  BUFFD0 U427 ( .I(rstn), .Z(n240) );
  BUFFD0 U428 ( .I(n240), .Z(n283) );
  BUFFD0 U429 ( .I(rstn), .Z(n241) );
  BUFFD0 U430 ( .I(n241), .Z(n273) );
  BUFFD0 U431 ( .I(n240), .Z(n282) );
  BUFFD0 U432 ( .I(n241), .Z(n274) );
  BUFFD0 U433 ( .I(n240), .Z(n281) );
  BUFFD0 U434 ( .I(n241), .Z(n275) );
  BUFFD0 U435 ( .I(rstn), .Z(n242) );
  BUFFD0 U436 ( .I(rstn), .Z(n243) );
  BUFFD0 U437 ( .I(n243), .Z(n276) );
  BUFFD0 U438 ( .I(n242), .Z(n280) );
  BUFFD0 U439 ( .I(n243), .Z(n277) );
  BUFFD0 U440 ( .I(n242), .Z(n279) );
  BUFFD0 U441 ( .I(n243), .Z(n278) );
  IOA21D0 U442 ( .A1(x0_addr_l[0]), .A2(n125), .B(n244), .ZN(n87) );
  IOA21D0 U443 ( .A1(x0_addr_l[6]), .A2(n126), .B(n245), .ZN(n79) );
  IOA21D0 U444 ( .A1(x0_addr_l[4]), .A2(n125), .B(n246), .ZN(n77) );
  IOA21D0 U445 ( .A1(x0_addr_l[3]), .A2(n126), .B(n247), .ZN(n76) );
  IOA21D0 U446 ( .A1(x0_addr_l[2]), .A2(n125), .B(n248), .ZN(n75) );
  IOA21D0 U447 ( .A1(x0_addr_l[1]), .A2(n126), .B(n249), .ZN(n74) );
  IOA21D0 U448 ( .A1(x0_addr_l[5]), .A2(n125), .B(n250), .ZN(n78) );
  BUFFD1 U449 ( .I(n284), .Z(n269) );
  BUFFD1 U450 ( .I(n270), .Z(n267) );
  BUFFD1 U451 ( .I(n271), .Z(n268) );
  OAI222D0 U452 ( .A1(n106), .A2(n258), .B1(n257), .B2(n256), .C1(n129), .C2(
        n254), .ZN(n102) );
  OAI22D0 U453 ( .A1(n106), .A2(n261), .B1(n260), .B2(n259), .ZN(n101) );
  OAI31D0 U454 ( .A1(state[0]), .A2(start), .A3(n112), .B(n266), .ZN(n98) );
endmodule

