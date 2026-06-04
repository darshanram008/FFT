// FE Release Version: 2.4.24 
//
//       CONFIDENTIAL AND PROPRIETARY SOFTWARE OF ARM PHYSICAL IP, INC.
//      
//       Copyright (c) 1993 - 2026 ARM Physical IP, Inc.  All Rights Reserved.
//      
//       Use of this Software is subject to the terms and conditions of the
//       applicable license agreement with ARM Physical IP, Inc.
//       In addition, this Software is protected by patents, copyright law 
//       and international treaties.
//      
//       The copyright notice(s) in this Software does not indicate actual or
//       intended publication of this Software.
//
//      Verilog model for Synchronous Single-Port Ram
//
//      Instance Name:              sram00
//      Words:                      512
//      Bits:                       8
//      Mux:                        16
//      Drive:                      6
//      Write Mask:                 On
//      Extra Margin Adjustment:    On
//      Accelerated Retention Test: Off
//      Redundant Rows:             0
//      Redundant Columns:          0
//      Test Muxes                  Off
//
//      Creation Date:  Tue Jun  2 14:00:16 2026
//      Version: 	r0p0-00eac0
//
//      Modeling Assumptions: This model supports full gate level simulation
//          including proper x-handling and timing check behavior.  Unit
//          delay timing is included in the model. Back-annotation of SDF
//          (v2.1) is supported.  SDF can be created utilyzing the delay
//          calculation views provided with this generator and supported
//          delay calculators.  All buses are modeled [MSB:LSB].  All 
//          ports are padded with Verilog primitives.
//
//      Modeling Limitations: None.
//
//      Known Bugs: None.
//
//      Known Work Arounds: N/A
//
`ifdef ARM_UD_MODEL

`timescale 1 ns/1 ps

`ifdef ARM_UD_DP
`else
`define ARM_UD_DP #0.001
`endif
`ifdef ARM_UD_CP
`else
`define ARM_UD_CP
`endif
`ifdef ARM_UD_SEQ
`else
`define ARM_UD_SEQ #0.01
`endif

`celldefine
`ifdef POWER_PINS
module sram00 (Q, CLK, CEN, WEN, A, D, EMA, GWEN, RETN, VSS, VDD);
`else
module sram00 (Q, CLK, CEN, WEN, A, D, EMA, GWEN, RETN);
`endif

  parameter BITS = 8;
  parameter WORDS = 512;
  parameter MUX = 16;
  parameter MEM_WIDTH = 128; // redun block size 8, 64 on left, 64 on right
  parameter MEM_HEIGHT = 32;
  parameter WP_SIZE = 7 ;
  parameter UPM_WIDTH = 3;

  output [7:0] Q;
  input  CLK;
  input  CEN;
  input [1:0] WEN;
  input [8:0] A;
  input [7:0] D;
  input [2:0] EMA;
  input  GWEN;
  input  RETN;
`ifdef POWER_PINS
  inout VSS;
  inout VDD;
`endif

  integer row_address;
  integer mux_address;
  reg [127:0] mem [0:31];
  reg [127:0] row;
  reg LAST_CLK;
  reg [127:0] data_out;
  reg [127:0] row_mask;
  reg [127:0] new_data;
  reg [7:0] Q_int;
  reg [7:0] writeEnable;
  reg clk0_int;
  reg CREN_legal;
  initial CREN_legal = 1'b1;

  wire [7:0] Q_;
 wire  CLK_;
  wire  CEN_;
  reg  CEN_int;
  wire [1:0] WEN_;
  reg [1:0] WEN_int;
  wire [8:0] A_;
  reg [8:0] A_int;
  wire [7:0] D_;
  reg [7:0] D_int;
  wire [2:0] EMA_;
  reg [2:0] EMA_int;
  wire  GWEN_;
  reg  GWEN_int;
  wire  RETN_;
  reg  RETN_int;

  assign Q[0] = Q_[0]; 
  assign Q[1] = Q_[1]; 
  assign Q[2] = Q_[2]; 
  assign Q[3] = Q_[3]; 
  assign Q[4] = Q_[4]; 
  assign Q[5] = Q_[5]; 
  assign Q[6] = Q_[6]; 
  assign Q[7] = Q_[7]; 
  assign CLK_ = CLK;
  assign CEN_ = CEN;
  assign WEN_[0] = WEN[0];
  assign WEN_[1] = WEN[1];
  assign A_[0] = A[0];
  assign A_[1] = A[1];
  assign A_[2] = A[2];
  assign A_[3] = A[3];
  assign A_[4] = A[4];
  assign A_[5] = A[5];
  assign A_[6] = A[6];
  assign A_[7] = A[7];
  assign A_[8] = A[8];
  assign D_[0] = D[0];
  assign D_[1] = D[1];
  assign D_[2] = D[2];
  assign D_[3] = D[3];
  assign D_[4] = D[4];
  assign D_[5] = D[5];
  assign D_[6] = D[6];
  assign D_[7] = D[7];
  assign EMA_[0] = EMA[0];
  assign EMA_[1] = EMA[1];
  assign EMA_[2] = EMA[2];
  assign GWEN_ = GWEN;
  assign RETN_ = RETN;

  assign `ARM_UD_SEQ Q_ = RETN_ ? (Q_int) : {8{1'b0}};

`ifdef INITIALIZE_MEMORY
  integer i;
  initial
    for (i = 0; i < MEM_HEIGHT; i = i + 1)
      mem[i] = {MEM_WIDTH{1'b0}};
`endif

  task failedWrite;
  input port;
  integer i;
  begin
    for (i = 0; i < MEM_HEIGHT; i = i + 1)
      mem[i] = {MEM_WIDTH{1'bx}};
  end
  endtask

  function isBitX;
    input bitIn;
    begin
      isBitX = ( bitIn===1'bx || bitIn===1'bz ) ? 1'b1 : 1'b0;
    end
  endfunction


  task readWrite;
  begin
    if (RETN_int === 1'bx) begin
      failedWrite(0);
      Q_int = {8{1'bx}};
    end else if (RETN_int === 1'b0 && CEN_int === 1'b0) begin
      failedWrite(0);
      Q_int = {8{1'bx}};
    end else if (RETN_int === 1'b0) begin
      // no cycle in retention mode
    end else if (^{CEN_int, EMA_int} === 1'bx) begin
      failedWrite(0);
      Q_int = {8{1'bx}};
    end else if ((A_int >= WORDS) && (CEN_int === 1'b0)) begin
      writeEnable = ~( {8{GWEN_int}} | {WEN_int[1], WEN_int[0], WEN_int[0], WEN_int[0],
         WEN_int[0], WEN_int[0], WEN_int[0], WEN_int[0]});
      Q_int = ((writeEnable & D_int) | (~writeEnable & {8{1'bx}}));
    end else if (CEN_int === 1'b0 && (^A_int) === 1'bx) begin
      if (GWEN_int !== 1'b1 && (& WEN_int) !== 1'b1) failedWrite(0);
      Q_int = {8{1'bx}};
    end else if (CEN_int === 1'b0) begin
      mux_address = (A_int & 4'b1111);
      row_address = (A_int >> 4);
      if (row_address >= 32)
        row = {128{1'bx}};
      else
        row = mem[row_address];
      if( isBitX(GWEN_int) )
        writeEnable = {8{1'bx}};
      else
        writeEnable = ~( {8{GWEN_int}} | {WEN_int[1], WEN_int[0], WEN_int[0], WEN_int[0],
         WEN_int[0], WEN_int[0], WEN_int[0], WEN_int[0]});
      row_mask =  ( {15'b000000000000000, writeEnable[7], 15'b000000000000000, writeEnable[6],
          15'b000000000000000, writeEnable[5], 15'b000000000000000, writeEnable[4],
          15'b000000000000000, writeEnable[3], 15'b000000000000000, writeEnable[2],
          15'b000000000000000, writeEnable[1], 15'b000000000000000, writeEnable[0]} << mux_address);
      new_data =  ( {15'b000000000000000, D_int[7], 15'b000000000000000, D_int[6],
          15'b000000000000000, D_int[5], 15'b000000000000000, D_int[4], 15'b000000000000000, D_int[3],
          15'b000000000000000, D_int[2], 15'b000000000000000, D_int[1], 15'b000000000000000, D_int[0]} << mux_address);
      row = (row & ~row_mask) | (row_mask & (~row_mask | new_data));
      mem[row_address] = row;
      data_out = (row >> mux_address);
      if (GWEN_int !== 1'b0)
        Q_int = {data_out[112], data_out[96], data_out[80], data_out[64], data_out[48],
          data_out[32], data_out[16], data_out[0]};
      else
        Q_int = {(writeEnable[7]?data_out[112]:Q_int[7]), (writeEnable[6]?data_out[96]:Q_int[6]),
          (writeEnable[5]?data_out[80]:Q_int[5]), (writeEnable[4]?data_out[64]:Q_int[4]),
          (writeEnable[3]?data_out[48]:Q_int[3]), (writeEnable[2]?data_out[32]:Q_int[2]),
          (writeEnable[1]?data_out[16]:Q_int[1]), (writeEnable[0]?data_out[0]:Q_int[0])};
    end
  end
  endtask

  always @ RETN_ begin
    if (RETN_ == 1'b0) begin
      Q_int = {8{1'b0}};
      CEN_int = 1'b0;
      WEN_int = {2{1'b0}};
      A_int = {9{1'b0}};
      D_int = {8{1'b0}};
      EMA_int = {3{1'b0}};
      GWEN_int = 1'b0;
      RETN_int = 1'b0;
    end else begin
      Q_int = {8{1'bx}};
      CEN_int = 1'bx;
      WEN_int = {2{1'bx}};
      A_int = {9{1'bx}};
      D_int = {8{1'bx}};
      EMA_int = {3{1'bx}};
      GWEN_int = 1'bx;
      RETN_int = 1'bx;
    end
    RETN_int = RETN_;
  end

  always @ CLK_ begin
`ifdef POWER_PINS
    if (VSS === 1'bx || VSS === 1'bz)
      $display("ERROR: Illegal value for VSS %b", VSS);
    if (VDD === 1'bx || VDD === 1'bz)
      $display("ERROR: Illegal value for VDD %b", VDD);
`endif
    if (CLK_ === 1'bx && (CEN_ !== 1'b1)) begin
      failedWrite(0);
      Q_int = {8{1'bx}};
    end else if (CLK_ === 1'b1 && LAST_CLK === 1'b0) begin
      CEN_int = CEN_;
      WEN_int = WEN_;
      A_int = A_;
      D_int = D_;
      EMA_int = EMA_;
      GWEN_int = GWEN_;
      RETN_int = RETN_;
      clk0_int = 1'b0;
      readWrite;
    end
    LAST_CLK = CLK_;
  end


endmodule
`endcelldefine
`else
`timescale 1 ns/1 ps
`celldefine
`ifdef POWER_PINS
module sram00 (Q, CLK, CEN, WEN, A, D, EMA, GWEN, RETN, VSS, VDD);
`else
module sram00 (Q, CLK, CEN, WEN, A, D, EMA, GWEN, RETN);
`endif

  parameter BITS = 8;
  parameter WORDS = 512;
  parameter MUX = 16;
  parameter MEM_WIDTH = 128; // redun block size 8, 64 on left, 64 on right
  parameter MEM_HEIGHT = 32;
  parameter WP_SIZE = 7 ;
  parameter UPM_WIDTH = 3;

  output [7:0] Q;
  input  CLK;
  input  CEN;
  input [1:0] WEN;
  input [8:0] A;
  input [7:0] D;
  input [2:0] EMA;
  input  GWEN;
  input  RETN;
`ifdef POWER_PINS
  inout VSS;
  inout VDD;
`endif

  integer row_address;
  integer mux_address;
  reg [127:0] mem [0:31];
  reg [127:0] row;
  reg LAST_CLK;
  reg [127:0] data_out;
  reg [127:0] row_mask;
  reg [127:0] new_data;
  reg [7:0] Q_int;
  reg [7:0] writeEnable;

  reg NOT_A0, NOT_A1, NOT_A2, NOT_A3, NOT_A4, NOT_A5, NOT_A6, NOT_A7, NOT_A8, NOT_CEN;
  reg NOT_CLK_MINH, NOT_CLK_MINL, NOT_CLK_PER, NOT_D0, NOT_D1, NOT_D2, NOT_D3, NOT_D4;
  reg NOT_D5, NOT_D6, NOT_D7, NOT_EMA0, NOT_EMA1, NOT_EMA2, NOT_GWEN, NOT_RETN, NOT_WEN0;
  reg NOT_WEN1;
  reg clk0_int;
  reg CREN_legal;
  initial CREN_legal = 1'b1;

  wire [7:0] Q_;
 wire  CLK_;
  wire  CEN_;
  reg  CEN_int;
  wire [1:0] WEN_;
  reg [1:0] WEN_int;
  wire [8:0] A_;
  reg [8:0] A_int;
  wire [7:0] D_;
  reg [7:0] D_int;
  wire [2:0] EMA_;
  reg [2:0] EMA_int;
  wire  GWEN_;
  reg  GWEN_int;
  wire  RETN_;
  reg  RETN_int;

  buf B0(Q[0], Q_[0]);
  buf B1(Q[1], Q_[1]);
  buf B2(Q[2], Q_[2]);
  buf B3(Q[3], Q_[3]);
  buf B4(Q[4], Q_[4]);
  buf B5(Q[5], Q_[5]);
  buf B6(Q[6], Q_[6]);
  buf B7(Q[7], Q_[7]);
  buf B8(CLK_, CLK);
  buf B9(CEN_, CEN);
  buf B10(WEN_[0], WEN[0]);
  buf B11(WEN_[1], WEN[1]);
  buf B12(A_[0], A[0]);
  buf B13(A_[1], A[1]);
  buf B14(A_[2], A[2]);
  buf B15(A_[3], A[3]);
  buf B16(A_[4], A[4]);
  buf B17(A_[5], A[5]);
  buf B18(A_[6], A[6]);
  buf B19(A_[7], A[7]);
  buf B20(A_[8], A[8]);
  buf B21(D_[0], D[0]);
  buf B22(D_[1], D[1]);
  buf B23(D_[2], D[2]);
  buf B24(D_[3], D[3]);
  buf B25(D_[4], D[4]);
  buf B26(D_[5], D[5]);
  buf B27(D_[6], D[6]);
  buf B28(D_[7], D[7]);
  buf B29(EMA_[0], EMA[0]);
  buf B30(EMA_[1], EMA[1]);
  buf B31(EMA_[2], EMA[2]);
  buf B32(GWEN_, GWEN);
  buf B33(RETN_, RETN);

  assign Q_ = RETN_ ? (Q_int) : {8{1'b0}};

`ifdef INITIALIZE_MEMORY
  integer i;
  initial
    for (i = 0; i < MEM_HEIGHT; i = i + 1)
      mem[i] = {MEM_WIDTH{1'b0}};
`endif

  task failedWrite;
  input port;
  integer i;
  begin
    for (i = 0; i < MEM_HEIGHT; i = i + 1)
      mem[i] = {MEM_WIDTH{1'bx}};
  end
  endtask

  function isBitX;
    input bitIn;
    begin
      isBitX = ( bitIn===1'bx || bitIn===1'bz ) ? 1'b1 : 1'b0;
    end
  endfunction


  task readWrite;
  begin
    if (RETN_int === 1'bx) begin
      failedWrite(0);
      Q_int = {8{1'bx}};
    end else if (RETN_int === 1'b0 && CEN_int === 1'b0) begin
      failedWrite(0);
      Q_int = {8{1'bx}};
    end else if (RETN_int === 1'b0) begin
      // no cycle in retention mode
    end else if (^{CEN_int, EMA_int} === 1'bx) begin
      failedWrite(0);
      Q_int = {8{1'bx}};
    end else if ((A_int >= WORDS) && (CEN_int === 1'b0)) begin
      writeEnable = ~( {8{GWEN_int}} | {WEN_int[1], WEN_int[0], WEN_int[0], WEN_int[0],
         WEN_int[0], WEN_int[0], WEN_int[0], WEN_int[0]});
      Q_int = ((writeEnable & D_int) | (~writeEnable & {8{1'bx}}));
    end else if (CEN_int === 1'b0 && (^A_int) === 1'bx) begin
      if (GWEN_int !== 1'b1 && (& WEN_int) !== 1'b1) failedWrite(0);
      Q_int = {8{1'bx}};
    end else if (CEN_int === 1'b0) begin
      mux_address = (A_int & 4'b1111);
      row_address = (A_int >> 4);
      if (row_address >= 32)
        row = {128{1'bx}};
      else
        row = mem[row_address];
      if( isBitX(GWEN_int) )
        writeEnable = {8{1'bx}};
      else
        writeEnable = ~( {8{GWEN_int}} | {WEN_int[1], WEN_int[0], WEN_int[0], WEN_int[0],
         WEN_int[0], WEN_int[0], WEN_int[0], WEN_int[0]});
      row_mask =  ( {15'b000000000000000, writeEnable[7], 15'b000000000000000, writeEnable[6],
          15'b000000000000000, writeEnable[5], 15'b000000000000000, writeEnable[4],
          15'b000000000000000, writeEnable[3], 15'b000000000000000, writeEnable[2],
          15'b000000000000000, writeEnable[1], 15'b000000000000000, writeEnable[0]} << mux_address);
      new_data =  ( {15'b000000000000000, D_int[7], 15'b000000000000000, D_int[6],
          15'b000000000000000, D_int[5], 15'b000000000000000, D_int[4], 15'b000000000000000, D_int[3],
          15'b000000000000000, D_int[2], 15'b000000000000000, D_int[1], 15'b000000000000000, D_int[0]} << mux_address);
      row = (row & ~row_mask) | (row_mask & (~row_mask | new_data));
      mem[row_address] = row;
      data_out = (row >> mux_address);
      if (GWEN_int !== 1'b0)
        Q_int = {data_out[112], data_out[96], data_out[80], data_out[64], data_out[48],
          data_out[32], data_out[16], data_out[0]};
      else
        Q_int = {(writeEnable[7]?data_out[112]:Q_int[7]), (writeEnable[6]?data_out[96]:Q_int[6]),
          (writeEnable[5]?data_out[80]:Q_int[5]), (writeEnable[4]?data_out[64]:Q_int[4]),
          (writeEnable[3]?data_out[48]:Q_int[3]), (writeEnable[2]?data_out[32]:Q_int[2]),
          (writeEnable[1]?data_out[16]:Q_int[1]), (writeEnable[0]?data_out[0]:Q_int[0])};
    end
  end
  endtask

  always @ RETN_ begin
    if (RETN_ == 1'b0) begin
      Q_int = {8{1'b0}};
      CEN_int = 1'b0;
      WEN_int = {2{1'b0}};
      A_int = {9{1'b0}};
      D_int = {8{1'b0}};
      EMA_int = {3{1'b0}};
      GWEN_int = 1'b0;
      RETN_int = 1'b0;
    end else begin
      Q_int = {8{1'bx}};
      CEN_int = 1'bx;
      WEN_int = {2{1'bx}};
      A_int = {9{1'bx}};
      D_int = {8{1'bx}};
      EMA_int = {3{1'bx}};
      GWEN_int = 1'bx;
      RETN_int = 1'bx;
    end
    RETN_int = RETN_;
  end

  always @ CLK_ begin
`ifdef POWER_PINS
    if (VSS === 1'bx || VSS === 1'bz)
      $display("ERROR: Illegal value for VSS %b", VSS);
    if (VDD === 1'bx || VDD === 1'bz)
      $display("ERROR: Illegal value for VDD %b", VDD);
`endif
    if (CLK_ === 1'bx && (CEN_ !== 1'b1)) begin
      failedWrite(0);
      Q_int = {8{1'bx}};
    end else if (CLK_ === 1'b1 && LAST_CLK === 1'b0) begin
      CEN_int = CEN_;
      WEN_int = WEN_;
      A_int = A_;
      D_int = D_;
      EMA_int = EMA_;
      GWEN_int = GWEN_;
      RETN_int = RETN_;
      clk0_int = 1'b0;
      readWrite;
    end
    LAST_CLK = CLK_;
  end

  reg globalNotifier0;
  initial globalNotifier0 = 1'b0;

  always @ globalNotifier0 begin
    if ($realtime == 0) begin
    end else if (CEN_int === 1'bx || EMA_int[0] === 1'bx || EMA_int[1] === 1'bx || 
      EMA_int[2] === 1'bx || RETN_int === 1'bx || clk0_int === 1'bx) begin
      Q_int = {8{1'bx}};
      failedWrite(0);
    end else begin
      readWrite;
   end
    globalNotifier0 = 1'b0;
  end

  always @ NOT_A0 begin
    A_int[0] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_A1 begin
    A_int[1] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_A2 begin
    A_int[2] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_A3 begin
    A_int[3] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_A4 begin
    A_int[4] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_A5 begin
    A_int[5] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_A6 begin
    A_int[6] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_A7 begin
    A_int[7] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_A8 begin
    A_int[8] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_CEN begin
    CEN_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D0 begin
    D_int[0] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D1 begin
    D_int[1] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D2 begin
    D_int[2] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D3 begin
    D_int[3] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D4 begin
    D_int[4] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D5 begin
    D_int[5] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D6 begin
    D_int[6] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_D7 begin
    D_int[7] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_EMA0 begin
    EMA_int[0] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_EMA1 begin
    EMA_int[1] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_EMA2 begin
    EMA_int[2] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_GWEN begin
    GWEN_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_RETN begin
    RETN_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_WEN0 begin
    WEN_int[0] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_WEN1 begin
    WEN_int[1] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_CLK_MINH begin
    clk0_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_CLK_MINL begin
    clk0_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_CLK_PER begin
    clk0_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end

  wire CEN_flag;
  wire flag;
  wire D_flag0;
  wire D_flag1;
  wire D_flag2;
  wire D_flag3;
  wire D_flag4;
  wire D_flag5;
  wire D_flag6;
  wire D_flag7;
  wire cyc_flag;
  wire EMA2eq0andEMA1eq0andEMA0eq0;
  wire EMA2eq0andEMA1eq0andEMA0eq1;
  wire EMA2eq0andEMA1eq1andEMA0eq0;
  wire EMA2eq0andEMA1eq1andEMA0eq1;
  wire EMA2eq1andEMA1eq0andEMA0eq0;
  wire EMA2eq1andEMA1eq0andEMA0eq1;
  wire EMA2eq1andEMA1eq1andEMA0eq0;
  wire EMA2eq1andEMA1eq1andEMA0eq1;
  assign CEN_flag = 1'b1;
  assign flag = !CEN_;
  assign D_flag0 = !(CEN_ || WEN_[0] || GWEN_);
  assign D_flag1 = !(CEN_ || WEN_[0] || GWEN_);
  assign D_flag2 = !(CEN_ || WEN_[0] || GWEN_);
  assign D_flag3 = !(CEN_ || WEN_[0] || GWEN_);
  assign D_flag4 = !(CEN_ || WEN_[0] || GWEN_);
  assign D_flag5 = !(CEN_ || WEN_[0] || GWEN_);
  assign D_flag6 = !(CEN_ || WEN_[0] || GWEN_);
  assign D_flag7 = !(CEN_ || WEN_[1] || GWEN_);
  assign cyc_flag = !CEN_;
  assign EMA2eq0andEMA1eq0andEMA0eq0 = !EMA_[2] && !EMA_[1] && !EMA_[0] && cyc_flag;
  assign EMA2eq0andEMA1eq0andEMA0eq1 = !EMA_[2] && !EMA_[1] && EMA_[0] && cyc_flag;
  assign EMA2eq0andEMA1eq1andEMA0eq0 = !EMA_[2] && EMA_[1] && !EMA_[0] && cyc_flag;
  assign EMA2eq0andEMA1eq1andEMA0eq1 = !EMA_[2] && EMA_[1] && EMA_[0] && cyc_flag;
  assign EMA2eq1andEMA1eq0andEMA0eq0 = EMA_[2] && !EMA_[1] && !EMA_[0] && cyc_flag;
  assign EMA2eq1andEMA1eq0andEMA0eq1 = EMA_[2] && !EMA_[1] && EMA_[0] && cyc_flag;
  assign EMA2eq1andEMA1eq1andEMA0eq0 = EMA_[2] && EMA_[1] && !EMA_[0] && cyc_flag;
  assign EMA2eq1andEMA1eq1andEMA0eq1 = EMA_[2] && EMA_[1] && EMA_[0] && cyc_flag;

  specify
      $hold(posedge CEN, negedge RETN, 1.000, NOT_RETN);
      $setuphold(posedge CLK &&& CEN_flag, posedge CEN, 1.000, 0.500, NOT_CEN);
      $setuphold(posedge CLK &&& CEN_flag, negedge CEN, 1.000, 0.500, NOT_CEN);
      $setuphold(posedge CLK &&& flag, posedge WEN[1], 1.000, 0.500, NOT_WEN1);
      $setuphold(posedge CLK &&& flag, negedge WEN[1], 1.000, 0.500, NOT_WEN1);
      $setuphold(posedge CLK &&& flag, posedge WEN[0], 1.000, 0.500, NOT_WEN0);
      $setuphold(posedge CLK &&& flag, negedge WEN[0], 1.000, 0.500, NOT_WEN0);
      $setuphold(posedge CLK &&& flag, posedge GWEN, 1.000, 0.500, NOT_GWEN);
      $setuphold(posedge CLK &&& flag, negedge GWEN, 1.000, 0.500, NOT_GWEN);
      $setuphold(posedge CLK &&& flag, posedge A[8], 1.000, 0.500, NOT_A8);
      $setuphold(posedge CLK &&& flag, negedge A[8], 1.000, 0.500, NOT_A8);
      $setuphold(posedge CLK &&& flag, posedge A[7], 1.000, 0.500, NOT_A7);
      $setuphold(posedge CLK &&& flag, negedge A[7], 1.000, 0.500, NOT_A7);
      $setuphold(posedge CLK &&& flag, posedge A[6], 1.000, 0.500, NOT_A6);
      $setuphold(posedge CLK &&& flag, negedge A[6], 1.000, 0.500, NOT_A6);
      $setuphold(posedge CLK &&& flag, posedge A[5], 1.000, 0.500, NOT_A5);
      $setuphold(posedge CLK &&& flag, negedge A[5], 1.000, 0.500, NOT_A5);
      $setuphold(posedge CLK &&& flag, posedge A[4], 1.000, 0.500, NOT_A4);
      $setuphold(posedge CLK &&& flag, negedge A[4], 1.000, 0.500, NOT_A4);
      $setuphold(posedge CLK &&& flag, posedge A[3], 1.000, 0.500, NOT_A3);
      $setuphold(posedge CLK &&& flag, negedge A[3], 1.000, 0.500, NOT_A3);
      $setuphold(posedge CLK &&& flag, posedge A[2], 1.000, 0.500, NOT_A2);
      $setuphold(posedge CLK &&& flag, negedge A[2], 1.000, 0.500, NOT_A2);
      $setuphold(posedge CLK &&& flag, posedge A[1], 1.000, 0.500, NOT_A1);
      $setuphold(posedge CLK &&& flag, negedge A[1], 1.000, 0.500, NOT_A1);
      $setuphold(posedge CLK &&& flag, posedge A[0], 1.000, 0.500, NOT_A0);
      $setuphold(posedge CLK &&& flag, negedge A[0], 1.000, 0.500, NOT_A0);
      $setuphold(posedge CLK &&& D_flag7, posedge D[7], 1.000, 0.500, NOT_D7);
      $setuphold(posedge CLK &&& D_flag7, negedge D[7], 1.000, 0.500, NOT_D7);
      $setuphold(posedge CLK &&& D_flag6, posedge D[6], 1.000, 0.500, NOT_D6);
      $setuphold(posedge CLK &&& D_flag6, negedge D[6], 1.000, 0.500, NOT_D6);
      $setuphold(posedge CLK &&& D_flag5, posedge D[5], 1.000, 0.500, NOT_D5);
      $setuphold(posedge CLK &&& D_flag5, negedge D[5], 1.000, 0.500, NOT_D5);
      $setuphold(posedge CLK &&& D_flag4, posedge D[4], 1.000, 0.500, NOT_D4);
      $setuphold(posedge CLK &&& D_flag4, negedge D[4], 1.000, 0.500, NOT_D4);
      $setuphold(posedge CLK &&& D_flag3, posedge D[3], 1.000, 0.500, NOT_D3);
      $setuphold(posedge CLK &&& D_flag3, negedge D[3], 1.000, 0.500, NOT_D3);
      $setuphold(posedge CLK &&& D_flag2, posedge D[2], 1.000, 0.500, NOT_D2);
      $setuphold(posedge CLK &&& D_flag2, negedge D[2], 1.000, 0.500, NOT_D2);
      $setuphold(posedge CLK &&& D_flag1, posedge D[1], 1.000, 0.500, NOT_D1);
      $setuphold(posedge CLK &&& D_flag1, negedge D[1], 1.000, 0.500, NOT_D1);
      $setuphold(posedge CLK &&& D_flag0, posedge D[0], 1.000, 0.500, NOT_D0);
      $setuphold(posedge CLK &&& D_flag0, negedge D[0], 1.000, 0.500, NOT_D0);
      $setuphold(posedge CLK &&& cyc_flag, posedge EMA[2], 1.000, 0.500, NOT_EMA2);
      $setuphold(posedge CLK &&& cyc_flag, negedge EMA[2], 1.000, 0.500, NOT_EMA2);
      $setuphold(posedge CLK &&& cyc_flag, posedge EMA[1], 1.000, 0.500, NOT_EMA1);
      $setuphold(posedge CLK &&& cyc_flag, negedge EMA[1], 1.000, 0.500, NOT_EMA1);
      $setuphold(posedge CLK &&& cyc_flag, posedge EMA[0], 1.000, 0.500, NOT_EMA0);
      $setuphold(posedge CLK &&& cyc_flag, negedge EMA[0], 1.000, 0.500, NOT_EMA0);
      $setuphold(posedge CLK, posedge RETN, 1.000, 0.500, NOT_RETN);
      $setuphold(posedge CLK, negedge RETN, 1.000, 0.500, NOT_RETN);
      $hold(posedge RETN, negedge CEN, 1.000, NOT_RETN);

      $width(posedge CLK &&& cyc_flag, 1.000, 0, NOT_CLK_MINH);
      $width(negedge CLK &&& cyc_flag, 1.000, 0, NOT_CLK_MINL);
`ifdef NO_SDTC
      $period(posedge CLK  &&& cyc_flag, 3.000, NOT_CLK_PER);
`else
      $period(posedge CLK &&& EMA2eq0andEMA1eq0andEMA0eq0, 3.000, NOT_CLK_PER);
      $period(posedge CLK &&& EMA2eq0andEMA1eq0andEMA0eq1, 3.000, NOT_CLK_PER);
      $period(posedge CLK &&& EMA2eq0andEMA1eq1andEMA0eq0, 3.000, NOT_CLK_PER);
      $period(posedge CLK &&& EMA2eq0andEMA1eq1andEMA0eq1, 3.000, NOT_CLK_PER);
      $period(posedge CLK &&& EMA2eq1andEMA1eq0andEMA0eq0, 3.000, NOT_CLK_PER);
      $period(posedge CLK &&& EMA2eq1andEMA1eq0andEMA0eq1, 3.000, NOT_CLK_PER);
      $period(posedge CLK &&& EMA2eq1andEMA1eq1andEMA0eq0, 3.000, NOT_CLK_PER);
      $period(posedge CLK &&& EMA2eq1andEMA1eq1andEMA0eq1, 3.000, NOT_CLK_PER);
`endif

      if ((EMA[2] == 1'b0) && (EMA[1] == 1'b0) && (EMA[0] == 1'b0))
        (posedge CLK => (Q[7]:1'b0))=(1.000, 1.000);
      if ((EMA[2] == 1'b0) && (EMA[1] == 1'b0) && (EMA[0] == 1'b1))
        (posedge CLK => (Q[7]:1'b0))=(1.000, 1.000);
      if ((EMA[2] == 1'b0) && (EMA[1] == 1'b1) && (EMA[0] == 1'b0))
        (posedge CLK => (Q[7]:1'b0))=(1.000, 1.000);
      if ((EMA[2] == 1'b0) && (EMA[1] == 1'b1) && (EMA[0] == 1'b1))
        (posedge CLK => (Q[7]:1'b0))=(1.000, 1.000);
      if ((EMA[2] == 1'b1) && (EMA[1] == 1'b0) && (EMA[0] == 1'b0))
        (posedge CLK => (Q[7]:1'b0))=(1.000, 1.000);
      if ((EMA[2] == 1'b1) && (EMA[1] == 1'b0) && (EMA[0] == 1'b1))
        (posedge CLK => (Q[7]:1'b0))=(1.000, 1.000);
      if ((EMA[2] == 1'b1) && (EMA[1] == 1'b1) && (EMA[0] == 1'b0))
        (posedge CLK => (Q[7]:1'b0))=(1.000, 1.000);
      if ((EMA[2] == 1'b1) && (EMA[1] == 1'b1) && (EMA[0] == 1'b1))
        (posedge CLK => (Q[7]:1'b0))=(1.000, 1.000);
      if ((EMA[2] == 1'b0) && (EMA[1] == 1'b0) && (EMA[0] == 1'b0))
        (posedge CLK => (Q[6]:1'b0))=(1.000, 1.000);
      if ((EMA[2] == 1'b0) && (EMA[1] == 1'b0) && (EMA[0] == 1'b1))
        (posedge CLK => (Q[6]:1'b0))=(1.000, 1.000);
      if ((EMA[2] == 1'b0) && (EMA[1] == 1'b1) && (EMA[0] == 1'b0))
        (posedge CLK => (Q[6]:1'b0))=(1.000, 1.000);
      if ((EMA[2] == 1'b0) && (EMA[1] == 1'b1) && (EMA[0] == 1'b1))
        (posedge CLK => (Q[6]:1'b0))=(1.000, 1.000);
      if ((EMA[2] == 1'b1) && (EMA[1] == 1'b0) && (EMA[0] == 1'b0))
        (posedge CLK => (Q[6]:1'b0))=(1.000, 1.000);
      if ((EMA[2] == 1'b1) && (EMA[1] == 1'b0) && (EMA[0] == 1'b1))
        (posedge CLK => (Q[6]:1'b0))=(1.000, 1.000);
      if ((EMA[2] == 1'b1) && (EMA[1] == 1'b1) && (EMA[0] == 1'b0))
        (posedge CLK => (Q[6]:1'b0))=(1.000, 1.000);
      if ((EMA[2] == 1'b1) && (EMA[1] == 1'b1) && (EMA[0] == 1'b1))
        (posedge CLK => (Q[6]:1'b0))=(1.000, 1.000);
      if ((EMA[2] == 1'b0) && (EMA[1] == 1'b0) && (EMA[0] == 1'b0))
        (posedge CLK => (Q[5]:1'b0))=(1.000, 1.000);
      if ((EMA[2] == 1'b0) && (EMA[1] == 1'b0) && (EMA[0] == 1'b1))
        (posedge CLK => (Q[5]:1'b0))=(1.000, 1.000);
      if ((EMA[2] == 1'b0) && (EMA[1] == 1'b1) && (EMA[0] == 1'b0))
        (posedge CLK => (Q[5]:1'b0))=(1.000, 1.000);
      if ((EMA[2] == 1'b0) && (EMA[1] == 1'b1) && (EMA[0] == 1'b1))
        (posedge CLK => (Q[5]:1'b0))=(1.000, 1.000);
      if ((EMA[2] == 1'b1) && (EMA[1] == 1'b0) && (EMA[0] == 1'b0))
        (posedge CLK => (Q[5]:1'b0))=(1.000, 1.000);
      if ((EMA[2] == 1'b1) && (EMA[1] == 1'b0) && (EMA[0] == 1'b1))
        (posedge CLK => (Q[5]:1'b0))=(1.000, 1.000);
      if ((EMA[2] == 1'b1) && (EMA[1] == 1'b1) && (EMA[0] == 1'b0))
        (posedge CLK => (Q[5]:1'b0))=(1.000, 1.000);
      if ((EMA[2] == 1'b1) && (EMA[1] == 1'b1) && (EMA[0] == 1'b1))
        (posedge CLK => (Q[5]:1'b0))=(1.000, 1.000);
      if ((EMA[2] == 1'b0) && (EMA[1] == 1'b0) && (EMA[0] == 1'b0))
        (posedge CLK => (Q[4]:1'b0))=(1.000, 1.000);
      if ((EMA[2] == 1'b0) && (EMA[1] == 1'b0) && (EMA[0] == 1'b1))
        (posedge CLK => (Q[4]:1'b0))=(1.000, 1.000);
      if ((EMA[2] == 1'b0) && (EMA[1] == 1'b1) && (EMA[0] == 1'b0))
        (posedge CLK => (Q[4]:1'b0))=(1.000, 1.000);
      if ((EMA[2] == 1'b0) && (EMA[1] == 1'b1) && (EMA[0] == 1'b1))
        (posedge CLK => (Q[4]:1'b0))=(1.000, 1.000);
      if ((EMA[2] == 1'b1) && (EMA[1] == 1'b0) && (EMA[0] == 1'b0))
        (posedge CLK => (Q[4]:1'b0))=(1.000, 1.000);
      if ((EMA[2] == 1'b1) && (EMA[1] == 1'b0) && (EMA[0] == 1'b1))
        (posedge CLK => (Q[4]:1'b0))=(1.000, 1.000);
      if ((EMA[2] == 1'b1) && (EMA[1] == 1'b1) && (EMA[0] == 1'b0))
        (posedge CLK => (Q[4]:1'b0))=(1.000, 1.000);
      if ((EMA[2] == 1'b1) && (EMA[1] == 1'b1) && (EMA[0] == 1'b1))
        (posedge CLK => (Q[4]:1'b0))=(1.000, 1.000);
      if ((EMA[2] == 1'b0) && (EMA[1] == 1'b0) && (EMA[0] == 1'b0))
        (posedge CLK => (Q[3]:1'b0))=(1.000, 1.000);
      if ((EMA[2] == 1'b0) && (EMA[1] == 1'b0) && (EMA[0] == 1'b1))
        (posedge CLK => (Q[3]:1'b0))=(1.000, 1.000);
      if ((EMA[2] == 1'b0) && (EMA[1] == 1'b1) && (EMA[0] == 1'b0))
        (posedge CLK => (Q[3]:1'b0))=(1.000, 1.000);
      if ((EMA[2] == 1'b0) && (EMA[1] == 1'b1) && (EMA[0] == 1'b1))
        (posedge CLK => (Q[3]:1'b0))=(1.000, 1.000);
      if ((EMA[2] == 1'b1) && (EMA[1] == 1'b0) && (EMA[0] == 1'b0))
        (posedge CLK => (Q[3]:1'b0))=(1.000, 1.000);
      if ((EMA[2] == 1'b1) && (EMA[1] == 1'b0) && (EMA[0] == 1'b1))
        (posedge CLK => (Q[3]:1'b0))=(1.000, 1.000);
      if ((EMA[2] == 1'b1) && (EMA[1] == 1'b1) && (EMA[0] == 1'b0))
        (posedge CLK => (Q[3]:1'b0))=(1.000, 1.000);
      if ((EMA[2] == 1'b1) && (EMA[1] == 1'b1) && (EMA[0] == 1'b1))
        (posedge CLK => (Q[3]:1'b0))=(1.000, 1.000);
      if ((EMA[2] == 1'b0) && (EMA[1] == 1'b0) && (EMA[0] == 1'b0))
        (posedge CLK => (Q[2]:1'b0))=(1.000, 1.000);
      if ((EMA[2] == 1'b0) && (EMA[1] == 1'b0) && (EMA[0] == 1'b1))
        (posedge CLK => (Q[2]:1'b0))=(1.000, 1.000);
      if ((EMA[2] == 1'b0) && (EMA[1] == 1'b1) && (EMA[0] == 1'b0))
        (posedge CLK => (Q[2]:1'b0))=(1.000, 1.000);
      if ((EMA[2] == 1'b0) && (EMA[1] == 1'b1) && (EMA[0] == 1'b1))
        (posedge CLK => (Q[2]:1'b0))=(1.000, 1.000);
      if ((EMA[2] == 1'b1) && (EMA[1] == 1'b0) && (EMA[0] == 1'b0))
        (posedge CLK => (Q[2]:1'b0))=(1.000, 1.000);
      if ((EMA[2] == 1'b1) && (EMA[1] == 1'b0) && (EMA[0] == 1'b1))
        (posedge CLK => (Q[2]:1'b0))=(1.000, 1.000);
      if ((EMA[2] == 1'b1) && (EMA[1] == 1'b1) && (EMA[0] == 1'b0))
        (posedge CLK => (Q[2]:1'b0))=(1.000, 1.000);
      if ((EMA[2] == 1'b1) && (EMA[1] == 1'b1) && (EMA[0] == 1'b1))
        (posedge CLK => (Q[2]:1'b0))=(1.000, 1.000);
      if ((EMA[2] == 1'b0) && (EMA[1] == 1'b0) && (EMA[0] == 1'b0))
        (posedge CLK => (Q[1]:1'b0))=(1.000, 1.000);
      if ((EMA[2] == 1'b0) && (EMA[1] == 1'b0) && (EMA[0] == 1'b1))
        (posedge CLK => (Q[1]:1'b0))=(1.000, 1.000);
      if ((EMA[2] == 1'b0) && (EMA[1] == 1'b1) && (EMA[0] == 1'b0))
        (posedge CLK => (Q[1]:1'b0))=(1.000, 1.000);
      if ((EMA[2] == 1'b0) && (EMA[1] == 1'b1) && (EMA[0] == 1'b1))
        (posedge CLK => (Q[1]:1'b0))=(1.000, 1.000);
      if ((EMA[2] == 1'b1) && (EMA[1] == 1'b0) && (EMA[0] == 1'b0))
        (posedge CLK => (Q[1]:1'b0))=(1.000, 1.000);
      if ((EMA[2] == 1'b1) && (EMA[1] == 1'b0) && (EMA[0] == 1'b1))
        (posedge CLK => (Q[1]:1'b0))=(1.000, 1.000);
      if ((EMA[2] == 1'b1) && (EMA[1] == 1'b1) && (EMA[0] == 1'b0))
        (posedge CLK => (Q[1]:1'b0))=(1.000, 1.000);
      if ((EMA[2] == 1'b1) && (EMA[1] == 1'b1) && (EMA[0] == 1'b1))
        (posedge CLK => (Q[1]:1'b0))=(1.000, 1.000);
      if ((EMA[2] == 1'b0) && (EMA[1] == 1'b0) && (EMA[0] == 1'b0))
        (posedge CLK => (Q[0]:1'b0))=(1.000, 1.000);
      if ((EMA[2] == 1'b0) && (EMA[1] == 1'b0) && (EMA[0] == 1'b1))
        (posedge CLK => (Q[0]:1'b0))=(1.000, 1.000);
      if ((EMA[2] == 1'b0) && (EMA[1] == 1'b1) && (EMA[0] == 1'b0))
        (posedge CLK => (Q[0]:1'b0))=(1.000, 1.000);
      if ((EMA[2] == 1'b0) && (EMA[1] == 1'b1) && (EMA[0] == 1'b1))
        (posedge CLK => (Q[0]:1'b0))=(1.000, 1.000);
      if ((EMA[2] == 1'b1) && (EMA[1] == 1'b0) && (EMA[0] == 1'b0))
        (posedge CLK => (Q[0]:1'b0))=(1.000, 1.000);
      if ((EMA[2] == 1'b1) && (EMA[1] == 1'b0) && (EMA[0] == 1'b1))
        (posedge CLK => (Q[0]:1'b0))=(1.000, 1.000);
      if ((EMA[2] == 1'b1) && (EMA[1] == 1'b1) && (EMA[0] == 1'b0))
        (posedge CLK => (Q[0]:1'b0))=(1.000, 1.000);
      if ((EMA[2] == 1'b1) && (EMA[1] == 1'b1) && (EMA[0] == 1'b1))
        (posedge CLK => (Q[0]:1'b0))=(1.000, 1.000);

      (RETN => (Q[7] +: 1'b0)) = (1.000);
      (RETN => (Q[6] +: 1'b0)) = (1.000);
      (RETN => (Q[5] +: 1'b0)) = (1.000);
      (RETN => (Q[4] +: 1'b0)) = (1.000);
      (RETN => (Q[3] +: 1'b0)) = (1.000);
      (RETN => (Q[2] +: 1'b0)) = (1.000);
      (RETN => (Q[1] +: 1'b0)) = (1.000);
      (RETN => (Q[0] +: 1'b0)) = (1.000);
  endspecify

endmodule
`endcelldefine
`endif
