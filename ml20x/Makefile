#ASM = ../tools/asm.py
ASM = assemble
TARGETS = ml20.prg boot20.prg image20.prg \
rs232.prg rs232_user.prg rs232_swift.prg \
post.prg path.prg tagscan.prg net.prg net1.prg \
punter.prg punter-9101290215.prg \
xmodem.prg xmodem-9101290216.prg \
copier.prg clock.prg menu2.prg sort.prg

all : $(TARGETS)

%.prg : %.s equat.s
	$(ASM) $<

ml20.prg: wedge.s editor.s gc.s ecs.s struct.s swap1.s swap2.s swap3.s jmptb.s strio.s
ml20.prg: mcicm.s chrio.s dskio.s irqhn.s setup.s varbl.s miscl.s shdlr.s modem.s
ml20.prg: calls.s intro.s

image20.prg: chr.imagelogo scn.imagelogo col.imagelogo
rs232.prg: rs232_swift.prg rs232_user.prg

clean :
	rm -f *~ *.sym_by_* $(TARGETS)
