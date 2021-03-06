# BCP_design
BCP: a BBC Micro Printed Circuit Design Program

A program to design printed circuit boards on the BBC Micro.  Yes, really.  Currently still just about fits into a Model B.  Whether or not it will still fit when finished  (if it ever gets finished)  is, at this stage, anybody's guess.

The brief: Accept input in the form of a wiring list (schematic capture can wait .....) and turn this, and user input, into Gerber and Drill files that can be used for manufacturing.  There is also, of course, a canonical format for wiring lists: the SPICE deck. We simply append an extra field to the end of each line, delimited by a star -- which the SPICE interpreter treats as a comment marker, so it does not even spoil the validity of the file! -- to indicate the (initial) footprint for the component.

Done so far: The maths, database and graphics libraries, most of the design application  (still commands to add and behaviour to tweak)  and some "breadboard and Dymo tape" utilities to generate footprints  (from DATA statements in the BASIC program) and design files  (from the generated footprints and a modified SPICE deck, either in a file or as DATA statements within a program).  Beginnings of a reporting system, which eventually will generate Gerber and drill files that can be used for manufacture.

The name really stands for "Back of Cigarette Packet", and it's pure coincidence that this also spells PCB backwards and is short for "BBC Circuit Program". :D


You can download a pre-built SSD image containing the latest version of BCP design, ready to use in an emulator or transfer to a real BBC micro, here: https://github.com/JulieMontoya/BCP_design/blob/master/beebasm/bcp_latest.ssd

You will also need the utilities disc, available here: https://github.com/JulieMontoya/BCP_design/blob/master/utils/bcp_utils.ssd

Documentation can be found here: https://github.com/JulieMontoya/BCP_design/wiki

If you are very brave, see https://github.com/JulieMontoya/BCP_design/wiki/Building

### 2021-04-17 ###

I think I am going to call this a release.

### 2019-09-11

I have made an improvement to the graphics library so it properly supports layers.  It is possible for components to be placed on either side of the board.  The pad definitions within a footprint refer to "mounted side" and "opposite side".  In the case of  (usually through-hole)  components mounted on the top, the silkscreen is on layer "TS", the mounted side pads are on layer "TC" and the opposite side pads are on layer "UC".  In the case of  (usually surface-mount)  components mounted on the underside of the board, the silkscreen is on layer "US", the mounted pads are on layer "UC" and the opposite side pads  (if there are any; surface-mount parts should have pad 0 on the opposite side)  are on layer "TC".  

### 2019-09-25

I have made available a "technology preview" as a ready-to-go disk image `image_put25.dfs`  (targeted for Model B).  To use this

 `CHAIN "PUT25"`
 `GOTO2200`  for MODE 4
 `GOTO2300`  for MODE 5
 `GOTO4800`  to draw component outlines
 `GOTO14200`  to begin routing test.
 
Select starting pin e.g. `R1 1`. A line will be drawn to another pad connected to that one.  Press SPACE to select among possible ending pads, then RETURN to begin routing.  Z, X, :, / to move, RETURN to add a vertex, @ to add the last vertex and complete the route to the destination pad.

It doesn't save anything yet .....

### 2019-10-19

New versions of graphics library  (pad drawing code fully rewritten, some stuff moved to database manager.  Now supports outline pads, enabled by setting bit 7 of memory location `padmode`),  database manager and placement/routing test program.  There's more yet to be done on the graphics library, but at least this version works.  Also a new program `REP10` which is the beginnings of a report generator.

### 2020-01-22

New versions uploaded.  Code builds and the "playable demo" runs .....  Next step will be a stand-alone wiring list generator  (and maybe even some new wiring lists and a new footprint file).  I first need to debug some code that I've broken somewhere along the way, that didn't get spotted because the demo isn't testing it .....

### 2020-02-23

Uploaded **bcpdemo2.ssd** and **bcpdemo3.ssd** disc images. 
