ASM = ../tools/asm.py
TARGETS = ml13.prg image13.prg extra.prg proto0.prg proto1.prg proto2.prg proto4.prg proto5.prg proto6.prg rs232.prg

#ecs.prg : ecs.s $(ASM) equat.s
#	$(ASM) ecs.s

all : $(TARGETS)

image13.prg : image.s $(ASM) equat.s
	$(ASM) image.s

ml13.prg : ml13.s $(ASM) equat.s
	$(ASM) ml13.s

extra.prg : extra.s $(ASM) equat.s
	$(ASM) extra.s

proto0.prg : proto0.s $(ASM) equat.s
	$(ASM) proto0.s

proto1.prg : proto1.s $(ASM) equat.s
	$(ASM) proto1.s

proto2.prg : proto2.s $(ASM) equat.s
	$(ASM) proto2.s

proto4.prg : proto4.s $(ASM) equat.s
	$(ASM) proto4.s

proto5.prg : proto5.s $(ASM) equat.s
	$(ASM) proto5.s

proto6.prg : proto6.s $(ASM) equat.s
	$(ASM) proto6.s

rs232.prg : rs232.s $(ASM) equat.s
	$(ASM) rs232.s

clean :
	rm -f *~ $(TARGETS)

