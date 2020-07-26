include "equat.s"

org $c000,"proto5.prg"

chrout = $ffd2
chrin = $ffcf
chkout = $ffc9
chkin = $ffc6
clrchn = $ffcc

		jmp doclock ;49152
		jmp savefile ;49155
		jmp loadfile ;49158
		jmp entry3 ;49161
		jmp entry4 ;49164
		jmp entry5 ;49167

track:
		dup 0, 193

calc:
		dex
		txa
		asl
		asl
		asl
		tax
		tya
		lsr
		lsr
		lsr
		sta calc0+1
		txa
calc0:
		ora #$00
		tax
		tya
		and #7
		tay
		lda #1
		cpy #0
		beq calc2
calc1:
		asl
		dey
		bne calc1
calc2:
		rts

;read array from file #2

entry1:
		ldx #2
		jsr chkin
		ldy #0
entry1a:
		jsr chrin
		sta track,y
		iny
		cpy #192
		bne entry1a
		jmp clrchn

;write array to file #2

entry2:
		ldx #2
		jsr chkout
		ldy #0
entry2a:
		lda track,y
		jsr chrout
		iny
		cpy #192
		bne entry2a
		jmp clrchn

;clear from x,y to end

entry3:
		jsr calc
		eor #255
entry3a:
		pha
		and track,x
		sta track,x
		pla
		sec
		rol
		bcs entry3a
		lda #0
		inx
		cpx #192
		bcs entry3c
entry3b:
		sta track,x
		inx
		cpx #192
		bcc entry3b
entry3c:
		rts

;set from x,y to end

entry4:
		jsr calc
entry4a:
		pha
		ora track,x
		sta track,x
		pla
		asl
		bcc entry4a
		lda #255
		inx
		cpx #192
		bcs entry4c
entry4b:
		sta track,x
		inx
		cpx #192
		bcc entry4b
entry4c:
		rts

;count

entry5:
		ldy #0
		sty sum
		jsr calc
		ldy #0
entry5a:
		lda #9
		sta count
		lda track,x
		inx
entry5b:
		dec count
		beq entry5a
		pha
		lda #" "
		sta buf2,y
		pla
		asl
		bcc entry5c
		inc sum
		pha
		lda #"*"
		sta buf2,y
		pla
entry5c:
		iny
		cpy #60
		bne entry5b
		sty var
		lda #<buf2
		sta var+1
		lda #>buf2
		sta var+2
		ldx #$01
		jsr putvar ;a$
		lda sum
		rts

count:
		byte 0
sum:
		byte 0

doclock0:
		rts
doclock:
		lda clock
		beq doclock0
		lda scs
		cmp clockscs
		beq doclock0
		sta clockscs
		lda hrs
		jsr bcdtoa
		tya
		and #1
		bne doclock2
		lda #8
		sta clockpos
		lda #0
		sta clockoff
		jsr clrclk1
		jmp doclock3
doclock2:
		tya
		pha
		lda #4
		sta clockpos
		lda #3
		sta clockoff
		jsr clrclk2
		pla
		and #1
		jsr clocknum
doclock3:
		txa
		jsr clocknum
		lda clockpos
		clc
		adc #3
		sta clockpos
		lda min
		jsr bcdtoa
		tya
		jsr clocknum
		txa
		jsr clocknum
		lda scs
		lsr
		lda #$40
		ror
		ldy clockoff
		sta $5c8,y
		sta $640,y
		lda ten
		rts

clrclock:
		sta $590,y
		sta $5b8,y
		sta $5e0,y
		sta $608,y
		sta $630,y
		sta $658,y
		sta $680,y
		rts

clrclk1:
		ldy #39
		lda #32
clrclk1a:
		jsr clrclock
		dey
		cpy #31
		bne clrclk1b
		ldy #17
clrclk1b:
		cpy #14
		bne clrclk1c
		ldy #7
clrclk1c:
		cpy #255
		bne clrclk1a
		rts

clrclk2:
		ldy #39
		lda #32
clrclk2a:
		jsr clrclock
		dey
		cpy #34
		bne clrclk2b
		ldy #20
clrclk2b:
		cpy #17
		bne clrclk2c
		ldy #3
clrclk2c:
		cpy #255
		bne clrclk2a
		rts

;* display # for clock
clocknum:
		sta clockpat
		txa
		pha
		tya
		pha
		lda clockpat
		and #$0f
		asl
		asl
		asl
		tax
		lda #<$0590
		sta $8b
		lda #>$0590
		sta $8c
clockn1:
		lda numpats,x
		asl
		sta clockpat
		ldy #$07
		sty hba63
		ldy clockpos
clockn2:
		asl clockpat
		lda #$40
		ror
		sta [$8b],y
		iny
		dec hba63
		bne clockn2
		inx
		clc
		lda $8b
		adc #40
		sta $8b
		lda $8c
		adc #0
		sta $8c
		lda $8b
		cmp #$a8
		bne clockn1
		lda clockpos
		clc
		adc #7
		sta clockpos
		pla
		tay
		pla
		tax
		rts

;* big clock number patterns

numpats:
		byte %00011100
		byte %00100010
		byte %00100010
		byte %00100010
		byte %00100010
		byte %00100010
		byte %00011100
		byte %00000000

		byte %00001000
		byte %00011000
		byte %00001000
		byte %00001000
		byte %00001000
		byte %00001000
		byte %00011100
		byte %00000000

		byte %00011100
		byte %00100010
		byte %00000010
		byte %00011100
		byte %00100000
		byte %00100000
		byte %00111110
		byte %00000000

		byte %00011100
		byte %00100010
		byte %00000010
		byte %00001100
		byte %00000010
		byte %00100010
		byte %00011100
		byte %00000000

		byte %00100100
		byte %00100100
		byte %00100100
		byte %00111110
		byte %00000100
		byte %00000100
		byte %00000100
		byte %00000000

		byte %00111110
		byte %00100000
		byte %00100000
		byte %00111100
		byte %00000010
		byte %00000010
		byte %00111100
		byte %00000000

		byte %00011100
		byte %00100010
		byte %00100000
		byte %00111100
		byte %00100010
		byte %00100010
		byte %00011100
		byte %00000000

		byte %00111110
		byte %00000010
		byte %00000010
		byte %00000100
		byte %00001000
		byte %00010000
		byte %00010000
		byte %00000000

		byte %00011100
		byte %00100010
		byte %00100010
		byte %00011100
		byte %00100010
		byte %00100010
		byte %00011100
		byte %00000000

		byte %00011100
		byte %00100010
		byte %00100010
		byte %00011110
		byte %00000010
		byte %00100010
		byte %00011100
		byte %00000000

;* convert bcd to ascii

bcdtoa:
		pha
		lsr
		lsr
		lsr
		lsr
		tay
		pla
		and #$0f
		tax
		rts

clockpos:
		byte 0
clockpat:
		byte 0
clockoff:
		byte 0
clockscs:
		byte 0
hba63:
		byte 0

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
		ldx #<track
		ldy #>track
		jmp loadf

savefile:
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
		lda #<track
		ldx #>track
		sta var
		stx var+1
		ldx #<(track+192)
		ldy #>(track+192)
		lda #var
		jmp savef

usevar:
		lda #29
		jmp usetbl1
putvar:
		lda #30
		jmp usetbl1
