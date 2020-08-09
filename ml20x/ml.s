revision = 1
version_string = "12/29/91  1:18p"
serial = $1001

include "equat.s"

org $6c00, "ml.prg"

; $0c00 - wedge

include "wedge.s"

; pad to the start of the next module
		dup 0,$7000-*

; $d000 - editor

include "editor.s"


; pad to the start of the next module
		dup 0,$8000-*

; $e000 - garbage collect

include "gc.s"


; pad to the start of the next module
		dup 0,$8400-*

; $e400 - e.c.s. checker

include "ecs.s"

; pad to the start of the next module
		dup 0, $8e00-*

; $ee00 - struct

include "struct.s"

; pad to the start of the next module
		dup 0, $9400-*

; $f400 - swap1

include "swap1.s"

		dup 0, $9800-*

; $f800 - swap2

include "swap2.s"

; pad to the start of the next module
		dup 0, $9c00-*

; $fc00 - swap3

include "swap3.s"

; pad to the start of the next module
		dup 0, jmptbl-*

include "jmptb.s"

include "strio.s"

include "mcicm.s"

include "chrio.s"

include "dskio.s"

include "irqhn.s"

include "setup.s"

include "varbl.s"

include "miscl.s"

include "shdlr.s"

include "modem.s"

include "calls.s"

; put intro program in

		dup 0, $c000-*

include "intro.s"

;* skip rest of proto area *

		dup 0,$cb00-*

swapper0:
		sta swappg1
		sty swappg2
		stx swapsiz
swapagn0:
		lda #$d3 ; reverse capital "S"
		sta tdisp+31
		jsr rsdisab
		sei
		lda 1
		pha
		lda #$34
		sta 1
swappg1 = *+1
		lda #$00
		sta $6a
swappg2 = *+1
		lda #$00
		sta $6c
swapsiz = *+1
		lda #$00
		sta $6d
		ldy #0
		sty $69
		sty $6b
swapr1:
		lda [$69],y
		tax
		lda [$6b],y
		sta [$69],y
		txa
		sta [$6b],y
		iny
		bne swapr1
		inc $6a
		inc $6c
		dec $6d
		bne swapr1
		pla
		sta 1
		cli
		jsr rsinabl
		lda #$a0
		sta tdisp+31
		rts

getversn:
		lda #15
		sta var
		lda #<version
		sta var+1
		lda #>version
		sta var+2
		ldx #1
		jsr putvar ;a$
		ldy #4
loop:
		lda versnum,y
		sta var,y
		dey
		bpl loop
		ldx #15
		jsr putvar ;lp
		jsr zero
		lda rvisnum
		sta var+1
		lda rvisnum+1
		sta var
		ldx #30
		jmp putvar ;a%

scrnset:
		sta blnkflag
		sta $d030
		stx $d011
		rts

; find a basic variable

findvar1:
		lda 1
		pha
		lda #$37
		sta 1
		jsr ptrget1
		jmp exitint

; relink basic program lines

relink:
		lda 1
		pha
		lda #$37
		sta 1
		jsr linkprg
		jmp exitint

fpout:
		lda 1
		pha
		lda #$37
		sta 1
		jsr $bddd
		jmp exitint

; make a dynamic string

makeroom:
		tax
		lda 1
		pha
		lda #$37
		sta 1
		txa
		jsr makerm1
exitint:
		pla
		sta 1
		rts

mlgosub:
		lda $7b
		pha
		lda $7a
		pha
		lda $3a
		pha
		lda $39
		pha
		lda #$8d
		pha
mlresume:
		lda #$37
		sta 1
mljump:
		jsr mlgoto
		jmp $a7ae

mlgoto:
		lda 1
		pha
		lda #$37
		sta 1
		stx $14
		sty $15
		jsr $a8a3
		pla
		sta 1
		rts

;* output a$
outspace:
		txa
		beq outspac2
outspac1:
		lda #" "
		jsr xchrout
		dex
		bne outspac1
outspac2:
		rts

outcomma:
		lda #0
outcomm1:
		clc
		adc #10
		bcs outastr0
		cmp modclm
		bcc outcomm1
		sec
		sbc modclm
		tax
		jsr outspace
outastr0:
		jsr chrget
		beq outastr2
outastr1:
		cmp #";"
		beq outastr0
		cmp #","
		beq outcomma
		jsr getstr
		stx var+1
		sty var+2
		sta var
		jsr outstr
		jsr chrgot
		bne outastr1
outastr2:
		rts
outastr:
		jsr chrgot
		bne outastr1
		ldx #1
		jmp prtvar

getstr:
		lda 1
		pha
		lda #$37
		sta 1
		jsr $ad9e
		bit $0d
		bpl getval
		jsr $b6a3
		tax
		jmp getstr1
getval:
		jsr $bddd
		lda #<$100
		sta $22
		lda #>$100
		sta $23
		ldx #0
getval1:
		lda $100,x
		beq getstr1
		inx
		bne getval1
getstr1:
		pla
		sta 1
		txa
		ldx $22
		ldy $23
		rts

fnvar0:
		lda 1
		pha
		lda #$37
		sta 1
		jsr chkcom
		jsr $b08b
		ldx $47
		ldy $48
		pla
		sta 1
		rts
fnvar2:
		jsr fnvar
		stx $14
		sty $15
		rts

evalstr0:
		lda 1
		sta rom0
		lda #$37
		sta 1
		jsr chkcom
		jsr $ad9e
		jsr $b6a3
		pha
		lda rom0
		sta 1
		pla
		ldx $22
		ldy $23
		rts

evalbyt0:
		lda 1
		sta rom0
		lda #$37
		sta 1
		jsr chkcom
		jsr $0079
		jsr $b79e
		lda rom0
		sta 1
		rts

evalint0:
		lda 1
		sta rom0
		lda #$37
		sta 1
		jsr chkcom
		jsr frmnum
		jsr getadr
		ldx $14
		ldy $15
		lda rom0
		sta 1
		rts

evalfil0:
		lda 1
		sta rom0
		lda #$37
		sta 1
		jsr chkcom
		jsr getfile
		lda rom0
		sta 1
		rts

convchr0:
		jsr chkspcl
		cmp #0
		bmi convchr1
		cmp #64
		bcc convchr1
		eor #64
convchr1:
		and #127
		rts

		dup 0, $cd00-*

; interface page jmp table

hcd00:
		jmp outastr
hcd03:
		jmp usetbl0
hcd06:
		jmp swapper0
hcd09:
		jmp swapagn0
hcd0c:
		jmp trace0
hcd0f:
		jmp chkspcl0
hcd12:
		jmp convchr0
hcd15:
		jmp fnvar0
hcd18:
		jmp fnvar2
hcd1b:
		jmp evalstr0
hcd1e:
		jmp evalbyt0
hcd21:
		jmp evalint0
hcd24:
		jmp evalfil0

chkspcl0:
		cmp #$85
		bcc chkspcl1
		cmp #$8d
		bcs chkspcl1
		stx cxsav
		sec
		sbc #$85
		tax
		lda spchars,x
		ldx cxsav
chkspcl1:
		cmp #0
		rts

usetbl0:
		sta 780
		stx 781
		sty 782
		asl
		tax
		lda 1
		pha
		lda #$36
		sta 1
		php
		sei
		lda jmptbl,x
		tay
		lda jmptbl+1,x
		tax
		plp
		lda #<caller
		sta jump+1
		lda #>caller
		sta jump+2
		cpx #$e0
		bcs jump
		sty jump+1
		stx jump+2
		ldx 781
		ldy 782
jump:
		jsr $ffff
		sta 780
		pla
		sta 1
		lda 780
nothing:
		rts

; new system chrout routine

newout:
		sta $9e
		lda 1
		pha
		lda #$36
		sta 1
		lda $9e
		jsr out
		sta $9e
		pla
		sta 1
		lda $9e
		rts
oldout:
		jmp $ffff

; raster interrupt routine

raster:
		lda #$00
		bne rast1
		lda scnmode
		bne rast0
		lda #23
		sta $d018
rast0:
		lda #106
		sta $d012
		lda #1
		sta $d019
		inc raster+1
		jmp $febc

rast1:
		nop
		lda mupcase
		and #1
		asl
		eor #23
		sta $d018
		lda #234
		sta $d012
		lda #1
		sta $d019
		dec raster+1
		inc jiffy

newirq:
		lda 1
		pha
		lda #$36
		sta 1
irqt:
		lda #$00
		beq newirq0
		dec irqt+1
		bne newirq1
newirq0:
		jsr irq
		lda irqcount
		sta irqt+1
newirq1:
		pla
		sta 1
		jmp $ea81

; far call to the error handler

farerr:
		lda #$37
		sta 1
		jmp error

		dup 0, $ce00-*

; buffer page

d1str:
		cbm "           "
spchars:
		byte ",:",34,"*?=",13,"^"

; pad up to fbuf start
		dup 0, fbuf-*
; fbuf:
		dup $20, 20

; pad up to buf2 start
		dup 0, buf2-*
; buf2:
		dup $20, 80

; pad up to buffer start
		dup 0, buffer-*
; buffer:
		dup $20, 80

; date in 6 byte bcd format

bootdate:

dateday:
		byte $01
datemon:
		byte $12
datedate:
		byte $09
dateyear:
		byte $90
		byte $20,$00

; storage for conversion routines

binary:
		byte 0,0,0,0

; days in each month

ha560:
		byte $31,$28,$31,$30,$31
		byte $30,$31,$31,$30,$00
decchr:
		byte $30,$30,$30,$30,$30
		byte $31,$30,$31

; the revision number of this ml

rvisnum:
		word revision

; the date this ml was made

version:
		cbm version_string

; version 1.3

versnum:
		byte $81,$26,$66,$66,$66
