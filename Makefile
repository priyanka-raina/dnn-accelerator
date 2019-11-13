.PHONY: hls sim syn pt pnr

hls:
	cd hls && $(MAKE)

sim: hls
	cd sim && $(MAKE)

syn: sim
	cd syn && $(MAKE)

pt: sim
	cd pt && $(MAKE)

pnr: syn
	cd pnr && $(MAKE)
