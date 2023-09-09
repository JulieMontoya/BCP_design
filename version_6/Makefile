VAR_PFX=vars-

all: sideways non-sw

non-sw: M.MTH13 M.DBM58 M.GFX51 M.DES18 M.NEWCODE M.PAGEA L.MINVARS design_test.bas
	beebasm -i disc_image.6502 -opt 3 -do bcp_main.bbc

M.MTH13: L.MINVARS
M.DBM58: L.MINVARS
M.GFX51: L.MINVARS
M.DES18: L.MINVARS
M.NEWCODE: L.MINVARS
M.PAGEA: L.MINVARS

L.MINVARS: workspace.6502 maths_library.6502 database.6502 graphics.6502 design.6502 variable_dump.6502
	rm -f L.MINVARS
	beebasm -i variable_dump.6502 -v | csplit -f"${VAR_PFX}" - '/##### I/' '/##### E/' \
	&& sed -n '/=/p' < "${VAR_PFX}01" > int_vars.6502 \
	&& sed -n '/=/s/ //gp' < "${VAR_PFX}02" > L.MINVARS \
	&& mv "${VAR_PFX}00" log.bcp

stub_vars.6502: jump_table.6502
	sed -n '/[.]/s/^ *[.]\([A-Za-z_][A-Za-z0-9_]*\)/PRINT "\1 =",~\1/p' jump_table.6502 > stub_vars.6502
	
stub_jump_table.6502: jump_table.6502
	awk '/^ *[.]|RTS/{print};/JMP|JSR/{print "    JSR sw_equiv"}' jump_table.6502 \
	| sed 's/jump_table/stub_jump_table/g' \
	> stub_jump_table.6502
	
sw_jump_table.6502: jump_table.6502
	sed 's/^\( *[.]\)/\1sw_/' jump_table.6502 > sw_jump_table.6502

sideways: R.BCP_SW L.SWVARS sw_design_test.bas
	beebasm -i sw_disc_image.6502 -opt 3 -do bcp_sideways.bbc

R.BCP_SW: L.SWVARS
M.STUB2E: L.SWVARS

L.SWVARS: workspace.6502 maths_library.6502 database.6502 graphics.6502 design.6502 sw_variable_dump.6502 sw_main.6502 stub_vars.6502 stub_jump_table.6502 sw_jump_table.6502
	rm -f L.SWVARS
	beebasm -i sw_variable_dump.6502 -v | csplit -f"${VAR_PFX}sw_" - \
	'/##### I/' '/##### E/' '/##### M/' \
	&& sed -n '/=/p' < "${VAR_PFX}sw_01" > sw_int_vars.6502 \
	&& sed -n '/=/s/ //gp' < "${VAR_PFX}sw_02" > L.SWVARS \
	&& sed -n '/=/s/ //gp' < "${VAR_PFX}sw_03" > L.BVARS \
	&& mv "${VAR_PFX}sw_00" log.sw

full_monty: M.MTH13 M.DBM58 M.GFX51 M.DES18 M.NEWCODE M.PAGEA L.MINVARS design_test.bas R.BCP_SW L.SWVARS sw_design_test.bas
	beebasm -i full_monty_disc_image.6502 -opt 3 -do bcp_full_monty.bbc
	
clean:
	rm -f bcp_main.bbc ${VAR_PFX}* int_vars.6502 L.MINVARS log.bcp \
	M.PAGEA M.MTH13 M.DBM58 M.GFX51 M.DES18 \
	bcp_sideways.bbc bcp_full_monty.bbc \
	R.BCP_SW M.STUB2E sw_int_vars.6502 L.SWVARS L.BVARS log.sw

tidy:
	rm -f ${VAR_PFX}*
	
.PHONY: all sideways non-sw full_monty clean tidy
