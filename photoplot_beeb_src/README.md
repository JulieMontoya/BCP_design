## BUILDING ON THE TARGET ##

The disc image [photoplot_beeb_src.ssd](https://github.com/JulieMontoya/BCP_design/blob/master/photoplot_beeb_src.ssd) contains BASIC source files to build the
photoplot and menu programs on a real or emulated BBC Master 128  (although once built, they will work on a Model B).  You will need to have built the main
source code, as some files generated during that process will be required again at this stage.

Copy the files
```
M.MMC12
M.DBC57
L.MINVARS
M.PAGEA
```
to the photoplot source disc.  Now just run
```
*EXEC !MAKE
```

## TESTING IT ##

Run
```
*EXEC !PLAY
```
to run the BASIC wrapper `PLOT2`.  A design you are going to be sick of by now is included in the disc image.

# FNTGEN1 #

This program generates the font data for the photoplotting program.  It can optionally generate BeebAsm source for the font data.  You probably will not need
this unless you have edited the font definitions on the target and want to bring those changes back through to the host.

Note that what the font generating program is printing to the screen  (and maybe also spooling to disc)  is a whole bunch of EQUW and EQUB statements with
labels.  This code is not actually being assembled by the BASIC assembler; rather, the appropriate values are being poked directly into memory.

# PLT11SC #

This is the first part of the photoplotting program proper.  The code begins with a jump table to keep entry points as static as possible.

Each of the main program stages creates a static status line at the top of the screen, which shows the current program and state  (gathering labels or
assembling code); and a window where the output scrolls.  The status line is _not_ used while variables exported by the previous program are being read back.

# PLT21SC #

This is the second part of the photoplotting program proper.

# MNU11SC #

This is the first part of the photoplot menu and header generation code.  The code begins with a static jump table.

# MNU21SC #

This is the second part of the photoplot menu and header code.

# FINALE #

This creates a dump of just the variables needed by `PLOT2` and combines the separate object code sections and font data into one file.

# PLOT2 #

This is a version of the BASIC wrapper around the assembled machine code, designed especially to work with the code assembled on the target.

