//==============================================================================
// fft_address_gen.v
//
// Pure combinational address generator for the 1024-point radix-2 DIT FFT.
//
// For a given (stage, group, bfly), produces:
//   x0_addr : data-SRAM address of the upper butterfly operand
//   x1_addr : data-SRAM address of the lower butterfly operand
//   w_addr  : twiddle-SRAM address (0..511)
//
// Radix-2 DIT indexing (N=1024, bit-reversed input, natural-order output):
//   stage       s ∈ {0..9}
//   distance    d = 2^s          (1..512)
//   group_size  G = 2*d          (2..1024)
//   num_groups  = N/G            (512..1)
//   group       g ∈ {0..num_groups-1}
//   bfly        b ∈ {0..d-1}
//
//   x0_addr = g * G + b
//   x1_addr = g * G + b + d
//   w_addr  = b * (N / G) = b << (9 - s)
//
// Also produces a 10-bit bit-reverse of linear_addr (used at LOAD time so the
// testbench can write natural-order samples while they land in the data SRAM
// at bit-reversed indices).
//==============================================================================
`timescale 1ns/1ps

module fft_address_gen (
    input      [3:0]   stage,         // 0..9
    input      [8:0]   group,         // 0..511
    input      [8:0]   bfly,          // 0..511

    input      [9:0]   linear_addr,   // 0..1023  (for bit-reverse)

    output     [9:0]   x0_addr,
    output     [9:0]   x1_addr,
    output     [8:0]   w_addr,
    output     [9:0]   bitrev_addr
);

    // distance = 1 << stage  (1..512, needs 10 bits)
    wire [9:0] distance = 10'd1 << stage;

    // group_base = group * 2^(stage+1)
    // Extend group to 10 bits before shifting so the shift result stays in 10 bits
    wire [9:0] group_base = {1'b0, group} << (stage + 4'd1);

    assign x0_addr = group_base + {1'b0, bfly};
    assign x1_addr = group_base + {1'b0, bfly} + distance;

    // Twiddle index: bfly << (9 - stage). Result fits in 9 bits (0..511).
    wire [3:0] tw_shift = 4'd9 - stage;
    assign w_addr = bfly << tw_shift;

    // 10-bit bit-reverse of linear_addr (MSB <-> LSB)
    assign bitrev_addr = { linear_addr[0], linear_addr[1], linear_addr[2],
                           linear_addr[3], linear_addr[4], linear_addr[5],
                           linear_addr[6], linear_addr[7], linear_addr[8],
                           linear_addr[9] };

endmodule

