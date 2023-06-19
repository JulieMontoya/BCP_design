# EXPERIMENTAL SIDEWAYS RAM BUILD

This is an experimental build of BCP to run  (mainly)  from sideways
ROM.  (Tested using sideways RAM, believed not to have any writes to
itself.)

The program uses BRK to throw errors.  This code has been moved to a
separate stub which runs from main RAM, thus ensuring that BASIC will
never be trying to read an error message from its own ROM and not the
sideways bank containing the program.

The stub also includes code to call a routine in sideways memory,
preserving the processor status word, accumulator and X and Y registers
before and afterwards.

Otherwise the code is unaltered save for repositioning in memory.  The
maths library component is position-sensitive, so it begins offset after
the loader code.


Note that the input disc image used for building it is slightly dodgy:
the contents of L.MINVARS are only partly correct.  Workspace variables
are fine, but entry points are wrong.  Fortunately, the test program
is only using one entry point.

_It almost works in MODE 1 on a Model B; but too much space is taken up_
_by not-strictly-necessary variables to allow the design to fit into_
_memory as well._  

It works in MODE 1 on a Model B!  At least, it works if the stub is
placed at &2E00 just below the MODE 1 screen memory, an abridged
variables file is used and the design fuile is only &800 bytes.


It ought to be possible to free a bit more space by moving the design
data into sideways RAM.  This obviously will require it to be copied
through a buffer in main RAM for loading and saving; but we can use
screen memory for this purpose, and just redraw the design afterwards.
Some temporary display corruption is a fair price to pay, if BCP can
be made to run in MODE 1 on a Model B with sideways RAM.

Starting the design data at &B000 will allow 4KB for our design; and if
we EOR addresses from &B000-&BFFF with &C000, we map onto &7000-&7FFF,
at the end of screen RAM.  Special versions of the SAVE and LOAD commands
will need to be created to take care of copying the design data from
sideways RAM pre-SAVE and back post-LOAD.  


The next step will be to compare the minimal changes that have been made
against the original code, and create a common set of source files from
which it is possible to build either the "normal" or the "sideways RAM"
versions of BCP.

It might even be possible to fit the photoplotter font into the ROM
image, along with code to generate text on screen in the photoplotter
font instead of the BBC's font.  


## THE SELF-LOADER

The ROM image file is intended to reload at an address of &3C00, where it
will occupy 16K immediately below the MODE 7 screen memory, and execute
from the same address.  It  contains a section of code whose purpose is
to copy the image file into its rightful location in a bank of sideways
RAM, as follows:
```
\  SELF-COPYING CODE FOR MODEL B WITHOUT *SRLOAD COMMAND

ORG &8000

.copy_to_swram
    LDA &F4
    PHA                 \  Save current ROM number on stack
    LDA #SW_BANK_NO
    STA &F4             \  RAM copy of selected bank
    STA romsel          \  Hardware bank select
```
This code reads the currently-selected ROM slot number from the copy in
memory and pushes it onto the stack.  It then selects the wanted bank
of sideways RAM  (here, hard-coded into the Source Code)  by storing its
ROM slot number in zero page  (this copy is kept in case the MOS has to
page a ROM out and back in again in the course of servicing an interrupt
or something, as the hardware was not designed to allow the value written
to the port to be read back),  then writing the ROMSEL register in SHEILA
actually to select it.

```
    LDA #&3C            \  Source address
    STA &71             \
    LDA #&80            \  Destination address
    STA &73
    LDY #0
    STY &70
    STY &72
```
This code initialises a pair of pointers in zero page for the source and
destination for the copying operation.  &70 and &71 are initialised with
&3C00, and &72 and &73 are initialised with &8000.  The  Y register is
used to hold the low byte, so we begin the next section with Y=0.
```
._cpy_swr_0
    LDA (&70), Y
    STA (&72), Y
    INY
    BNE _cpy_swr_0
    INC &73
    INC &71
    LDA &71
    CMP #&7C
    BCC _cpy_swr_0
```
This is the main loop.  We load the accumulator from (&70), Y and store
its contents to (&72), Y.  We increase Y and keep going round until Y
wraps around from &FF to &00.  (We have already copied this byte, on the
first pass through the loop.)

After copying 256 bytes, we increase the high bytes of the destination
and source addresses in &73 and &71, and compare the value in &71 with
&7C.  If the source address is less than &7C, we branch back to the top
of the loop again to copy another 256 bytes.  (At this point, Y is
still equal to 0.)

```
    PLA                 \  Restore previous ROM
    STA &F4
    STA romsel
    RTS
```
Once all the code up to and including address &7BFF has been copied, we
retrieve the last-selected ROM slot from the stack and select it again
before returning.

On a BBC Master, the MOS includes a `*SRLOAD` command which can be used
to load a ROM image directly from disc into sideways RAM, bypassing the
self-loader -- though the latter may actually be faster on a DFS floppy
system.

## THE MAIN-MEMORY STUB

This is a stub program which runs from main RAM and allows a routine in
sideways memory to be called.  It handles the memory paging more or
less transparently, preserving PAYX across the actual bank selections
so parameters can be passed both ways.  The address to be called is
poked into two locations in memory, and this code is called:

```
.go_sideways
    PHP                     \  Save processor status
    PHA                     \  Save accumulator
    LDA &F4
    STA restore_basic+1     \  This is legit; we are in RAM
    LDA #SW_BANK_NO
    STA &F4                 \  RAM copy of selected bank
    STA romsel              \  Hardware bank select
    PLA                     \  Restore accumulator
    PLP                     \  Restore processor status
```
This is the first section; which selects the sideways ROM slot with our
program, pushing the processor status byte and accumulator to the stack
and restoring them afterwards so that we will enter the routine with P,
A, X and Y intact.  Note that the value read from &F4 is stored right
into the operand of a later `LDA #` instruction!  This honestly seemed
as good a place as any to put it: it isn't taking up an extra byte
anywhere else, and we **know** this location is writable.
```
.jsr_swram
    JSR safe_return         \  Will get overwritten
    PHP                     \  Save processor status
```
The address in sideways memory to be called should have been written over
the operand of this `JSR` instruction before we started.
```
    PHA                     \  Save accumulator
.restore_basic
    LDA #12                 \  Operand will get overwritten!
    STA &F4                 \  RAM copy of selected bank
    STA romsel              \  Hardware bank select
    PLA                     \  Restore accumulator
    PLP                     \  Restore processor status
.safe_return
    RTS
```
This is just the reverse of the sideways ROM selection code.  The operand
in the `LDA #12` instruction was overwritten earlier with the value read
from &F4 at the beginning, and now this bank gets selected -- taking care
to preserve P and A -- before we return.


Finally we use this code to call a sideways ROM routine from BASIC:

```
14070DEFFNusr(M%)
14080PROCpoke(sw_addr,M%):=USRgo_sw
```
This makes use of `PROCpoke`, an existing PROCedure to store a 16-bit
value in memory.  `sw_addr` must already have been initialised with
`jsr_swram` + 1  (pointing to the second and third bytes, which are the
operand)  and `go_sw` with `go_sideways`.  Then we can call FNusr()
exactly like USR.
