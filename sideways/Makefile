all: non_sideways sideways

stub_vars.6502: jump_table.6502
	sed -n '/[.]/s/^ *[.]\([A-Za-z_][A-Za-z0-9_]*\)/PRINT "\1 =",~\1/p' jump_table.6502 > stub_vars.6502
	
stub_jump_table.6502: jump_table.6502
	awk '/^ *[.]|RTS/{print};/JMP|JSR/{print "    JSR sw_equiv"}' jump_table.6502 \
	| sed 's/jump_table/stub_jump_table/g' \
	> stub_jump_table.6502
	
sw_jump_table.6502: jump_table.6502
	sed 's/^\( *[.]\)/\1sw_/' jump_table.6502 > sw_jump_table.6502
	
non_sideways:
	beebasm -i non_sw_main.6502  -di sw_test1.bbc -do non_sw_main.bbc -v > log.non_sw
	
sideways: stub_vars.6502 stub_jump_table.6502 sw_jump_table.6502
	beebasm -i sw_main.6502 -di sw_test1.bbc -do sw_main.bbc -v > log.sw
	
clean:
	rm -rf stub_vars.6502 stub_jump_table.6502 sw_jump_table.6502
	
.PHONY: all non_sideways sideways clean
