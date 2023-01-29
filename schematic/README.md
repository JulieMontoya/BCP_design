# SCHEMATIC

My attempt to create a schematic capture program to go with BCP.

It's going to be harder than the PCB design side!  Since parts can be split into
several subparts .....  and there won't be anything like a direct mapping from
parts to PCB footprints .....

## THE ULTIMATE INTENTION

The ultimate intention is to generate a wiring list that can be imported into
BCP to create a circuit board design, or SPICE to simulate the operation of a
circuit.  (The file formats are essentially identical, since BCP is expecting
a syntactically-valid SPICE file with PCB footprints specified in a comment
on each line.)  This will be generated from the database as a report, probably
by a separate utility program.

The entire schematc design database will be built up piecemeal from scratch,
adding parts and making connections as required.

A utility program will need to be written to reorganise a design database if
a section outgrows its initial allocation.

_This will require the ability to import part definitions from a library into a
design "on the fly"._

## WHAT CAN BE REUSED FROM BCP?

At the heart of BCP is a geometry engine which transforms co-ordinates from
component space  (relative to some centre point, rotated through one of four
angles and optionally flipped)  to design space  (absolute, and extending
beyond the screen)  to screen space  (relative to some viewport, and scaled
so the viewport fits the screen exactly).  This is supported by a 
general-purpose 16-bit integer maths library making use of a single page of
workspace variables, and another up to 32 bytes of zero page workspace.

The remainder of the code is more or less cleanly separated into a database
library, which provides for parsing values from space-delimited strings,
packing and unpacking component designators and extracting information from
the design database; a graphics library, which draws copper pads, silkscreen
outlines and the copper tracks that make up the circuit; and the design
application itself, which makes use of the library functions.  The utility
programs make use of the maths and database libraries to create PCB
footprints, generate a design file from a wiring list, check a design for
unconnected component pins and produce photoplot and drill output files for
manufacture.  (An experimental, visual footprint creator will also use the
graphics library.)

The co-ordinate geometry engine can easily be repurposed to draw schematic
symbols instead of copper pads and silkscreen outlines, and simple connection
lines instead of copper tracks.  This is included within the maths library,
which can be lifted wholesale apart from the following differences:

* Some workspace variables will need to be renamed to reflect a different
meaning while performing a conceptually-similar function  (e.g., the basic
unit of the parts library is a _part_, not a _footprint_; schematic symbols
have _terminals_ as opposed to PCB pads, and their outlines are not for
silk-screen printing.  But the computer does not care about that).  Others
(e.g., the aperture definitions, which only make sense in the context of a
PCB design; schematics are usually plotted using only one or at most a few
line widths)  can be repurposed altogether.

* The jump table at the end of the maths library will need to be rewritten.

Parts of the database library will be directly reusable.

Those parts of the graphics library dealing with printing text in non-standard
orientations can be reused, with a slight modification:  "flipped" text is not
actually to be flipped left-to-right, only right-justified against the initial
cursor position.  (If we flip the symbol for a transistor so its base is on
the right-hand side, we still want its legend to read left-to-right; and we
still want it to extend away from the symbol.)

Some parts of the design application may be reusable; especially those parts
relating to moving the viewport, setting the scale and moving the cursor.  It
is anticipated that the command despatcher will be rewritten entirely, and a
version of the new despatcher may be ported to BCP.

## WIRING

The existing routes database format can be uised more or less as-is to store
connections as required in a schematic diagram.

Improvements:

We want to draw a visible junction where two wires are connected.
Junction points will be stored in place of layer/width changes, with an 8-bit
junction identifier in place of the layer and width.  The junction will
be drawn at the immediately-preceding vertex.  When a route _begins_ with a
T-junction, the routes database will be searched for the corresponding
junction point on a route connected to the same circuit node, backed up to
find the position of its vertex, and a junction marker drawn there.

There are no layers or track widths.  The notation for layer/width changes
will be adapted to store a T-junction identifier instead.  When a route _begins_
on a T-junction, the routing table will be searched for the co-ordinates of
the corresponding point.

```
rewind routes
repeat
    if (node matches) then
        for (second and subsequent waypoints along route)
            if (is junction and jid matches) then
                unpack preceding waypoint to absX, absY
                return C=0
            fi
        next
    fi
until (no more routes)
return C=1
```

## COMMANDS

_all provisional and not yet even looked at_

**A {designator} {part_type}** -- **ADD** a component to the design database.

Example: `A IC2 DOPA NE5532 * DIP8`  Adds a part, designated `IC2`; of type
`DOPA`  (which is the name in the parts library for a common 8-pin dual
operational amplifier);  with the value `NE5532`  (a low-noise part)  and the
associated PCB footprint `DIP8`  (corresponding to an entry in BCP's own
footprint library).

**W {component} {pin} {component} {pin}** -- **WIRE** a connection between
two component pins.  `RETURN` inserts a vertex, `DELETE` deletes one, `T`
inserts a T-junction. `I` removes one.

**WE** -- **WIRING EDIT** -- edit the most recently-added connection.  `Q` and
`W` select a vertex to move. `TAB` selects a vertex under a junction.  `t`
inserts a T-junction at the current vertex, then begins a brand new route from
there.

**WE {component} {pin}** -- select a connection to edit, connected to the given
pin.  The selected connection will be brought to the end of the database, where
it will have room to grow, and its original version wiped out by moving down
the data above it to close the gap that would have been created, adjusting
the table of indexes accordingly.





