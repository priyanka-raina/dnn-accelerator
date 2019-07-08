##### chip width not including seal ring #####
set chip_width      1200
set chip_height     1200

##### pad ring dimensions #####
# with pads
set io_width        110
set io_height       110

##### io2core margin #####
set left_io2core    40
set right_io2core   40
set top_io2core     40
set bottom_io2core  40

##### set the area of the design #####
set core_width [expr $chip_width - (2*$io_width + $left_io2core + $right_io2core)]
set core_height [expr $chip_height - (2*$io_height + $top_io2core + $bottom_io2core)]

##### create floorplan #####
# create_floorplan \
#     -control_type width_and_height \
#     -core_width $core_width \
#     -core_height $core_height \
#     -start_first_row \
#     -left_io2core $left_io2core \
#     -right_io2core $right_io2core \
#     -top_io2core $top_io2core \
#     -bottom_io2core $bottom_io2core
create_floorplan \
    -control_type aspect_ratio \
    -core_aspect_ratio 1 \
    -core_utilization 0.5 \
    -row_core_ratio 1 \
    -start_first_row \
    -left_io2core $left_io2core \
    -right_io2core $right_io2core \
    -top_io2core $top_io2core \
    -bottom_io2core $bottom_io2core

set_fp_placement_strategy -macros_on_edge on -auto_grouping high -minimize_auto_grouping_channels true -pin_routing_aware true

# ##### insert pad filler #####
# insert_pad_filler -cell "PFILLER20_G PFILLER10_G PFILLER5_G PFILLER1_G PFILLER05_G PFILLER0005_G"

# ##### create bond pads #####
# source ./createNplace_bondpads.tcl
# createNplace_bondpads -inline_pad_ref_name PAD60GU
# set_dont_touch_placement [get_cells -all bond_*]
