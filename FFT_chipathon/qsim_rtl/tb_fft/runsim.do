##################################################
#  Modelsim do file to run simuilation
#  MS 7/2015
##################################################

vlib work 
vmap work work

# include the testbench file
vlog +acc -incr tb_fft.v 

# include verilog modules
vlog +acc -incr ../../rtl/fft_address_gen/fft_address_gen.v 
vlog +acc -incr ../../rtl/fft_core/fft_core.v 
vlog +acc -incr ../../rtl/fft_controller/fft_controller.v 
vlog +acc -incr ../../rtl/fft_data_sram/fft_data_sram.v
vlog +acc -incr ../../rtl/fft_twiddle_sram/fft_twiddle_sram.v
vlog +acc -incr ../../rtl/fft_top/fft_top.v 
vlog +acc -incr ../../rtl/sram_wrapper/sram_wrapper.v 
vlog -reportprogress 300 +acc +define+ARM_UD_MODEL -incr ../../memory_compiler/single_port_sram/sram00.v




# run simulation and check waveforms 
vsim -voptargs=+acc -t ps -lib work testbench
do waveformat.do   
run -all
