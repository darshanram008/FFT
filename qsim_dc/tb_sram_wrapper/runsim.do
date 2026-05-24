##################################################
#  Modelsim do file to run simuilation
#  MS 7/2015
##################################################

vlib work 
vmap work work

# include the testbench file
vlog +acc -incr tb_sram_wrapper.v 

# include verilog modules
vlog +acc -incr dc_stubs.v
vlog +acc -incr ../../dc/sram_wrapper/sram_wrapper.nl.v 
vlog +acc -incr ../../memory_compiler/single_port_sram/sram00.v

# run simulation and check waveforms 
vsim -voptargs=+acc -t ps -lib work \
-sdftyp testbench.sram_wrapper_inst=../../dc/sram_wrapper/sram_wrapper.syn.sdf \
testbench
do waveformat.do   
run -all
