#########################################
# TCL script for Design Compiler        #
# MS 2015                               #
#########################################

##################################################
# Read design and library
##################################################

# Set top_level name
set top_level dut

# Read system verilog files
analyze -format verilog "../../rtl/dut/dut.v"

elaborate ${top_level}

# List the names of the designs
list_designs

# Check error
if { [check_error -v] == 1 } { exit 1 }

# Set current design
current_design $top_level

# Link the design
link

# Generate structural verilog netlist
write -hierarchy -format verilog -output "${top_level}.nl.v"

# Finish synthesis
quit

