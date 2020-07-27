ASM = ../tools/asm.py
TARGETS = ml20.prg boot20.prg rs232_user.prg rs232_swift.prg

all : $(TARGETS)

ml20.prg : ml20.s $(ASM) equat.s
	$(ASM) ml20.s

boot20.prg : iboot.s $(ASM) equat.s
	$(ASM) iboot.s

rs232_user.prg : rs232_user.s $(ASM) equat.s
	$(ASM) rs232_user.s

rs232_swift.prg : rs232_swift.s $(ASM) equat.s
	$(ASM) rs232_swift.s

clean :
	rm -f *~ *.sym $(TARGETS)

