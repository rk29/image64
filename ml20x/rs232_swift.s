include "equat.s"

org $0800, "rs232_swift.prg"

baudof= $299
rodbe = $29e
rodbs = $29d
ridbe = $29b
ridbs = $29c
enabl = $2a1

rstkey = $fe56
norest = $fe72
nmiexit = $febc
findfn = $f30f
devnum = $f31f
nofile = $f701

io1=$de00
io2=$df00
port=io1
status=port+1
command=port+2
control=port+3

comint0=%00001011 ;nmi off
comint1=%00001001 ;rxd on
comint2=%00000101 ;txd/rxd
comdtr0=%00001000 ;dtr off
comrts0=%00000001 ;rts off

statdcd=%01000000 ;carrier
statrxd=%00001000 ;receive
stattxd=%00010000 ;transmit
statint=%10000000 ;nmi

imagecd0=%00000000 ;none
imagecd1=%00010000 ;carrier

first:

xx00:
		jmp setup
xx03:
		jmp inable
xx06:
		jmp disabl
xx09:
		jmp rsget_entry
xx0c:
		jmp rsout_entry
xx0f:
		jmp setbaud

bauds:
		byte %00010101 ; 0300
		byte %00010110 ; 0600
		byte %00010111 ; 1200
		byte %00011000 ; 2400
		byte %00011010 ; 4800
		byte %00011100 ; 9600
		byte %00011110 ;19200
		byte %00011111 ;38400

; shadow command byte
; this is the last value set on the port
; which should be restored after disabling then enabling interrupts

shcomm:
		byte comint1

vectbl:

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
oldcho:
		byte $20
		word nchkout
oldclr:
		byte $22
		word nclrch
oldchr:
		byte $24
		word nchrin
;oldout:
;		byte $26
;		word nchrout
oldget:
		byte $2a
		word ngetin
		byte 0

setup:

; drop DTR initially

		lda #comint0
		sta command

		ldx #0
		lda #3
		sta 21
setup1:
		lda vectbl,x
		beq setup3
		sta 20

; replace index with a "JMP" instruction

		lda #$4c
		sta vectbl,x
		inx

		ldy #0
setup2:

; swap original vector with new value

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

; do a "soft" reset of the chip

		lda #0
		sta status

; set initial command register settings to "rx int enabled, tx int disabled"

		lda #comint1
		sta shcomm

; write the command register

		jsr inable

; set the image carrier detected bit based on DCD (should clear it)

		jsr setcarr

; set default bit rate to 1200

		lda #2
		jmp setbaud

; set the carrier flag based on DCD
; expected to only use A and Y

setcarr:
		ldy #imagecd1
		lda status
		and #statdcd
		beq setcarr1
		ldy #imagecd0
setcarr1:
		sty carrier
		rts

; interrupt routine

nmi64:
		pha
		txa
		pha
		tya
		pha
		cld

		lda status
		and #statint
		beq notacia

; disable further interrupts
; if we clear an interrupt source then another happens,
; then the new interrupt can interrupt this handler

		lda #comint0
		sta command

; handle interrupt sources

		jsr rsint

; enable interrupts

		lda shcomm
		sta command

		pla
		tay
		pla
		tax
		pla
		rti

; the interrupt wasn't from the ACIA, so it must have come from the "restore" key
notacia:
		ldy #0
		jmp rstkey

; check for character
; expected to only use A and Y

rsint:
		jsr setcarr

		lda status
		and #statrxd
		beq rsint2

; a byte is available

		lda port
		ldy ridbe
		sta ribuf,y
		iny
		bpl rsint1
		ldy #0
rsint1:
		sty ridbe

; check remaining space in buffer

		tya
		sec
		sbc ridbs
		and #127
		cmp #120
		bcc rsint2

; unassert RTS to prevent more bytes from being received

		lda #comrts0
		sta command

; ** check transmit

rsint2:

; if the transmit register is not empty, then we're done

		lda status
		and #stattxd
		beq rsint4

; if RTS is asserted, then transmit interrupts will be disabled too
; so we just skip output for that case

		lda shcomm
		cmp #comint1
		beq rsint4
		ldy rodbs
		lda robuf,y
		sta port
		iny
		bpl rsint3
		ldy #0
rsint3:
		sty rodbs
		cpy rodbe
		bne rsint4
		lda #comint1
		sta shcomm
rsint4:
		rts

; disable interrupts

disabl:
		php
		pha
		lda #comint0
		sta command
		pla
		plp
		rts

; enable interrupts (restore to shadow value)

inable:
		php
		pha
		lda shcomm
		sta command
		pla
		plp
		rts

; ** rs232 bsout

rsout0:

; try to send/receive on the port

		jsr rsint

; then try to put the byte in the buffer again

		jmp rsout1

rsout_entry:

; stash for later

		sta $9e
		sty $97

; disable interrupts

		lda #comint0
		sta command

rsout1:

; write the byte to the buffer

		lda $9e
		ldy rodbe
		sta robuf,y
		iny
		bpl rsout2
		ldy #0
rsout2:

		; if the buffer is full, try to push bytes to the port

		cpy rodbs
		beq rsout0

		sty rodbe

; enable rx and tx interrupts

		lda #comint2
		sta shcomm

rsout4:

; restore command register, enabling interrupts

		lda shcomm
		sta command

; exit and restore registers

		jmp ret1

xtmp:
		byte 0

nosuch:
		jmp nofile

nchkin:
		stx xtmp
		jsr findfn
		bne nosuch
		jsr devnum
		ldx xtmp
		lda $ba
		cmp #2
		bne nchkin1
		sta $99
		clc
		jmp inable

nchkin1:
		jsr disabl
		jsr oldchk
		jmp inable

nchkout:
		stx xtmp
		jsr findfn
		bne nosuch
		jsr devnum
		ldx xtmp
		lda $ba
		cmp #2
		bne nchkout1
		sta $9a
		clc
		jmp inable

nchkout1:
		jsr disabl
		jsr oldcho
		jmp inable

ngetin:
		pha
		lda $9a
		cmp #2
		bne notget
		pla

; ** rs232 getin

rsget_entry:

; stash for later

		sta $9e
		sty $97

; if buffer is empty, then we're done

		ldy ridbs
		cpy ridbe
		beq ret2

		lda ribuf,y
		sta $9e
		iny
		bpl rsget1
		ldy #0
rsget1:
		sty ridbs
		lda ridbe
		sec
		sbc ridbs
		and #127
		cmp #100
		bcs ret1
		lda shcomm
		sta command
ret1:
		clc
ret2:
		ldy $97
		lda $9e
		rts

notget:
		pla
		jsr disabl
		jsr oldget
		jmp inable

setbaud:
		cmp #254
		bcc setbaud3
		beq setbaud1
		lda shcomm
		jmp setbaud2
setbaud1:
		lda #comdtr0
setbaud2:
		sta command
		rts
setbaud3:
		and #7
		tay
		lda bauds,y
		sta control
		rts

;nchrout:
;		jsr disabl
;		jsr oldout
;		jmp inable

nopen:
		jsr disabl
		jsr oldopn
		jmp inable

nclose:
		jsr disabl
		jsr oldcls
		jmp inable

nclrch:
		jsr disabl
		jsr oldclr
		jmp inable

nchrin:
		jsr disabl
		jsr oldchr
		jmp inable

last:
