##################################################
# Innovus Script
##################################################


##################################################
# Setup design
##################################################

set design_name sram_wrapper
source ./config.globals
set_message -no_limit
set_message -id {TECHLIB-1467} -limit 10
setMultiCpuUsage -localCpu max -acquireLicense 8
init_design

##################################################
# Set parameters for the floorplan
##################################################

set std_cell_height 1.8
set core_width 586.59
#set core_height [expr 268*$std_cell_height]
set core_height [expr 46*$std_cell_height]
set ring_left_width 1
set ring_right_width 1
set ring_top_width 1
set ring_bottom_width 1
set ring_left_space 0.5
set ring_right_space 0.5
set ring_top_space 0.5
set ring_bottom_space 0.5


##################################################
# Create the floorplan
##################################################

# Specify the floorplan dimensions by size; or by die, I/O, or core coordinates (Need modification)
floorPlan -s $core_width $core_height [expr 2*$ring_left_width + $ring_left_space + 2] \
[expr 2*$ring_bottom_width + $ring_bottom_space +2] [expr 2*$ring_right_width + $ring_right_space +2] \
[expr 2*$ring_top_width + $ring_top_space + 2]
redraw
fit

set sram00_inst_x 4.4
set sram00_inst_y 17.8

set sram00_width 586.59
set sram00_height 372.965

placeInstance u_sram [expr $sram00_inst_x] [expr $sram00_inst_y] R0 -fixed
checkPlace
redraw
fit

#createPlaceBlockage -box {0 14.8 650 600}
createPlaceBlockage -box 0 [expr $sram00_inst_y - 3] 650 600
redraw
fit



##################################################
# Generate power rails 
##################################################

# Adds a new global net connection to the specified global net
proc connect_std_cells_to_power { } {

    # Connect the tiehi, tiolo nets in instances to the global nets 'VDD' & 'VSS'
    globalNetConnect VDD -type tiehi -inst * -verbose
    globalNetConnect VSS -type tielo -inst * -verbose

    # Connect the power pins in instances to the global nets 'VDD' & 'VSS'
    globalNetConnect VDD -type pgpin -pin VDD -inst * -verbose
    globalNetConnect VSS -type pgpin -pin VSS -inst * -verbose
}

Puts "#####################"
Puts "###"
Puts "### Power Routing ..."
Puts "###"
Puts "#####################"

connect_std_cells_to_power
# Apply and restore the global net connectivity rules to the the design
# and creates the necessary connecktions between instances and these global nets
applyGlobalNets


# Create rings for specified nets round the core boundary or selected blocks and groups of core rows
# Notes: This command should be used after creating an initial floorplan
#        Need to use different metal layers for horizontal and vertical lines (e.g. even: vertical, odd: horizontal)
addRing -nets {VDD VSS} -type core_rings -layer {top M5 bottom M5 left M6 right M6} -width $ring_top_width \
        -spacing $ring_top_space -center 1 \
	    -extend_corner {lt lb rt rb}

# GUI only
redraw
fit

# Route power nets
#sroute -nets {VDD VSS} -allowJogging 0 -allowLayerChange 0

# Add vertical power rails (Need modification)
#addStripe -block_ring_top_layer_limit M6 \
#	  -block_ring_bottom_layer_limit M6 \
#	  -padcore_ring_top_layer_limit M6 \
#	  -padcore_ring_bottom_layer_limit M6 \
#          -max_same_layer_jog_length 6 \
#          -merge_stripes_value 4 \
#	  -layer M6 \
#          -set_to_set_distance 8 \
#          -direction vertical \
#          -nets {VDD VSS} \
#	  -width 1 \
#	  -spacing 0.5 -area {8.95 4.4 588 388.6}

addStripe -block_ring_top_layer_limit M6 \
	  -block_ring_bottom_layer_limit M6 \
	  -padcore_ring_top_layer_limit M6 \
	  -padcore_ring_bottom_layer_limit M6 \
          -max_same_layer_jog_length 6 \
          -merge_stripes_value 4 \
	  -layer M6 \
          -set_to_set_distance 8 \
          -direction vertical \
          -nets {VDD VSS} \
	  -width 1 \
	  -spacing 0.5 -area {0 0 588 100}



sroute -nets {VDD VSS} \
       -connect { blockPin corePin floatingStripe } \
       -layerChangeRange { M1 M6 } \
       -allowJogging 1 \
       -crossoverViaLayerRange { M1 M6 }

#createRouteBlk -layer 1 2 3 4 5 6 -cutLayer all -box [expr $sram00_inst_x + 0.5] [expr $sram00_inst_y + 0.5] [expr $sram00_inst_x + $sram00_width - 0.5] [expr $sram00_inst_y + $sram00_height - 0.5]
#redraw
#fit

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

Puts "####################"
Puts "###"
Puts "### Place Design ..."
Puts "###"
Puts "####################"

# Defines the process technology value 
setDesignMode -process 65 -flowEffort standard
# Specify a routing layer limit for Early Global Route
setMaxRouteLayer 5

# Control certain aspects of how the software places cells
setPlaceMode -timingDriven true -congEffort high

# Set global parameters for timing optimization
setOptMode -fixFanoutLoad true -effort high -moveInst true -reclaimArea true

# Place stanard cells based on the global settings for placement, RC extraction, and timing analysis
place_design

connect_std_cells_to_power
redraw

# Check FIXED and PLACED cells for violations, add violation markers to the design display area
checkPlace

# Build the static timing model of the design
buildTimingGraph


##################################################
# Do preCTS optimization
##################################################

Puts "###########################"
Puts "###"
Puts "### PreCTS Optimization ..."
Puts "###"
Puts "###########################"

#set_dont_touch clkloc_inst

# Perform timing optimization before or after the clock tree is built, or after routing and generate timing reports
# Notes: '-preCTS' option performs timing optimization on the placed design, before the clock tree is built
 optDesign -preCTS

# Save design
redraw
saveDesign "$design_name.placed.enc"


####################################################
### Do clock tree synthesis
####################################################

Puts "############################"
Puts "###"
Puts "### Clock Tree Synthesis ..."
Puts "###"
Puts "############################"

# Set global analysis modes for timing analysis
# Notes: '-cppr' option removes pessimism from clock paths
#        '-analysisType bcwc' option checks the design for two extreme conditions
#setAnalysisMode -cppr both
update_constraint_mode -name typical_constraint -sdc_file "../../dc/$design_name/$design_name.syn.mod.sdc"
set_analysis_view -setup {typical} -hold {typical}

# Control certain aspects of how the NanoRoute router routes the design (uncomment if necessary)
# setNanoRouteMode -quiet -routeTopRoutingLayer 3

# Create a new route type and set the routing properties for the nets
# Notes: 'preferred_routing_layer_effort' specify whether the preferred routing layer effort will be low, medium, or high
create_route_type -name top -preferred_routing_layer_effort medium -top_preferred_layer 3 -bottom_preferred_layer 2
create_route_type -name trunk -preferred_routing_layer_effort medium -top_preferred_layer 3 -bottom_preferred_layer 2
create_route_type -name leaf -preferred_routing_layer_effort medium -top_preferred_layer 3 -bottom_preferred_layer 2

# Specify the route type
# Setting this property binds an existing user-defiend route_type to one or more types of clock tree nets
set_ccopt_property route_type -net_type top top
set_ccopt_property route_type -net_type trunk trunk
set_ccopt_property route_type -net_type leaf leaf

##TESTING THESE COMMANDS FROM THE IMCU PROJECT, DUE TO AN ERROR THAT STOPS THE SCRIPT
##NOT REQUIRED ANYMORE - JUST LEA
#####################################################################################
#set_ccopt_property sink_type -pin imem/imem/CLK ignore
#set_ccopt_property sink_type_reasons -pin imem/imem/CLK  no_sdc_clock
#set_ccopt_property sink_type -pin imem/imem/CLK ignore
#set_ccopt_property sink_type_reasons -pin imem/imem/CLK no_sdc_clock

#set_ccopt_property -pin imem/imem/CLK sink_type stop
#set_ccopt_property -pin imem/imem/CLK sink_type ignore
#set_ccopt_property -pin imem/imem/CLK sink_type stop
#set_ccopt_property -pin imem/imem/CLK sink_type ignore
######################################################################################

# Specify the buffer and inverter cells for CTS 
set_ccopt_property inverter_cells [list CKND0 CKND1 CKND2 CKND3 CKND4 CKND6 CKND8 CKND12 CKND16 CKND20 CKND24]
set_ccopt_property buffer_cells [list CKBD0 CKBD1 CKBD2 CKBD3 CKBD4 CKBD6 CKBD8 CKBD12 CKBD16 CKBD20 CKBD24]
set_ccopt_property use_inverters true

# Specify the target skew for clock tree balancing (Change skew !!!!!!!!)
#set_ccopt_property target_max_trans 20ps
set_ccopt_property target_skew 20ps

# Create a clock tree network with associated skew groups and other CTS configuration settings
create_ccopt_clock_tree_spec -file ccopt_clock_tree.spec
source "./ccopt_clock_tree.spec"

# Perform clock concurrent optimization (CCOpt) on the current loaded design in Innovus
# CCOpt optimizes both the clock tree and the datapath to meet global timing constraints
# Paul added: -cts 
ccopt_design

# Generate skew and clock tree report
report_ccopt_skew_groups -file "$design_name.ccopt.skew.rpt"
report_ccopt_clock_trees -file "$design_name.ccopt.clk_tree.rpt"

# Save design
connect_std_cells_to_power
redraw
saveDesign "$design_name.clock.enc"
savePlace "$design_name.place"


##################################################
# Route signals
##################################################

# Unfix the clock nets to avoid routing problems
 changeUseClockNetStatus -noFixedNetWires

Puts "###############################################################"
Puts "###"
Puts "### Route Critical Signal First (uncomment if necessary!!!) ..."
Puts "###"
Puts "###############################################################"

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
setNanoRouteMode -quiet -routeWithViaInPin true
setNanoRouteMode -quiet -routeWithViaOnlyForStandardCellPin false
setNanoRouteMode -quiet -droutePostRouteSwapVia none
setNanoRouteMode -quiet -drouteUseMultiCutViaEffort high
setNanoRouteMode -routeTopRoutingLayer 5
setNanoRouteMode -routeBottomRoutingLayer 1

globalDetailRoute
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
setExtractRCMode -engine postRoute -effortLevel low -coupled true

# Extract resistance and capacitance for the interconnects and store the results in an RC database
extractRC

# Set global analysis modes for timing analysis
# Notes: '-analysisType onChipVaration' option calculates the delay for one path based on maximum operation
#        condition while calculating the delay for another path based on minimum operating condition
#        for setup or hold checks
setAnalysisMode -analysisType onChipVariation

# Set global parameters for timing optimization
setOptMode -yieldEffort none
setOptMode -effort high
setOptMode -drcMargin 0.0
setOptMode -holdTargetSlack 0.1 -setupTargetSlack 0.1
setOptMode -holdFixingEffort high
setOptMode -simplifyNetlist false
setOptMode -usefulSkew false
setOptMode -moveInst true
setOptMode -reclaimArea true
setOptMode -fixDRC true
setOptMode -fixCap true

# Perform timing optimization before or after the clock tree is built, or after routing
# Notes: '-hold' option corrects hold violations
#        '-postRoute' option performs timing optimization on a design whose routing is complete
optDesign -postRoute -setup -hold 

# Connect all new cells to VDD/GND
globalNetConnect VDD -type pgpin -pin {VDD} -override
globalNetConnect VSS -type pgpin -pin {VSS} -override
globalNetConnect VDD -type tiehi
globalNetConnect VSS -type tielo
applyGlobalNets

# Save design 
saveDesign "$design_name.routed.enc"


##################################################
# Add decap or fillers
##################################################

Puts "############################"
Puts "###"
Puts "### Add Decap or Fillers ..."
Puts "###"
Puts "############################"

# Check width, spacing, and internal geometry of objects and the wiring between them
# Create and save violation markers in the design database
verify_drc

# Add filler cells 
# Notes: '-cell' option specifies the list of filler cells to add
# addFiller -cell FILL16TS FILL1TS FILL2TS FILL32TS FILL4TS FILL64TS FILL8TS -prefix IBM13RFLPVT_FILLER
addFiller -cell DCAP64 DCAP32 DCAP16 DCAP8 DCAP4 FILL64 FILL32 FILL16 FILL8 FILL4 FILL2 FILL1 -prefix FILLER
verifyGeometry
verify_drc
redraw


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
write_lef_abstract "$design_name.lef" -5.7 -PgpinLayers 6 -specifyTopLayer 6 -stripePin

# Write the specified information to a DEF file
defOut -floorplan -netlist -routing "$design_name.final.def"

# Create a GDSII file of the current database
# Notes: '-mapFile' option specifies the file used for layer mapping
#        '-libName' option specifies the library to convert to GDSII Stream format
streamOut "$design_name.gds" -mapFile "../layermap/tsmc65_6350_spring24.layermap" -libName tcbn65gplus -structureName $design_name -units 1000 -mode ALL 

# Write a netlist file of the design
# Notes: '-phys' option writes out physical cell instances, and inserts power and ground nets in the netlist
saveNetlist -phys -excludeLeafCell -excludeCellInst "FILL1 FILL2 FILL4 FILL8 FILL16 FILL32 FILL64 FILL1_LL FILL_NW_FA_LL FILL_NW_HH FILL_NW_LL" "$design_name.phy.v"
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
