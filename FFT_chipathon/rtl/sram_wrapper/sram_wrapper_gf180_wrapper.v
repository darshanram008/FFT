`timescale 1ns / 1ps

module sram_wrapper_gf180_wrapper (

    input        clk,
    input        cen,   // 1 = access enabled, 0 = idle (active-HIGH to user)
    input        wen,   // 1 = write, 0 = read (active-HIGH to user)
    input  [6:0] addr,
    input  [7:0] din,
    input        VDD,
    input        VSS,
    output [7:0] dout
);

    // --------------------------------------------------------------------
    // Convert active-HIGH user signals to active-LOW sram00 signals
    // --------------------------------------------------------------------
    wire       CEN_n = ~cen;  // active-LOW chip-enable
    wire       GWEN_n = ~wen;  // active-LOW global-write-enable
    wire [7:0] WEN_n = 8'b00000000;  // all 4 bytes enabled for writes;
    // GWEN_n gates whether write actually happens


    //  size mapping

    // --------------------------------------------------------------------
    // Instantiate sram00
    // --------------------------------------------------------------------
    gf180mcu_fd_ip_sram__sram128x8m8wm1(
        .CLK(clk),
        .CEN(CEN_n),
        .GWEN(GWEN_n),
        .WEN(WEN_n),
        .A(addr),
        .D(din),
        .Q(dout),
        .VDD(VDD),
        .VSS(VSS)
    );

endmodule
