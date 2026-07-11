//==============================================================================
// fft_top.v
//
// Top-level of the 1024-point radix-2 DIT FFT processor.
//
// Wires together:
//   - fft_controller  : master FSM
//   - fft_address_gen : butterfly & twiddle address generator
//   - fft_core        : single radix-2 butterfly
//   - fft_data_sram   : 1024-entry data SRAM (2-port muxed: tb + core)
//   - fft_twiddle_sram: 512-entry twiddle SRAM (2-port muxed: tb + core)
//
// External interface is just the testbench ports + start/busy/done.  The
// testbench drives tb_* ports for load/dump; 'start' is pulsed after
// testbench has loaded both SRAMs, and 'done' fires when compute finishes.
//
// Address-conversion helpers for the testbench:
//   - During LOAD of data samples, the testbench can use 'tb_bitrev_addr' as
//     the address to write to: pass in linear 0..1023, tb_bitrev_addr gives
//     the bit-reversed equivalent so samples land in bit-reversed slots.
//     (This is the standard DIT pre-conditioning.)
//==============================================================================
`timescale 1ns/1ps

module fft_top #(
    parameter DATA_WIDTH = 32,
    parameter FFT_POINT = 512,
    //parameter NUMBER_OF_STAGES = $clog2(FFT_POINT),
    parameter WORD_WIDTH = $clog2(FFT_POINT),
    parameter NUMBER_OF_TW = FFT_POINT/2,
    parameter WORD_WIDTH_TW = $clog2(NUMBER_OF_TW),
    parameter STAGES = $clog2(FFT_POINT),
    parameter STAGE_WIDTH = $clog2(STAGES),
    parameter HALF_WIDTH = $clog2(FFT_POINT/2),
    parameter FULL_WIDTH = $clog2(FFT_POINT),
   // parameter [WORD_WIDTH:0] DEPTH_CONST = FFT_POINT,
     parameter SRAM_DATA_WIDTH = 32
)(

    input              clk,
    input              rstn,
    // Control
    input              start,            // pulse to begin compute
    output             busy,
    output             done,

    // Testbench data-SRAM port
    input              tb_data_cen,
    input              tb_data_wen,
    input      [WORD_WIDTH-1:0]   tb_data_addr,     // linear 10-bit address
    input      [DATA_WIDTH-1:0]  tb_data_din,
    output     [SRAM_DATA_WIDTH-1:0]  tb_data_dout,

    // Testbench twiddle-SRAM port
    input              tb_tw_cen,
    input              tb_tw_wen,
    input      [WORD_WIDTH_TW-1:0]   tb_tw_addr,
    input      [DATA_WIDTH-1:0]  tb_tw_din,
    output     [DATA_WIDTH-1:0]  tb_tw_dout,

    // Bit-reverse helper (combinational): for testbench to use when loading
    input      [WORD_WIDTH-1:0]   tb_linear_addr,   // testbench-supplied linear index
    output     [WORD_WIDTH-1:0]   tb_bitrev_addr ,   // its 10-bit bit-reverse
    // from new data sram
     input [SRAM_DATA_WIDTH-1:0] sram_dout,
     output data_sram_cen,
      output data_sram_wen,
    output [WORD_WIDTH-1:0] data_sram_addr,
    output [DATA_WIDTH-1:0] data_sram_din

);



    // --------------------------------------------------------------------
    // Inter-module wires
    // --------------------------------------------------------------------
    // SRAM outputs
    wire [DATA_WIDTH-1:0] data_dout;
    wire [DATA_WIDTH-1:0] tw_dout;

    // Controller → SRAM (core-side ports)
    wire        core_data_cen;
    wire        core_data_wen;
    wire [WORD_WIDTH-1:0]  core_data_addr;
    wire [DATA_WIDTH-1:0] core_data_din;

    wire        core_tw_cen;
    wire [WORD_WIDTH_TW-1:0]  core_tw_addr;

    // SRAM mux select (shared: testbench grabs both)
    wire        sram_tb_sel;

    // Controller <-> address-gen
    wire [STAGE_WIDTH-1:0]  stage;
    wire [HALF_WIDTH-1:0]  group;
    wire [HALF_WIDTH-1:0]  bfly;
    wire [FULL_WIDTH-1:0]  x0_addr;
    wire [FULL_WIDTH-1:0]  x1_addr;
    wire [HALF_WIDTH-1:0]  w_addr;

    // Controller <-> core
    wire        core_start;
    wire [DATA_WIDTH-1:0] core_x0, core_x1, core_w;
    wire [DATA_WIDTH-1:0] core_x0_out, core_x1_out;
    wire        core_done;

    // --------------------------------------------------------------------
    // Address generator
    // --------------------------------------------------------------------
    // During compute, linear_addr input is unused (the bitrev helper is only
    // for the testbench's tb_linear_addr lookup). We route tb_linear_addr
    // through the address_gen to produce tb_bitrev_addr.
     fft_address_gen
     `ifndef SYNTH
     #(
    .FFT_POINT(FFT_POINT)
)
`endif
u_addr(
        .stage        (stage),
        .group        (group),
        .bfly         (bfly),
        .linear_addr  (tb_linear_addr),
        .x0_addr      (x0_addr),
        .x1_addr      (x1_addr),
        .w_addr       (w_addr),
        .bitrev_addr  (tb_bitrev_addr)
    );

    // --------------------------------------------------------------------
    // Butterfly core
    // --------------------------------------------------------------------
    fft_core
    `ifndef SYNTH
     #(

    	.DATA_WIDTH(DATA_WIDTH)

)
`endif
u_core(
        .clk      (clk),
        .rstn     (rstn),
        .start    (core_start),
        .x0       (core_x0),
        .x1       (core_x1),
        .w        (core_w),
        .x0_out   (core_x0_out),
        .x1_out   (core_x1_out),
        .done     (core_done)
    );

    // --------------------------------------------------------------------
    // Controller
    // --------------------------------------------------------------------
    fft_controller
    `ifndef SYNTH
     #(

    .DATA_WIDTH(DATA_WIDTH),
    .FFT_POINT(FFT_POINT)
)
`endif
u_ctrl(
        .clk          (clk),
        .rstn         (rstn),
        .start        (start),

        .data_dout    (data_dout),
        .tw_dout      (tw_dout),

        .core_done    (core_done),
        .core_start   (core_start),
        .core_x0      (core_x0),
        .core_x1      (core_x1),
        .core_w       (core_w),
        .core_x0_out  (core_x0_out),
        .core_x1_out  (core_x1_out),

        .stage        (stage),
        .group        (group),
        .bfly         (bfly),
        .x0_addr      (x0_addr),
        .x1_addr      (x1_addr),
        .w_addr       (w_addr),

        .data_cen     (core_data_cen),
        .data_wen     (core_data_wen),
        .data_addr    (core_data_addr),
        .data_din     (core_data_din),

        .tw_cen       (core_tw_cen),
        .tw_addr      (core_tw_addr),

        .sram_tb_sel  (sram_tb_sel),

        .busy         (busy),
        .done         (done)
    );

    // --------------------------------------------------------------------
    // Data SRAM
    // --------------------------------------------------------------------
    fft_data_sram
    `ifndef SYNTH
     #(

	.FFT_POINT(FFT_POINT),
	.DATA_WIDTH(DATA_WIDTH)
)
`endif
u_data_sram(

        .tb_sel    (sram_tb_sel),

        .tb_cen    (tb_data_cen),
        .tb_wen    (tb_data_wen),
        .tb_addr   (tb_data_addr),
        .tb_din    (tb_data_din),

        .core_cen  (core_data_cen),
        .core_wen  (core_data_wen),
        .core_addr (core_data_addr),
        .core_din  (core_data_din),



        // new input
        .sram_dout(sram_dout),
        //new outputs
        .data_sram_dout (data_dout),
        .cen_mux(data_sram_cen),
        .wen_mux(data_sram_wen),
        .data_sram_addr(data_sram_addr),
        .data_sram_din(data_sram_din)

    );
    assign tb_data_dout = data_dout;    // testbench sees the same Q

    // --------------------------------------------------------------------
    // Twiddle SRAM
    // --------------------------------------------------------------------

    fft_twiddle_sram
    `ifndef SYNTH
    #(

	.FFT_POINT(FFT_POINT),
	.DATA_WIDTH(DATA_WIDTH)

)
`endif
u_tw_sram(
        .clk       (clk),
        .tb_sel    (sram_tb_sel),

        .tb_cen    (tb_tw_cen),
        .tb_wen    (tb_tw_wen),
        .tb_addr   (tb_tw_addr),
        .tb_din    (tb_tw_din),

        .core_cen  (core_tw_cen),
        .core_addr (core_tw_addr),

        .dout      (tw_dout)
    );
    assign tb_tw_dout = tw_dout;

endmodule

