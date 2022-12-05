PROJ = display_00
PIN_DEF = display_00.pcf
DEVICE = hx1k
PACKAGE = vq100

all: $(PROJ).bin

%.json: display_00.vhd %.vhd
	# yosys -m ghdl -p 'ghdl $^ -e display_00; synth_ice40 -json $@'
	yosys -m ghdl -p 'ghdl display.vhd display_00.vhd -e display_00; synth_ice40 -json $@'

%.asc: %.json
	#nextpnr-ice40 --$(DEVICE) --package $(PACKAGE) --pcf $(PIN_DEF) --json $< --asc $@
	nextpnr-ice40 --ignore-loops --$(DEVICE) --package $(PACKAGE) --pcf $(PIN_DEF) --json $< --asc $@

%.bin: %.asc
	icepack $< $@

prog: $(PROJ).bin
	iceprog $<

clean:
	rm -f $(PROJ).json $(PROJ).asc $(PROJ).bin

.SECONDARY:

.PHONY: all prog clean
