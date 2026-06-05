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

module fft_address_gen #(
    parameter FFT_POINT = 512,
    parameter STAGES = $clog2(FFT_POINT),
    parameter STAGE_WIDTH = $clog2(STAGES),
    parameter HALF_WIDTH = $clog2(FFT_POINT/2),
    parameter FULL_WIDTH = $clog2(FFT_POINT)
    
    )(
   
    input      [STAGE_WIDTH-1:0]   stage,         // 0..9
    input      [HALF_WIDTH-1:0]   group,         // 0..511
    input      [HALF_WIDTH-1:0]   bfly,          // 0..511

    input      [FULL_WIDTH-1:0]   linear_addr,   // 0..1023  (for bit-reverse)

    output     [FULL_WIDTH-1:0]   x0_addr,
    output     [FULL_WIDTH-1:0]   x1_addr,
    output     [HALF_WIDTH-1:0]   w_addr,
    output     [FULL_WIDTH-1:0]   bitrev_addr
);
    

    // distance = 1 << stage  (1..512, needs 10 bits)
    wire [FULL_WIDTH-1:0] distance =  {{(FULL_WIDTH-1){1'b0}},1'd1} << stage; //can do 1

    // group_base = group * 2^(stage+1)
    // Extend group to 10 bits before shifting so the shift result stays in 10 bits
    wire [FULL_WIDTH-1:0] group_base =  {{(FULL_WIDTH-HALF_WIDTH){1'b0}}, group} << (stage + 1);

    assign x0_addr = group_base + {{(FULL_WIDTH-HALF_WIDTH){1'b0}}, bfly};
    assign x1_addr = x0_addr + distance;

    // Twiddle index: bfly << (9 - stage). Result fits in 9 bits (0..511).
    wire [STAGE_WIDTH-1:0] tw_shift = (STAGES-1) - stage;
    assign w_addr = bfly << tw_shift;

    // 10-bit bit-reverse of linear_addr (MSB <-> LSB)
    genvar i;
    generate
        for (i = 0; i < FULL_WIDTH; i = i + 1) begin : BITREV
            assign bitrev_addr[i] = linear_addr[FULL_WIDTH-1-i];
        end
    endgenerate

endmodule

