
##################################################
# Setup
##################################################
set design_name fft_top
source ./config.globals
set_message -no_limit
set_message -id {TECHLIB-1467} -limit 10
setMultiCpuUsage -localCpu max -acquireLicense 8

init_design
gui_show

##################################################
# Floorplan
##################################################
set core_width  750
set core_height 650
set ring_left_width 1
set ring_right_width 1
set ring_top_width 1
set ring_bottom_width 1
set ring_left_space 0.5
set ring_right_space 0.5
set ring_top_space 0.5
set ring_bottom_space 0.5
floorPlan -s $core_width $core_height 10 10 10 10
redraw; fit

##################################################
# Place macros
##################################################
placeInstance u_data_sram  72  52   R0 -fixed
placeInstance u_tw_sram    72  460  R0 -fixed
placeInstance u_core       72  240  R0 -fixed
placeInstance u_addr       190 240  R0 -fixed
placeInstance u_ctrl       240 240  R0 -fixed

checkPlace
redraw; fit

##################################################
# Global net connections
##################################################
globalNetConnect VDD -type pgpin -pin VDD -inst * -verbose
globalNetConnect VSS -type pgpin -pin VSS -inst * -verbose
applyGlobalNets

##################################################
# Core ring — M8 all sides (matches v7 which worked)
##################################################
addRing -nets {VDD VSS} -type core_rings -layer {top M8 bottom M8 left M7 right M7} -width $ring_top_width \
        -spacing $ring_top_space -center 1 \
	    -extend_corner {lt lb rt rb}

##################################################
# M6 vertical stripes — left corridor (X=10..62)
##################################################
addStripe -block_ring_top_layer_limit M7 \
	  -block_ring_bottom_layer_limit M7 \
	  -padcore_ring_top_layer_limit M7 \
	  -padcore_ring_bottom_layer_limit M7 \
          -max_same_layer_jog_length 6 \
          -merge_stripes_value 25 \
	  -layer M7 \
          -set_to_set_distance 8 \
          -direction horizontal \
          -nets {VDD VSS} \
	  -width 2 \
	  -spacing 2 -area {10 10 760 50}

addStripe -block_ring_top_layer_limit M7 \
	  -block_ring_bottom_layer_limit M7 \
	  -padcore_ring_top_layer_limit M7 \
	  -padcore_ring_bottom_layer_limit M7 \
          -max_same_layer_jog_length 6 \
          -merge_stripes_value 25 \
	  -layer M7 \
          -set_to_set_distance 8 \
          -direction horizontal \
          -nets {VDD VSS} \
	  -width 2 \
	  -spacing 2 -area {10 182 760 238}

addStripe -block_ring_top_layer_limit M7 \
	  -block_ring_bottom_layer_limit M7 \
	  -padcore_ring_top_layer_limit M7 \
	  -padcore_ring_bottom_layer_limit M7 \
          -max_same_layer_jog_length 6 \
          -merge_stripes_value 25 \
	  -layer M7 \
          -set_to_set_distance 8 \
          -direction horizontal \
          -nets {VDD VSS} \
	  -width 2 \
	  -spacing 2 -area {10 402 760 458}

addStripe -block_ring_top_layer_limit M7 \
	  -block_ring_bottom_layer_limit M7 \
	  -padcore_ring_top_layer_limit M7 \
	  -padcore_ring_bottom_layer_limit M7 \
          -max_same_layer_jog_length 6 \
          -merge_stripes_value 25 \
	  -layer M7 \
          -set_to_set_distance 8 \
          -direction horizontal \
          -nets {VDD VSS} \
	  -width 2 \
	  -spacing 2 -area {10 590 760 660}

##################################################
# M6 vertical stripes — right corridor (X=300..750)
# v7 used 760 which is past the 750 design boundary
# and triggered IMPPP-358.  Use 750 instead.
##################################################

##################################################
# sroute — connects all macro PG pins
# This is what made v7 succeed (685/685 ports routed).
##################################################
sroute \
    -connect { blockPin floatingStripe } \
    -nets { VDD VSS } \
    -allowJogging 1 \
    -allowLayerChange 1 \
    -blockPinTarget boundaryWithPin \
    -floatingStripeTarget stripe

redraw; fit

##################################################
# IO placement
##################################################
loadIoFile ./$design_name.io
redraw
saveDesign $design_name.floorplan.enc

##################################################
# NO placeDesign — there are 0 std cells.
# Calling placeDesign with empty design causes
# IMPSYT-6693 "too many nested evaluations" crash.
#
# Just set design modes for routing.
##################################################
puts "### Skipping placeDesign (no std cells to place)"



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
setNanoRouteMode -routeTopRoutingLayer 5
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
# Verify
##################################################
puts "### Verify ..."
clearDrc
verify_drc
verifyGeometry
verifyConnectivity -type regular -error 1000 -warning 50
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
puts "# Encounter script finished            #"
puts "########################################"
