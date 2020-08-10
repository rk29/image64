#ASM = ../tools/asm.py
ASM = assemble
TARGETS = ml.prg boot.prg image.prg \
rs232.prg rs232_user.prg rs232_swift.prg \
post.prg path.prg tagscan.prg net.prg \
punter.prg punter-9101290215.prg \
xmodem.prg xmodem-9101290216.prg \
copier.prg clock.prg menu2.prg sort.prg

all : $(TARGETS)

%.prg : %.s equat.s
	$(ASM) $<

ml.prg: wedge.s editor.s gc.s ecs.s struct.s swap1.s swap2.s swap3.s jmptb.s strio.s
ml.prg: mcicm.s chrio.s dskio.s irqhn.s setup.s varbl.s miscl.s shdlr.s modem.s
ml.prg: calls.s intro.s

image.prg: chr.imagelogo scn.imagelogo col.imagelogo
rs232.prg: rs232_swift.prg rs232_user.prg

clean :
	rm -f *~ *.sym_by_* $(TARGETS) *.tar.gz *.zip

release: dist
	cp ml-source.tar.gz ml.d81 ~/Public/public-downloads/content/

dist: ml-source.tar.gz ml.d81

ml-source.tar.gz: Makefile *.s
	tar czf ml-source.tar.gz Makefile *.s

ml.d81: $(TARGETS)
	c1541 -format image,ml d81 ml.d81 \
	-write boot.prg "boot 3.0" \
	-write image.prg "image 3.0" \
	-write ml.prg "ml 3.0" \
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

emu: $(TARGETS)
	cp emulated/8.d81 emulated/8-updated.d81
	c1541 -attach emulated/8-updated.d81 \
	-delete "boot 3.0"   -write boot.prg "boot 3.0" \
	-delete "image 3.0"  -write image.prg "image 3.0" \
	-delete "ml 3.0"     -write ml.prg "ml 3.0" \
	-delete "ml.rs232"   -write rs232.prg "ml.rs232" \
	-delete "++ punter"  -write punter.prg "++ punter" \
	-delete "++ xmodem"  -write xmodem.prg "++ xmodem" \
	-delete "++ clock"   -write clock.prg "++ clock" \
	-delete "++ copier"  -write copier.prg "++ copier" \
	-delete "++ menu2"   -write menu2.prg "++ menu2" \
	-delete "++ net"     -write net.prg "++ net" \
	-delete "++ path"    -write path.prg "++ path" \
	-delete "++ post"    -write post.prg "++ post" \
	-delete "++ sort"    -write sort.prg "++ sort" \
	-delete "++ tagscan" -write tagscan.prg "++ tagscan"
