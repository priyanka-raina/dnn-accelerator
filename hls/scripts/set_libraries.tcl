if { [info hostname] == "r6cad-tsmc28.stanford.edu"} {
    source [file join [file dirname [info script]] "tsmc28_libraries.tcl"]
} elseif { [info hostname] == "r6cad-tsmc40r.stanford.edu" } {
    source [file join [file dirname [info script]] "tsmc40_libraries.tcl"]
}