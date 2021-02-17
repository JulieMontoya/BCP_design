This is the "utilities" disc.

## MENU ##

This program offers a menu to select one of the other programs and either run it, or display some explanatory text.

## APER -- the aperture editor ##

This allows you to edit the apertures which will be used in your design.  Fifteen pad shapes are available for use in footprints  (a further fifteen will be automatically specified for their rotated counterparts),  and up to fifteen track widths may be defined  (although the design app currently supports only four).  Each track width also has an associated via size, which will always be twice the track width; and a via hole size  (which may be zero, indicating an undrilled pad for a surface-mount device).

The program has two screens.  The SPACE bar toggles between pad apertures, and track/via apertures.  On each screen the **:** and **/** keys are used to select a row; **Z** and **X** adjust the length or outer diameter of a pad or the width of a track as appropriate, and **C** and **V** adjust the width or inner diameter of a pad or the size of a hole.  On the pads screen, **S** selects a pad shape  (Oblong, Rectangular with Hole, Rectangular or Circular);  **L** allows you to enter a length or outer diameter directly, and **W** likewise a width or inner diameter.  On the tracks screen, **T** allows you to enter a track width directly, and **H** allows you to enter a hole diameter directly.  Press **M** to switch measuring units  (thousandths of an inch or hundredths of a millimetre).  Note that hole diameters are always entered directly in _tenths_ of a millimetre, although they are _displayed_ in hundredths.

When all your aperture and drill sizes are as desired, press **RETURN**.  The screen will show a command you can COPY to save the aperture definitions, but they will not actually be saved -- this is intended to allow you to change discs, or enter a new filename.  Aperture definitions are held in memory locations &A00 to &A3F.  You can `*LOAD` an aperture definition file over any existing `M.PAGEA` file, and then `*SAVE M.PAGEA A00 B00` to update it with the new apertures.

If you enter
```
GOTO5000
```
the pad shapes will be displayed on screen, at a scale of 1 physical pixel = 5 thou.  The top row shows apertures 1-5, the next row is 6-10 and the bottom row is 11-15.

## FPGEN -- the footprint generator ##

This program generates a master footprint file, from which footprints can be incorporated into new designs as required  (each design file contains its own copy of just the footprints used in that design.)  The footprints are generated from DATA statements in the program.

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
+ **-100,0,5,5,10** -- the X and Y co-ordinates of pin 1, in thou, the pad shape  (aperture code)  on the mounted side, the pad shape on the opposite side and the drill diameter in tenths of a millimetre
+ **100,0,5,5,10** -- likewise pin 2.
+ **"M",-150,-50** -- move to (-150, -50) thou
+ **"C",150,50** -- close shape to (150, 50) thou.

Silkscreen co-ordinates have a 2 thou resolution  (the program will round odd numbers down).  Each co-ordinate has one of four plot modes, as follows:  **M** -- Move  (and remember this point, to allow a closed shape to be drawn saving a vertex).  **D** -- Draw.  **T** -- Triangle  (using last 2 points visited as other two vertices).  **C** -- Close.  Draws a line to the given co-ordinates, then on to the point specified in the last **M** instruction; this allows a shape to be specified with one fewer instruction.  As a further economy, **C** immediately after **M** draws an outline rectangle using the two points as opposite corners.

The data for an individual footprint is self-contained, since the header line includes the number of pins and vertices and therefore the program knows exactly how much DATA to expect.  Therefore, the end of the data is indicated by the end of the program, and BASIC error trapping is used to detect an `out of DATA` condition.  The program makes two passes:  during the first pass, the header information is written to memory and the pin and vertex data are ignored but counted, and during the second pass the pin and vertex data are written to memory and the headers updated with the correct starting addresses.

## WL2DES -- Wiring List to Design ##

This is a program which takes a wiring list  (either from a separate file or from DATA statements within the program)  and a footprints file, and combines them to generate a BCP design file with space for routed tracks.  You will need to specify the amount of space to allocate for each section.

## DES2WL -- Design to Wiring List ##

This program does the opposite of the above  (but note that component values are not saved anywhere and will be missing from the output file; BCP does noyt care about this, but a circuit simulation program will).  Output may be to the screen or to a disc file.

## PHPLOT -- Photoplot ##

This program generates photoplot and CNC drill files suitable for manufacture of your PCB.  [See here.](https://github.com/JulieMontoya/BCP_design/wiki/PhotoPlotting)

## OTHER FILES ON THE DISC ##

The disc also contains the machine code files used by the BASIC programs, their associated variable dumps and a version of `M.PAGEA` from the version of BCP used to build the machine code  (in case I forgot to initialise something properly).



## VDUMP25 ##

A program to dump out BASIC variables, used in the [native build process](https://github.com/JulieMontoya/BCP_design/wiki/The-BBC-Native-Build-Process).

L% should be 0 to produce immediate mode statements, or some positive value smaller than 32767 to use that as a starting line number.  Variables whose names begin witgh an underscore _ or pound sign £ will not be included in the output; this allows variables which do not need to be exported to another section of program,  to be kept private. 

## DGM ##

This is a version of the Database, Graphics and Maths library code, used by WL2DES.  If replaced, you must update the entry points in the program.

**NOTE:** Now the build order has changed, the maths and database libraries are built before the graphics library, which is not used at all by `WL2DES`.
Therefore it should be possible to replace `DGM` with a shorter file containing just the maths and database code, especially with the inclusion of a static jump table.

