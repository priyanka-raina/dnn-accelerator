set_host_options -max_cores 8

set user_name $::env(USER)
set design_name TopWithPHYAndCGRA

file mkdir $syn_dir

source /home/$user_name/digital/$design_name/syn/dc_setup.tcl
source /home/$user_name/digital/$design_name/syn/synth.tcl
