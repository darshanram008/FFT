//==============================================================================
// fft_data_sram.v
//
// Data SRAM for the FFT processor.
// Holds 1024 complex samples, each 32 bits = {real[15:0], imag[15:0]} in Q1.15.
//
// Also exposes a multiplexed testbench port so the testbench can load inputs
// and read outputs row-by-row (spec requirement).
//
// When tb_sel = 1 → testbench owns the SRAM (addr/din/cen/wen from tb_* ports)
// When tb_sel = 0 → FFT controller owns the SRAM (addr/din/cen/wen from core_* ports)
//
// The SRAM itself is 8192x32 (sram00), but we only use words 0..1023 for data.
// Address is still 13-bit to match sram00; upper bits are held at 0.
//==============================================================================
`timescale 1ns / 1ps

module fft_data_sram #(
    parameter FFT_POINT = 512,
    parameter WORD_WIDTH = $clog2(FFT_POINT),
    parameter DATA_WIDTH = 32,
    parameter SRAM_WORDS = 512,
    parameter SRAM_WORD_WIDTH = $clog2(SRAM_WORDS),
    parameter SRAM_DATA_WIDTH = 32

) (

    //input clk,

    // Mux select: 1 = testbench, 0 = FFT core
    input tb_sel,

    // Testbench port
    input                  tb_cen,
    input                  tb_wen,
    input [WORD_WIDTH-1:0] tb_addr,
    input [DATA_WIDTH-1:0] tb_din,

    // FFT-core port
    input                       core_cen,
    input                       core_wen,
    input [     WORD_WIDTH-1:0] core_addr,
    input [     DATA_WIDTH-1:0] core_din,
    input [SRAM_DATA_WIDTH-1:0] sram_dout,

    // Shared data-out (registered one cycle after address)
    output                  cen_mux,
    output                  wen_mux,
    output [WORD_WIDTH-1:0] data_sram_addr,
    output [DATA_WIDTH-1:0] data_sram_din,
    output [DATA_WIDTH-1:0] data_sram_dout
);

    // --------------------------------------------------------------------
    // Mux the two ports
    // --------------------------------------------------------------------
    assign cen_mux = tb_sel ? tb_cen : core_cen;
    assign wen_mux = tb_sel ? tb_wen : core_wen;
    wire [WORD_WIDTH-1:0] addr_mux = tb_sel ? tb_addr : core_addr;
    wire [DATA_WIDTH-1:0] din_mux = tb_sel ? tb_din : core_din;

    // Zero-extend 10-bit logical address to 13-bit physical SRAM address
    // wire [SRAM_DATA_WIDTH-1:0] din_wrapper = {{(SRAM_DATA_WIDTH - DATA_WIDTH){1'b0}},din_mux};

    assign data_sram_addr = {{(SRAM_WORD_WIDTH - WORD_WIDTH) {1'b0}}, addr_mux};
    assign data_sram_din  = {{(SRAM_DATA_WIDTH - DATA_WIDTH) {1'b0}}, din_mux};
    assign data_sram_dout = {{(SRAM_DATA_WIDTH - DATA_WIDTH) {1'b0}}, sram_dout};

    // // --------------------------------------------------------------------
    // // Instantiate sram_wrapper
    // // --------------------------------------------------------------------
    // sram_wrapper u_sram (
    //     .clk (clk),
    //     .cen (cen_mux),
    //     .wen (wen_mux),
    //     .addr(sram_addr),
    //     .din (sram_din),
    //     .dout(sram_dout)
    // );

endmodule

