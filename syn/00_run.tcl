set_host_options -max_cores 8

set user_name $::env(USER)
set design_name dnn-accelerator

set rtl_dir /home/$user_name/$design_name/rtl
set syn_dir /sim/$user_name/$design_name/syn

file mkdir $syn_dir

source /home/$user_name/$design_name/syn/dc_setup.tcl
source /home/$user_name/$design_name/syn/synth.tcl
