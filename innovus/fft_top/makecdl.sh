#!/bin/bash

FN=fft_top

v2lvs -i \
-v $FN.PG.v \
-o $FN.cdl \
-s /courses/ee6350/pdk2025/tcbn65gplus/TSMCHOME/digital/Back_End/spice/tcbn65gplus_200a/tcbn65gplus_200a.spi \
-s /user/stud/fall25/dr3412/EECS6321_Adv_dig/fft/innovus/fft_controller/fft_controller.cdl \
-s /user/stud/fall25/dr3412/EECS6321_Adv_dig/fft/innovus/fft_core/fft_core.cdl \
-s /user/stud/fall25/dr3412/EECS6321_Adv_dig/fft/innovus/fft_address_gen/fft_address_gen.cdl \
-s /user/stud/fall25/dr3412/EECS6321_Adv_dig/fft/innovus/fft_twiddle_sram/fft_twiddle_sram.cdl \
-s /user/stud/fall25/dr3412/EECS6321_Adv_dig/fft/innovus/fft_data_sram/fft_data_sram.cdl \
-lsr /courses/ee6350/pdk2025/tcbn65gplus/TSMCHOME/digital/Back_End/spice/tcbn65gplus_200a/tcbn65gplus_200a.spi \
-lsr /user/stud/fall25/dr3412/EECS6321_Adv_dig/fft/innovus/fft_controller/fft_controller.cdl \
-lsr /user/stud/fall25/dr3412/EECS6321_Adv_dig/fft/innovus/fft_twiddle_sram/fft_twiddle_sram.cdl \
-lsr /user/stud/fall25/dr3412/EECS6321_Adv_dig/fft/innovus/fft_data_sram/fft_data_sram.cdl \
-lsr /user/stud/fall25/dr3412/EECS6321_Adv_dig/fft/innovus/fft_core/fft_core.cdl \
-lsr /user/stud/fall25/dr3412/EECS6321_Adv_dig/fft/innovus/fft_address_gen/fft_address_gen.cdl


cp ${FN}.cdl ${FN}.sp


#-lsr /courses/ee6350/pdk2025/tcbn65gplus/TSMCHOME/digital/Back_End/spice/tcbn65gplus_200a/tcbn65gplus_200a.spi \
#-lsr /user/stud/fall25/dr3412/EECS6321_Adv_dig/fft/innovus/fft_controller/fft_controller.cdl \
#-lsr /user/stud/fall25/dr3412/EECS6321_Adv_dig/fft/innovus/fft_twiddle_sram/fft_twiddle_sram.cdl \
#-lsr /user/stud/fall25/dr3412/EECS6321_Adv_dig/fft/innovus/fft_data_sram/fft_data_sram.cdl \
#-lsr /user/stud/fall25/dr3412/EECS6321_Adv_dig/fft/innovus/fft_core/fft_core.cdl \
#-lsr /user/stud/fall25/dr3412/EECS6321_Adv_dig/fft/innovus/sram_wrapper/sram_wrapper.cdl \
#-lsr /user/stud/fall25/dr3412/EECS6321_Adv_dig/fft/innovus/fft_address_gen/fft_address_gen.cdl
