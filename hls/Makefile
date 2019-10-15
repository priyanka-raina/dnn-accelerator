CATAPULT = /cad/mentor/2019.5/Catapult_Synthesis_10.3d-815731/Mgc_home/bin/catapult

build/conv.v1/rtl.v: build/SystolicArrayCore*.v1/rtl.v build/DoubleBuffer*.v1/rtl.v SystolicArray.h
	$(CATAPULT) -shell -file scripts/conv.tcl

build/SystolicArrayCore*.v1/rtl.v: build/ProcessingElement*.v1/rtl.v build/OutputSkewer*.v1/rtl.v build/InputSkewer*.v1/rtl.v SystolicArrayCore.h
	$(CATAPULT) -shell -file scripts/SystolicArrayCore.tcl

build/ProcessingElement*.v1/rtl.v: ProcessingElement.h
	$(CATAPULT) -shell -file scripts/ProcessingElement.tcl

build/InputSkewer*.v1/rtl.v: InputSkewer.h
	$(CATAPULT) -shell -file scripts/InputSkewer.tcl

build/OutputSkewer*.v1/rtl.v: OutputSkewer.h
	$(CATAPULT) -shell -file scripts/OutputSkewer.tcl

build/DoubleBuffer*.v1/rtl.v: DoubleBuffer.h
	$(CATAPULT) -shell -file scripts/DoubleBuffer.tcl

.PHONY: clean
clean:
	rm build.ccs
	rm -rf build
