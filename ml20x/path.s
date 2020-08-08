version = "07/05/90 11:34p"

include "equat.s"

org $c000, "path.prg"

usetbl1 = $cd03
buffer = $ce77
buf2 = $ce27

		jmp pathfind

		byte 255
		byte version

src:
		byte 0
dst:
		byte 0

dir:
		dup 0,32
nod:
		dup 0,32

pathfind:
		txa
		beq loadfile ;0
		dex
		beq srchpath ;1
		dex
		beq findnode ;2
		dex
		beq jshortct ;3
		rts

jshortct:
		jmp shortcut

;load index file to end of proto
loadfile:
		ldx #1
		jsr usevar ;a$
		lda var
		ldx var+1
		ldy var+2
		jsr setnam
		ldx #32
		jsr usevar ;dv%
		lda #8
		ldx var+1
		ldy #0
		jsr setlfs
		lda #0
		ldx #<last
		ldy #>last
		jsr loadf
		lda last
		sta var+1
		lda #0
		sta var
		ldx #30
		jmp putvar ;a%

findnode:
		ldx #1
		jsr usevar ;a$
		jsr find
		sta var+1
		lda #0
		sta var
		ldx #30
		jmp putvar ;a%

srchpath:
		ldx #31
		jsr usevar ;b%
		lda var+1
		sta dst
		bne srchpth1
		ldx #2
		jsr usevar ;b$
		jsr find
		sta dst
		tax
		beq srchpth3
srchpth1:
		ldx #30
		jsr usevar ;a%
		lda var+1
		sta src
		bne srchpth2
		ldx #1
		jsr usevar ;a$
		jsr find
		sta src
		tax
		beq srchpth3
srchpth2:
		jsr srch
srchpth3:
		stx var
		lda #<buffer
		sta var+1
		lda #>buffer
		sta var+2
		ldx #0
		jmp putvar ;an$

srch:
		ldx #0
		lda #3
		sta dir,x
srch01:
		lda src
		sta nod,x
		cmp dst
		beq srch07
srch02:
		inc dir,x
		lda dir,x
		cmp #8
		bcc srch03
		lda #4
		sta dir,x
		cpx #0
		beq srch11
srch03:
		jsr calc
		lda dir,x
		tay
		lda [20],y
		beq srch02
		cpx #0
		beq srch04
		cmp nod-1,x
		bne srch04
		dex
		lda nod,x
		sta src
		jmp srch02
srch04:
		sta src
		inx
		jsr calc
		ldy #4
srch05:
		lda [20],y
		cmp nod-1,x
		bne srch06
		tya
		sta dir,x
srch06:
		iny
		cpy #8
		bcc srch05
		jmp srch01
srch07:
		inx
		lda #0
		sta nod,x
		ldy #0
		ldx #0
srch08:
		lda #"/"
		jsr srch12
		lda nod,y
		beq srch10
		sta src
		tya
		pha
		jsr calc
		ldy #0
srch09:
		lda [20],y
		jsr srch12
		iny
		cpy #3
		bcc srch09
		pla
		tay
		iny
		jmp srch08
srch10:
		rts
srch11:
		ldx #0
		rts
srch12:
		sta buffer,x
		inx
		rts

find:
		lda #1
		sta src
find01:
		jsr calc
		ldy #0
find02:
		lda [20],y
		cmp [var+1],y
		bne find03
		iny
		cpy #3
		bcc find02
		lda src
		rts
find03:
		lda src
		inc src
		cmp last
		bcc find01
		lda #0
		rts

calc:
		lda #0
		sta 21
		lda src
		sec
		sbc #1
		asl
		rol 21
		asl
		rol 21
		asl
		rol 21
		sec
		adc #<last
		sta 20
		lda 21
		adc #>last
		sta 21
		rts

shortcut:
		ldx #1
		jsr usevar
		ldy #2
shortcut_loop:
		lda [var+1],y
		sta 105,y
		dey
		bpl shortcut_loop
		ldx #0
		jsr usevar
		ldy #0
		ldx #0
shortc0:
		cpy var
		bcs shortc3
shortc0_loop:
		lda [var+1],y
		cmp 105,x
		bne shortc1
		iny
		inx
		cpx #3
		bcc shortc0_loop
		dey
		dey
		dey
		tya
		clc
		adc var+1
		sta var+1
		lda #0
		adc var+2
		sta var+2
		sty var+3
		lda var
		sec
		sbc var+3
		sta var
		ldx #0
		jsr putvar
shortc1:
		cpx #0
		beq shortc2
		dey
		dex
		bne shortc1
shortc2:
		iny
		bne shortc0
shortc3:
		rts

usevar:
		lda #29
		jmp usetbl1
putvar:
		lda #30
		jmp usetbl1
last:
