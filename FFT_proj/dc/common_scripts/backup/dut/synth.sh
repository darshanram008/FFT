MODULE_NAME=dut

# Synthesize
dc_shell -f module.tcl | tee log

# Add power and ground pins
echo "--> Producing $MODULE_NAME.nl.PG.v"
source "/courses/ee6350/pdk2025/miniconda3/bin/activate"
python add_pg.py $MODULE_NAME
