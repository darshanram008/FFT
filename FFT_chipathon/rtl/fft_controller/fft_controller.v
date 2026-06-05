//==============================================================================
// fft_controller.v
//
// Top-level FSM for the 1024-point radix-2 DIT FFT processor.
//
// Phases:
//   S_IDLE    : wait for 'start' pulse. Data-SRAM is in tb mode (testbench
//               fills it with 1024 samples at bit-reversed addresses) and
//               twiddle-SRAM is in tb mode too.
//   S_READ_X0 : issue x0_addr (data) and w_addr (twiddle). Latch x0_addr_l /
//               x1_addr_l for later writeback.
//   S_READ_X1 : issue x1_addr. Data-Q from previous cycle (= x0 sample) is
//               valid this cycle -> latch it into x0_latched.
//   S_EXEC    : data-Q holds x1 this cycle; twiddle-Q still holds w. Fire
//               core_start=1 and feed x0_latched / data_dout / tw_dout into
//               the butterfly.
//   S_WB0     : butterfly result is registered, write x0' to x0_addr_l.
//   S_WB1     : write x1' to x1_addr_l. Advance (bfly, group, stage).
//               If last butterfly -> S_DONE.
//   S_DONE    : raise 'done' for one cycle; hand SRAM back to testbench
//               (sram_tb_sel=1). Wait for next 'start' for the next batch.
//
// The testbench is responsible for loading inputs at bit-reversed addresses
// and reading outputs at natural-order addresses (the bit-reverse helper
// output of fft_address_gen is available to it).
//==============================================================================
`timescale 1ns/1ps

module fft_controller #(

    parameter DATA_WIDTH = 32,
    parameter FFT_POINT = 512
   


)(
    
    input              clk,
    input              rstn,

    input              start,            // 1-cycle pulse to begin compute

    // SRAM registered-Q inputs
    input      [DATA_WIDTH-1:0]  data_dout,
    input      [DATA_WIDTH-1:0]  tw_dout,

    // Butterfly-core interface
    input              core_done,
    output reg         core_start,
    output reg [DATA_WIDTH-1:0]  core_x0,
    output reg [DATA_WIDTH-1:0]  core_x1,
    output reg [DATA_WIDTH-1:0]  core_w,
    input      [DATA_WIDTH-1:0]  core_x0_out,
    input      [DATA_WIDTH-1:0]  core_x1_out,

    // Address-generator interface
    output reg [STAGE_WIDTH-1:0]   stage,
    output reg [HALF_WIDTH-1:0]   group,
    output reg [HALF_WIDTH-1:0]   bfly,
    input      [FULL_WIDTH-1:0]   x0_addr,
    input      [FULL_WIDTH-1:0]   x1_addr,
    input      [HALF_WIDTH-1:0]   w_addr,

    // Data SRAM control (compute-side port)
    output reg         data_cen,
    output reg         data_wen,
    output reg [WORD_WIDTH-1:0]   data_addr,
    output reg [DATA_WIDTH-1:0]  data_din,

    // Twiddle SRAM control (compute-side port, read-only)
    output reg         tw_cen,
    output reg [WORD_WIDTH_TW-1:0]   tw_addr,

    // Mux selection for both SRAMs (1 = testbench owns, 0 = core owns)
    output reg         sram_tb_sel,

    // Status
    output reg         busy,
    output reg         done
);
    localparam NUMBER_OF_STAGES = $clog2(FFT_POINT);
    localparam WORD_WIDTH = $clog2(FFT_POINT);
    localparam NUMBER_OF_TW = FFT_POINT/2;
    localparam WORD_WIDTH_TW = $clog2(NUMBER_OF_TW);
    localparam STAGES = $clog2(FFT_POINT);
    localparam STAGE_WIDTH = $clog2(STAGES);
    localparam HALF_WIDTH = $clog2(FFT_POINT/2);
    localparam FULL_WIDTH = $clog2(FFT_POINT);
    localparam [WORD_WIDTH:0] DEPTH_CONST = FFT_POINT;
    // --------------------------------------------------------------------
    // FSM states
    // --------------------------------------------------------------------
    localparam [2:0]
        S_IDLE    = 3'd0,
        S_READ_X0 = 3'd1,
        S_READ_X1 = 3'd2,
        S_EXEC    = 3'd3,
        S_WB0     = 3'd4,
        S_WB1     = 3'd5,
        S_DONE    = 3'd6;

    reg [2:0] state, next_state;

    // Registers
    reg [DATA_WIDTH-1:0] x0_latched;        // x0 data sample, captured in S_READ_X1
    reg [WORD_WIDTH-1:0]  x0_addr_l;         // x0 physical address (for WB0)
    reg [WORD_WIDTH-1:0]  x1_addr_l;         // x1 physical address (for WB1)

    // --------------------------------------------------------------------
    // End-of-stage detectors  (width-correct for N=1024)
    //
    // distance   = 1 << stage              range 1..512, 10 bits
    // num_groups = 1024 / (2 << stage)     range 512..1, 10 bits
    //
    // last_bfly_in_group  := (bfly  + 1 == distance)
    // last_group_in_stage := (group + 1 == num_groups)
    // last_stage          := (stage == 9)
    // --------------------------------------------------------------------
    // distance   = 1 << stage          (1..512, needs 10 bits)
    // num_groups = 1024 >> (stage+1)    (512..1, needs 10 bits)
    // Use 11-bit literal 11'd1024 so the value isn't truncated.
    wire [WORD_WIDTH-1:0]  distance_w   = 1 << stage; //10'd1 << stage
    wire [WORD_WIDTH:0] num_groups_w = DEPTH_CONST >> (stage + 1); //11'd1024 >> (stage + 4'd1)

    wire last_bfly_in_group  = ({1'b0, bfly}   +  1 == distance_w); //({1'b0, bfly}   + 10'd1 == distance_w);
    wire last_group_in_stage = ({2'b00, group} + 1 == num_groups_w); //({2'b00, group} + 11'd1 == num_groups_w);
    wire last_stage          = (stage == (NUMBER_OF_STAGES-1)); //(stage == 4'd9);
    wire last_butterfly      = last_bfly_in_group & last_group_in_stage & last_stage; //last_bfly_in_group & last_group_in_stage & last_stage;

    // --------------------------------------------------------------------
    // State register
    // --------------------------------------------------------------------
    always @(posedge clk or negedge rstn) begin
        if (!rstn) state <= S_IDLE;
        else       state <= next_state;
    end

    // --------------------------------------------------------------------
    // Next-state logic
    // --------------------------------------------------------------------
    always @(*) begin
        next_state = state;
        case (state)
            S_IDLE:    if (start)          next_state = S_READ_X0;
            S_READ_X0:                     next_state = S_READ_X1;
            S_READ_X1:                     next_state = S_EXEC;
            S_EXEC:                        next_state = S_WB0;
            S_WB0:                         next_state = S_WB1;
            S_WB1:     if (last_butterfly) next_state = S_DONE;
                       else                next_state = S_READ_X0;
            S_DONE:    if (start)          next_state = S_READ_X0;
                       else                next_state = S_DONE;
            default:                       next_state = S_IDLE;
        endcase
    end

    // --------------------------------------------------------------------
    // Sequential datapath: counters and latches
    // --------------------------------------------------------------------
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            stage      <= 0;
            group      <=  0;
            bfly       <= 0;
            x0_latched <= 0;
            x0_addr_l  <= 0;
            x1_addr_l  <= 0;
        end else begin
            case (state)
                S_IDLE, S_DONE: begin
                    if (start) begin
                        stage <= 0;
                        group <= 0;
                        bfly  <= 0;
                    end
                end
                S_READ_X0: begin
                    // Latch the butterfly addresses so later WB states use the
                    // right locations even after (bfly, group, stage) advance.
                    x0_addr_l <= x0_addr;
                    x1_addr_l <= x1_addr;
                end
                S_READ_X1: begin
                    // Data-SRAM Q holds x0 this cycle (from S_READ_X0's read)
                    x0_latched <= data_dout;
                end
                S_WB1: begin
                    // Advance (bfly, group, stage). Order matters: innermost
                    // first, then group, then stage.
                    if (last_bfly_in_group) begin
                        bfly <= 0; //9'd0;
                        if (last_group_in_stage) begin
                            group <= 0;//9'd0;
                            if (!last_stage)
                                stage <= stage + 1; //4'd1
                        end else begin
                            group <= group + 1;//9'd1;
                        end
                    end else begin
                        bfly <= bfly + 1;//9'd1;
                    end
                end
                default: ;
            endcase
        end
    end
    // --------------------------------------------------------------------
    // Combinational outputs
    // --------------------------------------------------------------------
    always @(*) begin
        // Safe defaults
        data_cen    = 1'b0;
        data_wen    = 1'b0;
        data_addr   = 0;//10'd0;
        data_din    = 0;// 32'd0;
        tw_cen      = 1'b0;
        tw_addr     = 0; //9'd0;
        core_start  = 1'b0;
        core_x0     = x0_latched;
        core_x1     = 0;// 32'd0;
        core_w      = 0;// 32'd0;
        sram_tb_sel = 1'b1;   // tb owns by default
        busy        = 1'b0;
        done        = 1'b0;
        case (state)
            S_IDLE: begin
                sram_tb_sel = 1'b1;
            end

            S_READ_X0: begin
                sram_tb_sel = 1'b0;
                data_cen    = 1'b1;     // enable read of data SRAM
                data_wen    = 1'b0;
                data_addr   = x0_addr;
                tw_cen      = 1'b1;     // enable read of twiddle SRAM
                tw_addr     = w_addr;
                busy        = 1'b1;
            end

            S_READ_X1: begin
                sram_tb_sel = 1'b0;
                data_cen    = 1'b1;
                data_wen    = 1'b0;
                data_addr   = x1_addr;
                // Twiddle CEN off: twiddle Q will keep holding the value from
                // S_READ_X0's read through this cycle and the next (S_EXEC).
                tw_cen      = 1'b0;
                tw_addr     = w_addr;
                busy        = 1'b1;
            end

            S_EXEC: begin
                sram_tb_sel = 1'b0;
                // Data-Q has x1 this cycle; twiddle-Q still has w.
                core_start  = 1'b1;
                core_x0     = x0_latched;
                core_x1     = data_dout;
                core_w      = tw_dout;
                busy        = 1'b1;
            end

            S_WB0: begin
                sram_tb_sel = 1'b0;
                data_cen    = 1'b1;
                data_wen    = 1'b1;
                data_addr   = x0_addr_l;
                data_din    = core_x0_out;
                busy        = 1'b1;
            end

            S_WB1: begin
                sram_tb_sel = 1'b0;
                data_cen    = 1'b1;
                data_wen    = 1'b1;
                data_addr   = x1_addr_l;
                data_din    = core_x1_out;
                busy        = 1'b1;
                if (last_butterfly) done = 1'b1;
            end

            S_DONE: begin
                sram_tb_sel = 1'b1;   // return SRAM to testbench for dump
                busy        = 1'b0;
            end

            default: ;
        endcase
    end

endmodule

