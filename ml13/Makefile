TARGETS = ml13.prg image13.prg extra.prg proto5.prg

#ecs.prg : ecs.s asm.py equat.s
#	./asm.py ecs.s

all : $(TARGETS)

image13.prg : image.s asm.py equat.s
	./asm.py image.s

ml13.prg : ml13.s asm.py equat.s
	./asm.py ml13.s

extra.prg : extra.s asm.py equat.s
	./asm.py extra.s

proto5.prg : proto5.s asm.py equat.s
	./asm.py proto5.s

clean :
	rm -f *~ $(TARGETS)

