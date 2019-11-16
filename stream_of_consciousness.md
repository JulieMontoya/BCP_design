## Thoughts, in no particular order

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
updated, or the waypoints changed to X,Y pairs.

### Drawing Thick Lines

To represent tracks wider than a single pixel on screen, we need to implement a routine for drawimg a thick
line between two points.

### Command Language

Ideas for a command language.  

`M <des'r>` -- move a part around the screen.  (line 3800)

`W <des'r> <pin #>` -- start wiring from a component pin.  (line 14200)

`V <X offset> <Y offset>` -- move viewport.

We need to modify the `parse_num` subroutine to be able to handle negative numbers.  Allow - as first digit,
set a flag if seen, and twos-complement the number after the last digit if the negative flag was set.
