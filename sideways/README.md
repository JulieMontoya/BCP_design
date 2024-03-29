# EXPERIMENTAL SIDEWAYS RAM BUILD

This is an experimental build of BCP to run  (mainly)  from sideways
ROM.  (Tested using sideways RAM, believed not to have any writes to
itself.)

**N.B.  ALL FURTHER DEVELOPMENT IS TAKING PLACE IN THE version6**
**FOLDER!  THIS IS RETAINED ONLY FOR HISTORIC INTEREST .....**

## BUILDING

The included `Makefile` uses (mostly) the same source code to produce
either a sideways ROM build or a standard, non-sideways ROM build.
The difference is where the code is assembled to run from.

### NON-SIDEWAYS BUILD

This generates the usual version of **BCP DESIGN** which sits below
MODE 4/5 screen RAM, and can take advantage of shadow RAM to run in
MODE 129 on a Master 128.

To build the non-sideways version:

```
$ make non_sideways
```

To run the program, load the disc image into a real or emulated BBC
Micro and enter the following:

```
*LOAD M.PAGEA
CHAIN "NSTEST1"
```

### SIDEWAYS ROM BUILD

The sideways ROM build generates a version of **BCP DESIGN** which can
run in MODE 1 on an unexpanded Model B; in the form of a ROM image with
code allowing it to load into main RAM and copy itself to sideways RAM.

Note that for this experimental version, the sideways bank is hard-coded
into the source code.  You may need to edit the file `sw_main.6502` and
change the value of `SW_BANK_NO` to suit your target hardware.

To build the sideways version, edit `sw_main.6502` if necessary; then

```
$ make sideways
```

To run the program, load the disc image into a real or emulated BBC
Micro and enter the following:

```
*LOAD M.PAGEA
*/R.BCP_SW
CHAIN "TEST4"
```

## DIFFERENCES

The code is barely altered save for repositioning in memory.  The maths
library component is position-sensitive, so it begins offset after the
loader code.  The database and graphics libraries and the main design
application are moved after the maths library.

Code that uses BRK to throw errors has been moved to a separate stub
which runs from main RAM, thus ensuring that BASIC will never be trying
to read an error message from its own ROM instead of the sideways bank
containing the program.

The stub also includes code to call a routine in sideways memory,
preserving the processor status word, accumulator and X and Y registers
before and afterwards.



Note that the input disc image used for building it is slightly dodgy:
the contents of L.MINVARS are only partly correct.  Workspace variables
are fine, but entry points are wrong.  Fortunately, the test program
is only using one entry point.



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
    JSR page_in_bcp
.jsr_swram
    JSR safe_return         \  Will get overwritten
.page_in_basic
    PHP                     \  Save processor status
    PHA                     \  Save accumulator
.restore_basic
    LDA #12                 \  Operand will get overwritten!
    STA &F4                 \  RAM copy of selected bank
    STA romsel              \  Hardware bank select
    PLA                     \  Restore accumulator
    PLP                     \  Restore processor status
.safe_return
    RTS
.page_in_bcp
    PHP                     \  Save processor status
    PHA                     \  Save accumulator
    LDA &F4
    STA restore_basic+1     \  This is legit; we are in RAM
    LDA #SW_BANK_NO
    STA &F4                 \  RAM copy of selected bank
    STA romsel              \  Hardware bank select
    PLA                     \  Restore accumulator
    PLP                     \  Restore processor status
    RTS
```
This is the first section; which selects the sideways ROM slot with our
program, pushing the processor status byte and accumulator to the stack
and restoring them afterwards so that we will enter the routine with P,
A, X and Y intact.  Note that the value read from &F4 is stored right
into the operand of a later `LDA #` instruction!  This honestly seemed
as good a place as any to put it: it isn't taking up an extra byte
anywhere else, and we **know** this location is writable.

The address in sideways memory to be called should have been written over
the operand of this `JSR` instruction before we started.

`page_in_basic` is just the reverse of the sideways ROM selection code.
The operand in the `LDA #12` instruction was overwritten earlier with the
value read from &F4 at the beginning, and now this bank gets selected --
taking care to preserve P and A -- before we return.

We can use this code to call a sideways ROM routine from BASIC:

```
14070DEFFNusr(M%)
14080PROCpoke(sw_addr,M%):=USRgo_sw
```
This makes use of `PROCpoke`, an existing PROCedure to store a 16-bit
value in memory.  `sw_addr` must already have been initialised with
`jsr_swram` + 1  (pointing to the second and third bytes, which are the
operand)  and `go_sw` with `go_sideways`.  Then we can call FNusr()
exactly like USR.

## THE JUMP TABLE

The stub also includes a version of the jump table, still sitting
immediately before screen memory (though now at &2Fsomething), which
allows routines in sideways memory to be called directly from
corresponding addresses in main memory.  This is achieved by means of
some cunning trickery with the stack.

Every address in the jump table contains a JSR instruction pointing to
the _same_ address.  The code here pushes the P, A, Y and X registers to
the stack, then finds the return address that was on the stack before the
registers were pushed.  This will be the address of the _last_ byte of
the JSR instruction; we correct it to find the first byte of the JSR by
subtracting two, and we store the address directly into a JSR instruction
with the high byte modified to point to a copy of the jump table in
sideways memory.  The stack contents are then shunted up (= backwards) by
2 bytes to overwrite the return address; meaning we will not return to
the instruction after the JSR in the stub copy of the jump table, but to
the instruction after the JSR that called _it_.  The BCP sideways ROM is
paged in, then the X, Y, A and P registers are restored from the stack,
and the routine in sideways RAM is called.  When that returns, BASIC is
paged back in for a clean return to the prompt.

```
.sw_equiv

    PHP                 \  Save P, A, Y and X on the stack
    PHA
    TYA
    PHA
    TXA
    PHA
    
    TSX                 \  Get the stack pointer
    LDA &105, X         \  Low byte of return address
    SEC
    SBC #2
    STA call_rom+1
    LDA #sw_jump_table DIV256   \  High byte of return address with offset
    SBC #0
    STA call_rom+2
        
    \  Shift the P, A, Y, X we just pushed two places up the stack
    
    LDY #4              \  We are going to copy 4 bytes
.copy_stk4
    LDA &104,X          \  Initially points to wherever P is
    STA &106,X          \  Initially points to return address high byte
    DEX                 \  Copy next byte on stack
    DEY
    BNE copy_stk4       \  Keep going round till Y=0
    TSX                 \  Retrieve the original stack pointer ...
    INX                 \  ... and adjust it by 2
    INX
    TXS                 \  Now stack pointer points to the copy of X
    
    JSR page_in_bcp     \  Page in BCP ROM
    
    \  Retrieve the copied X, Y, A and P from the stack
    
    PLA
    TAX
    PLA
    TAY
    PLA
    PLP
    
.call_rom
    JSR safe_return     \  Will get overwritten
    JMP page_in_basic
```

# FURTHER WORK

The author considers the concept of a sideways ROM build of the code to
be proven.

The intention in future is for the source code files to be able to be
`INCLUDE`d into either a standard or a sideways build with different
"glue" files.  The Makefile must be able to generate sideways-specific
versions of files directly from the non-sideways versions wherever
necessary.  There will be no need to use an input disc image; any
variables files will be created from the BeebAsm output.

Remove dependency on a specific ROM slot.  Ideally, behave more like a
"real" sideways ROM; perhaps by providing a "star" command to set up the
code stub in main RAM, if Acorn's official entry mechanism proves not to
be suitable.

Create versions of utility programs to work with code in sideways ROM.
(This will test the entry mechanism thoroughly.)

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

It might even be possible to fit the photoplotter font into the ROM
image, along with code to generate text on screen in the photoplotter
font instead of the BBC's font.  _Maybe even more of photoplotting_
_code._



_It almost works in MODE 1 on a Model B; but too much space is taken up_
_by not-strictly-necessary variables to allow the design to fit into_
_memory as well._  

It works in MODE 1 on a Model B!  At least, it works if the stub is
placed at &2E00 just below the MODE 1 screen memory, an abridged
variables file is used and the design fuile is only &800 bytes.

