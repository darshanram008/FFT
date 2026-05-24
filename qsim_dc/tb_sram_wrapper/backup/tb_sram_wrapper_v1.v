`timescale 1ns/1ps
`define HALF_CLK_CYCLE #5

module testbench();

    reg clk;
    reg cen;
    reg gwen;
    reg [3:0] wen;
    reg [9:0] addr;
    reg [31:0] din;
    reg [2:0] ema;
    reg retn;
    wire [31:0] dout;

    sram_wrapper sram_wrapper_inst (
        .clk(clk),
        .cen(cen),
        .gwen(gwen),
        .wen(wen),
        .addr(addr),
        .din(din),
        .ema(ema),
        .retn(retn), 
        .dout(dout)    
    );

    always begin
        `HALF_CLK_CYCLE clk = ~clk;
    end

    initial begin
        clk = 1'b0;
        cen = 1'b1;
        gwen = 1'b1;
        wen = 4'b1111;
        addr = 10'b0;
        din = 32'b0;
        ema = 3'b0;
        retn = 1'b1;
       
        // Write
        @(posedge clk);
        cen = 1'b0;
        gwen = 1'b0;
        wen = 4'b0000;
        repeat(255) begin
            @(posedge clk);
            addr = addr + 1'b1;
            din = din + 1'b1;
        end 
       
        // Read
        @(posedge clk);
        cen = 1'b0;
        gwen = 1'b1;
        addr = 10'b0;
        repeat(255) begin
            @(posedge clk);
            addr = addr + 1'b1;
        end
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        $finish;
        
    end

endmodule
