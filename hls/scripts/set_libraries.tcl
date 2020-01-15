if { [info hostname] == "r6cad-tsmc28.stanford.edu"} {
    source [file join [file dirname [info script]] "tsmc28_libraries.tcl"]
} elseif { [info hostname] == "r6cad-tsmc40r.stanford.edu" || [info hostname] == "r7cad-tsmc40r.stanford.edu" } {
    source [file join [file dirname [info script]] "tsmc40_libraries.tcl"]
} else {
    source [file join [file dirname [info script]] "generic_libraries.tcl"]
}
