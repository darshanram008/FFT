/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Ultra(TM) in wire load mode
// Version   : U-2022.12-SP7
// Date      : Sat Jun 27 21:31:24 2026
/////////////////////////////////////////////////////////////


module fft_data_sram ( clk, tb_sel, tb_cen, tb_wen, tb_addr, tb_din, core_cen, 
        core_wen, core_addr, core_din, dout );
  input [6:0] tb_addr;
  input [15:0] tb_din;
  input [6:0] core_addr;
  input [15:0] core_din;
  output [15:0] dout;
  input clk, tb_sel, tb_cen, tb_wen, core_cen, core_wen;
  wire   u_sram_n_Logic0_, u_sram_n_Logic1_, n2, n3, n4, n5, n6, n7, n8, n9,
         n10, n11;
  wire   [6:0] addr_mux;
  wire   [15:0] din_mux;
  wire   SYNOPSYS_UNCONNECTED__0, SYNOPSYS_UNCONNECTED__1, 
        SYNOPSYS_UNCONNECTED__2, SYNOPSYS_UNCONNECTED__3, 
        SYNOPSYS_UNCONNECTED__4, SYNOPSYS_UNCONNECTED__5, 
        SYNOPSYS_UNCONNECTED__6, SYNOPSYS_UNCONNECTED__7, 
        SYNOPSYS_UNCONNECTED__8, SYNOPSYS_UNCONNECTED__9, 
        SYNOPSYS_UNCONNECTED__10, SYNOPSYS_UNCONNECTED__11, 
        SYNOPSYS_UNCONNECTED__12, SYNOPSYS_UNCONNECTED__13, 
        SYNOPSYS_UNCONNECTED__14, SYNOPSYS_UNCONNECTED__15;

  sram00 u_sram_u_sram ( .Q({SYNOPSYS_UNCONNECTED__0, SYNOPSYS_UNCONNECTED__1, 
        SYNOPSYS_UNCONNECTED__2, SYNOPSYS_UNCONNECTED__3, 
        SYNOPSYS_UNCONNECTED__4, SYNOPSYS_UNCONNECTED__5, 
        SYNOPSYS_UNCONNECTED__6, SYNOPSYS_UNCONNECTED__7, 
        SYNOPSYS_UNCONNECTED__8, SYNOPSYS_UNCONNECTED__9, 
        SYNOPSYS_UNCONNECTED__10, SYNOPSYS_UNCONNECTED__11, 
        SYNOPSYS_UNCONNECTED__12, SYNOPSYS_UNCONNECTED__13, 
        SYNOPSYS_UNCONNECTED__14, SYNOPSYS_UNCONNECTED__15, dout}), .WEN({
        u_sram_n_Logic0_, u_sram_n_Logic0_, u_sram_n_Logic0_, u_sram_n_Logic0_, 
        u_sram_n_Logic0_}), .A({u_sram_n_Logic0_, u_sram_n_Logic0_, addr_mux}), 
        .D({u_sram_n_Logic0_, u_sram_n_Logic0_, u_sram_n_Logic0_, 
        u_sram_n_Logic0_, u_sram_n_Logic0_, u_sram_n_Logic0_, u_sram_n_Logic0_, 
        u_sram_n_Logic0_, u_sram_n_Logic0_, u_sram_n_Logic0_, u_sram_n_Logic0_, 
        u_sram_n_Logic0_, u_sram_n_Logic0_, u_sram_n_Logic0_, u_sram_n_Logic0_, 
        u_sram_n_Logic0_, din_mux}), .EMA({u_sram_n_Logic0_, u_sram_n_Logic0_, 
        u_sram_n_Logic0_}), .CLK(clk), .CEN(n2), .GWEN(n3), .RETN(
        u_sram_n_Logic1_) );
  INVD0 U30 ( .I(n9), .ZN(n6) );
  INVD0 U31 ( .I(n11), .ZN(n5) );
  INVD0 U32 ( .I(n9), .ZN(n7) );
  INVD0 U33 ( .I(n11), .ZN(n10) );
  INVD0 U34 ( .I(n4), .ZN(n11) );
  TIEL U35 ( .ZN(u_sram_n_Logic0_) );
  TIEH U36 ( .Z(u_sram_n_Logic1_) );
  CKBD1 U37 ( .I(tb_sel), .Z(n4) );
  MUX2D0 U38 ( .I0(core_din[15]), .I1(tb_din[15]), .S(n5), .Z(din_mux[15]) );
  MUX2D0 U39 ( .I0(core_din[14]), .I1(tb_din[14]), .S(n5), .Z(din_mux[14]) );
  MUX2D0 U40 ( .I0(core_din[13]), .I1(tb_din[13]), .S(n5), .Z(din_mux[13]) );
  MUX2D0 U41 ( .I0(core_din[12]), .I1(tb_din[12]), .S(n5), .Z(din_mux[12]) );
  CKBD1 U42 ( .I(n11), .Z(n9) );
  MUX2D0 U43 ( .I0(core_din[9]), .I1(tb_din[9]), .S(n7), .Z(din_mux[9]) );
  MUX2D0 U44 ( .I0(core_din[8]), .I1(tb_din[8]), .S(n7), .Z(din_mux[8]) );
  MUX2D0 U45 ( .I0(core_din[7]), .I1(tb_din[7]), .S(n6), .Z(din_mux[7]) );
  MUX2D0 U46 ( .I0(core_din[6]), .I1(tb_din[6]), .S(n6), .Z(din_mux[6]) );
  MUX2D0 U47 ( .I0(core_din[5]), .I1(tb_din[5]), .S(n6), .Z(din_mux[5]) );
  MUX2D0 U48 ( .I0(core_din[4]), .I1(tb_din[4]), .S(n6), .Z(din_mux[4]) );
  INVD1 U49 ( .I(n9), .ZN(n8) );
  MUX2D0 U50 ( .I0(core_din[3]), .I1(tb_din[3]), .S(n8), .Z(din_mux[3]) );
  MUX2D0 U51 ( .I0(core_din[2]), .I1(tb_din[2]), .S(n8), .Z(din_mux[2]) );
  MUX2D0 U52 ( .I0(core_din[1]), .I1(tb_din[1]), .S(n8), .Z(din_mux[1]) );
  MUX2D0 U53 ( .I0(core_din[11]), .I1(tb_din[11]), .S(n7), .Z(din_mux[11]) );
  MUX2D0 U54 ( .I0(core_din[10]), .I1(tb_din[10]), .S(n7), .Z(din_mux[10]) );
  MUX2D0 U55 ( .I0(core_din[0]), .I1(tb_din[0]), .S(n8), .Z(din_mux[0]) );
  MUX2D0 U56 ( .I0(core_addr[3]), .I1(tb_addr[3]), .S(n10), .Z(addr_mux[3]) );
  MUX2D0 U57 ( .I0(core_addr[2]), .I1(tb_addr[2]), .S(n10), .Z(addr_mux[2]) );
  MUX2D0 U58 ( .I0(core_addr[1]), .I1(tb_addr[1]), .S(n10), .Z(addr_mux[1]) );
  MUX2D0 U59 ( .I0(core_addr[0]), .I1(tb_addr[0]), .S(n4), .Z(addr_mux[0]) );
  MUX2D0 U60 ( .I0(core_addr[6]), .I1(tb_addr[6]), .S(n4), .Z(addr_mux[6]) );
  MUX2D0 U61 ( .I0(core_addr[5]), .I1(tb_addr[5]), .S(tb_sel), .Z(addr_mux[5])
         );
  MUX2D0 U62 ( .I0(core_addr[4]), .I1(tb_addr[4]), .S(n4), .Z(addr_mux[4]) );
  AOI22D0 U63 ( .A1(n10), .A2(tb_cen), .B1(core_cen), .B2(n9), .ZN(n2) );
  AOI22D0 U64 ( .A1(tb_sel), .A2(tb_wen), .B1(core_wen), .B2(n11), .ZN(n3) );
endmodule

