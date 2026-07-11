project -new myTop.prj
add_file myAdder.v
add_file mySub.v
add_file myTop.v
set_option -technology VIRTEX4
set_option -part XC4VSX35
set_option -synthesis_onoff_pragma 0
set_option -frequency auto
project -run synthesis
