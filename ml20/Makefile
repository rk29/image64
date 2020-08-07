ASM = ../tools/asm.py
TARGETS = ml20.prg boot20.prg image20.prg rs232_user.prg rs232_swift.prg post.prg post-19910108-0139.prg

all : $(TARGETS)

%.prg : %.s $(ASM) equat.s
	$(ASM) $<

ml20.prg: wedge.s editor.s gc.s ecs.s struct.s swap1.s swap2.s swap3.s jmptb.s strio.s
ml20.prg: mcicm.s chrio.s dskio.s irqhn.s setup.s varbl.s miscl.s shdlr.s modem.s
ml20.prg: calls.s intro.s

image20.prg: chr.imagelogo scn.imagelogo col.imagelogo

clean :
	rm -f *~ *.sym $(TARGETS)
