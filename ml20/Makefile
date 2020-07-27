ASM = ../tools/asm.py
TARGETS = ml20.prg boot20.prg

all : $(TARGETS)

ml20.prg : ml20.s $(ASM) equat.s
	$(ASM) ml20.s

boot20.prg : iboot.s $(ASM) equat.s
	$(ASM) iboot.s

clean :
	rm -f *~ $(TARGETS)

