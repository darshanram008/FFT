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
vlog +acc -incr /courses/ee6350/pdk2025/tcbn65gplus/TSMCHOME/digital/Front_End/verilog/tcbn65gplus_140b/tcbn65gplus.v

# include the testbench file
vlog +acc=rn -incr tb_fft.v 
#vlog +acc -incr +define+SIM_INIT ../../memory_compiler/single_port_sram/sram00.v


# include verilog modules
vlog +acc=rn -incr +define+SYNTH ../../dc/fft_top/fft_top.nl.v 
vlog -reportprogress 300 +acc +define+ARM_UD_MODEL -incr ../../memory_compiler/single_port_sram/sram00.v

# run simulation with sdf annotations and check waveforms 
vsim -voptargs=+acc -t ps -lib work \
-sdfnoerror \
-sdftyp testbench/fft_top_inst=../../dc/fft_top/fft_top.syn.sdf \
 +nowarn3448 +nowarn8756 \
testbench



do waveformat.do   
run -all

