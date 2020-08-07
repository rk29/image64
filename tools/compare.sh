#!/bin/sh

hd "$1" > 1
hd "$2" > 2

OPTS="--width=170 --suppress-common-lines"
diff -y $OPTS 1 2

rm 1 2


