create_rectangular_rings -nets {VDD VSS} -left_offset 5 -left_segment_layer M7 -left_segment_width 2 -right_offset 5 -right_segment_layer M7 -right_segment_width 2 -bottom_offset 5 -bottom_segment_layer M8 -bottom_segment_width 2 -top_offset 5 -top_segment_layer M8 -top_segment_width 2

create_power_straps -direction vertical -start_at 155 -num_placement_strap 13 -increment_x_or_y 70 -nets {VDD VSS} -layer M7 -width 2

create_power_straps -direction horizontal -start_at 220 -num_placement_strap 12 -increment_x_or_y 70 -nets {VDD VSS} -layer M8 -width 2
