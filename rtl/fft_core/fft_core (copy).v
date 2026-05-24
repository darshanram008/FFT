// fft_core: Radix-2 DIT butterfly unit
//
// Operands x0 and x1 are loaded from the data SRAM output (sram_out).
// The controller presents x0 address first (core_valid_x0=1 on the cycle
// SRAM Q is valid), then x1 address (core_valid_x1=1 on the cycle SRAM Q
// is valid). Then start_compute=1 fires the butterfly.
//
// Data format: Q1.15 fixed-point, packed as {real[15:0], imag[15:0]}
//   x[31:16] = real part
//   x[15:0]  = imaginary part
//
// Butterfly (Radix-2 DIT):
//   x0' = x0 + x1
//   x1' = (x0 - x1) * W   where W = twiddle factor

module fft_core (
    input              clk,
    input              rstn_core,
    input              core_valid_x0,   // latch sram_out as x0 this cycle
    input              core_valid_x1,   // latch sram_out as x1 this cycle
    input              start_compute,   // fire butterfly computation
    input  [31:0]      twiddle,         // twiddle factor {Wr[15:0], Wi[15:0]}
    input  [31:0]      sram_out,        // data from SRAM (x0 or x1 depending on cycle)
    output reg [31:0]  x0,              // butterfly output x0' (also writeback to SRAM)
    output reg [31:0]  x1,              // butterfly output x1' (also writeback to SRAM)
    output reg         butterfly_done
);

    // Unpack twiddle factor
    wire signed [15:0] Wr = twiddle[31:16];
    wire signed [15:0] Wi = twiddle[15:0];

    // Unpack current x0, x1 register contents
    wire signed [15:0] x0r = x0[31:16];
    wire signed [15:0] x0i = x0[15:0];
    wire signed [15:0] x1r = x1[31:16];
    wire signed [15:0] x1i = x1[15:0];

    // (x0 - x1) — difference before twiddle multiply
    wire signed [15:0] diff_r = x0r - x1r;
    wire signed [15:0] diff_i = x0i - x1i;

    // Complex multiply: (diff_r + j*diff_i) * (Wr + j*Wi)
    //   real = diff_r*Wr - diff_i*Wi
    //   imag = diff_r*Wi + diff_i*Wr
    // Products are 32-bit; we take [31:16] (upper 16 bits) as the Q1.15 result
    wire signed [31:0] mult_r = diff_r * Wr - diff_i * Wi;
    wire signed [31:0] mult_i = diff_r * Wi + diff_i * Wr;

    always @(posedge clk) begin
        if (!rstn_core) begin
            x0             <= 32'd0;
            x1             <= 32'd0;
            butterfly_done <= 1'b0;

        end else begin

            // Load x0 from SRAM output when controller signals valid
            if (core_valid_x0)
                x0 <= sram_out;

            // Load x1 from SRAM output when controller signals valid
            if (core_valid_x1)
                x1 <= sram_out;

            // Compute butterfly when controller fires start_compute
            if (start_compute) begin
                // x0' = x0 + x1  (sum, real and imaginary separately)
                x0 <= { (x0r + x1r), (x0i + x1i) };
                // x1' = (x0 - x1) * W  (take upper 16 bits of 32-bit product)
                x1 <= { mult_r[31:16], mult_i[31:16] };
                butterfly_done <= 1'b1;
            end else begin
                butterfly_done <= 1'b0;
            end
        end
    end

endmodule

