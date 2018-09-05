# some convenience procedures
proc lappend_app_var {var val} {
    set v [get_app_var $var]
    lappend v $val
    set_app_var $var $v
}

proc lprepend_app_var {var val} {
    set v [get_app_var $var]
    set_app_var $var [linsert $v 0 $val]
}

proc lpop_index {l index} {
    upvar 1 $l li
    set li [lreplace $li $index $index]
}

proc boolean_arg {name largs} {
    upvar 1 $largs ai
    set lidx [lsearch -exact $ai $name]
    lpop_index ai $lidx
    return [expr $lidx != -1]
}

proc named_optional_arg {name val largs} {
    upvar 1 $largs ai
    set lidx [lsearch -exact $ai $name]
    if {$lidx != -1} {
        lpop_index ai $lidx
        set val [lindex $ai $lidx]
        lpop_index ai $lidx
    }
    return $val
}

proc add_search_path {path} {
    if {$path ne ""} {
        if {[lsearch -exact [get_app_var search_path] $path] == -1} {
            lappend_app_var search_path $path
        }
    }
}

proc add_library {lib args} {
    set target [boolean_arg -target args]
    set synthetic [boolean_arg -synthetic args]
    set link [boolean_arg -link args]
    set min [named_optional_arg -min "" args]
    set max [named_optional_arg -max "" args]

    if {[llength $args] != 0} {
        error "extra arguments to add_library: $args"
    }

    add_search_path [file dirname $lib$max]
    set libmax [file tail $lib$max]

    if {$target} {lappend_app_var target_library $libmax}
    if {$synthetic} {lappend_app_var synthetic_library $libmax}
    if {$link} {lappend_app_var link_library $libmax}

    if {$min ne ""} {
        add_search_path [file dirname $lib$min]
        set_min_library $libmax -min_version [file tail $lib$min]
    }
}

proc timer {ms} {
    puts "Time: [clock format [clock seconds] -format {%D %T}]"
    after $ms [list after idle [info level 0]]
}
