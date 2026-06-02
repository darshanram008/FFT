/tools/misc/EE6321/arm/tsmc/cln65gplus/sram_sp_hdc_svt_rvt_hvt/r0p0-00eac0/bin/sram_sp_hdc_svt_rvt_hvt verilog \
    -instname sram00 -words 1024 -bits 32 -frequency 100 -mux 16 \
    -drive 6 -write_mask on -write_thru on -wp_size 8 \
    -top_layer m5-m9 -redundancy off -bmux off -ser none \
    -back_biasing off -power_gating off -atf off \
    -cust_comment "First Attempt" \
    -left_bus_delim "[" -right_bus_delim "]" \
    -prefix "" -name_case upper -check_instname on -diodes on \
    -pwr_gnd_rename VDDPE:VDD,VDDCE:VDD,VSSE:VSS

/tools/misc/EE6321/arm/tsmc/cln65gplus/sram_sp_hdc_svt_rvt_hvt/r0p0-00eac0/bin/sram_sp_hdc_svt_rvt_hvt synopsys \
    -instname sram00 -words 1024 -bits 32 -frequency 100 -mux 16 \
    -drive 6 -write_mask on -write_thru on -wp_size 8 \
    -top_layer m5-m9 -redundancy off -bmux off -ser none \
    -back_biasing off -power_gating off -atf off \
    -cust_comment "First Attempt" \
    -left_bus_delim "[" -right_bus_delim "]" \
    -prefix "" -name_case upper -check_instname on -diodes on \
    -pwr_gnd_rename VDDPE:VDD,VDDCE:VDD,VSSE:VSS

/tools/misc/EE6321/arm/tsmc/cln65gplus/sram_sp_hdc_svt_rvt_hvt/r0p0-00eac0/bin/sram_sp_hdc_svt_rvt_hvt lvs \
    -instname sram00 -words 1024 -bits 32 -frequency 100 -mux 16 \
    -drive 6 -write_mask on -write_thru on -wp_size 8 \
    -top_layer m5-m9 -redundancy off -bmux off -ser none \
    -back_biasing off -power_gating off -atf off \
    -cust_comment "First Attempt" \
    -left_bus_delim "[" -right_bus_delim "]" \
    -prefix "" -name_case upper -check_instname on -diodes on \
    -pwr_gnd_rename VDDPE:VDD,VDDCE:VDD,VSSE:VSS

/tools/misc/EE6321/arm/tsmc/cln65gplus/sram_sp_hdc_svt_rvt_hvt/r0p0-00eac0/bin/sram_sp_hdc_svt_rvt_hvt vclef-fp  \
    -instname sram00 -words 1024 -bits 32 -frequency 100 -mux 16 \
    -drive 6 -write_mask on -write_thru on -wp_size 8 \
    -top_layer m5-m9 -redundancy off -bmux off -ser none \
    -back_biasing off -power_gating off -atf off \
    -cust_comment "First Attempt" \
    -left_bus_delim "[" -right_bus_delim "]" \
    -prefix "" -name_case upper -check_instname on -diodes on \
    -pwr_gnd_rename VDDPE:VDD,VDDCE:VDD,VSSE:VSS

/tools/misc/EE6321/arm/tsmc/cln65gplus/sram_sp_hdc_svt_rvt_hvt/r0p0-00eac0/bin/sram_sp_hdc_svt_rvt_hvt gds2 \
    -instname sram00 -words 1024 -bits 32 -frequency 100 -mux 16 \
    -drive 6 -write_mask on -write_thru on -wp_size 8 \
    -top_layer m5-m9 -redundancy off -bmux off -ser none \
    -back_biasing off -power_gating off -atf off \
    -cust_comment "First Attempt" \
    -left_bus_delim "[" -right_bus_delim "]" \
    -prefix "" -name_case upper -check_instname on -diodes on \
    -pwr_gnd_rename VDDPE:VDD,VDDCE:VDD,VSSE:VSS

