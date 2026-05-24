module fft_address_gen(
    input clk,
    input rstn_addr,
    input gen_pulse,
    input gen_select, //0 for sequential and 1 for FFT address pair
    input d2t,        // sequential generator output selector: 0=data, 1=twiddle

    input [8:0] group,
    input [8:0] butterfly_num,
    input [3:0] stage,

    output reg [9:0] data_address,
    output reg [8:0] twiddle_address
);

    reg toggle;
    reg [9:0] distance;             // 1,2,4,...,512
    reg [10:0] group_size;          // 2,4,8,...,1024
    reg [9:0] twiddle_index_step;   // 512, 256, ..., 1

    // Combinational FFT parameters
    always @(*) begin
        distance           = 10'd1 << stage;       // 1,2,4,...512
        group_size         = 11'd1 << (stage+1);   // 2,4,8,...1024
        twiddle_index_step = 10'd1 << (9 - stage); // 512,256,...1
    end

    // Toggle only when controller pulses
    always @(posedge clk) begin
        if (!rstn_addr)
            toggle <= 1'b0;
        else if (gen_pulse)
            toggle <= ~toggle;
    end

    // Address generation
    always @(posedge clk) begin
        if (!rstn_addr) begin
            data_address    <= 10'd0;
            twiddle_address <= 10'd0;
        end else begin

            if (!gen_select) begin
                // Sequential addressing
                if (d2t)
                    twiddle_address <= twiddle_address + 10'd1;
                else
                    data_address <= data_address + 10'd1;
            end

            else begin
                // FFT address pair generator
                if (toggle)
                    data_address <= (group * group_size) + butterfly_num + distance;
                else
                    data_address <= (group * group_size) + butterfly_num;

                // Radix-2 DIT twiddle index for N=1024:
                //   index = butterfly_num * (1024 / group_size)
                //         = butterfly_num << (9 - stage)
                // It depends on the butterfly position inside the group,
                // not on the group number itself.
                twiddle_address <= butterfly_num * twiddle_index_step;
            end
        end
    end

endmodule
