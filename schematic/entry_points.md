# ENTRY POINTS

The code has the following entry points:

### ext_get_point

### ext_sch_gplot

### ext_init

### ext_select_part

### ext_select_subpart

### ext_sym_draw

### ext_mark_term

### ext_draw_bdy

External entry points in fairly consistent places, for debugging.

### init

### get_point

### mult_r_cos

### mult_r_sin

### sch_gplot              \  GENERIC SYMBOL PLOT

### sch_gplotA

### sch_move

### sch_plot

### sch_draw

### sch_triangle

### sch_close

### sch_circle_nj          \  Non-joining version

### sch_circle             \  Keep same PLOT mode

### sch_circle_c

### sch_circle_a

### sch_circle_i

### sch_circle_p

### sch_centre

### sym_draw

### sym_unpack_vertex

### term_marker            \  Draw terminal marker

### term_mk0

### send_A_ext_sgn

Sends the value in the accumulator to the VDU, followed by &00 if it was
positive or &FF if it was negative.

### fit_X

### fit_X1

### mark_term

Plots a terminal marker in inverting mode.

### select_part

Select a part as current.

### store_part

Initialises workspace variables from a part.

### store_envelope

Initialises workspace variables specific to container parts.

### store_non_envelope

Initialises workspace variables specific to non-container parts, including
setting `w_pins` equal to `n_term`.

### store_non_env1

Alternative entry point which does _not_ set `w_pins`.  This is used when
selecting a subpart.

### unpack_bdy

Unpacks the boundary co-ordinates of the current part.

### select_subpart

Selects a subpart as current  (without altering `n_subp` or `w_pins`).
Initialises `ssb`, `pins_o`, `n_term`, `term_a`, `outl_l`, `bdyL`, `bdyB`,
`bdyR` and `bdyT` with appropriate values.

### sel_subp1

Similar, but expects `ssb` already set.

### use_subpart

Similar, but expects `ptb` already set.

### init_ptb

Initialises the part table pointer `ptb` to point to the beginning of the
part whose index in the parts table is in the accumulator.

### new_unpxy_es

A replacement for `unpxy_es` in the maths library.  Extends the sign of
a 4 bit, twos-complement value in the accumulator to 8 bits, by setting
bits 7, 6, 5 and 4 if bit 3 is set.

### search_pin

Searches for a pin within the currently-selected part  (which must be a
container)  and return its terminal number and containing subpart.

### draw_bdy

Draws the boundary outline of a component.

### seed_zp_o

Seed a zero page pointer pointed to by X, from a value at `wkspace, Y`
with an offset in A.

### show_char

Display a character on screen, in one of 8 different possible
orientations, and move the cursor to the correct position for the next
character.  The orientation is selected by the value in `lgdmode` as
follows:

Bit(s) | Meaning
------:|-----------------------------------------------------
7      | Flip top-bottom
6      | Flip left-right
5      | Rotate 90 degrees anticlockwise
4-0    | Control character for cursor dir after writing char

For right-reading text, the following values are used:

0°  | 90° | 180° | 270°
----|-----|------|------
&09 | &2B | &C8  | &EA

### graphics_rts

A convenient RTS for use as an execution address in a SAVE statement.

### pack_desr

Pack a component designator from the card buffer and store its packed form
in `desP` and `desP+1`.

### findpair

### parse_num

Parse a number from the card buffer, and store it in `decnum`.

### pn_notminus

### pn_next

### times10

Super-fast multiply-by-10 routine used in parsing numbers.

### find_part_by_name

Finds a part in the parts table  (or a parts library)  whose name is
pointed to by `ssb`.  

### rewind_lib

Rewind `ptb` to point to the first entry in the parts table.

### treble_ws_X

Load A with the value at `wkspace, X` times three.

### treble_A

Multiply the accumulator by three.

### vphome

Move the viewport to its home position:  bottom left at (0, 0) and top
right chosen according to the scale factor, so as to be (1279, 1023) in
screen space.

### vp_moved

Set the state to indicate the viewport has moved.

## TABLES

These are not code, but data.

### sch_plotmodes

Addresses of routines corresponding to PLOT modes

### tm_coords

Terminal marker co-ordinates

### alt_sines

### alt_cosines

Trig tables in sign-magnitude notation
