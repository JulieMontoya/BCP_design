## Thoughts, in no particular order

Create a jump table with all the entry points that will be used by the utilities.  Utilities need
modifying to incorporate address data into wiring list, and possibly to use `L_cmd` and `S_cmd` now
these are part of database library.

To make sideways RAM friendly, all BRKs must be thrown from main RAM.  

The palette now supports colours >=128 as meaning force outline mode, for 2-colour MODEs.

We need to be able to step through the database, searching for pins connected to a given node.
For each component, we need to step through its pins seeing which node each one is connected to; then
RTS  (saving the current pin and component so we can resume the search)  so we can process it, then
JSR to the "next pin" code  (where we would naturally have landed anyway, if the pin was not connected
to the wanted node)  to continue searching for pins connected to that node.  

We can use the carry flag to indicate whether or not we have searched the entire wiring list.  If we
match on a pin, the `CMP` instruction will set the carry flag; during the reinitialisation, we will
check to see if the current part number is less than the total number of parts.  If we are still
within the wiring list, the `CMP` will leave the carry flag unset if we have more parts to search, so
we will have to clear it manually to signal an end-of-search condition.

We also need to think about adding a section of code to check if a point is within the viewport.  As
we step through the parts, we can get the boundary of each one; if both corners are outside the
viewport, we can skip straight to the next part, so we only return points that are likely to appear
on the screen.  (A pin might fall outside the viewport if the component is overhanging the edge of the
viewport, but the calculated screen co-ordinates won't be out of range for the MOS graphics code to
deal with.)

We also need to be able to unpack a part's designator.  This will require decoding a binary number
to decimal.  (Or we could cheat and do that in BASIC.)

### Improvements to the Graphics Library

The code for plotting oblong pads is a mess.  It needs rewriting, using a loop and a table of offsets
to optimise the repeated `STA` and `STX` or `STY` instructions.  _What was I thinking when I wrote it?_
Well, I probably was thinking I didn't know a better way of doing it.  

The space saved rewriting that code ought to be sufficient to enable the use of a vector to hook into
the `get_colour`/`set_colour` subroutine.  The intention is to have the option for _either_ a colour
from the palette, _or_ a fixed colour obtained from some memory location.  The former will be used for
drawing parts in four-colour `MODE 5`; the latter for drawing parts in two-colour `MODE 4`, and also
for erasing parts by overdrawing with the background colour.

_Done now, mostly.  After initially writing for maximum compatibility with the previous version, by
inserting NOP instructions to keep all entry points the same to avoid rebuilding the test program, now
have bitten bullet and rebuilt database and test program._

Also, the mis-named `draw_pad`  (it used to call  `prepare_pad`)  always gets called after `select_pin`
and probably is best merged into that.

### Improvements to the Database

`get_pins` always gets called after `unpack_part` and probably needs a call adding right there.
`save_bdy` from the graphics library might be worth moving into the database code to add its
functionality to `unpack_part` as well.

Need to rewrite the `testpt` subroutine.  Instead of using zero-page variables bxb and ptb, use X
and Y as independent index registers into the page A workspace.  This frees up two zero-page variables
to use for routing functionality.

### Routes

`rtb` is a zero-page pointer to the routes table, which holds the fixed-length portion of each route record.
`wpb` (formerly `rdb` for route data base) is a zero-page pointer to the route waypoints table, which stores
the waypoints along each route.

If we assume only the _first_ waypoint along a route will ever be a pointer to a waypoint along another route
(which makes sense; this functionality would most often be used for branching off an existing route without
redrawing all the way to a component pad),  this will make things easier if / when we edit the route to which
it refers.  If the vertex is simply moved without rippng up the route, then this will be handled transparently.
If we change the length of a route, or replace it with a new one, then all references to it will need to be
updated, or the affected waypoints changed to X,Y pairs.

### Drawing Thick Lines

To represent tracks wider than a single pixel on screen, we need to implement a routine for drawimg a thick
line between two points.

### D-Codes for Tracks ###

D70-D73 will be used for widths 1-4.  On a modern photoplotter supporting more than 24 apertures, D74-D78 will also be available for widths 5-9.

### D-Codes for Vias ###

D80-D83  (or, with a mechanical photoplotter, appropriate substitutions made at the reporting stage)  will be used for vias  (pads around a hole where a track switches layers).  Vias will be drilled according to the pad size.  If the layer and width are changed together, the drill will be selected according to the smaller pad.

We generate a via in the photoplot output, on every layer change.  If the current layer is not ours, we wait -- keeping track of the absolute position, but without generating any output -- for a layer change; and then we flash the appropriate D-code for the current layer, based on the new width.  (If we are drawing with D70, we flash D80; if drawing with D71, we flash D81, and so forth.  These will have to be substitited appropriately if we are using a mechanical plotter.)

To generate the drill output, we follow tracks without generating any output until we reach a layer change.  At that point, we drill a hole based on the _smaller_ of the two widths.  

### Command Language

Ideas for a command language.  

`M <des'r>` -- move a part around the screen.  (line 3800)

`W <des'r> <pin #>` -- start wiring from a component pin.  (line 14200)

`V <X offset> <Y offset>` -- move viewport.

We need to modify the `parse_num` subroutine to be able to handle negative numbers.  Allow - as first digit,
set a flag if seen, and twos-complement the number after the last digit if the negative flag was set.

### Design File Creator

Needs to ask how much space to reserve for:

* Footprint headers
* Pins
* Silkscreen
* Parts list
* Wiring list
* Route headers
* Waypoints

Needs to have `PROC`s to list footprints in design and master files, and copy a footprint from master to design.  (NB: each footprint header contains offsets to its associated pin and silkscreen data, which will need to be updated on copy.)

### Footprint Creator

Needs option to import footprints from a master footprints file alongside those it creates.  (Also needs to work with _no_ master footprint file!)  Any footprint file can be used as a master file, but an actual design is restricted to 32 footprints.
