/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Ultra(TM) in wire load mode
// Version   : U-2022.12-SP7
// Date      : Sat Jun 27 21:49:43 2026
/////////////////////////////////////////////////////////////


module fft_address_gen ( stage, group, bfly, linear_addr, x0_addr, x1_addr, 
        w_addr, bitrev_addr );
  input [2:0] stage;
  input [5:0] group;
  input [5:0] bfly;
  input [6:0] linear_addr;
  output [6:0] x0_addr;
  output [6:0] x1_addr;
  output [5:0] w_addr;
  output [6:0] bitrev_addr;
  wire   intadd_0_B_3_, intadd_0_B_2_, intadd_0_B_1_, intadd_0_B_0_,
         intadd_0_CI, intadd_0_n4, intadd_0_n3, intadd_0_n2, intadd_0_n1, n40,
         n41, n42, n43, n44, n45, n46, n47, n48, n49, n50, n51, n52, n53, n54,
         n55, n57, n58, n59, n60, n61, n62, n63, n64, n65, n66, n67, n68, n69,
         n70, n71, n72, n73, n74, n75, n76, n77, n78, n79, n80, n81, n82, n83,
         n84, n85, n86, n87, n88, n89, n90, n91, n92, n93, n94, n95, n96, n97,
         n98, n99, n100, n101, n102, n103, n104, n105, n106, n107, n108, n109,
         n110, n111, n112, n113;

  FA1D0 intadd_0_U5 ( .A(bfly[2]), .B(intadd_0_B_0_), .CI(intadd_0_CI), .CO(
        intadd_0_n4), .S(x0_addr[2]) );
  FA1D0 intadd_0_U4 ( .A(bfly[3]), .B(intadd_0_B_1_), .CI(intadd_0_n4), .CO(
        intadd_0_n3), .S(x0_addr[3]) );
  FA1D0 intadd_0_U3 ( .A(bfly[4]), .B(intadd_0_B_2_), .CI(intadd_0_n3), .CO(
        intadd_0_n2), .S(x0_addr[4]) );
  FA1D0 intadd_0_U2 ( .A(bfly[5]), .B(intadd_0_B_3_), .CI(intadd_0_n2), .CO(
        intadd_0_n1), .S(x0_addr[5]) );
  CKND2D0 U62 ( .A1(stage[1]), .A2(n61), .ZN(n65) );
  INVD0 U63 ( .I(stage[0]), .ZN(n111) );
  AOI32D0 U64 ( .A1(n63), .A2(n91), .A3(group[2]), .B1(n54), .B2(n91), .ZN(n95) );
  INVD0 U65 ( .I(n111), .ZN(n61) );
  INVD0 U66 ( .I(n97), .ZN(n44) );
  CKND2D0 U67 ( .A1(n44), .A2(n77), .ZN(n78) );
  INVD0 U68 ( .I(n105), .ZN(n40) );
  CKAN2D0 U69 ( .A1(n46), .A2(n65), .Z(n105) );
  INVD0 U70 ( .I(n55), .ZN(x0_addr[0]) );
  INVD0 U71 ( .I(stage[2]), .ZN(n51) );
  INVD0 U72 ( .I(n51), .ZN(n52) );
  INVD0 U73 ( .I(n52), .ZN(n46) );
  INVD0 U74 ( .I(n111), .ZN(n60) );
  XNR2D1 U75 ( .A1(intadd_0_n1), .A2(n94), .ZN(n113) );
  NR2D1 U76 ( .A1(n95), .A2(n41), .ZN(intadd_0_CI) );
  INVD0 U77 ( .I(n107), .ZN(n42) );
  CKAN2D0 U78 ( .A1(n68), .A2(n103), .Z(n107) );
  BUFFD0 U79 ( .I(n103), .Z(n90) );
  NR2XD0 U80 ( .A1(n103), .A2(n40), .ZN(n96) );
  CKND2D1 U81 ( .A1(n104), .A2(n65), .ZN(n103) );
  OA21D0 U82 ( .A1(x0_addr[5]), .A2(n89), .B(n109), .Z(x1_addr[5]) );
  OR2D1 U83 ( .A1(n104), .A2(stage[2]), .Z(n97) );
  ND2D0 U84 ( .A1(n83), .A2(n46), .ZN(n100) );
  AOI211D0 U85 ( .A1(n58), .A2(n55), .B(stage[1]), .C(stage[2]), .ZN(n80) );
  BUFFD1 U86 ( .I(stage[1]), .Z(n110) );
  OAI31D0 U87 ( .A1(n62), .A2(n54), .A3(n46), .B(n109), .ZN(n112) );
  CKND2D1 U88 ( .A1(x0_addr[5]), .A2(n89), .ZN(n109) );
  OAI31D0 U89 ( .A1(stage[1]), .A2(n57), .A3(n51), .B(n88), .ZN(n89) );
  CKND2D1 U90 ( .A1(x0_addr[4]), .A2(n87), .ZN(n88) );
  OAI21D0 U91 ( .A1(n104), .A2(n46), .B(n86), .ZN(n87) );
  CKND2D1 U92 ( .A1(x0_addr[3]), .A2(n85), .ZN(n86) );
  CKND2D1 U93 ( .A1(n100), .A2(n84), .ZN(n85) );
  CKND2D1 U94 ( .A1(x0_addr[2]), .A2(n82), .ZN(n84) );
  OAI22D0 U95 ( .A1(n76), .A2(n42), .B1(n75), .B2(n74), .ZN(w_addr[5]) );
  NR2D0 U96 ( .A1(n69), .A2(n47), .ZN(w_addr[0]) );
  OAI31D0 U97 ( .A1(n61), .A2(stage[2]), .A3(n53), .B(n81), .ZN(n82) );
  OAI31D0 U98 ( .A1(n61), .A2(n55), .A3(n42), .B(n72), .ZN(w_addr[2]) );
  OAI22D0 U99 ( .A1(n76), .A2(n71), .B1(n43), .B2(n73), .ZN(w_addr[3]) );
  OAI22D0 U100 ( .A1(n93), .A2(n92), .B1(n47), .B2(n95), .ZN(n94) );
  CKND2D1 U101 ( .A1(x0_addr[1]), .A2(n80), .ZN(n81) );
  INVD0 U102 ( .I(n68), .ZN(n47) );
  NR2D0 U103 ( .A1(n71), .A2(n73), .ZN(w_addr[1]) );
  CKND2D1 U104 ( .A1(n50), .A2(n40), .ZN(n71) );
  OAI21D0 U105 ( .A1(n50), .A2(group[5]), .B(n105), .ZN(n92) );
  MAOI22D0 U106 ( .A1(n101), .A2(n49), .B1(n62), .B2(group[1]), .ZN(n91) );
  INVD0 U107 ( .I(n90), .ZN(n50) );
  INVD0 U108 ( .I(n90), .ZN(n49) );
  INVD0 U109 ( .I(n97), .ZN(n45) );
  INVD0 U110 ( .I(n105), .ZN(n41) );
  OAI22D0 U111 ( .A1(group[4]), .A2(n104), .B1(n103), .B2(n102), .ZN(n106) );
  OAI22D0 U112 ( .A1(n57), .A2(x0_addr[0]), .B1(bfly[1]), .B2(n63), .ZN(n73)
         );
  CKND2D0 U113 ( .A1(n64), .A2(x0_addr[0]), .ZN(n69) );
  INVD0 U114 ( .I(n63), .ZN(n59) );
  INVD0 U115 ( .I(n65), .ZN(n83) );
  INVD0 U116 ( .I(n110), .ZN(n54) );
  INVD0 U117 ( .I(n111), .ZN(n63) );
  INVD0 U118 ( .I(n111), .ZN(n62) );
  INVD0 U119 ( .I(group[0]), .ZN(n101) );
  INVD0 U120 ( .I(n107), .ZN(n43) );
  INVD0 U121 ( .I(n68), .ZN(n48) );
  INVD1 U122 ( .I(n110), .ZN(n53) );
  INVD0 U123 ( .I(bfly[0]), .ZN(n55) );
  INVD1 U124 ( .I(n60), .ZN(n57) );
  INVD1 U125 ( .I(n62), .ZN(n58) );
  BUFFD0 U126 ( .I(linear_addr[0]), .Z(bitrev_addr[6]) );
  BUFFD0 U127 ( .I(linear_addr[1]), .Z(bitrev_addr[5]) );
  BUFFD0 U128 ( .I(linear_addr[2]), .Z(bitrev_addr[4]) );
  BUFFD0 U129 ( .I(linear_addr[3]), .Z(bitrev_addr[3]) );
  BUFFD0 U130 ( .I(linear_addr[4]), .Z(bitrev_addr[2]) );
  BUFFD0 U131 ( .I(linear_addr[5]), .Z(bitrev_addr[1]) );
  BUFFD0 U132 ( .I(linear_addr[6]), .Z(bitrev_addr[0]) );
  AOI21D1 U133 ( .A1(n83), .A2(n52), .B(n105), .ZN(n68) );
  NR2D0 U134 ( .A1(n53), .A2(n61), .ZN(n64) );
  ND2D1 U135 ( .A1(n57), .A2(n53), .ZN(n104) );
  OAI221D0 U136 ( .A1(n60), .A2(bfly[4]), .B1(n59), .B2(bfly[3]), .C(n49), 
        .ZN(n67) );
  OA22D0 U137 ( .A1(n58), .A2(bfly[1]), .B1(bfly[2]), .B2(n62), .Z(n70) );
  IND2D0 U138 ( .A1(n43), .B1(n70), .ZN(n66) );
  OAI221D0 U139 ( .A1(n68), .A2(n69), .B1(n48), .B2(n67), .C(n66), .ZN(
        w_addr[4]) );
  MUX2D0 U140 ( .I0(group[3]), .I1(group[2]), .S(n59), .Z(n102) );
  MUX2ND0 U141 ( .I0(group[1]), .I1(group[0]), .S(n58), .ZN(n108) );
  INVD1 U142 ( .I(n108), .ZN(n77) );
  AO22D0 U143 ( .A1(n45), .A2(n102), .B1(n96), .B2(n77), .Z(intadd_0_B_1_) );
  MAOI22D0 U144 ( .A1(x0_addr[0]), .A2(n44), .B1(n45), .B2(x0_addr[0]), .ZN(
        x1_addr[0]) );
  AOI22D0 U145 ( .A1(n60), .A2(bfly[2]), .B1(bfly[3]), .B2(n59), .ZN(n76) );
  IND2D0 U146 ( .A1(n71), .B1(n70), .ZN(n72) );
  AOI221D0 U147 ( .A1(bfly[4]), .A2(n63), .B1(bfly[5]), .B2(n58), .C(n48), 
        .ZN(n75) );
  IOA21D0 U148 ( .A1(n47), .A2(n73), .B(n49), .ZN(n74) );
  INVD1 U149 ( .I(bfly[1]), .ZN(n79) );
  NR2D1 U150 ( .A1(n78), .A2(n79), .ZN(intadd_0_B_0_) );
  AOI21D1 U151 ( .A1(n79), .A2(n78), .B(intadd_0_B_0_), .ZN(x0_addr[1]) );
  OA21D0 U152 ( .A1(x0_addr[1]), .A2(n80), .B(n81), .Z(x1_addr[1]) );
  OA21D0 U153 ( .A1(x0_addr[2]), .A2(n82), .B(n84), .Z(x1_addr[2]) );
  OA21D0 U154 ( .A1(x0_addr[3]), .A2(n85), .B(n86), .Z(x1_addr[3]) );
  OA21D0 U155 ( .A1(x0_addr[4]), .A2(n87), .B(n88), .Z(x1_addr[4]) );
  OAI22D0 U156 ( .A1(group[4]), .A2(n59), .B1(group[3]), .B2(n54), .ZN(n93) );
  INVD1 U157 ( .I(n113), .ZN(x0_addr[6]) );
  OAI221D0 U158 ( .A1(n60), .A2(group[1]), .B1(n57), .B2(group[2]), .C(n96), 
        .ZN(n99) );
  CKND2D0 U159 ( .A1(n44), .A2(group[3]), .ZN(n98) );
  OAI211D1 U160 ( .A1(n101), .A2(n100), .B(n99), .C(n98), .ZN(intadd_0_B_2_)
         );
  OAI22D1 U161 ( .A1(n108), .A2(n42), .B1(n106), .B2(n41), .ZN(intadd_0_B_3_)
         );
  MUX2ND0 U162 ( .I0(n113), .I1(x0_addr[6]), .S(n112), .ZN(x1_addr[6]) );
endmodule

