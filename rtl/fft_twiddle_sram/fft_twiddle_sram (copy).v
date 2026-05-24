// fft_twiddle_sram: 512-word x 32-bit twiddle ROM using sram00.
//
// sram00 MUX=4 physical layout (from readWrite task in sram00.v):
//   mux_address = A[1:0]                (column 0-3 within 512-bit row)
//   row_address = A[8:2]                (row 0-127, total 128 rows)
//   Q[k] reads from: mem[row][4*k + mux]  (after right-shift by mux)
//
// To preload twiddle word W at logical address A:
//   row = A >> 2    (= A / 4, selects one of 128 physical rows)
//   mux = A & 2'b11 (= A % 4, selects mux column 0,1,2,3)
//   bit k of W → mem[row][4*k + mux]
//
// twiddle.hex: exactly 512 lines, each an 8-digit hex 32-bit word.
// Words are stored as {real[15:0], imag[15:0]} in Q1.15 format.

module fft_twiddle_sram(
    input             clk,
    input             twiddle_sram_c_en, // active-low chip enable
    input             twiddle_sram_w_en, // 1=write, 0=read (ROM: always 0)
    input  [8:0]      twiddle_address,   // 9-bit word address, 0-511
    input  [31:0]     twiddle_in,        // unused for ROM (tied to 32'd0 at top)
    output [31:0]     twiddle_out
);
    wire gwen = ~twiddle_sram_w_en;

    // Temporary array for hex file loading
    reg [31:0] twiddle_init [0:511];

    integer addr_idx, bit_idx, row_idx, mux_idx;

    initial begin
        $readmemh("twiddle.hex", twiddle_init);

        // Clear all 128 physical rows used by the twiddle table
        // (128 rows x 4 words/row = 512 words, exactly matching our needs)
        for (row_idx = 0; row_idx < 128; row_idx = row_idx + 1)
            sram_wrapper_inst.sram00_inst.mem[row_idx] = 512'd0;

        // Map each logical twiddle word into the correct physical bit position.
        // sram00 MUX=4:
        //   row = addr >> 2      (A[8:2])
        //   mux = addr & 3       (A[1:0])
        //   Q[k] = mem[row][4*k + mux]
        // Therefore: word[k] → mem[addr>>2][4*k + (addr&3)]
        for (addr_idx = 0; addr_idx < 512; addr_idx = addr_idx + 1) begin
            row_idx = addr_idx >> 2;
            mux_idx = addr_idx & 2'b11;
            for (bit_idx = 0; bit_idx < 32; bit_idx = bit_idx + 1)
                sram_wrapper_inst.sram00_inst.mem[row_idx][4*bit_idx + mux_idx]
                    = twiddle_init[addr_idx][bit_idx];
        end
    end

    sram_wrapper #(.DW(32), .AW(9)) sram_wrapper_inst (
        .clk  (clk),
        .cen  (twiddle_sram_c_en),
        .gwen (gwen),
        .addr (twiddle_address),
        .din  (twiddle_in),
        .dout (twiddle_out)
    );

endmodule
