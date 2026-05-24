// fft_data_sram: 1024-word x 32-bit data memory using sram00 physical macro.
//
// Per spec: inputs AND FFT results must reside on SRAM.
// sram00 is 512 words x 128-bit (MUX=4, 9-bit address).
// We need 1024 words → two sram00 instances banked on addr[9].
//
// Bank 0 (sram_wrapper_b0): words   0–511  (addr[9]=0)
// Bank 1 (sram_wrapper_b1): words 512–1023 (addr[9]=1)
// Both banks receive addr[8:0] as the 9-bit word address.
//
// sram00 MUX=4 physical layout (verified from readWrite task):
//   mux_address = A[1:0]  (word column 0-3 within 128-bit row)
//   row_address = A[8:2]  (row 0-127)
//   Q[k] = mem[row][ 4*k + mux ] after registered output
//   → Q[31:0] always contains the selected 32-bit word
//
// The $readmemh initialization is done from the TESTBENCH by writing
// samples word-by-word through the normal write port (din interface),
// matching the spec: "Load inputs on SRAM row-by-row using the testbench."
//
// Output (data_out) is registered — valid one cycle after address is presented.
// The controller accounts for this with the READ_X0/LATCH_X0 two-cycle read sequence.

module fft_data_sram(
    input              clk,
    input              din_sel,         // 0 = external din, 1 = butterfly result
    input              data_sram_c_en,  // active-low chip enable
    input              data_sram_w_en,  // 1=write, 0=read
    input  [9:0]       data_address,    // 10-bit word address (0-1023)
    input  [31:0]      din,             // external input data (from testbench)
    input  [31:0]      butterfly_out,   // butterfly result write-back
    output [31:0]      data_out
);
    wire gwen = ~data_sram_w_en;       // GWEN: 0=write, 1=read
    wire [31:0] data_in = din_sel ? butterfly_out : din;

    // Bank select: addr[9] picks which sram00 instance
    wire        bank_sel  = data_address[9];
    wire [8:0]  bank_addr = data_address[8:0];
	 
    // Only enable the selected bank (CEN active-low)
    wire cen_b0 = data_sram_c_en | bank_sel;   // disabled when bank_sel=1
    wire cen_b1 = data_sram_c_en | ~bank_sel;  // disabled when bank_sel=0

    wire [31:0] dout_b0, dout_b1;
	wire [8:0] bank_addr_dly;
	`ifdef SYNTH
      BUFFD0 U_BUF[8: 0](.I(bank_addr), .Z(bank_addr_dly));
	`else
      assign bank_addr_dly=bank_addr ;
	`endif
    // Bank 0: words 0-511
    sram_wrapper #(.DW(32), .AW(9)) sram_wrapper_b0 (
        .clk  (clk),
        .cen  (cen_b0),
        .gwen (gwen),
        .addr (bank_addr_dly),
        .din  (data_in),
        .dout (dout_b0)
    );

    // Bank 1: words 512-1023
    sram_wrapper #(.DW(32), .AW(9)) sram_wrapper_b1 (
        .clk  (clk),
        .cen  (cen_b1),
        .gwen (gwen),
        .addr (bank_addr_dly),
        .din  (data_in),
        .dout (dout_b1)
    );

    // Output mux aligned to sram00's registered Q output.
    // bank_sel is registered to stay in sync with the one-cycle SRAM latency:
    // address presented cycle N → Q valid cycle N+1 → bank_sel_q selects correct bank.
    reg bank_sel_q;
    always @(posedge clk) bank_sel_q <= bank_sel;

    assign data_out = bank_sel_q ? dout_b1 : dout_b0;

endmodule
