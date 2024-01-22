VAR_PFX=vars-

all: non-sideways sideways

non-sideways: M.MTH13 M.DBM58 M.GFX51 M.DES18 M.PAGEA L.MINVARS design_test.bas
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

sw_errors.6502: errors.6502
	sed 's/^ *BRK *\\.*$$/    JSR alt_brk/' errors.6502 > sw_errors.6502

sideways: R.BCP_SW1 R.BCP_SW2 L.SWVARS sw_design_test.bas
	beebasm -i sw_disc_image.6502 -opt 3 -do bcp_sideways.bbc

R.BCP_SW1: L.SWVARS

R.BCP_SW2: L.SWVARS
	rm -f R.BCP_SW2
	make_rfs -b`sed -n '/rfs_data/s/^.*&//p' sw_int_vars.6502` \
	-i rfs.cat \
	-o R.BCP_SW2

L.SWVARS: workspace.6502 maths_library.6502 jump_table.6502 database.6502 graphics.6502 design.6502 sw_errors.6502 sw_variable_dump.6502 sw_main.6502
	rm -f L.SWVARS
	beebasm -i sw_variable_dump.6502 -v | csplit -f"${VAR_PFX}sw_" - \
	'/##### I/' '/##### E/' '/##### M/' \
	&& sed -n '/=/p' < "${VAR_PFX}sw_01" > sw_int_vars.6502 \
	&& sed -n '/=/s/ //gp' < "${VAR_PFX}sw_02" > L.SWVARS \
	&& sed -n '/=/s/ //gp' < "${VAR_PFX}sw_03" > L.BVARS \
	&& mv "${VAR_PFX}sw_00" log.sw

#L.BVARS: L.SWVARS sw_int_vars.6502

full_monty: M.MTH13 M.DBM58 M.GFX51 M.DES18 M.PAGEA L.MINVARS design_test.bas R.BCP_SW1 R.BCP_SW2 L.SWVARS sw_design_test.bas
	rm -f bcp_full_monty.bbc
	beebasm -i full_monty_disc_image.6502 -opt 3 -do bcp_full_monty.bbc
	
experimental: M.NEWCODE design_test.bas
	beebasm -i disc_image_exp.6502 -opt 3 -do bcp_experimental.bbc
	
M.NEWCODE: workspace.6502 maths_library.6502 database.6502 graphics.6502 design.6502 experimental.6502 new_design.6502
	rm -f L.MINVARS M.NEWCODE
	beebasm -i experimental.6502 -v | csplit -f"${VAR_PFX}" - '/##### I/' '/##### E/' \
	&& sed -n '/=/p' < "${VAR_PFX}01" > int_vars.6502 \
	&& sed -n '/=/s/ //gp' < "${VAR_PFX}02" > L.MINVARS \
	&& mv "${VAR_PFX}00" log.bcp

M.NEWCODE:

2nd_proc: M.BCP_HI L.HIVARS
	rm -f bcp_second_proc.bbc
	beebasm -i hi_disc_image.6502 -opt 3 -do bcp_second_proc.bbc

M.BCP_HI: L.HIVARS

L.HIVARS: workspace.6502 maths_library.6502 jump_table.6502 database.6502 graphics.6502 design.6502 errors.6502 hi_variable_dump.6502 hi_main.6502
	rm -f L.HIVARS
	beebasm -i hi_variable_dump.6502 -v | csplit -f"${VAR_PFX}hi_" - \
	'/##### I/' '/##### E/' \
	&& sed -n '/=/p' < "${VAR_PFX}hi_01" > hi_int_vars.6502 \
	&& sed -n '/=/s/ //gp' < "${VAR_PFX}hi_02" > L.HIVARS \
	&& mv "${VAR_PFX}hi_00" log.hi
	
clean:
	rm -f ${VAR_PFX}* int_vars.6502 L.MINVARS log.bcp \
	M.PAGEA M.MTH13 M.DBM58 M.GFX51 M.DES18 \
	bcp_main.bbc bcp_sideways.bbc bcp_full_monty.bbc \
	M.NEWCODE bcp_experimental.bbc \
	R.BCP_SW* sw_errors.6502 sw_int_vars.6502 L.SWVARS L.BVARS log.sw \
	bcp_second_proc.bbc M.BCP_HI L.HIVARS hi_int_vars.6502 log.hi


tidy:
	rm -f ${VAR_PFX}*
	
.PHONY: all clean tidy
