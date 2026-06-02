##################################################
# Innovus Script
##################################################


##################################################
# Setup design
##################################################

set design_name fft_top
source ./config.globals
set_message -no_limit
set_message -id {TECHLIB-1467} -limit 10
setMultiCpuUsage -localCpu max -acquireLicense 8

# Initialize a design using the Tcl globals listed in the Related Global section
# Notes: At this script, all the settings are included in the file 'config.globals'
init_design
gui_show

##################################################
# Set parameters for the floorplan
##################################################

set core_width 700
set core_height 468

##################################################
# Create the floorplan
##################################################

floorPlan -s $core_width $core_height 2 2 2 2
redraw
fit

##################################################
# Place Blocks
##################################################

placeInstance u_tw_sram 62 340 R0 -fixed
placeInstance u_core 120 190 R0 -fixed
placeInstance u_addr 320 190 R0 -fixed
placeInstance u_ctrl 420 190 R0 -fixed
placeInstance u_data_sram 62 22 R0 -fixed
dbSet [dbGetInstByName u_data_sram].orient MX

checkPlace
redraw 
fit

##################################################
# Generate power rails 
#################################################	#

addStripe -block_ring_top_layer_limit M9 \
	  -block_ring_bottom_layer_limit M9 \
	  -padcore_ring_top_layer_limit M9 \
	  -padcore_ring_bottom_layer_limit M9 \
          -max_same_layer_jog_length 6 \
          -merge_stripes_value 4 \
	  -layer M9 \
          -set_to_set_distance 10 \
          -direction horizontal \
          -nets {VDD VSS} \
	  -width 2 \
	  -spacing 2 -area {2 2 122 50}


##################################################
# Set all the input/output ports
##################################################
 
# Load an I/O assignment file 
loadIoFile "./$design_name.io"

redraw

# Save the flooprlan information to a file (intermediate saving)
saveDesign "$design_name.floorplan.enc"


##################################################
# Place design
##################################################

#Puts "####################"
#Puts "###"
#Puts "### Place Design ..."
#Puts "###"
#Puts "####################"
#
## Defines the process technology value 
#setDesignMode -process 65 -flowEffort standard
## Specify a routing layer limit for Early Global Route
#setMaxRouteLayer 5
#
## Control certain aspects of how the software places cells
#setPlaceMode -timingDriven true -congEffort high
#
## Set global parameters for timing optimization
#setOptMode -fixFanoutLoad true -effort high -moveInst true -reclaimArea true
#
## Place stanard cells based on the global settings for placement, RC extraction, and timing analysis
#place_design -noPrePlaceOpt
#setDrawView place
#connect_std_cells_to_power
#redraw
#
## Check FIXED and PLACED cells for violations, add violation markers to the design display area
#checkPlace
#
## Build the static timing model of the design
#buildTimingGraph


##################################################
# Do preCTS optimization
##################################################

#Puts "###########################"
#Puts "###"
#Puts "### PreCTS Optimization ..."
#Puts "###"
#Puts "###########################"
#
##set_dont_touch clkloc_inst
#setOptMode -yieldEffort none ; # Default is none
#setOptMode -effort high ; # man setOptMode and see the effort table
#setOptMode -maxDensity 0.95 ; # Default is 0.95 (netlist won't grow above this value)
#setOptMode -drcMargin 0.0 ; # Default is 0
##setOptMode -holdTargetSlack 0.0 
#setOptMode -holdTargetSlack 0.2
#setOptMode -setupTargetSlack 0.0
#setOptMode -SimplifyNetlist false ; # When true, simplifies the netlist to decrease congestion, area, and improve runtime
#clearClockDomains
#setOptMode -usefulSkew false
#
#
## Perform timing optimization before or after the clock tree is built, or after routing and generate timing reports
## Notes: '-preCTS' option performs timing optimization on the placed design, before the clock tree is built
# optDesign -preCTS
#connect_std_cells_to_power
#applyGlobalNets
## Save design
#redraw
#saveDesign "$design_name.placed.enc"


####################################################
# Do clock tree synthesis
####################################################

#Puts "############################"
#Puts "###"
#Puts "### Clock Tree Synthesis ..."
#Puts "###"
#Puts "############################"
#
## Set global analysis modes for timing analysis
## Notes: '-cppr' option removes pessimism from clock paths
##        '-analysisType bcwc' option checks the design for two extreme conditions
##setAnalysisMode -cppr both
#setAnalysisMode -analysisType bcwc
#
#
#update_constraint_mode -name typical_constraint -sdc_file "../../dc/$design_name/$design_name.syn.mod.sdc"
## Control certain aspects of how the NanoRoute router routes the design (uncomment if necessary)
## setNanoRouteMode -quiet -routeTopRoutingLayer 3
#
##Declare the analysis views to be used during ccopt_design
#set_analysis_view -setup {typical} -hold {typical}
## Define route types
#create_route_type -name leaf_rule -top_preferred_layer M5 -bottom_preferred_layer M4
#create_route_type -name trunk_rule -top_preferred_layer M5 -bottom_preferred_layer M4
#create_route_type -name top_rule -top_preferred_layer M5 -bottom_preferred_layer M4
## Specify route types
#set_ccopt_property -net_type leaf route_type leaf_rule
#set_ccopt_property -net_type trunk route_type trunk_rule
#set_ccopt_property -net_type top route_type top_rule
#set_ccopt_property routing_top_min_fanout 10000
## 
## Specify the buffer and inverter cells for CTS 
#set_ccopt_property inverter_cells [list CKND1 CKND12 CKND16 CKND2 CKND20 CKND24 CKND3 CKND4 CKND6 CKND8]
#set_ccopt_property buffer_cells [list CKBD1 CKBD12 CKBD16 CKBD2 CKBD20 CKBD24 CKBD3 CKBD4 CKBD6 CKBD8]
#
##use inverteres instead of buffers
#set_ccopt_property use_inverters true
#
## Specify the target skew for clock tree balancing (Change skew !!!!!!!!)
##set_ccopt_property target_max_trans 35ps
#set_ccopt_property target_skew 20ps
#
## Create a clock tree network with associated skew groups and other CTS configuration settings
#create_ccopt_clock_tree_spec -file ccopt_clock_tree.spec
#source "./ccopt_clock_tree.spec"
#
## Perform clock concurrent optimization (CCOpt) on the current loaded design in Innovus
## CCOpt optimizes both the clock tree and the datapath to meet global timing constraints
#ccopt_design -cts
#
## Generate skew and clock tree report
#report_ccopt_skew_groups -file "$design_name.ccopt.skew.rpt"
#report_ccopt_clock_trees -file "$design_name.ccopt.clk_tree.rpt"
#
## Save design
#connect_std_cells_to_power
#redraw
#saveDesign "$design_name.clock.enc"
#savePlace "$design_name.place"


##################################################
# Route signals
##################################################

# Unfix the clock nets to avoid routing problems
# changeUseClockNetStatus -noFixedNetWires

#Puts "###############################################################"
#Puts "###"
#Puts "### Route Critical Signal First (uncomment if necessary!!!) ..."
#Puts "###"
#Puts "###############################################################"

############### Route resetn first ###############
# Attach attributes to nets / Attaching the attributes allows the NanoRoute routing commands
#setAttribute -net rstn -weight 5 -avoid_detour true -bottom_preferred_routing_layer 2 \
#            -top_preferred_routing_layer 3 -preferred_extra_space 2

# Select a net and highlight it in the design display window
#selectNet rstn

# Control certain aspects of how the NanoRoute router routes the design
#setNanoRouteMode -quiet -routeWithTimingDriven true
#setNanoRouteMode -quiet -routeSelectedNetOnly true
#setNanoRouteMode -quiet -routeTopRoutingLayer 4
#setNanoRouteMode -quiet -routeBottomRoutingLayer 1

# Use the NanoRoute router to perform both global and detailed routing with one command
#globalDetailRoute

#redraw
##################################################

Puts "###########################"
Puts "###"
Puts "### Route Other Signals ..."
Puts "###"
Puts "###########################"

############## Route all other nets ##############
setNanoRouteMode -quiet -routeSelectedNetOnly false
setNanoRouteMode -quiet -routeWithTimingDriven true
setNanoRouteMode -quiet -routeTdrEffort 10
setNanoRouteMode -quiet -drouteFixAntenna true
setNanoRouteMode -quiet -routeWithSiDriven true
setNanoRouteMode -quiet -routeSiLengthLimit 200
setNanoRouteMode -quiet -routeSiEffort high
setNanoRouteMode -quiet -routeWithViaInPin false
setNanoRouteMode -quiet -routeWithViaOnlyForStandardCellPin false
setNanoRouteMode -quiet -droutePostRouteSwapVia none
setNanoRouteMode -quiet -drouteUseMultiCutViaEffort low
setNanoRouteMode -routeTopRoutingLayer 8
setNanoRouteMode -routeBottomRoutingLayer 1
setNanoRouteMode -drouteElapsedTimeLimit 0


globalDetailRoute
deleteAllRouteBlks
redraw
##################################################


##################################################
# Extract and optimize
##################################################

Puts "######################################"
Puts "###"
Puts "### RC Extraction and Optimization ..."
Puts "###"
Puts "######################################"

# Set the native RC extraction mode
# Notes: This command should be used before using the extractRC command
setExtractRCMode -engine postRoute -effortLevel low 

# Extract resistance and capacitance for the interconnects and store the results in an RC database
extractRC

# Save design 
saveDesign "$design_name.routed.enc"


##################################################
# Verify the design
##################################################

Puts "##############"
Puts "###"
Puts "### Verify ..."
Puts "###"
Puts "##############"

# Clear all design rule checking (DRC) markers in your design
clearDrc
verify_drc
verifyGeometry

# Detect conditions such as opens, unconnected wires, unconnected pins, loops, partial routing, and unrouted nets
# Generate violation markers in the design window
verifyConnectivity -type regular -error 1000 -warning 50

# Verify process antenna effect (PAE) and maximum floating area violations
verifyProcessAntenna

##################################################
# Produce outputs
##################################################

Puts "#######################"
Puts "###"
Puts "### Produce Outputs ..."
Puts "###"
Puts "#######################"

# Report
report_power -leakage -cap -nworst -pg_pin -outfile "$design_name.power.rpt"

# Generate hierarchical design abstract (LEF) information for the current routed block-level design
#write_lef_abstract "$design_name.lef" -5.7 -PgpinLayers {5 6} -specifyTopLayer 6 -stripePin
write_lef_abstract "$design_name.lef" -5.7 -PgpinLayers 7 -specifyTopLayer 7 -stripePin

# Write the specified information to a DEF file
defOut -floorplan -netlist -routing "$design_name.final.def"

# Create a GDSII file of the current database
# Notes: '-mapFile' option specifies the file used for layer mapping
#        '-libName' option specifies the library to convert to GDSII Stream format
streamOut "$design_name.gds" -mapFile "../layermap/tsmc65_6350_spring24.layermap" -libName tcbn65gplus -structureName $design_name -units 1000 -mode ALL 

# Write a netlist file of the design
# Notes: '-phys' option writes out physical cell instances, and inserts power and ground nets in the netlist
saveNetlist -phys -excludeLeafCell -excludeCellInst "FILL64 FILL32 FILL16 FILL8 FILL4 FILL2 FILL1" "$design_name.phy.v"
saveNetlist "$design_name.nophy.v"
saveNetlist -includePhysicalCell "DCAP64 DCAP32 DCAP16 DCAP8 DCAP4" -includePowerGround -excludeLeafCell -excludeCellInst "FILL64 FILL32 FILL16 FILL8 FILL4 FILL2 FILL1" "$design_name.PG.v"

# Extract RC information
extractRC -outfile "$design_name.cap"
rcOut -spef "$design_name.spef"

# Write delays to a Standard Delay Format (SDF) file
write_sdf -version 2.1 "$design_name.sdf"
write_sdf -version 2.1 -target_application verilog "$design_name.verilog.sdf"

# Report hold/setup violation
setAnalysisMode -checkType hold -useDetailRC true
report_timing -check_type hold -nworst 5 > "$design_name.hold.rpt"
setAnalysisMode -checkType setup -useDetailRC true
report_timing -check_type setup -nworst 5 > "$design_name.setup.rpt"
reportCapViolation -outfile final_cap.tarpt

# Run DRC and connection checks
verifyGeometry
verifyConnectivity -type all

# Report statistics for the entire design
summaryReport -outfile "$design_name.summary.rpt"

# Generate a file containing a list of nets which have critical slack of the currently specified timing analysis mode
reportCritNet -outfile "$design_name.critnet.rpt"

do_extract_model "$design_name.lib" -view typical



puts "########################################"
puts "#                                      #"
puts "# And finally ...                      #"
puts "#                                      #"
puts "# Encounter script finished            #"
puts "#                                      #"
puts "########################################"

#exit
