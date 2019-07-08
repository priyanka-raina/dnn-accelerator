#####################################################################
#                                                                   #
# Description     : Tcl script to create and place bond pad         #
#                   (inline or stagger style)                       #
# Completion Date : 14 Dec 2008                                     #
#                                                                   #
#####################################################################

#####################################################################
#                                                                   #
# To use this Tcl procedure in IC Compiler "icc_shell>"             #
# Usage:                                                            #
#   createNplace_bondpads # create and place bond pad               #
#                           (inine or stagger style)                #
#     inline_pad_ref_name  : specify inline bond pad reference name #
#     stagger              : inline or stagger style bond pad       #
#     stagger_pad_ref_name : specify stagger bond pad reference name#
# Example:                                                          #
#   createNplace_bondpads -inline_pad_ref_name PADIZ40 ;#inline     #
#   createNplace_bondpads -inline_pad_ref_name PAD9M126GAL \        #
#                         -stagger true \                           #
#                         -stagger_pad_ref_name PAD9M126GAS         #
#                                                                   #
#####################################################################

proc createNplace_bondpads {args} {
  
  parse_proc_arguments -args $args pargs
  set_object_snap_type -disable
  ## get bond pad style 
  if {[info exists pargs(-stagger)]} {
     set stagger $pargs(-stagger)
  } else {
     set stagger false
  }
  
  ## get inline bond pad ref_name
  if {[info exists pargs(-inline_pad_ref_name)]} {

      set bond_pad_ref_name $pargs(-inline_pad_ref_name)
      ## check specified inline bond pad cell
      if {[get_physical_lib_cells $bond_pad_ref_name] == "" } {
            echo ">>>> You specified inline bond pad cell $bond_pad_ref_name don't exist in physical library."
            return
      }

   } else {
        echo ">>>> Please specify the inline bond pad ref_name."
      return
   }

   ## get stagger bond pad ref_name
   if { $stagger == "true" } {
       if {[info exists pargs(-stagger_pad_ref_name)]} {
           set stagger_bond_pad_ref_name $pargs(-stagger_pad_ref_name)
           ## check specified inline bond pad cell
           if {[get_physical_lib_cells $stagger_bond_pad_ref_name] == "" } {
                 echo ">>>> You specified stagger bond pad cell $stagger_bond_pad_ref_name don't exist in physical library."
                 return
           }
     } else {
	   echo ">>>> Please specify the stagger bond pad ref_name." 
	   return
      }
   }

   suppress_message {HDU-104}
   
   ## get bond pad height & width
   set bond_pad_bbox [get_attribute [get_physical_lib_cells $bond_pad_ref_name] bbox]
   set pad_width     [expr [lindex $bond_pad_bbox 1 0] - [lindex $bond_pad_bbox 0 0]]
   set pad_height    [expr [lindex $bond_pad_bbox 1 1] - [lindex $bond_pad_bbox 0 1]]
  
   if {$stagger == "true" } {

      ## get stagger bond pad height & width
      set stagger_bond_pad_bbox [get_attribute [get_physical_lib_cells $stagger_bond_pad_ref_name] bbox]
      set stagger_pad_width     [expr [lindex $stagger_bond_pad_bbox 1 0] - [lindex $stagger_bond_pad_bbox 0 0]]
      set stagger_pad_height    [expr [lindex $stagger_bond_pad_bbox 1 1] - [lindex $stagger_bond_pad_bbox 0 1]]
   }
   
   ## get all left io_pad list and sort tis list by coordinate
   set all_left_io_cell_sort_list ""
   set all_left_io_cell_list [collection_to_list -name_only -no_braces [get_cells -all -hierarchical -filter "mask_layout_type==io_pad && orientation==E && ref_name!=PRCUTA_G"]]
   foreach left_io_cell $all_left_io_cell_list {
   	set io_sort_index [lindex [get_attribute [get_cells -all -hierarchical $left_io_cell] origin] 1]
   	lappend all_left_io_cell_sort_list [list $left_io_cell $io_sort_index]
   }
   set all_left_io_cell_sort_list [lsort -real -index 1 $all_left_io_cell_sort_list]

   ## get all top io_pad list and sort tis list by coordinate
   set all_top_io_cell_sort_list ""
   set all_top_io_cell_list [collection_to_list -name_only -no_braces [get_cells -all -hierarchical -filter "mask_layout_type==io_pad && orientation==S && ref_name!=PRCUTA_G"]]
   foreach top_io_cell $all_top_io_cell_list {
   	set io_sort_index [lindex [get_attribute [get_cells -all -hierarchical $top_io_cell] origin] 0]
   	lappend all_top_io_cell_sort_list [list $top_io_cell $io_sort_index]	
   }
   set all_top_io_cell_sort_list [lsort -real -index 1 $all_top_io_cell_sort_list]
   	
   ## get all right io_pad list and sort tis list by coordinate
   set all_right_io_cell_sort_list ""
   set all_right_io_cell_list [collection_to_list -name_only -no_braces [get_cells -all -hierarchical -filter "mask_layout_type==io_pad && orientation==W && ref_name!=PRCUTA_G"]]
   foreach right_io_cell $all_right_io_cell_list {
   	set io_sort_index [lindex [get_attribute [get_cells -all -hierarchical $right_io_cell] origin] 1]
   	lappend all_right_io_cell_sort_list [list $right_io_cell $io_sort_index]
   }
   set all_right_io_cell_sort_list [lsort -real -index 1 $all_right_io_cell_sort_list]
   	
   ## get all bottom inline io_pad list and sort tis list by coordinate
   set all_bottom_io_cell_sort_list ""
   set all_bottom_io_cell_list [collection_to_list -name_only -no_braces [get_cells -all -hierarchical -filter "mask_layout_type==io_pad && orientation==N && ref_name!=PRCUTA_G"]]
   foreach bottom_io_cell $all_bottom_io_cell_list {
   	set io_sort_index [lindex [get_attribute [get_cells -all -hierarchical $bottom_io_cell] origin] 0]
   	lappend all_bottom_io_cell_sort_list [list $bottom_io_cell $io_sort_index]
   }
   set all_bottom_io_cell_sort_list [lsort -real -index 1 $all_bottom_io_cell_sort_list]

   set all_io_cell_list [concat $all_left_io_cell_sort_list $all_top_io_cell_sort_list $all_right_io_cell_sort_list $all_bottom_io_cell_sort_list]
   
   ## remove current exist inline bonding pad cell
   set get_bond_pad_cells_cmd "get_cells -all -hierarchical -filter \"ref_name =="
   append get_bond_pad_cells_cmd $bond_pad_ref_name "\""
   
   set exist_bond_pad_list [eval $get_bond_pad_cells_cmd]
   
   if { $exist_bond_pad_list !=""} {
      echo ">>>> remove pre-exist inline bond pad cell $stagger_bond_pad_ref_name."
      remove_cell $exist_bond_pad_list
      } else {
      echo ">>>> current cell" [get_object_name [current_mw_cel]] "don't exist inline bond pad cell $bond_pad_ref_name."      
      }

   ## remove current exist stagger bonding pad cell
   if {$stagger == "true"}  {
     set get_stagger_bond_pad_cells_cmd "get_cells -all -hierarchical -filter \"ref_name =="
     append get_stagger_bond_pad_cells_cmd $stagger_bond_pad_ref_name "\""
     
     set exist_stagger_bond_pad_list [eval $get_stagger_bond_pad_cells_cmd]
     
     if { $exist_stagger_bond_pad_list !=""} {
        echo ">>>> remove pre-exist stagger bond pad cell $stagger_bond_pad_ref_name."
        remove_cell $exist_stagger_bond_pad_list
        } else {
        echo ">>>> current cell" [get_object_name [current_mw_cel]] "don't exist stagger bond pad cell $stagger_bond_pad_ref_name."      
	}
   }

   ## stagger pad counter
   set left_i   1
   set top_i    1
   set right_i  0
   set bottom_i 0

   foreach io_cell $all_io_cell_list {
   
      set io_cell_bbox [get_attribute [get_cells -all -hierarchical [lindex $io_cell 0]] bbox]
      set io_cell_orient [get_attribute [get_cells -all -hierarchical [lindex $io_cell 0]] orientation]
      set io_cell_LL_X [lindex $io_cell_bbox 0 0]
      set io_cell_LL_Y [lindex $io_cell_bbox 0 1]
      set io_cell_UR_X [lindex $io_cell_bbox 1 0]
      set io_cell_UR_Y [lindex $io_cell_bbox 1 1]
   
      set bond_pad_name ""
      #append bond_pad_name [get_attribute [get_cells -all -hierarchical [lindex $io_cell 0]] name] "_PAD"
      # CHANGED by dbankman
      append bond_pad_name "bond_" [get_attribute [get_cells -all -hierarchical [lindex $io_cell 0]] name]

      ## left side io cell- $stagger_pad_height 
      if { $io_cell_orient == "E" } {

	 if {$stagger == "true" && ![expr $left_i % 2]} {

	     create_cell $bond_pad_name $stagger_bond_pad_ref_name
             set bond_pad_LL_X $io_cell_LL_X
             set bond_pad_LL_Y $io_cell_LL_Y
         } else {

	    create_cell $bond_pad_name $bond_pad_ref_name
        # CHANGED by dbankman
	    set bond_pad_LL_X [expr $io_cell_LL_X - 11.66]
        set bond_pad_LL_Y $io_cell_LL_Y
	   }
	 
	 set left_i [expr $left_i + 1]
      }

      ## top side io cell
      if { $io_cell_orient == "S" } {
	 
	 if {$stagger == "true" && ![expr $top_i % 2]} {

	     create_cell $bond_pad_name $stagger_bond_pad_ref_name
	     set bond_pad_LL_X $io_cell_LL_X
             set bond_pad_LL_Y [expr $io_cell_UR_Y - $stagger_pad_height]

	 } else {
	 
	     create_cell $bond_pad_name $bond_pad_ref_name
             set bond_pad_LL_X $io_cell_LL_X
             # CHANGED by dbankman
             set bond_pad_LL_Y [expr [expr $io_cell_UR_Y  - $pad_height ] + 11.66]
         }
        
        set top_i [expr $top_i + 1]
      }
   
      ## right side io cell
      if { $io_cell_orient == "W" } {
	 
	 if {$stagger == "true" && ![expr $right_i % 2]} {

	     create_cell $bond_pad_name $stagger_bond_pad_ref_name
	     set bond_pad_LL_X [expr $io_cell_UR_X - $stagger_pad_height]
             set bond_pad_LL_Y $io_cell_LL_Y
             

	 } else {

	    create_cell $bond_pad_name $bond_pad_ref_name
        # CHANGED by dbankman
	    set bond_pad_LL_X [expr [expr $io_cell_UR_X - $pad_height] + 11.66]
            set bond_pad_LL_Y $io_cell_LL_Y

	 }
	
	set right_i [expr $right_i + 1]

       }
   
      ## bottom side io cell - $stagger_pad_height    - $pad_height
      if { $io_cell_orient == "N" } {

	 if {$stagger == "true" && ![expr $bottom_i % 2]} {

	     create_cell $bond_pad_name $stagger_bond_pad_ref_name
             set bond_pad_LL_X $io_cell_LL_X
             set bond_pad_LL_Y $io_cell_LL_Y

	 } else {
	
	     create_cell $bond_pad_name $bond_pad_ref_name
	     set bond_pad_LL_X $io_cell_LL_X
         # CHANGED by dbankman
         set bond_pad_LL_Y [expr $io_cell_LL_Y - 11.66]

          }

	  set bottom_i [expr $bottom_i + 1]

         }
    
    set_attribute -quiet $bond_pad_name orientation $io_cell_orient
   
    move_objects -x $bond_pad_LL_X -y $bond_pad_LL_Y [list $bond_pad_name]
   
   }
  
   ## get current inline bonding pad cell
   set get_bond_pad_cells_cmd "get_cells -all -hierarchical -filter \"ref_name =="
   append get_bond_pad_cells_cmd $bond_pad_ref_name "\""
   
   echo ">>>> Total add" [sizeof_collection [eval $get_bond_pad_cells_cmd]] "inline bond pad cell $bond_pad_ref_name.<<<<"
   
   ## get all stagger io_pad list
   if {$stagger == "true"}  {
     set get_stagger_bond_pad_cells_cmd "get_cells -all -hierarchical -filter \"ref_name =="
     append get_stagger_bond_pad_cells_cmd $stagger_bond_pad_ref_name "\""
     echo ">>>> Total add" [sizeof_collection [eval $get_stagger_bond_pad_cells_cmd]] "stagger bond pad cell $stagger_bond_pad_ref_name.<<<<"
   }

   unsuppress_message {HDU-104}
   set_object_snap_type -enable
}

define_proc_attributes createNplace_bondpads -info "createNplace_bondpads # create and place bond pad"  -define_args {
	{-inline_pad_ref_name "inline bond pad reference name" inline_pad_ref_name string required}
	{-stagger "inline or stagger style bond pad <true | false(default)>" stagger string optional}
	{-stagger_pad_ref_name "stagger bond pad reference name" stagger_pad_ref_name string optional}
}

