/////////////////////////////////////////////////////////////
// Created by: Synopsys Design Compiler(R)
// Version   : U-2022.12-SP7
// Date      : Thu Dec 12 13:02:47 2024
/////////////////////////////////////////////////////////////


module dut ( clk, rstn, reset, start, sram_dout, counter_out ,VDD,VSS);
inout VDD, VSS;
  output [7:0] sram_dout;
  output [7:0] counter_out;
  input clk, rstn, reset, start;
  wire   sram_cen, sram_gwen;
  wire   [12:0] sram_addr;

  down_counter down_counter_inst ( .clk(clk), .rstn(rstn), .start(start), 
        .reset(reset), .counter_out(counter_out) , .VDD(VDD), .VSS(VSS) );
  sram_controller sram_controller_inst ( .clk(clk), .rstn(rstn), .counter_out(
        counter_out), .sram_cen(sram_cen), .sram_gwen(sram_gwen), .sram_addr(
        sram_addr) , .VDD(VDD), .VSS(VSS) );
  sram_wrapper sram_wrapper_inst ( .clk(clk), .cen(sram_cen), .gwen(sram_gwen), 
        .addr(sram_addr), .din(counter_out), .dout(sram_dout) , .VDD(VDD), .VSS(VSS) );
endmodule

