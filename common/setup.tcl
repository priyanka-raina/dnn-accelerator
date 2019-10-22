if { [info hostname] == "r6cad-tsmc28.stanford.edu"} {
    source [file join [file dirname [info script]] "tsmc28_setup.tcl"] 
} elseif { [info hostname] == "r6cad-tsmc40r.stanford.edu" } {
    source [file join [file dirname [info script]] "tsmc40_setup.tcl"] 
}

set mw_design_library ${design_name}_mwlib

file delete -force $mw_design_library

create_mw_lib -technology $tech_file -mw_reference_library $mw_reference_libraries -bus_naming_style {[%d]} $mw_design_library

open_mw_lib $mw_design_library

check_library

set_tlu_plus_files -max_tluplus $max_tluplus \
        -tech2itf_map $map_file

check_tlu_plus_files
