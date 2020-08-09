#!/bin/sh

c1541 -format image,ml d81 ml.d81 \
-write boot20.prg "boot 2.0" \
-write image20.prg "image 2.0" \
-write ml20.prg "ml 2.0" \
-write rs232.prg "ml.rs232" \
-write punter.prg "++ punter" \
-write xmodem.prg "++ xmodem" \
-write clock.prg "++ clock" \
-write copier.prg "++ copier" \
-write menu2.prg "++ menu2" \
-write net.prg "++ net" \
-write path.prg "++ path" \
-write post.prg "++ post" \
-write sort.prg "++ sort" \
-write tagscan.prg "++ tagscan"

cp ml.d81 ~/Public/public-downloads/content/

