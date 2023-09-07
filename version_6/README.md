# VERSION SIX

Version 6 is work in progress.  It is intended that the same source files
will be used to produce a "standard" version, a "sideways" version which
runs from sideways ROM or RAM and a set of source code disc images for
assembly on the target system.


The main new features are:

+ An improved command despatcher
+ Each component in the design now has its own legend position.

(This has necessitated **a breaking change** to the data file format,
see below.)

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



## BREAKING CHANGE

BCP now includes the ability for each component in the design to have
its own individual legend position and angle.  This requires a change
to the database format; the fixed-length records in the parts list are
now 12 bytes long as follows:

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

This requires a new version of `WL2DES` and also a new utility to convert
an existing design database file in the "old" format to the "new" format.


The original idea to minimise space requirements by having all instances
of a component have their legends in the same relative position proved
to be a limitation too far.  Thus, the format of the wiring list section
of the design data file has been extended to inclide a pair of X, Y
co-ordinates, a size (currently ignored) and an angle.




### TO BE DONE

Write conversion utility.

Update photoplot utility to handle legend rotation properly  (this is an
old deficiency that was never corrected; in testing, this version builds
successfully against updated database and handles legend positions as
expected, so can at least be added with confidence).  _Should also think_
_about inner layers.  Probably need to add even more apertures for each_
_hole size used in the design plus something for the plating to take to,_
_and associated clearances (to create a void in a ground plane)._

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

