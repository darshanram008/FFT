
`timescale 1ns/1ps
`define DELAY #1

// sram_wrapper: thin wrapper around sram00 (512 words x 128-bit, MUX=4, 9-bit address)
//
// sram00 internal addressing (verified from readWrite task in sram00.v):
//   mux_address = A[1:0]       → selects which 32-bit word within the 128-bit row
//   row_address = A[8:2]       → selects which of 128 rows
//   Q[k]        = data_out[4*k] after right-shift by mux_address
//
// So the full 9-bit A directly addresses 512 x 32-bit logical words.
// sram00 handles all internal word-select — we pass A straight through.
//
// Write control:
//   GWEN=0, WEN=16'h0000 → write all 128 bits (sram00 picks correct 32-bit lane via mux)
//   GWEN=1               → read
//
// Q[31:0] always contains the correctly selected 32-bit word after sram00's internal mux.

module sram_wrapper #(
    parameter DW = 32,
    parameter AW = 9    // 9-bit → 512 addressable 32-bit words
)(
    input              clk,
    input              cen,    // chip enable, active-low
    input              gwen,   // 0=write, 1=read
    input  [AW-1:0]    addr,
    input  [DW-1:0]    din,
    output [DW-1:0]    dout
);

    wire              cen_d, gwen_d;
    wire [AW-1:0]     addr_d;
    wire [DW-1:0]     din_d;
	

    assign `DELAY cen_d  = cen;
    assign `DELAY gwen_d = gwen;
    assign `DELAY addr_d = addr;
    assign `DELAY din_d  = din;



    // Zero-pad address to 9 bits
    wire [8:0] sram_A = {{(9-AW){1'b0}}, addr_d};

    // Pack 32-bit data into D[31:0]; sram00's mux shifts it to correct lane internally
    wire [127:0] sram_D = {96'b0, din_d};
	
	
    wire [127:0] row_out;
	wire [15:0] wen_final = (gwen_d == 1'b0) ? 16'hFFF0 : 16'hFFFF;

    // Q[31:0] always holds the selected word (sram00 mux handles lane extraction)
    assign dout = row_out[31:0];

    sram00 sram00_inst (
        .CLK  (clk),
        .CEN  (cen_d),
        .GWEN (gwen_d),
        .WEN(wen_final),   // all byte lanes enabled; GWEN controls read/write
        .A    (sram_A),
        .D    (sram_D),
        .EMA  (3'b000),
        .RETN (1'b1),
        .Q    (row_out)
    );

endmodule
