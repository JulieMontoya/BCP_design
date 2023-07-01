all: non_sideways sideways
non_sideways:
	beebasm -i non_sw_main.6502  -di sw_test1.bbc -do non_sw_main.bbc -v > log.non_sw
sideways:
	beebasm -i sw_main.6502 -di sw_test1.bbc -do sw_main.bbc -v > log.sw
.PHONY: all non_sideways sideways
