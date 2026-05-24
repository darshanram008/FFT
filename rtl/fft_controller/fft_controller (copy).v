module fft_controller(
    input         clk,
    input         rstn,

    input         din_valid,
    input         butterfly_done,

    input  [9:0]  data_address,    // from address_gen
    input  [8:0]  twiddle_address, // from address_gen (if you want to use it)

    output reg        rstn_addr,
    output reg        rstn_core,

    output reg [8:0]  group,
    output reg [8:0]  butterfly_num,
    output reg [3:0]  stage,

    output reg        gen_pulse,
    output reg        gen_select,   // 0 = sequential, 1 = FFT pair
    output reg        d2t,          // 0 = data SRAM, 1 = twiddle SRAM

    output reg        core_valid_x0,
    output reg        core_valid_x1,
    output reg        start_compute,

    output reg        data_sram_c_en,
    output reg        data_sram_w_en,
    output reg        din_sel,

    output reg        twiddle_sram_c_en,
    output reg        twiddle_sram_w_en
);

    // ----------------------------------------------------------------
    // State encoding (Verilog-2001 style)
    // ----------------------------------------------------------------
    parameter [2:0]
        S_IDLE         = 3'd0,
        S_LOAD         = 3'd1,
        S_COMP_READ    = 3'd2,
	S_COMP_READ2   = 3'd3,
        S_COMP_EXEC    = 3'd4,
        S_COMP_WRITE   = 3'd5,
 	S_COMP_WRITE2  = 3'd6,
        S_DUMP         = 3'd7;

	
	output reg wb_sel; 
    reg [2:0] state, next_state;

    // ----------------------------------------------------------------
    // Stage / group / butterfly math
    // ----------------------------------------------------------------
    reg [9:0] groups_per_stage;
    reg [9:0] butterflies_per_group;

    always @(*) begin
        // 1024-point FFT, stage = 0..9
        // groups_per_stage = 1024 / 2^(stage+1) = 1 << (9 - stage)
        // butterflies_per_group = 2^stage
        groups_per_stage      = 10'd1 << (9 - stage);
        butterflies_per_group = 10'd1 << stage;
    end

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
                // assume address_gen sequentially increments data_address
                if (data_address == 10'd1023)
                    next_state = S_COMP_READ;
            end

            S_COMP_READ: begin
                // one cycle to present x0/x1 + twiddle to core
                next_state = S_COMP_EXEC;
            end

            S_COMP_EXEC: begin
                if (butterfly_done)
                    next_state = S_COMP_WRITE;
            end

            S_COMP_WRITE: begin
                // after write-back, decide next butterfly / group / stage
                if ((butterfly_num == butterflies_per_group - 1) &&
                    (group         == groups_per_stage      - 1) &&
                    (stage         == 4'd9))
                    next_state = S_DUMP;       // all stages done
                else
                    next_state = S_COMP_READ;  // next butterfly
            end

            S_DUMP: begin
                // sequentially read out 1024 results
                if (data_address == 10'd1023)
                    next_state = S_IDLE;
            end

            default: begin
                next_state = S_IDLE;
            end
        endcase
    end

    // ----------------------------------------------------------------
    // Output + counter logic
    // ----------------------------------------------------------------
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            // resets
            rstn_addr          <= 1'b0;
            rstn_core          <= 1'b0;

            group              <= 9'd0;
            butterfly_num      <= 9'd0;
            stage              <= 4'd0;

            gen_pulse          <= 1'b0;
            gen_select         <= 1'b0;
            d2t                <= 1'b0;

            core_valid_x0      <= 1'b0;
            core_valid_x1      <= 1'b0;
            start_compute      <= 1'b0;

            data_sram_c_en     <= 1'b1; // inactive (active-low)
            data_sram_w_en     <= 1'b0; // 0=read, 1=write (your convention)
            din_sel            <= 1'b0;

            twiddle_sram_c_en  <= 1'b1;
            twiddle_sram_w_en  <= 1'b0;
        end else begin
            // defaults each cycle
            gen_pulse          <= 1'b0;
            core_valid_x0      <= 1'b0;
            core_valid_x1      <= 1'b0;
            start_compute      <= 1'b0;

            data_sram_c_en     <= 1'b1;
            data_sram_w_en     <= 1'b0;
            twiddle_sram_c_en  <= 1'b1;
            twiddle_sram_w_en  <= 1'b0;
            din_sel            <= 1'b0;
            d2t                <= 1'b0;
            gen_select         <= 1'b0;

            case (state)

                // ----------------------------------------------------
                // IDLE
                // ----------------------------------------------------
                S_IDLE: begin
                    rstn_addr <= 1'b0;
                    rstn_core <= 1'b0;
                    group     <= 9'd0;
                    butterfly_num <= 9'd0;
                    stage     <= 4'd0;   // start at stage 0
                end

                // ----------------------------------------------------
                // LOAD: write 1024 input samples into data SRAM
                // ----------------------------------------------------
                S_LOAD: begin
                    rstn_addr      <= 1'b1;
                    rstn_core      <= 1'b0;

                    gen_select     <= 1'b0; // sequential addressing
                    d2t            <= 1'b0; // data SRAM
                    data_sram_c_en <= 1'b0; // enable
                    data_sram_w_en <= 1'b1; // write
                    din_sel        <= 1'b0; // take din from TB
                end

                // ----------------------------------------------------
                // COMPUTE_READ: read x0, x1, twiddle
                // ----------------------------------------------------
                S_COMP_READ: begin
                    rstn_core      <= 1'b1;

                    gen_select     <= 1'b1; // FFT pair addressing
                    gen_pulse      <= 1'b1; // advance pair (depends on your addr_gen)
                    d2t            <= 1'b0; // data SRAM

                    // data SRAM read
                    data_sram_c_en <= 1'b0;
                    data_sram_w_en <= 1'b0; // read

                    // twiddle SRAM read
                    twiddle_sram_c_en <= 1'b0;
                    twiddle_sram_w_en <= 1'b0; // read

                    core_valid_x0  <= 1'b1;
                    core_valid_x1  <= 1'b1;
                end

                // ----------------------------------------------------
                // COMPUTE_EXEC: run butterfly
                // ----------------------------------------------------
                S_COMP_EXEC: begin
                    start_compute  <= 1'b1;
                    // core runs, we wait for butterfly_done
                end

                // ----------------------------------------------------
                // COMPUTE_WRITE: write x0', x1' back to data SRAM
                // ----------------------------------------------------
                S_COMP_WRITE: begin
                    // write butterfly outputs back
                    d2t            <= 1'b0; // data SRAM
                    din_sel        <= 1'b1; // select butterfly_out into data_sram
                    data_sram_c_en <= 1'b0;
                    data_sram_w_en <= 1'b1; // write

                    // update butterfly_num, group, stage
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

                // ----------------------------------------------------
                // DUMP: sequentially read out final 1024 results
                // ----------------------------------------------------
                S_DUMP: begin
                    gen_select     <= 1'b0; // sequential
                    d2t            <= 1'b0; // data SRAM
                    data_sram_c_en <= 1'b0;
                    data_sram_w_en <= 1'b0; // read
                    // testbench watches data_out + data_address
                end

            endcase
        end
    end

endmodule

