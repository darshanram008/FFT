#!/bin/bash

FN=sram_wrapper

v2lvs -i -v $FN.PG.v -o $FN.cdl \
-s /courses/ee6350/pdk2025/tcbn65gplus/TSMCHOME/digital/Back_End/spice/tcbn65gplus_200a/tcbn65gplus_200a.spi \
-s /user/stud/fall25/dr3412/EECS6321_Adv_dig/fft/memory_compiler/single_port_sram/sram00.cdl \
-lsr /courses/ee6350/pdk2025/tcbn65gplus/TSMCHOME/digital/Back_End/spice/tcbn65gplus_200a/tcbn65gplus_200a.spi \
-lsr /user/stud/fall25/dr3412/EECS6321_Adv_dig/fft/memory_compiler/single_port_sram/sram00.cdl
 
cp ${FN}.cdl ${FN}.sp


