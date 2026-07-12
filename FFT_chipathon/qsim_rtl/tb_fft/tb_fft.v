//==============================================================================
// tb_fft.v
//
// Testbench for the 1024-point FFT processor.
//
// Flow:
//   1. Reset.
//   2. Load 512 twiddle factors from "twiddle.hex" into the twiddle SRAM.
//   3. For each of 10 batches (10240 samples total):
//        a. Load 1024 input samples from "input.hex" into the data SRAM,
//           writing them at BIT-REVERSED addresses (DIT pre-conditioning).
//        b. Pulse 'start'.
//        c. Wait for 'done'.
//        d. Read 1024 complex outputs from the data SRAM in natural order,
//           compute magnitude in Q9.7 (16-bit unsigned-ish / 9 integer + 7
//           fraction bits), and write to "fft_out_<batch>.hex".
//
// Notes:
//   - Inputs are real-valued Q1.15 16-bit numbers. We pack them as
//     { sample_q15, 16'h0000 }  => 32-bit complex with imag=0.
//   - Hardware scales by 1/2 per stage (1/1024 total). We multiply the
//     magnitude by 1024 in software before quantizing to Q9.7 so that the
//     written magnitudes correspond to the unscaled FFT result.
//   - Magnitude is computed as sqrt(re^2 + im^2) in real arithmetic. If a
//     pure-hardware magnitude is needed the $sqrt in simulation is an
//     acceptable golden model for the mid-report.
////==============================================================================
//to change to 512 point change the FFT point, and then change the twiddle inputs and then change the SRAM dir

`timescale 1ns / 1ps

module testbench;
    parameter DATA_WIDTH = 16;
    parameter FFT_POINT = 128;
    localparam NUMBER_OF_STAGES = $clog2(FFT_POINT);
    localparam WORD_WIDTH = $clog2(FFT_POINT);
    localparam NUMBER_OF_TW = FFT_POINT / 2;
    localparam WORD_WIDTH_TW = $clog2(NUMBER_OF_TW);
    //localparam STAGES = $clog2(FFT_POINT);
    //localparam STAGE_WIDTH = $clog2(STAGES);
    //localparam HALF_WIDTH = $clog2(FFT_POINT/2);
    localparam FULL_WIDTH = $clog2(FFT_POINT);
    localparam SRAM_WORDS = 512;
    localparam SRAM_DATA_WIDTH = 32;
    localparam SRAM_WORDS = 512;
    localparam SRAM_WORD_WIDTH = $clog2(SRAM_WORDS);
    // localparam [WORD_WIDTH:0] DEPTH_CONST = FFT_POINT;
    // --------------------------------------------------------------------
    // Clock / reset
    // --------------------------------------------------------------------
    reg clk;
    reg rstn;
    always #5 clk = ~clk;  // 100 MHz

    // --------------------------------------------------------------------
    // DUT ports
    // --------------------------------------------------------------------
    reg                         start;
    wire                        busy;
    wire                        done;

    reg                         tb_data_cen;
    reg                         tb_data_wen;
    reg  [      WORD_WIDTH-1:0] tb_data_addr;
    reg  [      DATA_WIDTH-1:0] tb_data_din;
    wire [      DATA_WIDTH-1:0] tb_data_dout;

    reg                         tb_tw_cen;
    reg                         tb_tw_wen;
    reg  [   WORD_WIDTH_TW-1:0] tb_tw_addr;
    reg  [      DATA_WIDTH-1:0] tb_tw_din;
    wire [      DATA_WIDTH-1:0] tb_tw_dout;

    reg  [NUMBER_OF_STAGES-1:0] tb_linear_addr;
    wire [NUMBER_OF_STAGES-1:0] tb_bitrev_addr;
    // FFT <-> SRAM connection wires
    wire [ SRAM_DATA_WIDTH-1:0] sram_dout;
    wire                        data_sram_cen;
    wire                        data_sram_wen;
    wire [ SRAM_WORD_WIDTH-1:0] data_sram_addr;
    wire [ SRAM_DATA_WIDTH-1:0] data_sram_din;


    fft_top #(
        .DATA_WIDTH(DATA_WIDTH),
        .FFT_POINT (FFT_POINT)
    ) fft_top_inst (
        .clk  (clk),
        .rstn (rstn),
        .start(start),
        .busy (busy),
        .done (done),

        .tb_data_cen (tb_data_cen),
        .tb_data_wen (tb_data_wen),
        .tb_data_addr(tb_data_addr),
        .tb_data_din (tb_data_din),
        .tb_data_dout(tb_data_dout),

        .tb_tw_cen (tb_tw_cen),
        .tb_tw_wen (tb_tw_wen),
        .tb_tw_addr(tb_tw_addr),
        .tb_tw_din (tb_tw_din),
        .tb_tw_dout(tb_tw_dout),

        .tb_linear_addr(tb_linear_addr),
        .tb_bitrev_addr(tb_bitrev_addr),
        .sram_dout     (sram_dout),
        .data_sram_cen (data_sram_cen),
        .data_sram_wen (data_sram_wen),
        .data_sram_addr(data_sram_addr),
        .data_sram_din (data_sram_din)

    );

    sram_wrapper #(
        .SRAM_WORDS(SRAM_WORDS),
        .SRAM_DATA_WIDTH(SRAM_DATA_WIDTH)

    ) sram_wrapper_inst (

        .clk (clk),
        .cen (data_sram_cen),
        .wen (data_sram_wen),
        .addr(data_sram_addr),
        .din (data_sram_din),
        .dout(sram_dout)


    );

    // --------------------------------------------------------------------
    // Input / twiddle data buffers
    // --------------------------------------------------------------------
    // reg [15:0] input_mem   [0:1023];  // Q1.15 real samples
    //reg [31:0] twiddle_mem [0:511];    // Q1.15 complex twiddles
    reg [DATA_WIDTH-1:0] input_mem   [0:10239];  // Q1.15 real samples
    reg [DATA_WIDTH-1:0] twiddle_mem [0:NUMBER_OF_TW-1];
    // Per-batch output buffers
    //reg [15:0] out_re [0:1023];
    //reg [15:0] out_im [0:1023];
    reg [DATA_WIDTH/2-1:0] out_re [0:FFT_POINT-1];
    reg [DATA_WIDTH/2-1:0] out_im [0:FFT_POINT-1];
    integer batch;
    integer i;
    integer fd;

    // --------------------------------------------------------------------
    // Utility: 10-bit bit-reverse (redundant with DUT, used for load)
    // --------------------------------------------------------------------

    function [NUMBER_OF_STAGES-1:0] bitrev10;
        input [NUMBER_OF_STAGES-1:0] a;
        integer k;
        begin

            for (k = 0; k < NUMBER_OF_STAGES; k = k + 1) begin : BITREV
                bitrev10[k] = a[NUMBER_OF_STAGES-1-k];
            end

        end
    endfunction

    // --------------------------------------------------------------------
    // Utility: compute |X[k]| in Q9.7 from (re, im) stored as 16-bit Q1.15,
    // undoing the 1/1024 per-FFT scaling.
    //
    // Since this is simulation only, we use $itor and real math.
    // Q9.7 : 16 bits, 9 integer, 7 fraction. We clip to [0, 65535/128 ≈ 511.99].
    // We output SIGNED 16-bit Q9.7 (but magnitude is always non-negative, so
    // the sign bit will always be 0).
    // --------------------------------------------------------------------
    /* function [15:0] to_q9_7;
        input signed [15:0] re;
        input signed [15:0] im;
        real re_f, im_f, mag_f;
        integer q;
        begin
            re_f  = $itor(re) / 32768.0;      // back to float Q1.15
            im_f  = $itor(im) / 32768.0;
            // Magnitude, undoing the 1/1024 hardware scaling
            mag_f = 1024.0 * $sqrt(re_f*re_f + im_f*im_f);
            // Quantize to Q9.7: multiply by 128, round
            q = $rtoi(mag_f * 128.0 + 0.5);
            if (q < 0)       q = 0;
            if (q > 16'hFFFF) q = 16'hFFFF;
            to_q9_7 = q[15:0];
        end
    endfunction */
    function [15:0] to_q9_7;
        input signed [DATA_WIDTH/2-1:0] re;
        input signed [DATA_WIDTH/2-1:0] im;
        real re_f, im_f, mag_f;
        integer q;
        begin
            re_f = $itor(re) / 32768.0;
            im_f = $itor(im) / 32768.0;
            mag_f = $itor(FFT_POINT) *
                $sqrt(re_f * re_f + im_f * im_f);  // FFT_POINT not hardcoded 1024
            q = $rtoi(mag_f * 128.0 + 0.5);
            if (q < 0) q = 0;
            if (q > 65535) q = 65535;
            to_q9_7 = q[15:0];
        end
    endfunction

    // --------------------------------------------------------------------
    // Main test sequence
    // --------------------------------------------------------------------
    initial begin
        // $dumpfile("tb_fft.vcd"); $dumpvars(0, tb_fft);   // optional waves

        // Init
        clk            = 1'b0;
        rstn           = 1'b0;
        start          = 1'b0;
        tb_data_cen    = 1'b0;
        tb_data_wen    = 1'b0;
        tb_data_addr   = 0;  //10'd0;
        tb_data_din    = 0;  //32'd0;
        tb_tw_cen      = 1'b0;
        tb_tw_wen      = 1'b0;
        tb_tw_addr     = 0;  //9'd0
        tb_tw_din      = 0;  //32'd0;
        tb_linear_addr = 0;  //10'd0;

        // Read input and twiddle hex files
        $readmemh("input.hex", input_mem);
        $readmemh("twiddle128.hex", twiddle_mem);
        $display("[TB] input.hex and twiddle.hex loaded");

        // Release reset
        repeat (4) @(posedge clk);
        rstn = 1'b1;
        @(posedge clk);
        @(posedge clk);

        // ----------------------------------------------------------------
        // LOAD TWIDDLES  (done once; they stay resident for all batches)
        // ----------------------------------------------------------------
        $display("[TB] Loading %d twiddle factors...", NUMBER_OF_TW);
        for (i = 0; i < NUMBER_OF_TW; i = i + 1) begin
            @(negedge clk);
            tb_tw_cen  = 1'b1;
            tb_tw_wen  = 1'b1;
            tb_tw_addr = i[WORD_WIDTH_TW-1:0];
            tb_tw_din  = twiddle_mem[i];
        end
        @(negedge clk);
        tb_tw_cen = 1'b0;
        tb_tw_wen = 1'b0;
        $display("[TB] Twiddles loaded.");

        // ----------------------------------------------------------------
        // BATCH LOOP
        // ----------------------------------------------------------------
        for (batch = 0; batch < 10; batch = batch + 1) begin
            $display("[TB] ===== Batch %0d =====", batch);

            // ------------------------------------------------------------
            // (a) LOAD 1024 input samples into data SRAM at bit-reversed
            //     addresses.  Input is real-valued Q1.15; pack as
            //     { sample, 16'h0000 } giving imag=0.
            // ------------------------------------------------------------
            for (i = 0; i < FFT_POINT; i = i + 1) begin
                @(negedge clk);
                tb_data_cen = 1'b1;
                tb_data_wen = 1'b1;
                tb_data_addr = bitrev10(i[NUMBER_OF_STAGES-1:0])
                    ;  // removed bitrev function to store data in sram in normal order ?
                tb_data_din = {input_mem[batch*FFT_POINT+i]};
            end
            @(negedge clk);
            tb_data_cen = 1'b0;
            tb_data_wen = 1'b0;

            // ------------------------------------------------------------
            // (b) Start compute
            // ------------------------------------------------------------
            @(negedge clk);
            start = 1'b1;
            @(negedge clk);
            start = 1'b0;

            // ------------------------------------------------------------
            // (c) Wait for done
            // ------------------------------------------------------------
            wait (done == 1'b1);
            @(posedge clk);
            $display("[TB] Batch %0d compute done.", batch);

            // ------------------------------------------------------------
            // (d) DUMP 1024 outputs from the data SRAM in natural order.
            //     The SRAM is registered-Q: address A issued on cycle N
            //     produces Q on cycle N+1.  We pipeline address and capture.
            // ------------------------------------------------------------
            // Kick off the first read
            @(negedge clk);
            tb_data_cen  = 1'b1;
            tb_data_wen  = 1'b0;
            tb_data_addr = 0;
            // Issue addresses 1..1023 while capturing Q[i-1]
            for (i = 1; i < FFT_POINT; i = i + 1) begin
                @(negedge clk);
                tb_data_addr = i[WORD_WIDTH-1:0];
                // Previous cycle's Q (from address i-1) is now on tb_data_dout
                out_re[i-1]  = tb_data_dout[DATA_WIDTH-1:DATA_WIDTH/2];
                out_im[i-1]  = tb_data_dout[DATA_WIDTH/2-1:0];
            end
            // One more cycle to capture Q for address 1023
            @(negedge clk);
            out_re[FFT_POINT-1] = tb_data_dout[DATA_WIDTH-1:DATA_WIDTH/2];
            out_im[FFT_POINT-1] = tb_data_dout[DATA_WIDTH/2-1:0];
            tb_data_cen         = 1'b0;

            // ------------------------------------------------------------
            // Write output file
            // ------------------------------------------------------------
            case (batch)
                0: fd = $fopen("fft_out_0.hex", "w");
                1: fd = $fopen("fft_out_1.hex", "w");
                2: fd = $fopen("fft_out_2.hex", "w");
                3: fd = $fopen("fft_out_3.hex", "w");
                4: fd = $fopen("fft_out_4.hex", "w");
                5: fd = $fopen("fft_out_5.hex", "w");
                6: fd = $fopen("fft_out_6.hex", "w");
                7: fd = $fopen("fft_out_7.hex", "w");
                8: fd = $fopen("fft_out_8.hex", "w");
                9: fd = $fopen("fft_out_9.hex", "w");
            endcase

            if (fd == 0) begin
                $display("[TB] ERROR: could not open output file for batch %0d", batch);
                $finish;
            end

            for (i = 0; i < FFT_POINT; i = i + 1) begin
                // 16-bit Q9.7 magnitude, one per line, 4 hex digits
                $fwrite(fd, "%04h\n", $signed({out_re[i], out_im[i]}));  // remove to_q9_7
            end
            $fclose(fd);
            $display("[TB] Batch %0d output written.", batch);
        end

        $display("[TB] All 10 batches processed.  10 output files generated.");
        #100;
        $finish;
    end

    // Safety: simulation timeout
    initial begin
        #50000000;  // 50 ms of sim time
        $display("[TB] TIMEOUT");
        $finish;
    end

endmodule
