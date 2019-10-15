# Check if build already exists
if {[file isdirectory build]} { 
    project load build
} else {
    project new -name build
    project save
}

flow package require /SCVerify
flow package option set /SCVerify/USE_CCS_BLOCK true
flow package option set /SCVerify/USE_NCSIM true
flow package option set /SCVerify/USE_VCS true

flow package require /NCSim

solution options set Flows/NCSim/NCSIM_DOFILE dump_saif.do
solution options set Flows/NCSim/NC_ROOT /cad/cadence/INCISIVE15.20.022/

# Delete solution if already exists
catch {
    set existing_solution [project get /SOLUTION/$blockname* -match glob -return leaf]
    solution remove -solution $existing_solution -delete
}


# Delete solution if already exists
# if {[file isdirectory build/$blockname.v1]} {
#     solution remove -solution $blockname.v1 -delete
# }

# solution new -state initial $blockname

go new
solution file add ./conv_top.cpp
solution file add ./tb_gemm_systolic.cpp -exclude true

go analyze

