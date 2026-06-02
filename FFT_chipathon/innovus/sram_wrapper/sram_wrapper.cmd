#######################################################
#                                                     
#  Innovus Command Logging File                     
#  Created on Sat May  2 18:33:45 2026                
#                                                     
#######################################################

#@(#)CDS: Innovus v21.16-s078_1 (64bit) 12/07/2022 12:07 (Linux 3.10.0-693.el7.x86_64)
#@(#)CDS: NanoRoute 21.16-s078_1 NR221206-1807/21_16-UB (database version 18.20.600) {superthreading v2.17}
#@(#)CDS: AAE 21.16-s035 (64bit) 12/07/2022 (Linux 3.10.0-693.el7.x86_64)
#@(#)CDS: CTE 21.16-s024_1 () Dec  5 2022 05:41:45 ( )
#@(#)CDS: SYNTECH 21.16-s009_1 () Nov  9 2022 03:47:50 ( )
#@(#)CDS: CPE v21.16-s066
#@(#)CDS: IQuantus/TQuantus 21.1.1-s939 (64bit) Wed Nov 9 09:34:24 PST 2022 (Linux 3.10.0-693.el7.x86_64)

set_global _enable_mmmc_by_default_flow      $CTE::mmmc_default
suppressMessage ENCEXT-2799
set init_verilog ../../dc/sram_wrapper/sram_wrapper.nl.PG.v
set init_io_file ./sram_wrapper.io
set init_lef_file {/courses/ee6350/pdk2025/tcbn65gplus/TSMCHOME/digital/Back_End/lef/tcbn65gplus_200a/lef/tcbn65gplus_9lmT2.lef ../../memory_compiler/single_port_sram/sram00.vclef }
set init_mmmc_file ./mmmc.view
setImportMode -treatUndefinedCellAsBbox 0 -keepEmptyModule 1
set init_import_mode {-treatUndefinedCellAsBbox 0 -keepEmptyModule 1}
set init_pwr_net VDD
set init_gnd_net VSS
set_message -no_limit
set_message -id TECHLIB-1467 -limit 10
setMultiCpuUsage -localCpu max -acquireLicense 8
init_design
floorPlan -s 586.59 82.8 4.5 4.5 4.5 4.5
redraw
fit
placeInstance u_sram 4.4 17.8 R0 -fixed
checkPlace
redraw
fit
createPlaceBlockage -box 0 14.8 650 600
redraw
fit
globalNetConnect VDD -type tiehi -inst * -verbose
globalNetConnect VSS -type tielo -inst * -verbose
globalNetConnect VDD -type pgpin -pin VDD -inst * -verbose
globalNetConnect VSS -type pgpin -pin VSS -inst * -verbose
applyGlobalNets
addRing -nets {VDD VSS} -type core_rings -layer {top M5 bottom M5 left M6 right M6} -width 1 -spacing 0.5 -center 1 -extend_corner {lt lb rt rb}
redraw
fit
addStripe -block_ring_top_layer_limit M6 -block_ring_bottom_layer_limit M6 -padcore_ring_top_layer_limit M6 -padcore_ring_bottom_layer_limit M6 -max_same_layer_jog_length 6 -merge_stripes_value 4 -layer M6 -set_to_set_distance 8 -direction vertical -nets {VDD VSS} -width 1 -spacing 0.5 -area {0 0 588 100}
sroute -nets {VDD VSS} -connect { blockPin corePin floatingStripe } -layerChangeRange { M1 M6 } -allowJogging 1 -crossoverViaLayerRange { M1 M6 }
loadIoFile ./sram_wrapper.io
redraw
saveDesign sram_wrapper.floorplan.enc
setDesignMode -process 65 -flowEffort standard
setRouteMode -earlyGlobalMaxRouteLayer 5
setPinAssignMode -maxLayer 5
setNanoRouteMode -routeTopRoutingLayer 5
setDesignMode -topRoutingLayer M5
setPlaceMode -timingDriven true -congEffort high
setOptMode -fixFanoutLoad true -effort high -moveInst true -reclaimArea true
place_design
globalNetConnect VDD -type tiehi -inst * -verbose
globalNetConnect VSS -type tielo -inst * -verbose
globalNetConnect VDD -type pgpin -pin VDD -inst * -verbose
globalNetConnect VSS -type pgpin -pin VSS -inst * -verbose
redraw
checkPlace
buildTimingGraph
optDesign -preCTS
redraw
saveDesign sram_wrapper.placed.enc
update_constraint_mode -name typical_constraint -sdc_file "../../dc/$design_name/$design_name.syn.mod.sdc"
set_analysis_view -setup {typical} -hold {typical}
create_route_type -name top -preferred_routing_layer_effort medium -top_preferred_layer 3 -bottom_preferred_layer 2
create_route_type -name trunk -preferred_routing_layer_effort medium -top_preferred_layer 3 -bottom_preferred_layer 2
create_route_type -name leaf -preferred_routing_layer_effort medium -top_preferred_layer 3 -bottom_preferred_layer 2
set_ccopt_property route_type -net_type top top
set_ccopt_property route_type -net_type trunk trunk
set_ccopt_property route_type -net_type leaf leaf
set_ccopt_property inverter_cells {CKND0 CKND1 CKND2 CKND3 CKND4 CKND6 CKND8 CKND12 CKND16 CKND20 CKND24}
set_ccopt_property buffer_cells {CKBD0 CKBD1 CKBD2 CKBD3 CKBD4 CKBD6 CKBD8 CKBD12 CKBD16 CKBD20 CKBD24}
set_ccopt_property use_inverters true
set_ccopt_property target_skew 20ps
create_ccopt_clock_tree_spec -file ccopt_clock_tree.spec
get_ccopt_clock_trees
ccopt_check_and_flatten_ilms_no_restore
set_ccopt_property cts_is_sdc_clock_root -pin clk true
create_ccopt_clock_tree -name clk -source clk -no_skew_group
set_ccopt_property target_max_trans_sdc -delay_corner typical_dly -early -clock_tree clk 0.040
set_ccopt_property target_max_trans_sdc -delay_corner typical_dly -late -clock_tree clk 0.040
set_ccopt_property source_driver -clock_tree clk {INVD0/I INVD0/ZN}
set_ccopt_property source_max_capacitance -clock_tree clk 0.005
set_ccopt_property clock_period -pin clk 2
set_ccopt_property timing_connectivity_info {}
create_ccopt_skew_group -name clk/typical_constraint -sources clk -auto_sinks
set_ccopt_property include_source_latency -skew_group clk/typical_constraint true
set_ccopt_property extracted_from_clock_name -skew_group clk/typical_constraint clk
set_ccopt_property extracted_from_constraint_mode_name -skew_group clk/typical_constraint typical_constraint
set_ccopt_property extracted_from_delay_corners -skew_group clk/typical_constraint typical_dly
check_ccopt_clock_tree_convergence
get_ccopt_property auto_design_state_for_ilms
ccopt_design
report_ccopt_skew_groups -file sram_wrapper.ccopt.skew.rpt
report_ccopt_clock_trees -file sram_wrapper.ccopt.clk_tree.rpt
globalNetConnect VDD -type tiehi -inst * -verbose
globalNetConnect VSS -type tielo -inst * -verbose
globalNetConnect VDD -type pgpin -pin VDD -inst * -verbose
globalNetConnect VSS -type pgpin -pin VSS -inst * -verbose
redraw
saveDesign sram_wrapper.clock.enc
getPlaceMode -doneQuickCTS -quiet
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
setExtractRCMode -engine postRoute -effortLevel low -coupled true
extractRC
setAnalysisMode -analysisType onChipVariation
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
optDesign -postRoute -setup -hold
globalNetConnect VDD -type pgpin -pin VDD -override
globalNetConnect VSS -type pgpin -pin VSS -override
globalNetConnect VDD -type tiehi
globalNetConnect VSS -type tielo
applyGlobalNets
saveDesign sram_wrapper.routed.enc
verify_drc
addFiller -cell DCAP64 DCAP32 DCAP16 DCAP8 DCAP4 FILL64 FILL32 FILL16 FILL8 FILL4 FILL2 FILL1 -prefix FILLER
verify_drc
redraw
clearDrc
verify_drc
verifyConnectivity -type regular -error 1000 -warning 50
verifyProcessAntenna
report_power -leakage -cap -nworst -pg_pin -outfile sram_wrapper.power.rpt
write_lef_abstract sram_wrapper.lef -5.7 -PgpinLayers 6 -specifyTopLayer 6 -stripePin
defOut -floorplan -netlist -routing sram_wrapper.final.def
streamOut sram_wrapper.gds -mapFile ../layermap/tsmc65_6350_spring24.layermap -libName tcbn65gplus -structureName sram_wrapper -units 1000 -mode ALL
saveNetlist -phys -excludeLeafCell -excludeCellInst {FILL1 FILL2 FILL4 FILL8 FILL16 FILL32 FILL64 FILL1_LL FILL_NW_FA_LL FILL_NW_HH FILL_NW_LL} sram_wrapper.phy.v
saveNetlist sram_wrapper.nophy.v
saveNetlist -includePhysicalCell {DCAP64 DCAP32 DCAP16 DCAP8 DCAP4} -includePowerGround -excludeLeafCell -excludeCellInst {FILL64 FILL32 FILL16 FILL8 FILL4 FILL2 FILL1} sram_wrapper.PG.v
extractRC -outfile sram_wrapper.cap
rcOut -spef sram_wrapper.spef
write_sdf -version 2.1 "$design_name.sdf"
write_sdf -version 2.1 -target_application verilog "$design_name.verilog.sdf"
setAnalysisMode -checkType hold -useDetailRC true
report_timing -check_type hold -nworst 5 > "$design_name.hold.rpt"
setAnalysisMode -checkType setup -useDetailRC true
report_timing -check_type setup -nworst 5 > "$design_name.setup.rpt"
reportCapViolation -outfile final_cap.tarpt
verifyConnectivity -type all
summaryReport -outfile sram_wrapper.summary.rpt
reportCritNet -outfile sram_wrapper.critnet.rpt
do_extract_model "$design_name.lib" -view typical
