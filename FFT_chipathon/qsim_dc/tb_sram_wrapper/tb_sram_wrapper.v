`timescale 1ps/1ps

module testbench();

    parameter DW = 8;
    parameter AW = 9;

    reg clk;
    reg cen;
    reg gwen;
    reg [AW-1:0] addr;
    reg [DW-1:0] din;
    wire [DW-1:0] dout;

    sram_wrapper sram_wrapper_inst (
        .clk(clk),
        .cen(cen),
        .gwen(gwen),
        .addr(addr),
        .din(din),
        .dout(dout)
    );

    // 1.4 ns clock period
    always #700 clk = ~clk;

    initial begin
        $dumpfile("./sram_wrapper.vcd");
        $dumpvars(0, testbench.sram_wrapper_inst);
    end

    initial begin
        clk  = 0;
        cen  = 1;
        gwen = 1;
        addr = 0;
        din  = 0;

        
        // Move away from clock edge
   
        @(negedge clk); #50;

        
        // WRITE PHASE
        
        cen  = 0;
        gwen = 0;
        addr = 0;
        din  = 0;

        repeat (256) begin
            @(negedge clk); #50;
            addr = addr + 1;
            din  = din + 1;
        end

       
        // Idle before read
      
        @(negedge clk); #50;
        cen  = 1;
        gwen = 1;

        @(negedge clk); #500;

        
        // READ PHASE
        
        cen  = 0;
        gwen = 1;
        addr = 0;

        repeat (256) begin
            @(negedge clk); #50;
            addr = addr + 1;
        end

        // finish simulation
        @(posedge clk);
        @(posedge clk);

        $dumpall;
        $dumpflush;
        $finish;
    end

endmodule
