# VERSION SIX

Version 6 is work in progress.

A Makefile is used to generate versions of BCP to run from main RAM and
sideways ROM/RAM from (mostly) the same Source Code files.  It is
intended eventually also to produce a set of source code disc images for
building on the target system.

The main new features are:

+ An improved command despatcher
+ Each component in the design now has its own legend position.

(This has necessitated **a breaking change** to the data file format,
see below.)

The original idea to minimise space requirements by having all instances
of a component have their legends in the same relative position proved
to be a limitation too far.  Thus, in order to allow each component in
the design to have its own legend position, the format of the wiring
list section of the design data file has been extended to include a pair
of co-ordinates, a size (which currently is ignored) and an angle; and
the command language has been extended with a new command, **ML** for
**M**ove **L**egend.

## MAKEFILE TARGETS

`$ make non-sw` -- Builds a disc image with a version of BCP to run from
main RAM, targeted to end at &57FF to allow the use of MODE 4 or MODE 5
on a Model B.  MODE 129 can be used on a Master 128.

This disc image also includes a modified version of `WL2DES` which
supports the new design data file format.

`$ make sideways` -- Builds a disc image with a version of BCP which
runs the machine code portion mostly from sideways RAM / ROM, and allows
the use of MODE 1 on a Model B.

As well as the BASIC portion, a sideways ROM image file is provided
which may be burned into a 27128 EPROM or loaded into sideways RAM.
Self-loading code is incorporated to allow the file to be `*RUN`
directly from the disc, whereupon it will copy itself to sideways RAM.
This is intended for use on a BBC Model B without the `*SRLOAD` command.
This actually appeared to work much faster than the `*SRLOAD` of an
emulated Master 128, but real hardware may well behave differently.

Note that the sideways ROM bank is currently hard-coded into the
program.  This will be addressed in future; probably by making the ROM
image behave more like a "proper" sideways ROM as opposed to treating it
as general memory.

`$ make full_monty` -- Builds a disc image with both non-sideways and
sideways versions of BCP.  For showing off :)

# NEW FEATURES

## THE "MOVE LEGEND" COMMAND

+ **ML {component}** -- Allows a component's legend to be moved.
+ **ML** -- repeats moving legend.  (Strictly: moves the legend of the last component mentioned.  If you have done anything but **M** or **ML** in the meantime, this may have been updated.)

The legend cursor is in the form of a triangle indicating the height
and direction of the legend text.  Component rotation is taken into
account so movement on screen is in the expected direction.

### KEYS ###

**Z**, **X**, **:**, **/** : directions.

**1**, **2**, **3**, **4** : set rotation angle (0, 90°, 180°, 270°)

**7**, **8**, **9**, **0** : Set grid spacing  (step)  5, 25, 50, 100 thou.

**Delete** : Abandon editing and restore default legend position

**Space** : Display mounting side, rotation angle and co-ordinates (in thou)

**Return** : Place Legend  (i.e., store its position and angle into the wiring list)

## THE NEW COMMAND DESPATCHER

The command despatcher has been rewritten completely, based around
matching variable-length strings with a wildcard.  There is no need for
each command to handle its own modifiers anymore; commands and modifiers
are matched together, and each modified or unmodified command can have
its own separate entry point.

## DATABASE FORMAT CHANGE

BCP now includes the ability for each component in the design to have
its own individual legend position and angle.  This requires a change
to the database format; 

The fixed-length records in the parts list are now 12 bytes long as
follows:

BYTES | BITS | MEANING                      | Notes
------|------|------------------------------|-----------
0     | 2-7  | Designator letter(s)         | No change
0     | 0-1  | Designator number high bits  | No change
1     |      | Designator number low bits   | No change
2-4   |      | Packed X,Y co-ordinates      | No change
5-6   |      | Wiring list offset           | No change
7     | 6-7  | Angle in 90° steps           | No change
7     | 5    | Side (0 = top, 1 = under)    | No change
7     | 0-4  | Footprint                    | No change
8-10  |      | Legend co-ordinates          | New
11    | 6-7  | Legend angle                 | New
11    | 0-3  | Legend size                  | New

When a footprint's definition is unpacked by the code at
`real_select_fp`, the value at (plb)+11 is examined. If that byte is
&00, then the legend position and angle from the footprint definition
will be used; otherwise, the legend position and angle will be taken
from (plb)+8 to (plb)+10.

(Care will need to be taken if a footprint is ever selected directly
as opposed to from within the normal course of selecting a part, e.g.
in some sort of footprint viewer.)


A new utility will ultimately be required to convert an existing design
database file in the "old" format to the "new" format.  The parts list
section of a design with more than 20 parts will exceed a single page,
and need to have space inserted and the pointers to subsequent sections
(which are stored in a trailer record at the end of the parts list)
adjusted to suit.

# WL2DES

The version of the program `WL2DES` included here is modified to
produce a database file with 12-byte records, along with a suitable
`D.FTPRNT` master footprint file.  The new positions are initialised
with all zeros to ensure that the default legend positions will be
used when the design is loaded into the editor.

# NOTES

## OTHER CHANGES

The structure of the BeebAsm source files has changed to accommodate the
possibility of standard and sideways builds.  In particular, the actual
source files are kept as "pure" as possible, with no `ORG` or `SAVE`
commands; these instructions are taken care of in a wrapper file from
which the source files are included.  (`ALIGN` is permissible; any
future script generating a BBC BASIC program for target-side assembly
can handle this itself.)  This wrapper then generates the object files
and corresponding variable dump files; one with starting, ending and
execution addresses for internal use when generating the disc image,
and another with labels to be exported as BASIC variables.  When
creating the disc image, these object files are included along with the
variable dump, the BASIC program and some other files.  This obviates
the need for a pre-existing input disc image.

## PLANNED CHANGES

The route editor will be overhauled and given the ability to edit an
existing route by moving, inserting or deleting vertices, rather than
just deleting it.  We can copy the route to the end of the list, delete
the old copy and close the gap where it was; once copied to the end, it
is then free to grow as necessary.

### TO BE DONE

Write design data conversion utility.

Update photoplot utility to handle legend rotation properly  (this is an
old deficiency that was never corrected; in testing, this version builds
successfully against updated database and handles legend positions as
expected, so can at least be added with confidence).  _Should also think_
_about inner layers.  Probably need to add even more apertures for each_
_hole size used in the design plus something for the plating to take to,_
_and associated clearances (to create a void in a ground plane)._

Adapt Utilities to work with Sideways RAM version of code.  _Probably_
_best to hold off until have decided how to do "properly"._
