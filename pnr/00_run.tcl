set_host_options -max_cores 12

set user_name $::env(USER)
set design_name conv_rtl

set rtl_dir ../rtl
set syn_dir ../syn
set par_dir .

source -echo ./01_design_setup.tcl
source -echo ./02_design_planning.tcl
source -echo ./03_placement.tcl
source -echo ./04_cts.tcl
source -echo ./05_route.tcl
source -echo ./06_dfm.tcl
source -echo ./07_streamout.tcl
