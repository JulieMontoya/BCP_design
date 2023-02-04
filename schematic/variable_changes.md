# VARIABLE NAME CHANGES

BCP name | Meaning              | SCH name | Meaning
---------|----------------------|----------|----------------------
fpbase   | Footprints base      | ptbase   | Parts table base
fpb      | Footprint pointer    | ptb      | Parts table pointer
nfp      | Number of footprints | n_ptyp   | Number of part types
ssbase   | Silkscreen base      | tmbase   | Terminals base
moveX    | Constant &00000000   | cons_0   | Constant &00000000


## NEWLY INTRODUCED VARIABLES

SCH name | Bytes | Meaning
---------|-------|----------------------------------
n_subp   |     1 | Number of subparts
subp_a   |     2 | Address of subparts
w_pins   |     1 | Number of pins in whole part
pins_a   |     2 | Address of pin table
n_term   |     1 | Number of terminals in (sub)part
term_a   |     2 | Address of terminals
outl_a   |     1 | Outline length


`select_part` updates `w_pins` when the part selected has no subparts, but `select_subpart` never touches `w_pins`.  