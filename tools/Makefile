CFLAGS = -std=c99 -Wall -Werror

TARGETS = d6502 extractall

d6502 : d6502.c
	$(CC) -o d6502 d6502.c

extractall : extractall.c
	$(CC) $(CFLAGS) -o extractall extractall.c

clean:
	rm -f $(TARGETS) *~

install: d6502
	cp d6502 ~/bin
