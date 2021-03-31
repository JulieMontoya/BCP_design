## 2021-03-31 ##

This latest version incorporates the new formula for calculating via pad sizes.  The original version used twice the track width.  This version uses the sum of the track width and hole diameter.

## BUILDING ON THE TARGET ##

The disc image [photoplot_beeb_src.ssd](https://github.com/JulieMontoya/BCP_design/blob/master/photoplot_beeb_src.ssd) contains BASIC source files to build the
photoplot and menu programs on a real or emulated BBC Master 128  (although once built, they will work on a Model B).  You will need to have built the main
source code, as some files generated during that process will be required again at this stage.  (The versions used for testing have been provided as a courtesy, but must be considered out-of-date.)

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
You will be prompted whether to generate BeebAsm source code for the font data  (you probably can safely say no to this, unless you are building the BeebAsm version yourself, have edited the font definitions on the target and want to bring those changes back through to the host);  turn on paged mode;  and display the assembled code on screen as it goes.

## TESTING IT ##

Run
```
*EXEC !PLAY
```
to run the BASIC wrapper `PLOT2`.  A design you are going to be sick of by now is included in the disc image.

# FNTGEN1 #

This program generates the font data for the photoplotting program.  It can optionally generate BeebAsm source for the font data.  (If you run it in a graphics MODE, it can even produce a preview of the characters.)

Note that what the font generating program is printing to the screen  (and maybe also spooling to disc)  is a whole bunch of EQUW and EQUB statements with
labels.  This code is not actually being assembled by the BASIC assembler; rather, the appropriate values are being calculated and poked directly into memory.

# PLT11SC #

This is the first part of the photoplotting program proper.  The code begins with a jump table to keep entry points as static as possible.

Each of the main program stages creates a static status line at the top of the screen, which shows the current program and state  (gathering labels or
assembling code); and a window where the output scrolls.

# PLT21SC #

This is the second part of the photoplotting program proper.

# MNU12SC #

This is the first part of the photoplot menu and header generation code.  The code begins with a static jump table.

# MNU22SC #

This is the second part of the photoplot menu and header code.

# FINALE #

This creates a dump of just the variables needed by `PLOT2` and combines the separate object code sections and font data into one file.

# PLOT2 #

This is a version of the BASIC wrapper around the assembled machine code, designed especially to work with the code assembled on the target.

# !MAKE #

This is a script file which you can `*EXEC` to build everything.

# !PLAY #

This is another script which you can `*EXEC` to run the PLOT2 program.

# VDUMP #

This is a version of the variable dump utility; it is assembled to run from &900 and **will overwrite** the page A workspace.

