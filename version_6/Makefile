VAR_PFX=vars-

all: L.MINVARS M.MTH13 M.DBM58 M.GFX51 M.DES18 M.PAGEA design_test.bas
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

clean:
	rm -f bcp_main.bbc ${VAR_PFX}* int_vars.6502 L.MINVARS log.bcp \
	M.PAGEA M.MTH13 M.DBM58 M.GFX51 M.DES18 M.NEWCODE

tidy:
	rm -f ${VAR_PFX}*
	
.PHONY: all clean tidy
