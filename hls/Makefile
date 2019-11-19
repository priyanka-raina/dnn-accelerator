CATAPULT = /cad/mentor/2019.11/Catapult_Synthesis_10.4b-841621/Mgc_home/bin/catapult

build/conv.v1/rtl.v: build/SystolicArrayCore*.v1/rtl.v build/DoubleBuffer*.v1/rtl.v src/SystolicArray.h
	$(CATAPULT) -shell -file scripts/conv.tcl
	cat build/conv.v1/concat_rtl.v | sed '/module CGHpart (/,+9 d' > ../rtl/concat_rtl.v	

build/SystolicArrayCore*.v1/rtl.v: build/ProcessingElement*.v1/rtl.v src/SystolicArrayCore.h
	$(CATAPULT) -shell -file scripts/SystolicArrayCore.tcl

build/ProcessingElement*.v1/rtl.v: src/ProcessingElement.h
	$(CATAPULT) -shell -file scripts/ProcessingElement.tcl

build/DoubleBuffer*.v1/rtl.v: src/DoubleBuffer.h
	$(CATAPULT) -shell -file scripts/DoubleBuffer.tcl

.PHONY: clean
clean:
	rm build.ccs
	rm -rf build
