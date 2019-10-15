.PHONY: hls sim syn pt pnr

hls:
	cd hls && $(MAKE)

sim: hls
	cd sim && $(MAKE)

syn: hls
	cd syn && $(MAKE)

pt: sim syn
	cd pt && $(MAKE)

pnr: syn
	cd pnr && $(MAKE)
