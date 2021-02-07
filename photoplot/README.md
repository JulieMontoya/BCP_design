The Photoplot disc contains a program to generate photoplot and drill files suitable for PCB manufacture, from a BCP design database.

The machine code files `TRICODE` and `MNUCODE` are generated from sources which can be found in the [beebasm](https://github.com/JulieMontoya/BCP_design/tree/master/beebasm) folder; see  [photoplot_main.6502](https://github.com/JulieMontoya/BCP_design/blob/master/photoplot/photoplot_main.6502)  reproduced above.

# PLOT1 #

This is the BASIC wrapper for the photoplot generation program.

# PLOT2 #

This is a modified version, designed especially to work with the code assembled on the target.

## BUILDING ON THE TARGET ##

The disc image [photoplot_beeb_src.ssd](https://github.com/JulieMontoya/BCP_design/blob/master/photoplot_beeb_src.ssd) contains BASIC source files to build the photoplot and menu programs on a real or emulated BBC Master 128  (although once built, they will work on a Model B).  You will need to have built the main source code, as some files generated during that process will be required again at this stage.

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
You probably don't need to generate the BeebASM source unless you have edited the font definitions on the target and want to bring those changes back through to the host.  What the font generating program is printing to the screen  (and maybe also spooling to disc)  is a whole bunch of EQUW and EQUB statements with labels.  This code is not actually being assembled; rather, the appropriate values are being poked directly into memory.  It's best to leave paged mode off, so the computer can churn away unattended, but you might as well have the assembled code displayed.

Each of the main program stages creates a static status line at the top of the screen, which shows the current program and state; and a window where the output scrolls.  The `FINALE` program, which is run last of all, creates a dump of just the variables needed by `PLOT2` and combines the object code sections into one file.

## TESTING IT ##

Run
```
*EXEC !PLAY
```
to run the BASIC wrapper `PLOT2`.  A design you are going to be sick of by now is included in the disc image.
