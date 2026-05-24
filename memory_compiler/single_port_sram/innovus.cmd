#######################################################
#                                                     
#  Innovus Command Logging File                     
#  Created on Thu Apr 23 11:16:17 2026                
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
win
set_message -no_limit
set_message -id TECHLIB-1467 -limit 10
setMultiCpuUsage -localCpu max -acquireLicense 8
init_design
floorPlan -s 468 468.0 4.5 4.5 4.5 4.5
redraw
fit
zoomBox -0.04100 -0.02300 0.13600 0.14700
zoomBox -0.06300 -0.03800 0.14600 0.16300
zoomBox -0.08900 -0.05500 0.15800 0.18200
zoomBox -0.00700 -0.00300 0.12200 0.12100
placeInstance sram00_inst 4.4 17.8 R0 -fixed
placeInstance u_sram 4.4 17.8 R0 -fixed
set_message -no_limit
set_message -id TECHLIB-1467 -limit 10
setMultiCpuUsage -localCpu max -acquireLicense 8
init_design
set init_verilog ../../dc/sram_wrapper/sram_wrapper.nl.PG.v
set_message -no_limit
set_message -id TECHLIB-1467 -limit 10
setMultiCpuUsage -localCpu max -acquireLicense 8
