module fft_controller(
    input         clk,
    input         rstn,

    input         din_valid,
    input         butterfly_done,

    input  [9:0]  data_address,
    input  [8:0]  twiddle_address,

    output reg        rstn_addr,
    output reg        rstn_core,

    output reg [8:0]  group,
    output reg [8:0]  butterfly_num,
    output reg [3:0]  stage,

    output reg        gen_pulse,
    output reg        gen_select,
    output reg        d2t,

    output reg        core_valid_x0,
    output reg        core_valid_x1,
    output reg        start_compute,

    output reg        data_sram_c_en,
    output reg        data_sram_w_en,
    output reg        din_sel,

    output reg        twiddle_sram_c_en,
    output reg        twiddle_sram_w_en,

    output reg        wb_sel,
    output reg 	[3:0] state_out
);

    // ----------------------------------------------------------------
    // State encoding
    // ----------------------------------------------------------------
    // Per-butterfly compute sequence (single-port SRAM, registered Q):
    //
    //  S_LOAD       : write 1024 samples sequentially into data SRAM
    //  S_READ_X0    : toggle=0 → x0 addr on SRAM; addr registered this cycle
    //  S_LATCH_X0   : SRAM Q = x0; core latches x0; pulse toggle→1
    //  S_READ_X1    : toggle=1 → x1 addr on SRAM; twiddle addr also set
    //  S_LATCH_X1   : SRAM Q = x1; twiddle Q valid; core latches x1
    //  S_EXEC       : start_compute=1; fft_core produces result in one cycle
    //  S_WRITE_X1   : toggle=1 → x1 addr; write x1'; pulse toggle→0
    //  S_WRITE_X0   : toggle=0 → x0 addr; write x0'; advance counters
    //  S_DUMP_RST   : assert rstn_addr=0 for one cycle → data_address=0
    //  S_DUMP       : sequential read-out of 1024 results
    // ----------------------------------------------------------------
    parameter [3:0]
        S_IDLE      = 4'd0,
        S_LOAD      = 4'd1,
        S_READ_X0   = 4'd2,
        S_LATCH_X0  = 4'd3,
        S_READ_X1   = 4'd4,
        S_LATCH_X1  = 4'd5,
        S_EXEC      = 4'd6,
        S_WRITE_X1  = 4'd7,
        S_WRITE_X0  = 4'd8,
        S_DUMP_RST  = 4'd9,
        S_DUMP      = 4'd10;

    reg [3:0] state, next_state;
	always @(*) begin
		 state_out = state;
	end
    // ----------------------------------------------------------------
    // Stage / group / butterfly combinational parameters
    // ----------------------------------------------------------------
    reg [9:0] groups_per_stage;
    reg [9:0] butterflies_per_group;

    always @(*) begin
        groups_per_stage      = 10'd1 << (9 - stage);
        butterflies_per_group = 10'd1 << stage;
    end

    wire last_butterfly = (butterfly_num == butterflies_per_group - 1) &&
                          (group         == groups_per_stage      - 1) &&
                          (stage         == 4'd9);

    // Internal counters that are NOT dependent on address_gen's
    // registered output — avoids off-by-one exit conditions
    reg [9:0] load_cnt;   // counts samples written during LOAD
    reg [9:0] dump_cnt;   // counts addresses issued during DUMP

    // ----------------------------------------------------------------
    // State register
    // ----------------------------------------------------------------
    always @(posedge clk or negedge rstn) begin
        if (!rstn)
            state <= S_IDLE;
        else
            state <= next_state;
    end

    // ----------------------------------------------------------------
    // Next-state logic
    // ----------------------------------------------------------------
    always @(*) begin
        next_state = state;
        case (state)

            S_IDLE: begin
                if (din_valid)
                    next_state = S_LOAD;
            end

            S_LOAD: begin
                // load_cnt reaches 1023 on the last sample write cycle
                if (load_cnt == 10'd1023)
                    next_state = S_READ_X0;
            end

            S_READ_X0:  next_state = S_LATCH_X0;
            S_LATCH_X0: next_state = S_READ_X1;
            S_READ_X1:  next_state = S_LATCH_X1;
            S_LATCH_X1: next_state = S_EXEC;

            S_EXEC: begin
                if (butterfly_done)
                    next_state = S_WRITE_X1;
            end

            S_WRITE_X1: next_state = S_WRITE_X0;

            S_WRITE_X0: begin
                if (last_butterfly)
                    next_state = S_DUMP_RST;
                else
                    next_state = S_READ_X0;
            end

            // One cycle reset pulse → data_address zeroed
            S_DUMP_RST: next_state = S_DUMP;

            S_DUMP: begin
                // dump_cnt counts addresses issued; exit after 1023
                if (dump_cnt == 10'd1023)
                    next_state = S_IDLE;
            end

            default: next_state = S_IDLE;

        endcase
    end

    // ----------------------------------------------------------------
    // Output + counter logic
    // ----------------------------------------------------------------
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            rstn_addr         <= 1'b0;
            rstn_core         <= 1'b0;

            group             <= 9'd0;
            butterfly_num     <= 9'd0;
            stage             <= 4'd0;

            load_cnt          <= 10'd0;
            dump_cnt          <= 10'd0;

            gen_pulse         <= 1'b0;
            gen_select        <= 1'b0;
            d2t               <= 1'b0;

            core_valid_x0     <= 1'b0;
            core_valid_x1     <= 1'b0;
            start_compute     <= 1'b0;

            data_sram_c_en    <= 1'b1;
            data_sram_w_en    <= 1'b0;
            din_sel           <= 1'b0;

            twiddle_sram_c_en <= 1'b1;
            twiddle_sram_w_en <= 1'b0;

            wb_sel            <= 1'b0;

        end else begin

            // Safe defaults every cycle — overridden per state below
            gen_pulse         <= 1'b0;
            gen_select        <= 1'b0;
            d2t               <= 1'b0;
            core_valid_x0     <= 1'b0;
            core_valid_x1     <= 1'b0;
            start_compute     <= 1'b0;
            data_sram_c_en    <= 1'b1;
            data_sram_w_en    <= 1'b0;
            din_sel           <= 1'b0;
            twiddle_sram_c_en <= 1'b1;
            twiddle_sram_w_en <= 1'b0;
            wb_sel            <= 1'b0;

            case (state)

                // ------------------------------------------------
                // IDLE
                // ------------------------------------------------
                S_IDLE: begin
                    rstn_addr     <= 1'b0;
                    rstn_core     <= 1'b0;
                    group         <= 9'd0;
                    butterfly_num <= 9'd0;
                    stage         <= 4'd0;
                    load_cnt      <= 10'd0;
                    dump_cnt      <= 10'd0;
                end

                // ------------------------------------------------
                // LOAD: write 1024 samples into data SRAM.
                // gen_select=0, d2t=0 → address_gen increments
                // data_address sequentially each cycle.
                // load_cnt increments in sync.
                // ------------------------------------------------
                S_LOAD: begin
                    rstn_addr         <= 1'b1;
                    rstn_core         <= 1'b0;

                    gen_select        <= 1'b0;
                    d2t               <= 1'b0;
                    data_sram_c_en    <= 1'b0;
                    data_sram_w_en    <= 1'b1;
                    din_sel           <= 1'b0;  // source = external din

                    if (load_cnt < 10'd1023)
                        load_cnt <= load_cnt + 10'd1;
                end

                // ------------------------------------------------
                // READ_X0: FFT-pair mode, toggle=0 (was reset to 0
                // in S_WRITE_X0 or is 0 from init).
                // address_gen drives: data_address = group*group_size
                //                                    + butterfly_num
                // This address is registered into SRAM this cycle;
                // Q appears next cycle (S_LATCH_X0).
                // Also drive twiddle SRAM address (address_gen drives
                // twiddle_address combinationally regardless of toggle).
                // ------------------------------------------------
                S_READ_X0: begin
                    rstn_addr         <= 1'b1;
                    rstn_core         <= 1'b1;

                    gen_select        <= 1'b1;
                    gen_pulse         <= 1'b0;  // keep toggle=0 → x0 addr

                    data_sram_c_en    <= 1'b0;
                    data_sram_w_en    <= 1'b0;

                    twiddle_sram_c_en <= 1'b0;
                    twiddle_sram_w_en <= 1'b0;
                end

                // ------------------------------------------------
                // LATCH_X0: SRAM Q now holds x0.
                // core_valid_x0=1 → fft_core latches sram_out as x0.
                // Pulse gen_pulse to flip toggle 0→1 so next cycle
                // address_gen outputs the x1 address.
                // ------------------------------------------------
                S_LATCH_X0: begin
                    rstn_addr         <= 1'b1;
                    rstn_core         <= 1'b1;

                    gen_select        <= 1'b1;
                    gen_pulse         <= 1'b1;  // toggle 0→1 → x1 addr next cycle

                    core_valid_x0     <= 1'b1;

                    data_sram_c_en    <= 1'b0;
                    data_sram_w_en    <= 1'b0;

                    twiddle_sram_c_en <= 1'b0;
                    twiddle_sram_w_en <= 1'b0;
                end

                // ------------------------------------------------
                // READ_X1: toggle=1 → x1 address on data SRAM.
                // Twiddle address also stable (group*distance +
                // butterfly_num, driven by address_gen combinationally).
                // ------------------------------------------------
                S_READ_X1: begin
                    rstn_addr         <= 1'b1;
                    rstn_core         <= 1'b1;

                    gen_select        <= 1'b1;
                    gen_pulse         <= 1'b0;  // hold toggle=1

                    data_sram_c_en    <= 1'b0;
                    data_sram_w_en    <= 1'b0;

                    twiddle_sram_c_en <= 1'b0;
                    twiddle_sram_w_en <= 1'b0;
                end

                // ------------------------------------------------
                // LATCH_X1: x1 on data SRAM Q; twiddle on twiddle
                // SRAM Q. Core latches x1.
                // ------------------------------------------------
                S_LATCH_X1: begin
                    rstn_addr         <= 1'b1;
                    rstn_core         <= 1'b1;

                    core_valid_x1     <= 1'b1;

                    data_sram_c_en    <= 1'b0;
                    data_sram_w_en    <= 1'b0;

                    twiddle_sram_c_en <= 1'b0;
                    twiddle_sram_w_en <= 1'b0;
                end

                // ------------------------------------------------
                // EXEC: assert start_compute for one cycle.
                // fft_core computes and asserts butterfly_done next
                // posedge. SRAMs idle.
                // ------------------------------------------------
                S_EXEC: begin
                    rstn_addr     <= 1'b1;
                    rstn_core     <= 1'b1;
                    start_compute <= 1'b1;
                end

                // ------------------------------------------------
                // WRITE_X1: toggle is still 1 → x1 address on bus.
                // Write x1' (wb_sel=1) to SRAM.
                // Pulse gen_pulse to flip toggle 1→0 so NEXT cycle
                // address_gen will output x0 address (for WRITE_X0).
                // ------------------------------------------------
                S_WRITE_X1: begin
                    rstn_addr         <= 1'b1;
                    rstn_core         <= 1'b1;

                    gen_select        <= 1'b1;
                    gen_pulse         <= 1'b1;  // toggle 1→0 → x0 addr next cycle

                    wb_sel            <= 1'b1;  // select x1' from fft_core
                    din_sel           <= 1'b1;  // butterfly result path
                    data_sram_c_en    <= 1'b0;
                    data_sram_w_en    <= 1'b1;
                end

                // ------------------------------------------------
                // WRITE_X0: toggle=0 → x0 address on bus.
                // Write x0' (wb_sel=0) to SRAM.
                // Advance butterfly/group/stage counters.
                // gen_pulse=0 → toggle stays 0, ready for the next
                // butterfly's READ_X0.
                // ------------------------------------------------
                S_WRITE_X0: begin
                    rstn_addr         <= 1'b1;
                    rstn_core         <= 1'b1;

                    gen_select        <= 1'b1;
                    gen_pulse         <= 1'b0;  // hold toggle=0

                    wb_sel            <= 1'b0;  // select x0' from fft_core
                    din_sel           <= 1'b1;  // butterfly result path
                    data_sram_c_en    <= 1'b0;
                    data_sram_w_en    <= 1'b1;

                    // Advance counters
                    if (butterfly_num == butterflies_per_group - 1) begin
                        butterfly_num <= 9'd0;
                        if (group == groups_per_stage - 1) begin
                            group <= 9'd0;
                            if (stage != 4'd9)
                                stage <= stage + 4'd1;
                        end else begin
                            group <= group + 9'd1;
                        end
                    end else begin
                        butterfly_num <= butterfly_num + 9'd1;
                    end
                end

                // ------------------------------------------------
                // DUMP_RST: pull rstn_addr low for exactly one cycle.
                // This zeroes data_address inside address_gen so
                // the DUMP read-out starts from address 0.
                // Reset dump_cnt here too.
                // ------------------------------------------------
                S_DUMP_RST: begin
                    rstn_addr <= 1'b0;   // resets data_address → 0
                    rstn_core <= 1'b1;
                    dump_cnt  <= 10'd0;
                end

                // ------------------------------------------------
                // DUMP: sequential read-out.
                // rstn_addr=1 again; gen_select=0, d2t=0 → address_gen
                // increments data_address from 0 each cycle.
                // dump_cnt counts addresses issued (not Q samples
                // captured — that 1-cycle lag is handled in tb_fft.v).
                // ------------------------------------------------
                S_DUMP: begin
                    rstn_addr         <= 1'b1;

                    gen_select        <= 1'b0;
                    d2t               <= 1'b0;
                    data_sram_c_en    <= 1'b0;
                    data_sram_w_en    <= 1'b0;

                    if (dump_cnt < 10'd1023)
                        dump_cnt <= dump_cnt + 10'd1;
                end

            endcase
        end
    end

endmodule

