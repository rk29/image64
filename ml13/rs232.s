org $4300, "rs232.prg"

ribuf = $f7
baudof = $299
ridbe = $29b
ridbs = $29c
enabl = $2a1
rstkey = $fe56
norest = $fe72
nmiexit = $febc
findfn = $f30f
devnum = $f31f
nofile = $f701

first:

xx00:
		jmp setup
xx03:
		jmp inabl
xx06:
		jmp disab
xx09:
		jmp rsget
xx0c:
		jmp rsout
xx0f:
		jmp setbaud

bauds:
		word 0300,0600,1200,2400
strt:
		word 4915,2550,1090,0459
full:
		word 3410,1705,0845,0421
baudofs:
		word 3410,1706,0852,0426

vectbl:

oldbrk:
		byte $16
		word break
oldnmi:
		byte $18
		word nmi64
oldopn:
		byte $1a
		word nopen
oldcls:
		byte $1c
		word nclose
oldchk:
		byte $1e
		word nchkin
oldclr:
		byte $22
		word nclrch
oldchr:
		byte $24
		word nchrin
oldout:
		byte $26
		word nchrout
oldget:
		byte $2a
		word ngetin
		byte 0

setup:
		ldx #0
		lda #3
		sta 21
setup1:
		lda vectbl,x
		beq setup3
		sta 20
		lda #$4c
		sta vectbl,x
		inx
		ldy #0
setup2:
		lda vectbl,x
		pha
		lda [20],y
		sta vectbl,x
		pla
		sta [20],y
		iny
		inx
		cpy #2
		bcc setup2
		jmp setup1
setup3:
		ldx #$00
		ldy #<426
		lda $2a6
		beq setup4
		ldx #$80
		ldy #<416
setup4:
		stx $dc0e
		sty baudofs+6
		rts

nmi64:
		pha
		txa
		pha
		tya
		pha
nmi128:
		cld
		ldx $dd07
		lda #$7f
		sta $dd0d
		lda $dd0d
		bpl notcia
		cpx $dd07
		ldy $dd01
		bcs mask
		ora #2
		ora $dd0d
mask:
		and enabl
		tax
		lsr
		bcc ckflag
		lda $dd00
		and #$fb
		ora $b5
		sta $dd00
ckflag:
		txa
		and #$10
		beq nmion
strtlo:
		lda #$42
		sta $dd06
strthi:
		lda #$04
		sta $dd07
		lda #$11
		sta $dd0f
		lda #$12
		eor enabl
		sta enabl
		sta $dd0d
fulllo:
		lda #$4d
		sta $dd06
fullhi:
		lda #$03
		sta $dd07
		lda #$08
		sta $a8
		bne chktxd

notcia:
		ldy #$00
		jmp rstkey

nmion:
		lda enabl
		sta $dd0d
		txa
		and #$02
		beq chktxd
		tya
		lsr
		ror $aa
		dec $a8
		bne txd
		ldy ridbe
		lda $aa
		sta [ribuf],y
		inc ridbe
		lda #$00
		sta $dd0f
		lda #$12
switch:
		ldy #$7f
		sty $dd0d
		sty $dd0d
		eor enabl
		sta enabl
		sta $dd0d
txd:
		txa
		lsr
chktxd:
		bcc exit
		dec $b4
		bmi char
		lda #$04
		ror $b6
		bcs store
low:
		lda #$00
store:
		sta $b5
exit:
		jmp nmiexit
char:
		lda rsoutf
		beq txoff
		lda rsoutb
		sta $b6
		lda #0
		sta rsoutf
		lda #$09
		sta $b4
		bne low
txoff:
		ldx #$00
		stx $dd0e
		lda #$01
		bne switch

rsoutb:
		byte 0
rsoutf:
		byte 0

disabl:
		pha
test:
		lda enabl
		and #$03
		bne test
		lda #$10
		sta $dd0d
		lda #$02
		and enabl
		bne test
		sta enabl
		pla
		rts

rsout:
		sta $9e
		sty $97
point:
		ldy rsoutf
		bne fulbuf
		sta rsoutb
		inc rsoutf
strtup:
		lda enabl
		and #1
		bne ret3
		sta $b5
		lda #$09
		sta $b4
		lda rsoutb
		sta $b6
		lda #0
		sta rsoutf
		lda baudof
		sta $dd04
		lda baudof+1
		sta $dd05
		lda #$11
		sta $dd0e
		lda #$81
change:
		sta $dd0d
		php
		sei
		ldy #$7f
		sty $dd0d
		sty $dd0d
		ora enabl
		sta enabl
		sta $dd0d
		plp
ret3:
		clc
		ldy $97
		lda $9e
		rts

fulbuf:
		jsr strtup
		jmp point

nchkin:
		stx xtmp
		jsr findfn
		bne nosuch
		jsr devnum
		lda $ba
		cmp #2
		bne back
		sta $99
inable:
		sta $9e
		sty $97
		jsr getenabl
		bne ret1
		sta $dd0f
		lda #$90
		jmp change
nosuch:
		jmp nofile
back:
		ldx xtmp
		jsr disab
		jsr oldchk
		jmp inabl
xtmp:
		byte 0

ngetin:
		pha
		lda $9a
		cmp #2
		bne notget
		pla
rsget:
		sta $9e
		sty $97
		ldy ridbs
		cpy ridbe
		beq ret2
		lda [ribuf],y
		sta $9e
		inc ridbs
ret1:
		clc
ret2:
		ldy $97
		lda $9e
		rts
notget:
		pla
		jsr disab
		jsr oldget

inabl:
		php
		pha
		txa
		pha
		tya
		pha
		jsr inable
		pla
		tay
		pla
		tax
		pla
		plp
		rts

disab:
		php
		jsr disabl
		plp
		rts

getenabl:
		lda enabl
		and #$12
		rts

setbaud:
		and #3
		asl
		tay
		lda strt,y
		sta strtlo+1
		lda strt+1,y
		sta strthi+1
		lda full,y
		sta fulllo+1
		lda full+1,y
		sta fullhi+1
		lda baudofs,y
		sta baudof
		lda baudofs+1,y
		sta baudof+1
		jsr getenabl
		bne ret1
		sta $dd0f
		rts

nchrout:
		jsr disab
		jsr oldout
		jmp inabl

nopen:
		jsr disab
		jsr oldopn
		jmp inabl

nclose:
		jsr disab
		jsr oldcls
		jmp inabl

nclrch:
		jsr disab
		jsr oldclr
		jmp inabl

nchrin:
		jsr disab
		jsr oldchr
		jmp inabl

break:
		lda #$27
		sta $d011
		ldy #0
		lda #"!"
		jsr hex2
		lda 0
		jsr hex
		lda 1
		jsr hex
		lda $df02
		jsr hex
		tsx
		txa
		jsr hex
break2:
		pla
		jsr hex
		tsx
		cpx #$ff
		bne break2
		byte 2

hex:
		pha
		lsr
		lsr
		lsr
		lsr
		jsr hex1
		pla
hex1:
		and #$0f
		ora #$30
		cmp #$3a
		bcc hex2
		adc #$06
hex2:
		sta $0400,y
		lda #1
		sta $db00,y
		iny
		rts
