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

Also, the mis-named `draw_pad`  (it used to call  `prepare_pad`)  always gets called after `select_pin`
and probably is best merged into that.

### Improvements to the Database

`get_pins` always gets called after `unpack_part` and probably needs a call adding right there.
`save_bdy` from the graphics library might be worth moving into the database code to add its
functionality to `unpack_part` as well.

