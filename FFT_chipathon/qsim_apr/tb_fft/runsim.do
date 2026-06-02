##################################################
#  Modelsim do file to run simuilation
#  MS 7/2015 #-sdftyp testbench/fft_top_inst/fft_address_gen_inst=../../dc/fft_address_gen/fft_address_gen.syn.sdf \
# testbench/fft_top_inst/fft_core_inst=../../dc/fft_core/fft_core.syn.sdf \
#testbench/fft_top_inst/fft_controller_inst=../../dc/fft_controller/fft_controller.syn.sdf \
# testbench/fft_top_inst/fft_data_sram_inst/sram_wrapper_b1=../../dc/sram_wrapper/sram_wrapper.syn.sdf \
# testbench/fft_top_inst/fft_data_sram_inst/sram_wrapper_b0=../../dc/sram_wrapper/sram_wrapper.syn.sdf \
# testbench/fft_top_inst/fft_twiddle_sram_inst/sram_wrapper_inst=../../dc/sram_wrapper/sram_wrapper.syn.sdf \
# testbench/fft_top_inst=../../dc/fft_top/fft_top.syn.sdf \
#vlog +acc=rn -incr ../../dc/fft_address_gen/fft_address_gen.nl.v 
#vlog +acc=rn -incr ../../dc/fft_core/fft_core.nl.v 
#vlog +acc=rn -incr ../../dc/fft_controller/fft_controller.nl.v 
#vlog +acc=rn -incr ../../dc/fft_data_sram/fft_data_sram.nl.v 
#vlog +acc=rn -incr ../../dc/fft_twiddle_sram/fft_twiddle_sram.nl.v 
#vlog +acc=rn -incr ../../dc/sram_wrapper/sram_wrapper.nl.v 
#vlog +acc -incr ../../memory_compiler/single_port_sram/sram00.v
##################################################

vlib work 
vmap work work

# include standard cell verilog model
vlog +acc -incr /courses/ee6350/pdk2025/tcbn65gplus/TSMCHOME/digital/Front_End/verilog/tcbn65gplus_140b/tcbn65gplus_pwr.v

# include the testbench file
vlog +acc=rn -incr tb_fft.v 
#vlog +acc -incr +define+SIM_INIT ../../memory_compiler/single_port_sram/sram00.v


# include verilog modules
vlog +acc=rn -incr +define+SYNTH ../../innovus/fft_top/fft_top.PG.v
vlog +acc=rn -incr +define+SYNTH ../../innovus/fft_address_gen/fft_address_gen.PG.v 
vlog +acc=rn -incr +define+SYNTH ../../innovus/fft_controller/fft_controller.PG.v
vlog +acc=rn -incr +define+SYNTH ../../innovus/fft_data_sram/fft_data_sram.PG.v
vlog +acc=rn -incr +define+SYNTH ../../innovus/fft_twiddle_sram/fft_twiddle_sram.PG.v
vlog +acc=rn -incr +define+SYNTH ../../innovus/fft_core/fft_core.PG.v
vlog +acc=rn -incr +define+SYNTH ../../innovus/sram_wrapper/sram_wrapper.PG.v
vlog -reportprogress 300 +acc +define+ARM_UD_MODEL +define+POWER_PINS -incr ../../memory_compiler/single_port_sram/sram00.v

# run simulation with sdf annotations and check waveforms 
vsim -voptargs=+acc -t ps -lib work \
-sdfnoerror \
-sdfmax testbench/fft_top_inst=../../innovus/fft_top/fft_top.verilog.sdf \
-sdfmax testbench/fft_top_inst/u_addr=../../innovus/fft_address_gen/fft_address_gen.verilog.sdf \
-sdfmax testbench/fft_top_inst/u_core=../../innovus/fft_core/fft_core.verilog.sdf \
-sdfmax testbench/fft_top_inst/u_tw_sram=../../innovus/fft_twiddle_sram/fft_twiddle_sram.verilog.sdf \
-sdfmax testbench/fft_top_inst/u_data_sram=../../innovus/fft_data_sram/fft_data_sram.verilog.sdf \
-sdfmax testbench/fft_top_inst/u_ctrl=../../innovus/fft_controller/fft_controller.verilog.sdf \
testbench

#+nowarn3448 +nowarn8756 \

do waveformat.do   
run -all

