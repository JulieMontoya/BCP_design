A collection of host-side scripts used in the BCP pre-build process.

## add_line_numbers

This script takes a detokenised BASIC source file  (as produced by `*SPOOL`)  without line numbers, and automatically
adds line numbers for you.

It's possible to specify the first line and the step on the command line:
```
$ add_line_numbers -l100 -s20 L.MTH01SC.1 > L.MTH01SC.2
```
will read the source file `L.MTH01SC.1` and add line numbers starting at 100  (the `-l` parameter)  and going up in
steps of 20  (the `-s` parameter).  If you omit either or both, default values will be taken from the script source,
so you can easily change the defaults if you don't like the default defaults of 10 and 10  :)

But you can also embed instructions into the BASIC source file to control the behaviour of the script.  This allows you to insert gaps in your sequence.  This is indicated by a line beginning with `*|`  (which the BBC would ignore).
`*|1000` on a line by itself means give the next line the number 1000 and carry on with the same step as before.
`*|2000,5` means give the next line the number 2000 and then go up in steps of 5.
`*|0,10` means keep the sequence for the following line, but start going up in steps of 10 afterward.

The `-t` option, if given, sets "test mode" which produces extra `*|` lines giving information.  (These will be ignored by the BBC or emulator when the file is read with `*EXEC`.)

The script will give an error if the "automatic" line number has already gone past a line number specified in a `*|` line in the input.

## remove_line_numbers

This script takes a detokenised BASIC source file  (as produced by `*SPOOL`)  with line numbers, and automatically
removes the line numbers for you, so you can more easily edit them on the host system.  It inserts `*|` lines into the output at the beginning and following a sufficiently-large gap in the line numbering  (so "high" line numbers at the end of a program can be preserved).

```
$ remove_line_numbers -g50 L.MTH01SC.0 > L.MTH01SC
```
will read the source file `L.MTH01SC.0` and strip line numbers, inserting a `*|` line into the output  (which the BBC would ignore if the file were being read in with `*EXEC`, but which `add_line_numbers` will honour)  with the new line number, anywhere a gap of at least 50  (the `-g` parameter)  is spotted in the numbering sequence.  This allows you to have sections of program tucked away in high-numbered lines, and preserve the numbering.

_It would be nice to be able to spot GOTO, GOSUB and RESTORE instructions in the BASIC, and insert_ `*|` _lines into the output before the target line.  But this would require two passes, which would require reading the entire source file into an array._
