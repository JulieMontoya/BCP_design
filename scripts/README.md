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
