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

module fft_twiddle_sram (
    input              clk,

    // Mux select: 1 = testbench, 0 = FFT core
    input              tb_sel,

    // Testbench port
    input              tb_cen,
    input              tb_wen,
    input      [8:0]   tb_addr,
    input      [31:0]  tb_din,

    // FFT-core port (read-only in practice, but we expose wen for symmetry)
    input              core_cen,
    input      [8:0]   core_addr,

    // Shared data-out (registered one cycle after address)
    output     [31:0]  dout
);

    // --------------------------------------------------------------------
    // Mux the two ports
    // --------------------------------------------------------------------
    wire        cen_mux  = tb_sel ? tb_cen  : core_cen;
    wire        wen_mux  = tb_sel ? tb_wen  : 1'b0;   // core never writes twiddles
    wire [8:0]  addr_mux = tb_sel ? tb_addr : core_addr;
    wire [31:0] din_mux  = tb_sel ? tb_din  : 32'd0;

    // Zero-extend 9-bit logical address to 13-bit physical SRAM address
    wire [9:0] sram_addr = {1'b0, addr_mux};

    // --------------------------------------------------------------------
    // Instantiate sram_wrapper
    // --------------------------------------------------------------------
    sram_wrapper u_sram (
        .clk  (clk),
        .cen  (cen_mux),
        .wen  (wen_mux),
        .addr (sram_addr),
        .din  (din_mux),
        .dout (dout)
    );

endmodule

