/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Expert(TM) in wire load mode
// Version   : U-2022.12-SP7
// Date      : Sat Jun 27 18:01:37 2026
/////////////////////////////////////////////////////////////


module fft_twiddle_sram ( clk, tb_sel, tb_cen, tb_wen, tb_addr, tb_din, 
        core_cen, core_addr, dout );
  input [5:0] tb_addr;
  input [15:0] tb_din;
  input [5:0] core_addr;
  output [15:0] dout;
  input clk, tb_sel, tb_cen, tb_wen, core_cen;
  wire   n_Logic0_, cen_mux, wen_mux, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11
;
  wire   [5:0] addr_mux;
  wire   [15:0] din_mux;
  wire   SYNOPSYS_UNCONNECTED__0, SYNOPSYS_UNCONNECTED__1, 
        SYNOPSYS_UNCONNECTED__2, SYNOPSYS_UNCONNECTED__3, 
        SYNOPSYS_UNCONNECTED__4, SYNOPSYS_UNCONNECTED__5, 
        SYNOPSYS_UNCONNECTED__6, SYNOPSYS_UNCONNECTED__7, 
        SYNOPSYS_UNCONNECTED__8, SYNOPSYS_UNCONNECTED__9, 
        SYNOPSYS_UNCONNECTED__10, SYNOPSYS_UNCONNECTED__11, 
        SYNOPSYS_UNCONNECTED__12, SYNOPSYS_UNCONNECTED__13, 
        SYNOPSYS_UNCONNECTED__14, SYNOPSYS_UNCONNECTED__15;

  sram_wrapper u_sram ( .clk(clk), .cen(cen_mux), .wen(wen_mux), .addr({
        n_Logic0_, n_Logic0_, n_Logic0_, addr_mux}), .din({n_Logic0_, 
        n_Logic0_, n_Logic0_, n_Logic0_, n_Logic0_, n_Logic0_, n_Logic0_, 
        n_Logic0_, n_Logic0_, n_Logic0_, n_Logic0_, n_Logic0_, n_Logic0_, 
        n_Logic0_, n_Logic0_, n_Logic0_, din_mux}), .dout({
        SYNOPSYS_UNCONNECTED__0, SYNOPSYS_UNCONNECTED__1, 
        SYNOPSYS_UNCONNECTED__2, SYNOPSYS_UNCONNECTED__3, 
        SYNOPSYS_UNCONNECTED__4, SYNOPSYS_UNCONNECTED__5, 
        SYNOPSYS_UNCONNECTED__6, SYNOPSYS_UNCONNECTED__7, 
        SYNOPSYS_UNCONNECTED__8, SYNOPSYS_UNCONNECTED__9, 
        SYNOPSYS_UNCONNECTED__10, SYNOPSYS_UNCONNECTED__11, 
        SYNOPSYS_UNCONNECTED__12, SYNOPSYS_UNCONNECTED__13, 
        SYNOPSYS_UNCONNECTED__14, SYNOPSYS_UNCONNECTED__15, dout}) );
  AN2XD1 U2 ( .A1(tb_wen), .A2(n2), .Z(wen_mux) );
  AN2XD1 U3 ( .A1(tb_din[9]), .A2(n2), .Z(din_mux[9]) );
  AN2XD1 U4 ( .A1(tb_din[8]), .A2(n2), .Z(din_mux[8]) );
  AN2XD1 U5 ( .A1(tb_din[7]), .A2(n2), .Z(din_mux[7]) );
  AN2XD1 U6 ( .A1(tb_din[6]), .A2(n11), .Z(din_mux[6]) );
  AN2XD1 U7 ( .A1(tb_din[5]), .A2(tb_sel), .Z(din_mux[5]) );
  AN2XD1 U8 ( .A1(tb_din[4]), .A2(tb_sel), .Z(din_mux[4]) );
  AN2XD1 U9 ( .A1(tb_din[3]), .A2(n11), .Z(din_mux[3]) );
  AN2XD1 U10 ( .A1(tb_din[2]), .A2(n3), .Z(din_mux[2]) );
  AN2XD1 U11 ( .A1(tb_din[1]), .A2(n3), .Z(din_mux[1]) );
  AN2XD1 U12 ( .A1(tb_din[15]), .A2(n3), .Z(din_mux[15]) );
  AN2XD1 U13 ( .A1(tb_din[14]), .A2(n3), .Z(din_mux[14]) );
  AN2XD1 U14 ( .A1(tb_din[13]), .A2(n4), .Z(din_mux[13]) );
  AN2XD1 U15 ( .A1(tb_din[12]), .A2(n4), .Z(din_mux[12]) );
  AN2XD1 U16 ( .A1(tb_din[11]), .A2(n4), .Z(din_mux[11]) );
  AN2XD1 U17 ( .A1(tb_din[10]), .A2(n4), .Z(din_mux[10]) );
  AN2XD1 U18 ( .A1(tb_din[0]), .A2(n5), .Z(din_mux[0]) );
  INVD1 U27 ( .I(n7), .ZN(n5) );
  INVD1 U28 ( .I(n7), .ZN(n6) );
  INVD1 U29 ( .I(n8), .ZN(n2) );
  INVD1 U30 ( .I(n8), .ZN(n3) );
  INVD1 U31 ( .I(n7), .ZN(n4) );
  CKBD1 U32 ( .I(n10), .Z(n8) );
  CKBD1 U33 ( .I(n10), .Z(n7) );
  CKBD1 U34 ( .I(n10), .Z(n9) );
  INVD1 U35 ( .I(n11), .ZN(n10) );
  AO22D0 U36 ( .A1(tb_addr[1]), .A2(n6), .B1(core_addr[1]), .B2(n8), .Z(
        addr_mux[1]) );
  AO22D0 U37 ( .A1(tb_addr[0]), .A2(n6), .B1(core_addr[0]), .B2(n7), .Z(
        addr_mux[0]) );
  CKBD1 U38 ( .I(tb_sel), .Z(n11) );
  AO22D0 U39 ( .A1(tb_addr[5]), .A2(n5), .B1(core_addr[5]), .B2(n9), .Z(
        addr_mux[5]) );
  AO22D0 U40 ( .A1(tb_addr[4]), .A2(n5), .B1(core_addr[4]), .B2(n9), .Z(
        addr_mux[4]) );
  AO22D0 U41 ( .A1(tb_addr[3]), .A2(n6), .B1(core_addr[3]), .B2(n9), .Z(
        addr_mux[3]) );
  AO22D0 U42 ( .A1(tb_addr[2]), .A2(n6), .B1(core_addr[2]), .B2(n9), .Z(
        addr_mux[2]) );
  AO22D0 U43 ( .A1(tb_cen), .A2(n5), .B1(core_cen), .B2(n8), .Z(cen_mux) );
  TIEL U44 ( .ZN(n_Logic0_) );
endmodule

