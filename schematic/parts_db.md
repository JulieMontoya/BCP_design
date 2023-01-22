The parts database contains three fundamental types of object: **container parts** which consist of several sub-parts which may be treated independently, or **systems**, and a mapping between the terminals of each system and the pins of the physical package; those systems themselves, each of which includes a schematic symbol; and **self-contained parts** which contain only a single system.

## EXAMPLES OF SELF-CONTAINED PARTS

**RES1** is a resistor.  This has a schematic symbol with an **outline** and two **terminals** for connection to the rest of the circuit.

Self-contained parts do not require a **pin map**.  The terminals on the symbol for a self-contained part correspond directly to the physical pins of the component.

**NPN1** is an NPN transistor.  This has three terminals.  In accordance with the conventions of the circuit simulation program **SPICE**, the first is the collector; the second is the base; and the third is the emitter.  

## EXAMPLES OF SYSTEMS

**OPA1** is an operational amplifier.  This has a schematic symbol with three **terminals**, corresponding to its non-inverting and inverting inputs and output.

**POW2** is a two-terminal power connector; it exists to allow the balance of the pins on a package containing several other systems to be connected to something.

The container part to which a system belongs must include a table to describe the mapping between the pins on the physical package of a component and the terminals within the systems that make it up.

## EXAMPLES OF CONTAINER PARTS

**2904** is an LM2904 dual op-amp.  This consists of three systems; two operational amplifiers and a power connector.

System 0 is an operational amplifier whose non-inverting input is connected to pin 3, inverting input to pin 2 and output to pin 1.

System 1 is an operational amplifier whose non-inverting input is connected to pin 5, inverting input to pin 6 and output to pin 7.

System 2 is a power connector, using pins 4 (positive) and 8 (negative).

The pin mappings would be represented thus:

System | Terminal | Pin
-------|---------:|-----
0      |        0 | 3
0      |        1 | 2
0      |        2 | 1
1      |        0 | 5
1      |        1 | 6
1      |        2 | 7
2      |        0 | 4
2      |        1 | 8

The corresponding back references would be:

Pin | System | Terminal
----|-------:|----------
1   |      0 | 2
2   |      0 | 1
3   |      0 | 0
4   |      2 | 1
5   |      1 | 0
6   |      1 | 1
7   |      1 | 2
8   |      2 | 0


## SCHEMATIC SYMBOLS

Schematic symbols are described by a series of instructions for plotting on a co-ordinate grid.  Co-ordinates of points within a symbol are specified relative to its centre, in **design units**, and may optionally be rotated to any of 4 orthogonal orientations and/or flipped.

The program handles all conversion of co-ordinates from symbol space to design space, and thence to screen space.

A symbol's record consists of a fixed-size portion and a variable-size portion.  The fixed-size portion holds the number of terminals, the length of the drawing instructions and the address of the variable-length portion.  The latter holds the co-ordinates of each of the symbol's terminals and the instructions to draw it.  The address of the drawing instructions is not given directly, but may be calculated knowing the number of terminals.



### CONTAINER FIXED SIZE RECORD

Byte | Length | Meaning
-----|-------:|--------------------------------
0    |      4 | Name
4    |      1 | No. of Systems OR &80
5    |      2 | Offset to systems
7    |      1 | Number of pins
8    |      2 | Offset to pin map
10   |      4 | Not used

### NON-CONTAINER FIXED SIZE RECORD

Byte | Length | Meaning
-----|-------:|--------------------------------
0    |      4 | Name
4    |      1 | No. of terminals
5    |      2 | Offset to Terminals
7    |      1 | Length of Outline
8    |      3 | Boundary Left X, Bottom Y
11   |      3 | Boundary Right X, Top Y


### SUB-PART FIXED SIZE RECORD

Byte | Length | Meaning
-----|-------:|-----------------------
0    |      4 | System Name
4    |      1 | System Index
5    |      1 | Offset into pin map

### PIN MAP

The pin map is a simple, linear list of which **pin** on the package is connected to each **terminal** of each **system** in turn.  The sub-part record for the system contains its offset into the pin map.

### SYMBOL PLOTTING COMMANDS

+ MOVE -- move the cursor to the given position without drawing anything.  Remember the new position in component space as `DstX` and `DstY` and its equivalent in screen space as `lmX` and `lmY`, for use in a subsequent `CLOSE` instruction.
+ DRAW -- draw a line to the new cursor position.
+ TRIANGLE -- draw a triangle using the two previous and new cursor positions as its vertices.  (`PLOT 85` to experienced BBC Micro users!)
+ CLOSE -- draw a line to the new cursor position given, and then on to (`DstX`, `DstY`), thus completing an outline by returning to the start; this saves a vertex in a closed outline.  As an additional economy, `CLOSE` immediately following `MOVE` completes a rectangle with the two specified positions as opposite vertices.
+ CENTRE -- set the centre of a circle or arc, or the origin for text, without moving the cursor or altering `DstXY`.
+ ICIRCLE -- draw an independent (i.e., beginning with `MOVE` so as not to join to anything) arc of a circle.  The value given as an X co-ordinate specifies the radius and direction of drawing  (negative is clockwise).  The value given as a Y co-ordinate specifies the starting and finishing points.
+ JCIRCLE -- draw an arc of a circle, joined from the last cursor position.
+ _TEXT -- write some text at the position specified by a CENTRE command.  The least significant 8 bits of each of the X and Y co-ordinates specify the address in memory of the text, which is preceded by a length and a disposition. If bit 8 of the Y co-ordinate is 1, the byte following the length specifies the size and orientation; otherwise size 1 is used, with the same orientation as the symbol itself.  If bits 7-0 of Y are %00000000 (i.e., the text would be in zero page) then the text, possibly with a disposition byte, is embedded directly in the plotting instructions, with bits 7-0 of X giving the length._
+ TERMINAL -- the specified point is a terminal.  Not usually used in drawing, but embedding termninals within the outline allows the outline drawing code to be re-used to find the co-ordinates of a terminal in order to draw connections from it.  

### SPECIAL PACKED CO-ORDINATES

Co-ordinates used in symbols consist of a 10-bit X co-ordinate, a 10-bit Y co-ordinate and a 4-bit plot mode  (terminals are treated similarly enough to a plotting instruction to be handled by the same code).  Instead of modifying the existing packed co-ordinate format, a special format has been created for this purpose as follows:

The first two bytes are the low bytes of the X and Y co-ordinates, respectively, and can be copied to `PinX` and `PinY`.  The third byte is constructed thus:

Bit     |  7 |  6 |  5 |  4 |  3 |  2 |  1 |  0
--------|----|----|----|----|----|----|----|----
Meaning | Y9 | Y8 | X9 | X8 | K3 | K2 | K1 | K0

To unpack this last byte, we first make a copy on the stack with `PHA` and shift left one bit; if the carry (representing bit 9 of the Y co-ordinate) is set, we set `pinY+1` to be &FF, otherwise we set it to &00.  (Recall that whenever a twos-complement number is being copied into a longer word space, all bits to the left of its highest (sign) bit need to be set the same as that bit.)  In either case, the high byte of Y is correct so far and _we do not need to shift in C_.  We shift out the next bit from the packed byte into C and thence left into `pinY+1`.  Now the 2-byte value at `pinY` has had its sign correctly extended to 16 bits.  We repeat the process of shift out, store in, shift out, shift in for the X co-ordinate.  Lastly we retrieve the copy from the stack with `PLA` and `AND` it with &0F to extract just the plot mode in the accumulator.



## SELECTING A SYMBOL




GRAVEYARD

  (at the offset into which the drawing instructions begin can be inferred from the number of terminals).


Byte | Length | Meaning
-----|-------:|--------------------------------
0    |      4 | Name
4    |      1 | Type / No. Sys / No. Terms
5    |      2 | Offset to systems or terminals
7    |      1 | No. pins / Len. Outl
8    |      3 | Boundary LX, BY
11   |      3 | Boundary RX, TY
8    |      2 | Offset to pin map
10   |      4 | Not used

