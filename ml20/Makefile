ASM = ../tools/asm.py
TARGETS = ml20.prg boot20.prg rs232_user.prg rs232_swift.prg post.prg

all : $(TARGETS)

%.prg : %.s $(ASM) equat.s
	$(ASM) $<

clean :
	rm -f *~ *.sym $(TARGETS)

