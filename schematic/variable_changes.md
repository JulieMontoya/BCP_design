# VARIABLE NAME CHANGES

BCP name | Meaning              | SCH name | Meaning
---------|----------------------|----------|----------------------
fpbase   | Footprints base      | ptbase   | Parts table base
fpb      | Footprint pointer    | ptb      | Parts table pointer
nfp      | Number of footprints | n_ptyp   | Number of part types
ssbase   | Silkscreen base      | tmbase   | Terminals base


n_subp   | Number of subparts
subp_a   | Address of subparts
w_pins   | Number of pins in whole part
wpns_a   | Address of pins in whole part




\  Type / no. subparts          1   n_subp  
\  Address of subparts          2   subp_a
\  No. of pins in whole part    1   w_pins
\  Addr. of pins in whole part  2   wpns_a
\  Address of back references   2   bkrf_a
\  No. of pins in subpart       1   n_pins  *
\  Address of pins              2   pins_a  *
\  No. of terminals in subpart  1   n_term  *
\  Address of terminals         2   term_a  *
\  Length of outline            1   outl_l  *
\  Address of outline           2   outl_a  *
\  Boundary left X co-ordinate  2   bdyL    *
\  Boundary bottom Y co-ord     2   bdyB    *
\  Boundary right X co-ordinate 2   bdyR    *
\  Boundary top Y co-ordinate   2   bdyT    *

