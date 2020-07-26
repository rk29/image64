include "equat.s"

org $c000, "proto2.prg"

t3 = 70
status = $90
copybuf = $0518
usetbl1 = $cd03
buffer = $ce77

readst = $ffb7
chkin = $ffc6
chkout = $ffc9
clrchn = $ffcc
chrin = $ffcf
chrout = $ffd2
getin = $ffe4

h49152:
		jmp copyall
h49155:
		jmp count
h49158:
		jmp copysome

copyall:
		lda #$ff
		sta flen
		sta flen+1
		sta flen+2
copy:
		jsr cscreen
		lda #0
		sta done
copyfile:
		ldx #3
		jsr chkin
		ldy #0
		ldx #0
nextbyte:
		stx tmp2
		jsr chrin
		ldx status
		beq intobuf
		cpx #$40
		beq intobuf
		cpx tmp2
		bne nextbyte
		beq outbuf
intobuf:
		sta copybuf,y
		iny
		lda flen
		bne ib1
		lda flen+1
		bne ib0
		dec flen+2
ib0:
		dec flen+1
ib1:
		dec flen
		lda flen
		ora flen+1
		ora flen+2
		bne ib2
		lda #1
		sta done
		bne outbuf
ib2:
		cpy #254
		beq outbuf
		cpx #0
		beq nextbyte
outbuf:
		sty tmp3
		stx tmp2
		jsr clrchn
		ldx #2
		jsr chkout
		ldy #0
		ldx #0
copy4:
		lda copybuf,y
copy5:
		stx tmp4
		jsr chrout
		ldx status
		beq copy6
		cpx tmp4
		bne copy5
		beq nextblk
copy6:
		iny
		cpy tmp3
		bne copy4
nextblk:
		jsr clrchn
		jsr goodblok
		lda tmp2
		ora status
		bne nb2
		lda done
		bne nb2
		jmp copyfile
nb2:
		rts

cscreen:
		ldx #$07
cscr1:
		jsr $e9ff
		inx
		cpx #22
		bne cscr1
		ldy #0
cscr2:
		lda #3
		sta $d918,y
		iny
		bne cscr2
		ldy #9
cscr3:
		lda ctext1,y
		sta $748,y
		lda #1
		sta $db48,y
		dey
		bpl cscr3
		rts

ctext1:
		byte "blks:0000"

count:
		ldx #3
		jsr chkin
		lda #0
		sta flen
		sta flen+1
		sta flen+2 ; zero counter
count1:
		jsr getin
		inc flen
		bne nxtcount
		inc flen+1
		bne nxtcount
		inc flen+2
nxtcount:
		lda status
		beq count1
		jsr clrchn
		ldx #2
		jsr chkout
		lda flen
		jsr chrout
		lda flen+1
		jsr chrout
		lda flen+2
		jsr chrout
		jsr clrchn
		lda #3
		jmp $ffc3 ; close

copysome:
		ldx #3
		jsr chkin
		jsr getin
		sta flen
		jsr getin
		sta flen+1
		jsr getin
		sta flen+2
		jsr clrchn
		jmp copy
flen:
		byte 0,0,0
done:
		byte 0

goodblok:
		ldx #$51
		ldy #3
counter:
		inc $700,x
		lda $700,x
		cmp #":"
		bne counter1
		lda #"0"
		sta $700,x
		dex
		dey
		bpl counter
counter1:
		rts
