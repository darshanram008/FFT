`timescale 1ps/1ps
module DEL01(input I, output Z);
  assign Z = I;
  specify
    (I => Z) = (0:0:0, 0:0:0);
  endspecify
endmodule

module DEL005(input I, output Z);
  assign Z = I;
  specify
    (I => Z) = (0:0:0, 0:0:0);
  endspecify
endmodule

module CKBD1(input I, output Z);
  assign Z = I;
  specify
    (I => Z) = (0:0:0, 0:0:0);
  endspecify
endmodule

module CKND0(input I, output ZN);
  assign ZN = ~I;
  specify
    (I => ZN) = (0:0:0, 0:0:0);
  endspecify
endmodule

module TIEH(output Z);
  assign Z = 1'b1;
endmodule

module TIEL(output ZN);
  assign ZN = 1'b0;
endmodule
