# VERSION SIX

Version 6 is work in progress.  It is intended that the same source files
will be used to produce a "standard" version, a "sideways" version which
runs from sideways ROM or RAM and a set of source code disc images for
assembly on the target system.

## BREAKING CHANGE

BCP version 6 will include the ability for each component in the design
to have its legend moved.  This requires a change to the database format;
the fixed-length record is now 12 bytes long as follows:

BYTES | BITS | MEANING
------|------|---------------------
0     | 2-7  | Designator letter(s)
0     | 0-1  | Designator number high bits
1     |      | Designator number low bits
2-4   |      | Packed X,Y co-ordinates
5-6   |      | Wiring list offset
7     | 6-7  | Angle in 90° steps
7     | 5    | Side (0 = top, 1 = under)
7     | 0-4  | Footprint
8-10  |      | Legend co-ordinates
11    | 6-7  | Legend angle
11    | 0-3  | Legend size

This requires a new version of `WL2DES` and also a new utility to convert
an existing design database file in the "old" format to the "new" format.

### TO BE DONE

Write conversion utility.

Update photoplot utility to handle legend rotation properly  (this is an
old deficiency that was never corrected; in testing, this version builds
successfully against updated database and handles legend positions as
expected, so can at least be added with confidence).  _Should also think_
_about inner layers.  Probably need to add even more apertures for each_
_hole size used in the design plus something for the plating to take to,_
_and associated clearances._

Extend program with ability to move component legend and store its new
position and angle in the database.

## OTHER CHANGES

The structure of the BeebAsm source files has changed to accommodate the
possibility of standard and sideways builds.

The command despatcher has been rewritten completely, based around
matching variable-length strings with a wildcard.  There is no need for
each command to handle its own modifiers anymore.

## PLANNED CHANGES

A command will be added to move a component's legend.

The route editor will be overhauled and given the ability to edit an
existing route by moving, inserting or deleting vertices, rather than
just deleting it.  We can copy the route to the end of the list, delete
the old copy and close the gap where it was; once copied to the end, it
is then free to grow as necessary.

