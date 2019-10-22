#! /bin/tcsh

# If directory exists, rename it to current date+time
if (-d conv) then
  mv conv conv.`date +%F-%T`
endif
mkdir conv
cd conv

dc_shell -topographical -o conv_syn.log -f ../run.tcl
