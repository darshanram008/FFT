/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Expert(TM) in wire load mode
// Version   : U-2022.12-SP7
// Date      : Sat Jun 27 17:50:06 2026
/////////////////////////////////////////////////////////////


module sram_wrapper ( clk, cen, wen, addr, din, dout );
  input [8:0] addr;
  input [31:0] din;
  output [31:0] dout;
  input clk, cen, wen;
  wire   n_Logic1_, n_Logic0_, n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11,
         n12, n13, n14, n15, n16, n17, n18, n19, n20, n21, n22, n23, n24, n25,
         n26, n27, n28, n29, n30, n31, n32, n33, n34, n35, n36, n37, n38, n39,
         n40, n41, n42, n43, n44, n45, n46, n47, n48, n49, n50, n51, n52, n53,
         n54, n55, n56, n57, n58, n59, n60, n61, n62, n63, n64;

  sram00 u_sram ( .Q(dout), .WEN({n_Logic0_, n_Logic0_, n_Logic0_, n_Logic0_, 
        n_Logic0_}), .A({n64, n62, n60, n58, n56, n54, n52, n50, n48}), .D({
        n14, n15, n16, n17, n18, n19, n20, n21, n22, n23, n24, n25, n26, n27, 
        n28, n29, n30, n31, n32, n33, n34, n35, n36, n37, n38, n39, n40, n41, 
        n42, n43, n44, n45}), .EMA({n_Logic0_, n_Logic0_, n_Logic0_}), .CLK(
        clk), .CEN(n3), .GWEN(n46), .RETN(n_Logic1_) );
  CKBD0 U5 ( .I(cen), .Z(n4) );
  CKBD1 U6 ( .I(n1), .Z(n3) );
  CKBD0 U7 ( .I(addr[8]), .Z(n5) );
  CKBD0 U8 ( .I(addr[7]), .Z(n6) );
  CKBD0 U9 ( .I(addr[6]), .Z(n7) );
  CKBD0 U10 ( .I(addr[5]), .Z(n8) );
  CKBD0 U11 ( .I(addr[4]), .Z(n9) );
  CKBD0 U12 ( .I(addr[3]), .Z(n10) );
  CKBD0 U13 ( .I(addr[2]), .Z(n11) );
  CKBD0 U14 ( .I(addr[1]), .Z(n12) );
  CKBD0 U15 ( .I(addr[0]), .Z(n13) );
  DEL01 U16 ( .I(din[31]), .Z(n14) );
  DEL01 U17 ( .I(din[30]), .Z(n15) );
  DEL01 U18 ( .I(din[29]), .Z(n16) );
  DEL01 U19 ( .I(din[28]), .Z(n17) );
  DEL01 U20 ( .I(din[27]), .Z(n18) );
  DEL01 U21 ( .I(din[26]), .Z(n19) );
  DEL01 U22 ( .I(din[25]), .Z(n20) );
  DEL01 U23 ( .I(din[24]), .Z(n21) );
  DEL01 U24 ( .I(din[23]), .Z(n22) );
  DEL01 U25 ( .I(din[22]), .Z(n23) );
  DEL01 U26 ( .I(din[21]), .Z(n24) );
  DEL01 U27 ( .I(din[20]), .Z(n25) );
  DEL01 U28 ( .I(din[19]), .Z(n26) );
  DEL01 U29 ( .I(din[18]), .Z(n27) );
  DEL01 U30 ( .I(din[17]), .Z(n28) );
  DEL01 U31 ( .I(din[16]), .Z(n29) );
  DEL01 U32 ( .I(din[15]), .Z(n30) );
  DEL01 U33 ( .I(din[14]), .Z(n31) );
  DEL01 U34 ( .I(din[13]), .Z(n32) );
  DEL01 U35 ( .I(din[12]), .Z(n33) );
  DEL01 U36 ( .I(din[11]), .Z(n34) );
  DEL01 U37 ( .I(din[10]), .Z(n35) );
  DEL01 U38 ( .I(din[9]), .Z(n36) );
  DEL01 U39 ( .I(din[8]), .Z(n37) );
  DEL01 U40 ( .I(din[7]), .Z(n38) );
  DEL01 U41 ( .I(din[6]), .Z(n39) );
  DEL01 U42 ( .I(din[5]), .Z(n40) );
  DEL01 U43 ( .I(din[4]), .Z(n41) );
  DEL01 U44 ( .I(din[3]), .Z(n42) );
  DEL01 U45 ( .I(din[2]), .Z(n43) );
  DEL01 U46 ( .I(din[1]), .Z(n44) );
  DEL01 U47 ( .I(din[0]), .Z(n45) );
  DEL01 U48 ( .I(n2), .Z(n46) );
  INVD1 U49 ( .I(wen), .ZN(n2) );
  CKND0 U50 ( .I(n13), .ZN(n47) );
  CKND0 U51 ( .I(n47), .ZN(n48) );
  CKND0 U52 ( .I(n12), .ZN(n49) );
  CKND0 U53 ( .I(n49), .ZN(n50) );
  CKND0 U54 ( .I(n11), .ZN(n51) );
  CKND0 U55 ( .I(n51), .ZN(n52) );
  CKND0 U56 ( .I(n10), .ZN(n53) );
  CKND0 U57 ( .I(n53), .ZN(n54) );
  CKND0 U58 ( .I(n9), .ZN(n55) );
  CKND0 U59 ( .I(n55), .ZN(n56) );
  CKND0 U60 ( .I(n8), .ZN(n57) );
  CKND0 U61 ( .I(n57), .ZN(n58) );
  CKND0 U62 ( .I(n7), .ZN(n59) );
  CKND0 U63 ( .I(n59), .ZN(n60) );
  CKND0 U64 ( .I(n6), .ZN(n61) );
  CKND0 U65 ( .I(n61), .ZN(n62) );
  CKND0 U66 ( .I(n5), .ZN(n63) );
  CKND0 U67 ( .I(n63), .ZN(n64) );
  INVD1 U68 ( .I(n4), .ZN(n1) );
  TIEH U69 ( .Z(n_Logic1_) );
  TIEL U70 ( .ZN(n_Logic0_) );
endmodule

