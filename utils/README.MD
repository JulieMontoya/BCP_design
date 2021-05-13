This is the "utilities" disc.

Note that the machine code programs on the utilities disc are taken from a snapshot of the latest target-side build.  The locations of variables in PAGE &A workspace are subject to change between builds, and some of these locations are jump vectors into the code.  If everything was written properly, these will be initialised properly and everything will behave as expected .....  except I'm not absolutely, completely 110% certain I took that much care to initialise everything properly, and the only way to find out is to see if it crashes.  A suitable `M.PAGEA` file is included on the disc, just in case any strange behaviour is encountered.

## MENU ##

This program offers a menu to select one of the other programs and either run it, or display some explanatory text about it.  To run a program, type its number and press RETURN; to display help text, type its number followed by a question mark **?** and press RETURN.

(There is no real need to use the menu -- you can `CHAIN` any of these programs directly, if you already know in advance what you want to do.)


![The Utilities Disc Menu](https://raw.githubusercontent.com/JulieMontoya/BCP_design/master/screenshots/bcp_utils_menu_s.png)

## APER -- the aperture editor ##

This allows you to edit the apertures which will be used in your design.  Fifteen pad shapes are available for use in footprints  (a further fifteen will be automatically specified for their rotated counterparts),  and up to fifteen track widths may be defined  (although the design app currently supports only four).  Each track width also has an associated via size, which will always be twice the track width; and a via hole size  (which may be zero, indicating an undrilled pad for a surface-mount device).

The program has two screens.  The SPACE bar toggles between pad apertures, and track/via apertures.

On each screen:
+ **:** and **/** select a row  (= aperture shape or track width)
+ **Z** and **X** adjust the length or outer diameter of a pad or the width of a track as appropriate
+ **C** and **V** adjust the width or inner diameter of a pad or the size of a hole.
 
![Editing Apertures used for Pads](https://raw.githubusercontent.com/JulieMontoya/BCP_design/master/screenshots/bcp_utils_aper1s.png)

On the pads screen:
+ **S** selects a pad shape  (Oblong, Rectangular with Hole, Rectangular or Circular)
+ **L** allows you to enter a length or outer diameter directly
+ **W** likewise a width or inner diameter.

![Editing Apertures used for Tracks and Vias](https://raw.githubusercontent.com/JulieMontoya/BCP_design/master/screenshots/bcp_utils_aper2s.png)

On the tracks screen:
+ **T** allows you to enter a track width directly
+ **H** allows you to enter a hole diameter directly.  Note that hole diameters are always entered directly in _tenths_ of a millimetre, although they are _displayed_ in hundredths!
 
Press **M** to switch measuring units  (thousandths of an inch or hundredths of a millimetre).

When all your aperture and drill sizes are as desired, press **RETURN**.  The screen will show a command you can COPY to save the aperture definitions, but they will not actually be saved -- this is intended to allow you to change discs, or enter a new filename.  Aperture definitions are held in memory locations &A00 to &A3F.  You can `*LOAD` an aperture definition file over any existing `M.PAGEA` file, and then `*SAVE M.PAGEA A00 B00` to update it with the new apertures.

### Previewing Apertures ###

If you enter
```
GOTO5000
```
the (unrotated) pad shapes will be displayed on screen, at a scale of 1 physical pixel = 5 thou.  The top row shows apertures 1-5, the next row is 6-10 and the bottom row is 11-15.

### Vias ###

Aperture definitions used for vias are automatically generated when the photoplot utility is run.  

## FPGEN -- the footprint generator ##

This program generates a master footprint file, from which footprints can be incorporated into new designs as required  (each design file contains its own copy of just the footprints used in that design.)  The footprints are generated from DATA statements in the program, which are just the unpacked representation of the binary data in the file.  For more information on the footprint file format, see the [wiki page](https://github.com/JulieMontoya/BCP_design/wiki/The-Footprints-Database).

![FPGEN after finishing](https://raw.githubusercontent.com/JulieMontoya/BCP_design/master/screenshots/bcp_utils_fpgen1s.png)

An example footprint definition follows:
```
20610DATA"CP2X1",2,-150,-50,150,50,-150,150,0,1,2
20620DATA-100,0,5,5,10
20630DATA100,0,5,5,10
20640DATA"M",-150,-50
20650DATA"C",150,50
```
This breaks down as follows:
+ **"CP2X1"** -- the footprint name (up to 7 characters).
+ **2** -- the number of pins in the component, plus 128 if it is a surface mount device
+ **-150,-50,150,50** -- the left, bottom, right and top co-ordinates of the bounding rectangle, in thou
+ **-150,150,0,1** -- the X and Y co-ordinates of the legend in thou, the rotation angle and the size (the photoplot utility has a problem in this incarnation, and treats this as always = 1)
+ **2** -- the number of vertices in the silkscreen outline.
+ **-100,0,5,5,10** -- the X and Y co-ordinates in thou of pin 1, the pad shape  (aperture code)  on the mounted side, the pad shape on the opposite side and the drill diameter in tenths of a millimetre
+ **100,0,5,5,10** -- likewise pin 2.
+ **"M",-150,-50** -- move to (-150, -50) thou
+ **"C",150,50** -- close shape to (150, 50) thou.

Note that the header line includes the number of pins and the number of vertices in the silkscreen outline, so the program knows exactly how much DATA to expect; there is no need for any delimiters between sections.  

**Footprint names** may be up to 7 characters.  Some of the ones used here are based on a shortened form of the stores codes used by one of the author's former employers; for instance "Capacitor, Polyester, 2 by 1 Veroboard holes".  (Veroboard holes, = 100 thou = 2.54mm., are a convenient measuring unit when space is limited!)

The **bounding rectangle** should include the silkscreen outline and the extreme edges of all pads.  Co-ordinates are relative to the component centre, with a 1 thou resolution and a maximum range of -2048 to 2047.

**Pin co-ordinates** are relative to the component centre, with a 1 thou resolution and a maximum range of -2048 to 2047.  A pin also has:
+ An aperture code (1-15) for the pad on the side of the board where it is mounted
+ An aperture code (1-15, or 0 for no pad on the reverse of a surface-mounted device) for the pad on the opposite side of the board
+ A hole diameter, given in tenths of a millimetre.

**Silkscreen co-ordinates** are relative to the component centre, with a 2 thou resolution  (the program will automatically round odd numbers down).  Each co-ordinate pair also has one of four plot modes, as follows:
+ **M** -- Move  (and remember this point, to allow a closed shape to be drawn saving a vertex).  
+ **D** -- Draw; draws a line from the last point visited to the co-ordinates supplied.
+ **T** -- Triangle  (using last 2 points visited as other two vertices).  A solid rectangle may be drawn by visiting the corners in a Z shape, move - move - triangle - triangle.
+ **C** -- Close.  Draws a line to the given co-ordinates, then carries on drawing to the point specified in the last **M** instruction; this allows a closed shape to be specified using one fewer instruction than otherwise.  As a further economy, **C** immediately after **M** draws an outline rectangle using the two points as opposite corners.

The data for an individual footprint is self-contained, since the header line includes the number of pins and vertices and therefore the program knows exactly how much DATA to expect.  Therefore, the end of the data is indicated by the end of the program.  

The program actually makes two passes, because it does not know how at the beginning much space the file is going to take up.  During the first pass, the header information is written to memory; the pin and vertex data are ignored, but the bytes thay occupy are counted.  The program stops with an `Out of DATA` error, which is trapped by BASIC.  During the second pass, the pin and vertex data are written to memory, and the footprint headers are updated with the correct starting addresses.

### Adding Your Own Footprints ###

Simply follow the existing syntax to convert a design on paper to the format used by the program!  Note that in accordance with the expectations of SPICE  (whose input data format BCP borrows and extends)  transistors must have the pins given in this order: collector, base, emitter.  FETs must be given in this order: drain, gate, source.  Some knowledge of the 39.37 times table probably will not go amiss.  If you get a `Type mismatch` error, this almost certainly indicates too much or too little data somewhere; the program was expecting a number but got a string, or vice versa.

**ProTip:**  Make a temporary copy of the program, delete all the existing `DATA` lines and start your own DATA at a line number after the end of the original program.  Unless you are very lucky, your first attempt probably will contain at least one error; and it might as well crash as soon as possible.  Re-building a bunch of unchanged data first is just going to prolong the agony.

Once you have got your additions working, you can merge them in properly as follows:
1. `*SPOOL filename` to create a file on disc
2. `LIST` with a starting line to get just your added DATA statements
3. `*SPOOL` on its own to stop spooling
4. Re-`LOAD` the original program
5. `*EXEC filename` to add your data lines onto the end of it.

## WL2DES -- Wiring List to Design ##

This is a program which takes a wiring list  (either from a separate file or from DATA statements within the program)  and a footprints file, and combines them to generate a BCP design file with space for routed tracks.  You will need to specify the amount of space to allocate for each section.

## DES2WL -- Design to Wiring List ##

This program does the opposite of the above  (but note that component values are not saved anywhere and will be missing from the output file; BCP does not care about this, but a circuit simulation program will).  Output may be to the screen or to a disc file.

## CHECK -- Design Connections Checker ##

This program takes a design file and checks to see that every pin appears on a routed track.

## PHPLOT -- Photoplot ##

This program generates photoplot and CNC drill files suitable for manufacture of your PCB.

When the photoplotting program is run, first you will be asked for a design file name.  At this prompt you can enter a filename, a star command such as `*DRIVE 1` or `*CAT`, or -- even quicker than typing `*.` -- just press RETURN to display a disc catalogue.  Anything you type that does _not_ begin with a * will be taken as a filename.

If the selected file exists, you will next be prompted for the design description, which will be added as a human-readable comment to each of the plot files.

A menu will be displayed with the standard plotting options:

![Standard Plot Menu](https://github.com/JulieMontoya/BCP_design/blob/master/screenshots/bcp_ppmenu1s.png?raw=true)

These will generate photoplots with the correct combination of features already included to match the description.  (The single sided solder mask exposes vias on the underside for soldering, and the single sided silkscreen includes track segments on the topside.  This allows wire links to be inserted into the design just by routing tracks on the topside.)

To generate a composite plot, select option 9 from the main photoplotting menu.  The screen will change to look like this:

![Composite Plot Menu](https://github.com/JulieMontoya/BCP_design/blob/master/screenshots/bcp_ppmenu2s.png?raw=true)

Enter a number 0-15 to toggle a design layer on or off, a letter A-K to turn a design feature on or off, or a full stop . when all desired options are indicated by a star between the brackets.  

### Silkscreen and Pads ###

Silkscreen outlines, bounding boxes and legends are all drawn with the aperture D70.  Pads are flashed with their corresponding apertures.  We step through each component in turn, seeing which side of the board it is mounted.  Each pin has, along with its co-ordinates, a pad shape on the mounted side, a pad shape on the opposite side and a hole size.  The hole size is used to determine a pad size to be used on inner layers, from the selection used for vias; if no suitable aperture is found, the pad on the non-mounted side will be used as a last resort.

**DO NOT SELECT INNER LAYER PADS -- THIS IS BROKEN!  A FUTURE VERSION WILL FIX THIS AND ALSO TREAT THROUGH-HOLE PADS  (I.E. WITH HOLES)  AND SURFACE-MOUNT PADS  (WITHOUT HOLES)  SEPARATELY.**

### Tracks and Vias ###

Via positions are implicitly embedded in the routed track data, since a waypoint can be _either_ a vertex _or_ a layer/width change, and are obtained by linearly stepping along routes.  Vias necessarily appear on all layers, in order to give something for the metal through-hole plating to adhere to.  We keep track of the current layer and width  (which determines the aperture we will use to draw track segments)  and send appropriate instructions to the photoplotter when the track is on a layer we are interested in.  Vias, if we are drawing them, are flashed with the appropriate aperture chosen according to the larger of the widths of the tracks on the layers we came from and to.

### Generating the Plot File ###

Once a plot has been selected, you will be asked for an oversize to be added to each aperture.  For all except solder mask and solder paste stencils, this should be zero.  For solder mask plots, an oversize can be added.  This should be in hundredths of a millimetre, so use 50 for a 0.5mm. oversize.  A negative oversize will be treated as an _under_size, for creating paste stencil plots.

Lastly you will be asked for an output filename.  Again, `*COMMANDS` can be entered, and pressing RETURN is equivalent to *CAT.  (If you type two pairs of speech marks with a space between them `" "`, nothing will be saved, but you will be able to see the output on screen.  You might want to press CTRL+N to turn on paged mode.)  The plot file will be displayed on screen as it is being spooled to disc, and afterwards you will be prompted to generate another plot or not.

### Drill Files ###

The photoplotting program can also generate CNC drill files.  Select option 10 from the standard menu.  A drilling machine is inevitably mechanical in nature, so some care is taken to minimise unnecessary tool changes and head movements: we cannot simply output everything in the order in which it is found.  Drilling machines also require logical tool numbers.  Holes are sorted first on drill diameter, then the holes of each diameter are sorted in co-ordinate order, from smallest X to largest X and where holes share an X co-ordinate, from smallest Y to largest Y.  Via drill sizes are determined by the wider of the connected tracks.  The program will display information at each stage of building up the drill information.

### Supplementary Information ###

The photoplot files produced by BCP contain embedded aperture definitions, so there is no need for a separate aperture wheel file.  The aperture definitions are repeated in human-readable form, in case you are using a photoplotter that does not support embedded apertures.

The drill files produced by BCP contain embedded drill rack information, in both machine and human readable forms.

The photoplot and drill files produced by BCP have been tested against the most popular online viewers.


## OTHER FILES ON THE DISC ##

The disc also contains the machine code files used by the BASIC programs, their associated variable dumps and a version of `M.PAGEA` from the version of BCP used to build the machine code  (in case I forgot to initialise something properly).



## VDUMP25 ##

A program to dump out BASIC variables, used in the [native build process](https://github.com/JulieMontoya/BCP_design/wiki/The-BBC-Native-Build-Process).

L% should be 0 to produce immediate mode statements, or some positive value smaller than 32767 to use that as a starting line number.  Variables whose names begin witgh an underscore _ or pound sign £ will not be included in the output; this allows variables which do not need to be exported to another section of program,  to be kept private. 

## DGM ##

This is a version of the Database, Graphics and Maths library code, used by WL2DES.  If replaced, you must update the entry points in the program.

**NOTE:** Now the build order has changed, the maths and database libraries are built before the graphics library, which is not used at all by `WL2DES`.
Therefore it should be possible to replace `DGM` with a shorter file containing just the maths and database code, especially with the inclusion of a static jump table.

