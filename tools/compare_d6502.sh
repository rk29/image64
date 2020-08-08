#!/bin/sh

d6502 "$1" > 1
d6502 "$2" > 2

OPTS="--width=170"
diff -y $OPTS 1 2

rm 1 2


