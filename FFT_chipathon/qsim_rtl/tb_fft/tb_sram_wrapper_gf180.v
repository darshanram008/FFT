`timescale 1ns / 1ps

module tb_sram_wrapper_gf180;

    reg        clk;
    reg        cen;  // active-HIGH to user
    reg        wen;  // active-HIGH to user (1 = write)
    reg  [6:0] addr;
    reg  [7:0] din;
    wire [7:0] dout;

    // Power pins (tie high/low)
    reg        VDD = 1'b1;
    reg        VSS = 1'b0;

    // Instantiate DUT
    sram_wrapper_gf180_wrapper dut (
        .clk (clk),
        .cen (cen),
        .wen (wen),
        .addr(addr),
        .din (din),
        .VDD (VDD),
        .VSS (VSS),
        .dout(dout)
    );

    // Clock generation
    always #5 clk = ~clk;  // 100 MHz clock

    integer i;

    initial begin
        clk  = 0;
        cen  = 0;  // idle
        wen  = 0;  // read mode
        addr = 0;
        din  = 0;

        #20;

        // ---------------------------------------------------------
        // WRITE PHASE: write 128 bytes (0..127)
        // ---------------------------------------------------------
        $display("---- WRITE PHASE ----");

        cen = 1;  // enable memory

        for (i = 0; i < 128; i = i + 1) begin
            @(posedge clk);
            wen  = 1;  // write mode
            addr = i[6:0];
            din  = i[7:0];
        end

        @(posedge clk);
        wen = 0;  // switch to read mode

        // ---------------------------------------------------------
        // READ PHASE: read back all 128 bytes
        // ---------------------------------------------------------
        $display("---- READ PHASE ----");

        for (i = 0; i < 128; i = i + 1) begin
            @(posedge clk);
            addr = i[6:0];

            @(posedge clk);  // wait 1 cycle for registered output

            if (dout !== i[7:0]) begin
                $display("ERROR: addr %0d expected %0d got %0d", i, i[7:0], dout);
            end else begin
                $display("PASS: addr %0d = %0d", i, dout);
            end
        end

        $display("---- TEST COMPLETE ----");
        $finish;
    end

endmodule
