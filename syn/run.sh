#! /bin/tcsh
# Takes in top level design name as argument and
# runs basic synthesis script
setenv DESIGN conv
if (-d $DESIGN) then
  rm -rf $DESIGN
endif
mkdir $DESIGN
cd $DESIGN
dc_shell -o "$DESIGN_syn.log" -f ../run.tcl
