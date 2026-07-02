//==============================================================================
// sram_wrapper.v
//
// Thin wrapper around sram00 (ARM 8192x32 single-port SRAM).
//
// sram00 interface:
//   A    : 13-bit address (8192 words)
//   D    : 32-bit data-in
//   Q    : 32-bit data-out (registered, appears one cycle after address)
//   CEN  : chip-enable, active-LOW  (0 = enabled, 1 = disabled)
//   GWEN : global-write-enable, active-LOW (0 = write, 1 = read)
//   WEN  : 4-bit byte-write-enable, active-LOW (one bit per byte of D)
//   EMA  : extra margin adjustment (tie 3'b000)
//   RETN : retention, active-LOW (tie 1'b1 for normal operation)
//
// Wrapper interface (active-HIGH for user convenience):
//   cen  : chip-enable, active-HIGH (1 = enable SRAM access)
//   wen  : write-enable, active-HIGH (1 = write, 0 = read)
//   addr : 13-bit address
//   din  : 32-bit data-in
//   dout : 32-bit data-out
//
// Timing:
//   - Write:  on rising edge of clk, din is written to mem[addr]
//   - Read:   on rising edge of clk, mem[addr] is latched into internal reg
//             and appears on dout one cycle later (registered-Q SRAM)
//==============================================================================
`timescale 1ns/1ps

module sram_wrapper #(
    parameter SRAM_WORDS = 512,
    parameter SRAM_WORD_WIDTH = $clog2(SRAM_WORDS),
    parameter SRAM_DATA_WIDTH = 32
) (
    
    input              clk,
    input              cen,    // 1 = access enabled, 0 = idle (active-HIGH to user)
    input              wen,    // 1 = write, 0 = read (active-HIGH to user)
    input      [SRAM_WORD_WIDTH-1:0]  addr,
    input      [SRAM_DATA_WIDTH-1:0]  din,
    output     [SRAM_DATA_WIDTH-1:0]  dout
);
    
    // --------------------------------------------------------------------
    // Convert active-HIGH user signals to active-LOW sram00 signals
    // --------------------------------------------------------------------
    wire CEN_n  = ~cen;        // active-LOW chip-enable
    wire GWEN_n = ~wen;        // active-LOW global-write-enable
    wire [4:0] WEN_n = 5'b0000; // all 4 bytes enabled for writes;
                                // GWEN_n gates whether write actually happens


    //  size mapping
  
    // --------------------------------------------------------------------
    // Instantiate sram00
    // --------------------------------------------------------------------
    sram00 u_sram (
        .CLK  (clk), // 1 bit 
        .CEN  (CEN_n), // 1 bit
        .GWEN (GWEN_n), // 1 bit 
        .WEN  (WEN_n), // 5 bits 
        .A    (addr), //9 bits
        .D    (din), // 32 bits
        .EMA  (3'b000), // 3 bits
        .RETN (1'b1), // 1 bit
        .Q    (dout) //32 bits
    );

endmodule

