VAR_PFX=vars-

all: sideways non-sw

non-sw: M.MTH13 M.DBM58 M.GFX51 M.DES18 M.PAGEA L.MINVARS design_test.bas
	beebasm -i disc_image.6502 -opt 3 -do bcp_main.bbc

M.MTH13: L.MINVARS
M.DBM58: L.MINVARS
M.GFX51: L.MINVARS
M.DES18: L.MINVARS
M.PAGEA: L.MINVARS

L.MINVARS: workspace.6502 maths_library.6502 database.6502 graphics.6502 design.6502 variable_dump.6502
	rm -f L.MINVARS
	beebasm -i variable_dump.6502 -v | csplit -f"${VAR_PFX}" - '/##### I/' '/##### E/' \
	&& sed -n '/=/p' < "${VAR_PFX}01" > int_vars.6502 \
	&& sed -n '/=/s/ //gp' < "${VAR_PFX}02" > L.MINVARS \
	&& mv "${VAR_PFX}00" log.bcp

sw_errors.6502: errors.6502
	sed 's/^ *BRK *\\.*$$/    JSR alt_brk/' errors.6502 > sw_errors.6502

sideways: R.BCP_SW L.SWVARS sw_design_test.bas
	beebasm -i sw_disc_image.6502 -opt 3 -do bcp_sideways.bbc

R.BCP_SW: L.SWVARS

L.SWVARS: workspace.6502 maths_library.6502 jump_table.6502 database.6502 graphics.6502 design.6502 sw_errors.6502 sw_variable_dump.6502 sw_main.6502
	rm -f L.SWVARS
	beebasm -i sw_variable_dump.6502 -v | csplit -f"${VAR_PFX}sw_" - \
	'/##### I/' '/##### E/' '/##### M/' \
	&& sed -n '/=/p' < "${VAR_PFX}sw_01" > sw_int_vars.6502 \
	&& sed -n '/=/s/ //gp' < "${VAR_PFX}sw_02" > L.SWVARS \
	&& sed -n '/=/s/ //gp' < "${VAR_PFX}sw_03" > L.BVARS \
	&& mv "${VAR_PFX}sw_00" log.sw

full_monty: M.MTH13 M.DBM58 M.GFX51 M.DES18 M.PAGEA L.MINVARS design_test.bas R.BCP_SW L.SWVARS sw_design_test.bas
	beebasm -i full_monty_disc_image.6502 -opt 3 -do bcp_full_monty.bbc
	
clean:
	rm -f bcp_main.bbc ${VAR_PFX}* int_vars.6502 L.MINVARS log.bcp \
	M.PAGEA M.MTH13 M.DBM58 M.GFX51 M.DES18 \
	bcp_sideways.bbc bcp_full_monty.bbc \
	R.BCP_SW sw_errors.6502 sw_int_vars.6502 L.SWVARS L.BVARS log.sw

tidy:
	rm -f ${VAR_PFX}*
	
.PHONY: all clean tidy
