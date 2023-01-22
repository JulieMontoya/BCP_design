name        | X register | | Y register | Action                         | Advance X,Y
------------|------------|-|------------|--------------------------------|-------------
sub16       | min, diff  |W| subtrahend | WS[X] := WS[X] - WS[Y]         | yes
sbc16       | min, diff  |W| subtrahend | WS[X] := WS[X] - WS[Y] - !C    | yes
add16       | aug, sum   |W| addend     | WS[X] := WS[X] + WS[Y]         | yes
adc16       | aug, sum   |W| addend     | WS[X] := WS[X] + WS[Y] + C     | yes
twc16       | arg, ans   |W| -          | WS[X] := -WS[X]                | no
teq16       | minuend    |W| subtrahend | Z=1 => WS[X] == WS[Y]          | no
cmp16       | minuend    |W| subtrahend | N=1 => WS[X] < WS[Y]           | no
maybe_swp16 | minuend    |W| subtrahend | WS[X] >= WS[Y]                 | yes
swp16       | lhs        |W| rhs        | WS[X],WS[Y] := WS[Y], WS[X]    | yes
add8_16     | aug, sum   |W| -          | WS[X] := WS[X] + A             | yes
adc8_16     | aug, sum   |W| -          | WS[X] := WS[X] + A + C         | yes
sub1_16     | min, diff  |W| -          | WS[X] := WS[X] - A             | yes
sbc1_16     | min, diff  |W| -          | WS[X] := WS[X] - A - !C        | yes
copy_coords | source     |W| dest       | WS[Y],WS[Y+2] := WS[X],WS[X+2] | yes
copy_word   | source     |W| dest       | WS[Y],WS[Y+2] := WS[X],WS[X+2] | yes

```

```
