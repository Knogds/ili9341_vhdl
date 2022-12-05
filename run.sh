#!/bin/bash

ghdl -a display.vhd && \
ghdl -a display_00.vhd && \
ghdl -a display_00_tb.vhd && \
ghdl -e display_00 && \
ghdl -e display_00_tb && \
ghdl -r display_00_tb --vcd=display_00_tb.vcd --stop-time=1000000ns && \
gtkwave --script=tcl_skripta.tcl display_00_tb.vcd
