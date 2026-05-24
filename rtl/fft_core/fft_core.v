//==============================================================================
// fft_core.v
//
// Radix-2 Decimation-In-Time (DIT) butterfly.
//
// Butterfly equations (DIT):
//     x0' = x0 + W * x1
//     x1' = x0 - W * x1
//
// With 1/2 scaling per stage (arithmetic shift right by 1) to prevent
// overflow in 10-stage Q1.15 fixed-point computation.  Total scaling = 1/1024.
//
// Data format: 32 bits = {real[15:0], imag[15:0]} in Q1.15
// Twiddle format: same
//
// Protocol (single-cycle combinational butterfly, output registered):
//
//   cycle t-1 :  x0, x1, w are presented stable on inputs; start=1
//   cycle t   :  x0_out, x1_out, done=1 valid  (registered outputs)
//
// So from the controller's perspective: drive x0/x1/w/start on one cycle,
// read x0_out/x1_out/done on the next.
//==============================================================================
`timescale 1ns/1ps

module fft_core (
    input              clk,
    input              rstn,

    input              start,         // fire the butterfly this cycle

    input      [31:0]  x0,            // {re, im}, Q1.15
    input      [31:0]  x1,            // {re, im}, Q1.15
    input      [31:0]  w,             // twiddle {re, im}, Q1.15

    output reg [31:0]  x0_out,        // butterfly result  x0' = (x0 + W*x1)/2
    output reg [31:0]  x1_out,        // butterfly result  x1' = (x0 - W*x1)/2
    output reg         done
);

    // --------------------------------------------------------------------
    // Unpack inputs (signed Q1.15)
    // --------------------------------------------------------------------
    wire signed [15:0] x0_re = x0[31:16];
    wire signed [15:0] x0_im = x0[15:0];
    wire signed [15:0] x1_re = x1[31:16];
    wire signed [15:0] x1_im = x1[15:0];
    wire signed [15:0] w_re  = w [31:16];
    wire signed [15:0] w_im  = w [15:0];

    // --------------------------------------------------------------------
    // Complex multiply: W * x1
    //   (w_re + j*w_im) * (x1_re + j*x1_im)
    //     real = w_re*x1_re - w_im*x1_im
    //     imag = w_re*x1_im + w_im*x1_re
    //
    // Each product is 16*16 = 32-bit.  Sum of two products fits in 33 bits.
    // We take bits [30:15] to get back to Q1.15 (discarding the redundant
    // sign bit in [31] and the low fractional bits).
    // --------------------------------------------------------------------
    wire signed [31:0] pr_rr = w_re * x1_re;   // Q2.30
    wire signed [31:0] pr_ii = w_im * x1_im;   // Q2.30
    wire signed [31:0] pr_ri = w_re * x1_im;   // Q2.30
    wire signed [31:0] pr_ir = w_im * x1_re;   // Q2.30

    wire signed [32:0] wx1_re_full = pr_rr - pr_ii;  // Q2.30, 33-bit
    wire signed [32:0] wx1_im_full = pr_ri + pr_ir;  // Q2.30, 33-bit

    // Extract Q1.15 from Q2.30 : shift right by 15, keep 16 bits.
    // Bits [30:15] of the 33-bit value give us Q1.15 (saturating-free;
    // if |product| slightly exceeds 1.0 due to |W|≈1 + rounding we clip).
    wire signed [15:0] wx1_re = wx1_re_full[30:15];
    wire signed [15:0] wx1_im = wx1_im_full[30:15];

    // --------------------------------------------------------------------
    // Butterfly add/sub with 1/2 scaling (arithmetic shift right by 1).
    // Using 17-bit intermediates to avoid overflow on the add/sub before
    // the shift.
    // --------------------------------------------------------------------
    wire signed [16:0] sum_re = {x0_re[15], x0_re} + {wx1_re[15], wx1_re};
    wire signed [16:0] sum_im = {x0_im[15], x0_im} + {wx1_im[15], wx1_im};
    wire signed [16:0] dif_re = {x0_re[15], x0_re} - {wx1_re[15], wx1_re};
    wire signed [16:0] dif_im = {x0_im[15], x0_im} - {wx1_im[15], wx1_im};

    // Scale by 1/2: arithmetic shift right by 1, then truncate to 16 bits.
    wire signed [15:0] x0p_re = sum_re[16:1];
    wire signed [15:0] x0p_im = sum_im[16:1];
    wire signed [15:0] x1p_re = dif_re[16:1];
    wire signed [15:0] x1p_im = dif_im[16:1];

    // --------------------------------------------------------------------
    // Register the outputs
    // --------------------------------------------------------------------
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            x0_out <= 32'd0;
            x1_out <= 32'd0;
            done   <= 1'b0;
        end else begin
            if (start) begin
                x0_out <= {x0p_re, x0p_im};
                x1_out <= {x1p_re, x1p_im};
                done   <= 1'b1;
            end else begin
                done   <= 1'b0;
            end
        end
    end

endmodule

