#################################################
# PrimeTime script for static timing analysis   #
# MS 7/2015                                     #
#################################################

# Display long reports one page at a time
set sh_enable_page_mode true

# Enable or Disable PrimePower, which provides power analysis
set power_enable_analysis true


##################################################
# Set files and paths
##################################################

# Set the top_level name
set top_level fft_top

# Set library paths
set search_path [list "." "/courses/ee6350/pdk2025/tcbn65gplus/TSMCHOME/digital/Front_End/timing_power_noise/CCS/tcbn65gplus_200a" "/home/cad/installs/synopsys/syn/O-2018.06-SP5-1/libraries/syn" "../../memory_compiler/single_port_sram/sram00_libs"]

# Specify a list of libraries, design files, and library files used during linking
set link_path [list "*" "tcbn65gplustc_ccs.db" "sram00_nldm_tt_1p00v_1p00v_25c_syn.db"]

# Read design or library files
read_db [list "tcbn65gplustc_ccs.db"]

# Read verilog files
set svr_enable_vpp true
read_verilog "../../innovus/$top_level/$top_level.PG.v"
read_verilog "../../innovus/fft_address_gen/fft_address_gen.PG.v"
read_verilog "../../innovus/fft_controller/fft_controller.PG.v"
read_verilog "../../innovus/fft_data_sram/fft_data_sram.PG.v"
read_verilog "../../innovus/fft_twiddle_sram/fft_twiddle_sram.PG.v"
read_verilog "../../innovus/fft_core/fft_core.PG.v"
read_verilog "../../innovus/sram_wrapper/sram_wrapper.PG.v"

#read_verilog $verilog_files

# Resolve references in a design
# Note: It resolves all references between different modules in the hierarchy
#       and builds an internal representation of the design for timing analysis
link_design $top_level

# Read parasitic files 
read_parasitics "../../innovus/$top_level/$top_level.spef"
read_parasitics -path u_addr "../../innovus/fft_address_gen/fft_address_gen.spef"
read_parasitics -path u_ctrl "../../innovus/fft_controller/fft_controller.spef"
read_parasitics -path u_data_sram "../../innovus/fft_data_sram/fft_data_sram.spef"
read_parasitics -path u_tw_sram "../../innovus/fft_twiddle_sram/fft_twiddle_sram.spef"
read_parasitics -path u_core "../../innovus/fft_core/fft_core.spef"


#set spef_files "\
#../../innovus/dut/dut.spef \
#../../innovus/down_counter/down_counter.spef \
#../../innovus/sram_controller/sram_controller.spef \
#../../innovus/sram_wrapper/sram_wrapper.spef \
#"
#
#read_parasitics $spef_files

##################################################
# Define timing constraints
##################################################

# Timing constraints
source ./timing.tcl

##################################################
# Run PrimeTime 
##################################################

# Generate a report file
set rpt_file "${top_level}.pt.rpt"
check_timing

report_design >> ${rpt_file}
report_reference >> ${rpt_file}
report_constraint >> ${rpt_file}
report_constraint -all_violators -significant_digits 4 >> ${rpt_file}
report_timing -significant_digits 4 -delay_type min_max -nworst 120 >> ${rpt_file}
report_timing -significant_digits 4 -delay_type min -nworst 120 -slack_greater_than 0 >> ${rpt_file}
report_timing -significant_digits 4 -delay_type max -nworst 5 -slack_greater_than 0 >> ${rpt_file}

# Do power analysis
set power_analysis_mode "time_based"
read_vcd "../../qsim_apr/tb_fft/tb_fft.vcd" -time {0 50000000} -strip_path "testbench/fft_top_inst"

update_power
report_switching_activity >> ${rpt_file}
report_switching_activity -list_not_annotated >> ${rpt_file}
report_power >> ${rpt_file}
report_power -hierarchy >> ${rpt_file}

write_sdf -context verilog "./${top_level}.pt.sdf"

#Finish PrimeTime
quit
