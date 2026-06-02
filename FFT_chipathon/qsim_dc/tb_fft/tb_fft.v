`timescale 1ns/1ps

module testbench;

    // --------------------------------------------------------------------
    // Clock / reset
    // --------------------------------------------------------------------
    reg clk;
    reg rstn;
    always #5 clk = ~clk;      // 100 MHz

    // --------------------------------------------------------------------
    // DUT ports
    // --------------------------------------------------------------------
    reg         start;
    wire        busy;
    wire        done;

    reg         tb_data_cen;
    reg         tb_data_wen;
    reg  [9:0]  tb_data_addr;
    reg  [31:0] tb_data_din;
    wire [31:0] tb_data_dout;

    reg         tb_tw_cen;
    reg         tb_tw_wen;
    reg  [8:0]  tb_tw_addr;
    reg  [31:0] tb_tw_din;
    wire [31:0] tb_tw_dout;

    reg  [9:0]  tb_linear_addr;
    wire [9:0]  tb_bitrev_addr;

    fft_top fft_top_inst (
        .clk             (clk),
        .rstn            (rstn),
        .start           (start),
        .busy            (busy),
        .done            (done),

        .tb_data_cen     (tb_data_cen),
        .tb_data_wen     (tb_data_wen),
        .tb_data_addr    (tb_data_addr),
        .tb_data_din     (tb_data_din),
        .tb_data_dout    (tb_data_dout),

        .tb_tw_cen       (tb_tw_cen),
        .tb_tw_wen       (tb_tw_wen),
        .tb_tw_addr      (tb_tw_addr),
        .tb_tw_din       (tb_tw_din),
        .tb_tw_dout      (tb_tw_dout),

        .tb_linear_addr  (tb_linear_addr),
        .tb_bitrev_addr  (tb_bitrev_addr)
    );

    // --------------------------------------------------------------------
    // Input / twiddle data buffers
    // --------------------------------------------------------------------
    reg [15:0] input_mem   [0:10239];  // Q1.15 real samples
    reg [31:0] twiddle_mem [0:511];    // Q1.15 complex twiddles

    // Per-batch output buffers
    reg [15:0] out_re [0:1023];
    reg [15:0] out_im [0:1023];

    integer batch;
    integer i;
    integer fd;

    // --------------------------------------------------------------------
    // Utility: 10-bit bit-reverse (redundant with DUT, used for load)
    // --------------------------------------------------------------------
    function [9:0] bitrev10;
        input [9:0] a;
        begin
            bitrev10 = { a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8], a[9] };
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
    function [15:0] to_q9_7;
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
    endfunction

    // --------------------------------------------------------------------
    // Main test sequence
    // --------------------------------------------------------------------
    initial begin
        // $dumpfile("tb_fft.vcd"); $dumpvars(0, tb_fft);   // optional waves
	   $dumpfile("tb_fft.vcd");
        $dumpvars(0, testbench.fft_top_inst);

        // Init
        clk          = 1'b0;
        rstn         = 1'b0;
        start        = 1'b0;
        tb_data_cen  = 1'b0;
        tb_data_wen  = 1'b0;
        tb_data_addr = 10'd0;
        tb_data_din  = 32'd0;
        tb_tw_cen    = 1'b0;
        tb_tw_wen    = 1'b0;
        tb_tw_addr   = 9'd0;
        tb_tw_din    = 32'd0;
        tb_linear_addr = 10'd0;

        // Read input and twiddle hex files
        $readmemh("input.hex",   input_mem);
        $readmemh("twiddle.hex", twiddle_mem);
        $display("[TB] input.hex and twiddle.hex loaded");

        // Release reset
        repeat (4) @(posedge clk);
        rstn = 1'b1;
        @(posedge clk);
        @(posedge clk);

        // ----------------------------------------------------------------
        // LOAD TWIDDLES  (done once; they stay resident for all batches)
        // ----------------------------------------------------------------
        $display("[TB] Loading 512 twiddle factors...");
        for (i = 0; i < 512; i = i + 1) begin
            @(negedge clk);
            tb_tw_cen  = 1'b1;
            tb_tw_wen  = 1'b1;
            tb_tw_addr = i[8:0];
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
            for (i = 0; i < 1024; i = i + 1) begin
                @(negedge clk);
                tb_data_cen  = 1'b1;
                tb_data_wen  = 1'b1;
                tb_data_addr = bitrev10(i[9:0]);
                tb_data_din  = { input_mem[batch*1024 + i], 16'h0000 };
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
            tb_data_addr = 10'd0;
            // Issue addresses 1..1023 while capturing Q[i-1]
            for (i = 1; i < 1024; i = i + 1) begin
                @(negedge clk);
                tb_data_addr = i[9:0];
                // Previous cycle's Q (from address i-1) is now on tb_data_dout
                out_re[i-1] = tb_data_dout[31:16];
                out_im[i-1] = tb_data_dout[15:0];
            end
            // One more cycle to capture Q for address 1023
            @(negedge clk);
            out_re[1023] = tb_data_dout[31:16];
            out_im[1023] = tb_data_dout[15:0];

            tb_data_cen = 1'b0;

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

            for (i = 0; i < 1024; i = i + 1) begin
                // 16-bit Q9.7 magnitude, one per line, 4 hex digits
                $fwrite(fd, "%04h\n", to_q9_7($signed(out_re[i]), $signed(out_im[i])));
            end
            $fclose(fd);
            $display("[TB] Batch %0d output written.", batch);
        end

        $display("[TB] All 10 batches processed.  10 output files generated.");
        #100;
	$dumpall;
        $dumpflush;
        $finish;
    end

    // Safety: simulation timeout
    initial begin
        #50000000;  // 50 ms of sim time
        $display("[TB] TIMEOUT");
        $finish;
    end

endmodule
