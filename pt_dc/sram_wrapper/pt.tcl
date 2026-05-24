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
set top_level sram_wrapper

# Set library paths
set search_path [list "." "/courses/ee6350/pdk2025/tcbn65gplus/TSMCHOME/digital/Front_End/timing_power_noise/CCS/tcbn65gplus_200a" "/home/cad/installs/synopsys/syn/O-2018.06-SP5-1/libraries/syn" "../../memory_compiler/single_port_sram/sram00_libs"]

# Specify a list of libraries, design files, and library files used during linking
set link_path [list "*" "tcbn65gplustc_ccs.db" "sram00_nldm_tt_1p00v_1p00v_25c_syn.db"]

# Read design or library files
read_db [list "tcbn65gplustc_ccs.db"]

# Read verilog files
set svr_enable_vpp true
read_verilog "../../dc/$top_level/$top_level.nl.v"

# Resolve references in a design
# Note: It resolves all references between different modules in the hierarchy
#       and builds an internal representation of the design for timing analysis
link_design $top_level

##################################################
# Define timing constraints
##################################################

# Timing constraints
source ./timing.tcl
###############################################################
# Clock Period Sweep: 0.1 ns to 2.0 ns
###############################################################

set sweep_report "freq_sweep.rpt"
file delete -force $sweep_report
set fp [open $sweep_report w]

# 0.1, 0.2, ..., 2.0 ns
for {set per 0.1} {$per <= 2.0001} {set per [expr {$per + 0.1}]} {

    # remove old clock and create new one
    remove_clock [all_clocks]
    create_clock -name clk -period $per [get_ports clk]

    # re-apply clock-related constraints
    set clk_obj [get_clocks clk]
    set_clock_uncertainty $clk_uncertainty $clk_obj
    set_clock_transition  $clk_transition  $clk_obj

    # re-apply I/O delays relative to the new clock
    set_input_delay  $typical_input_delay  -clock clk [remove_from_collection [all_inputs] [get_ports clk]]
    set_output_delay $typical_output_delay -clock clk [all_outputs]

    update_timing

    # get worst max-delay path slack
    set path_obj [lindex [get_timing_paths -max_paths 1 -nworst 1 -delay_type max] 0]

    if {$path_obj eq ""} {
        set slack "NO_PATH"
        puts "Period = $per ns   Slack = $slack"
        puts $fp "Period = $per ns   Slack = $slack"
    } else {
        set slack [get_attribute $path_obj slack]
        puts "Period = $per ns   Slack = $slack"
        puts $fp "Period = $per ns   Slack = $slack"
    }

    # full timing report for this period
    puts $fp "----- Timing report for period = $per ns -----"
    redirect -append $sweep_report {
        report_timing -delay_type max -nworst 10 -significant_digits 4
    }
    puts $fp "----------------------------------------------"
}

close $fp

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
#read_vcd "/vlsidl/projects4/riscv2024/riscv/qsim_dc/tb_ibex_basic_v4_b/ibex_top.vcd" -time {9000000 9200000} -strip_path "testbench/ibex_top"
read_vcd "../../qsim_dc/tb_sram_wrapper/sram_wrapper.vcd" -time {0 9000000} -strip_path "testbench/sram_wrapper_inst"





update_power
report_switching_activity >> ${rpt_file}
report_switching_activity -list_not_annotated >> ${rpt_file}
report_power >> ${rpt_file}
report_power -hierarchy >> ${rpt_file}

write_sdf -context verilog "./${top_level}.pt.sdf"

#Finish PrimeTime
quit
