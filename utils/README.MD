This is the "utilities" disc.

## FP12 ##

This is a BASIC program to generate a file of footprints suitable for inclusion in BCP design files.  (Each design file contains its own copy of just the
footprints used in that design.)  Footprints are generated from DATA statements in the program.



## WL2DES ##

This is a program which takes a wiring list  (either from a separate file or from DATA statements within the program)  and a footprints file, and generates
a BCP design file with space for routed tracks.

**NOTE:** The latest version of the test program now requires some values to be stored in the data file, that this program does not include.  As a result,
loading them directly with the L command _will not work_.  The workspace pointers will need to be reinitialised after `*LOAD`ing manually.  The file can then be
re-saved with the necessary values included.

## WL2DES2 ##

This is a crudely-hacked version of WL2DES which works with the mathematics and database libraries built using the native build system, and a sound basis for future work.  Expects to run from drive 1 with bcp_beeb_build3.ssd in drive 0.  The "analyse design" section also has the offset to the wiring data hardcoded into it, which is incorrect.  Also will need to be patched to use the actual SAVE command in the database library, rather than risk errors trying unnecessarily to replicate its functionality.  (Likewise the actual LOAD command?  and/or move "analyse design" to a separate program?)

## VDUMP25 ##

A program to dump out BASIC variables, used in the [native build process](https://github.com/JulieMontoya/BCP_design/wiki/The-BBC-Native-Build-Process).

L% should be 0 to produce immediate mode statements, or some positive value smaller than 32767 to use that as a starting line number.  Variables whose names begin witgh an underscore _ or pound sign £ will not be included in the output; this allows variables which do not need to be exported to another section of program,  to be kept private. 

## DGM ##

This is a version of the Database, Graphics and Maths library code, used by WL2DES.  If replaced, you must update the entry points in the program.

**NOTE:** Now the build order has changed, the maths and database libraries are built before the graphics library, which is not used at all by `WL2DES`.
Therefore it should be possible to replace `DGM` with a shorter file containing just the maths and database code, especially with the inclusion of a static jump table.

_To do:  D-Code Editor_
