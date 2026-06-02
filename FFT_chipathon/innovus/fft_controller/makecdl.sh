#!/bin/bash

FN=fft_controller

v2lvs -i -v $FN.PG.v \
-o $FN.cdl -s /courses/ee6350/pdk2025/tcbn65gplus/TSMCHOME/digital/Back_End/spice/tcbn65gplus_200a/tcbn65gplus_200a.spi -lsr /courses/ee6350/pdk2025/tcbn65gplus/TSMCHOME/digital/Back_End/spice/tcbn65gplus_200a/tcbn65gplus_200a.spi
 
cp ${FN}.cdl ${FN}.sp


