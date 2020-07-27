ASM = ../tools/asm.py
TARGETS = ml20.prg

all : $(TARGETS)

ml20.prg : ml20.s $(ASM) equat.s
	$(ASM) ml20.s

clean :
	rm -f *~ $(TARGETS)

