//==============================================================================
// fft_twiddle_sram.v
//
// Twiddle-factor SRAM for the FFT processor.
// Holds 512 complex twiddle factors W_N^k = e^(-j*2*pi*k/1024) for k=0..511.
// Each is 32 bits = {real[15:0], imag[15:0]} in Q1.15.
//
// Like fft_data_sram, exposes a multiplexed testbench port so the testbench
// can preload twiddle factors at startup.
//
// Uses its own sram00 instance (8192x32). We only use words 0..511.
//==============================================================================
`timescale 1ns/1ps

module fft_twiddle_sram #( 
    parameter FFT_POINT = 128,
    parameter NUMBER_OF_TW = FFT_POINT/2,
    parameter WORD_WIDTH_TW = $clog2(NUMBER_OF_TW),
    parameter DATA_WIDTH =16,
    parameter SRAM_WORDS = 512,
    parameter SRAM_WORD_WIDTH = $clog2(SRAM_WORDS),
    parameter SRAM_DATA_WIDTH = 32
     )(
    
    input              clk,

    // Mux select: 1 = testbench, 0 = FFT core
    input              tb_sel,

    // Testbench port
    input              tb_cen,
    input              tb_wen,
    input      [WORD_WIDTH_TW-1:0]   tb_addr,
    input      [DATA_WIDTH-1:0]  tb_din,

    // FFT-core port (read-only in practice, but we expose wen for symmetry)
    input              core_cen,
    input      [WORD_WIDTH_TW-1:0]   core_addr,

    // Shared data-out (registered one cycle after address)
    output     [DATA_WIDTH-1:0]  dout
);
    
    // --------------------------------------------------------------------
    // Mux the two ports
    // --------------------------------------------------------------------
    wire        cen_mux  = tb_sel ? tb_cen  : core_cen;
    wire        wen_mux  = tb_sel ? tb_wen  : 1'b0;
    wire [WORD_WIDTH_TW-1:0]  addr_mux = tb_sel ? tb_addr : core_addr;
    wire [DATA_WIDTH-1:0] din_mux  = tb_sel ? tb_din  : {(DATA_WIDTH){1'b0}};

// size matching
    wire [SRAM_WORD_WIDTH-1:0] sram_addr ={{(SRAM_WORD_WIDTH-WORD_WIDTH_TW){1'b0}}, addr_mux};
    wire [SRAM_DATA_WIDTH-1:0] sram_din ={{(SRAM_DATA_WIDTH-DATA_WIDTH){1'b0}}, din_mux};
    wire [SRAM_DATA_WIDTH-1:0] sram_dout;
    assign dout = sram_dout[DATA_WIDTH-1:0];
    // --------------------------------------------------------------------
    // Instantiate sram_wrapper
    //----------------------------------------------------------------------
    sram_wrapper u_sram(
        .clk  (clk),
        .cen  (cen_mux),
        .wen  (wen_mux),
        .addr (sram_addr),
        .din  (sram_din),
        .dout (sram_dout)
    );

endmodule

