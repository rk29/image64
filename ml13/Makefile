TARGETS = ml13.prg image13.prg extra.prg proto0.prg proto1.prg proto2.prg proto4.prg proto5.prg proto6.prg rs232.prg

#ecs.prg : ecs.s asm.py equat.s
#	./asm.py ecs.s

all : $(TARGETS)

image13.prg : image.s asm.py equat.s
	./asm.py image.s

ml13.prg : ml13.s asm.py equat.s
	./asm.py ml13.s

extra.prg : extra.s asm.py equat.s
	./asm.py extra.s

proto0.prg : proto0.s asm.py equat.s
	./asm.py proto0.s

proto1.prg : proto1.s asm.py equat.s
	./asm.py proto1.s

proto2.prg : proto2.s asm.py equat.s
	./asm.py proto2.s

proto4.prg : proto4.s asm.py equat.s
	./asm.py proto4.s

proto5.prg : proto5.s asm.py equat.s
	./asm.py proto5.s

proto6.prg : proto6.s asm.py equat.s
	./asm.py proto6.s

rs232.prg : rs232.s asm.py equat.s
	./asm.py rs232.s

clean :
	rm -f *~ $(TARGETS)

