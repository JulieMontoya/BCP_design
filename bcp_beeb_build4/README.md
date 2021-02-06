# BCP Beeb Build 4 #

This version is designed to be built entirely in the target environment.

It builds successfully on an emulated Master 128, but the build process runs out of memory on a 32K Model B.  This will be addressed soon; `GFX50SC` needs to
be split into two smaller files, and some label names need altering where there is no need for them to persist outside a module.

**TO BUILD IT**
```
*EXEC !MAKE
```
Answer N to "paged mode", Y to "show code", sit back and watch the build process .....

The machine code program VDUMP is the same as the output from [here](https://github.com/JulieMontoya/BCP_design/blob/master/bcp_beeb_build3/VDUMP25).

Main difference in this version is that the design application has been split between `DEX17SC` (for "design extension") and `DES17SC`, which probably ought to
have been version-bumped.  Naughty Julie.  Better hurry up and give yourself a reason to bump it .....  

The build takes two passes  (of which one is actually a double pass, so maybe it takes three passes).
1.  Each section -- `WKS03SC`, `MTH12SC`, `DBM57SC`, `GFX50SC`, `DEX17SC` and `DES17SC` -- uses a `*EXEC` command to import any variables from the previous program
as a series of immediate-mode BASIC commands, so they take up no additional space in memory beyond the variable name, its contents and some sundry
housekeeping data; then assembles its code above HIMEM with OPT 4.  At the end of this pass, all labels defined in the code are properly assigned to
BASIC variables.  The program then invokes a utility to dump out as a `*SPOOL` file, the definitions of all variables except the static integer variables
`A%`-`Z%` and `@%`, and any variables whose names begin with an `_` underscore or `£` pound sign; and finally, chain-loads the next program.  The effect
of this is for variables to persist from one BASIC program to another.
2.  By the end of pass one, we have gathered up all labels in the code not starting with an underscore or pound sign  (these can be used to indicate
labels not referenced outside this section of code, such as destinations of conditional branches which only matter within the loop to which they belong,
so only important entry points need get exported).  We now work through `MTH12SC`, `DBM57SC`, `GFX50SC`, `DEX17SC` and `DES17SC` again  (`WKS03SC` is just
a series of BASIC variable initialisations and assembler label definitions, and already saved its output the first time); running one assembler pass with OPT 4
to gather up the labels we did not export, and a second with OPT 6 or OPT 7 actually to assemble the code above HIMEM, but using addresses appropriate to
its intended location in memory.  Lastly, each section saves its assembled code, with the appropriate reload address and an execution address pointing to
some convenient RTS instruction, and chain-loads the next one.
3.  After all the code has been assembled, `FINALE` is run.  This reads the final list of exported variables, and dumps out a minimal selection of
them as `L.MINVARS` to enable the test program `DT42H` to be run, and the code for the utilities disc to be built.  It then concatenates together the individual machine code sections and saves the result as `ALLCODE`.


**TO RUN IT**
The test program `DT42H` and a very simple design file are included in the disc image.
```
*EXEC !PLAY
```
If you drop out of the program with an error, `GOTO 11010` will resume where you left off.

This version includes a temporary command **Y** which works as follows:

+ **Y** -- clears the text window.
+ **Y {route number}** -- draws the numbered routed track  (numbers start from 0).

The machine code files for the maths and database libraries can be used to build the photoplotting code, and in conjunction with the `WL2DES2` program on the utilities disc.

## Coming Soon ##

A target-side buildable version of the photoplotting program.
