version = "03/19/89 11:39p"

include "equat.s"

org $c000, "proto1.prg"

; " 1   2   3    4 - 131    132
; " 1  blk {CTRL-B}{CTRL-L}{CTRL-K}  128 bytes  chksum

t1 = 65 ; time to wait for blk (rcv)
t2 = 100 ;
usetbl1 = $cd03

chrin = $ffcf
chkin = $ffc6
chkout = $ffc9
clrchn = $ffcc
chrout = $ffd2
getin = $ffe4

ridbe = $29b
ridbs = $29c
charval = $200

ack = 6
nak = 21
eot = 4
can = 24
soh = 1
nbufs = 4

; jump table
		jmp upload ; transmit
		jmp dnload ; recieve

putchr:
		pha
		ldx #131
		jsr chkout
		pla
		jmp chrout

outfil:
		pha
		ldx #2
		jsr chkout
		pla
		jmp chrout

getfil:
		ldx #2
		jsr chkin
		jmp chrin

clrbuf:
		lda #30
		jsr waitch
		bcc clrbuf
		rts

tmer2:
		byte 0
dltime:
		byte 0
savbuf:
		byte 0 ;current buffer #
errcnt:
		byte 0
bufnum:
		byte 0
chrnum:
		byte 0
chksum:
		word 0
blknum:
		byte 0
tmer1:
		word 0
charval:
		byte 0
blksum:
		byte 0
endblk:
		byte 0
stack:
		byte 0
bytes:
		byte 0,0,0
padchr:
		byte 0
oldtrans:
		byte 0

sendnak:
		jsr clrbuf
		jsr badblok
		inc errcnt
		lda errcnt
		cmp #21
		beq sendnak1
sendnak0:
		lda #nak
		jmp putchr
sendnak1:
		jmp ext1

sendack:
		lda #ack
		jsr putchr
		lda #$00
		sta errcnt
		rts

sendcan:
		lda #can
		jsr putchr
		jsr nobytes
		jmp clrchn

lobyts:
		byte <$518,<$59c,<$620
		byte <$6a4

hibyts:
		byte >$518,>$59c,>$620
		byte >$6a4

getbuf:
		lda lobyts-1,x
		sta $b0
		lda hibyts-1,x
		sta $b1
		dey
		lda ($b0),y
		iny
		rts

putbuf:
		pha
		lda lobyts-1,x
		sta $b0
		lda hibyts-1,x
		sta $b1
		pla
		dey
		sta ($b0),y
		iny
		rts

; x-modem recieve file

dnload:
		tsx
		stx stack
		jsr screen
		jsr setup
		jsr reset
		lda #1
		sta bufnum
		lda #0
		sta chksum
		lda #1
		sta chrnum
;send nak, wait for reply
dnl0:
		jsr sendnak0
		lda #100
		jsr waitch
		bcc dnl4
		bcs dnl0
;set buffer pointer to first buf
dnl1:
		lda #1
		sta bufnum
;get block
dnl2:
		lda #0
		sta chksum
		lda #1
		sta chrnum
dnl3:
		lda #100
		jsr waitch
		bcc dnl4
		jsr sendnak0
		jmp dnl2
dnl4:
		cmp #soh
		beq dnl9
		cmp #can
		beq dnl5
		cmp #eot
		bne dnl3
		jsr sendack
		jmp dnl20
;cancel received .. quit
dnl5:
		jmp ext1

dnl6:
		lda #150
		jsr waitch
		bcc dnl9
		jmp dnl11
dnl9:
		ldx bufnum
		ldy chrnum
		lda charval
		jsr putbuf
		cpy #4
		bcc dnl10
		cpy #132
		bcs dnl10
		lda charval
		jsr docheck
dnl10:
		inc chrnum
		lda chrnum
		cmp #133
		bne dnl6
		ldx bufnum
		ldy #132
		jsr getbuf
		sta blksum
		cmp chksum
		beq dnl12
;bad block
dnl11:
		jsr clrbuf
		jsr sendnak
		jmp dnl2
;good block
dnl12:
		inc blknum
		ldx bufnum
		ldy #2
		jsr getbuf
		cmp blknum
		beq dnl13
		dec blknum
		cmp blknum
		bne dnl11
		jsr sendack
		jmp dnl2
dnl13:
		lda #4
		sta chrnum
;write a block
dnl18:
		ldx bufnum
		ldy chrnum
		jsr getbuf
		jsr outfil
		inc chrnum
		lda chrnum
		cmp #132
		bne dnl18
		jsr reset
		jsr dobytes
		jsr sendack
		inc bufnum
		lda bufnum
		cmp #nbufs+1
		bne dnl19
		jmp dnl1
dnl19:
		jmp dnl2
dnl20:
		jmp ext2

delay:
		ldx #21
delay1:
		lda #0
		sta dltime
delay2:
		dec dltime
		bne delay2
		dex
		bne delay1
		dey
		bne delay
		rts

;transmit file

upload:
		tsx
		stx stack
		jsr screen
		jsr setup
		jsr reset
;wait for initial nak
upl1:
		jsr getnum
		bcs upl1
		cmp #nak
		beq upl2
		cmp #can
		bne upl1
		jmp ext1
upl2:
		lda #1
		sta savbuf
upl3:
		ldx savbuf
		ldy #1
		lda #soh
		jsr putbuf
		inc blknum
		iny
		lda blknum
		jsr putbuf
		iny
		eor #$ff
		jsr putbuf
		lda #0
		sta chksum
		lda #4
		sta chrnum
upl4:
		jsr getfil
		sta charval
		ldx savbuf
		ldy chrnum
		jsr putbuf
		jsr docheck
		lda $90
		beq upl6
;pad rest of buffer
		lda #0
		sta padchr
		lda charval
		bne upl4a
;if last byte=0.use ctrl-z
		lda #26
		sta padchr
upl4a:
		lda savbuf
		sta endblk
		inc chrnum
		lda chrnum
		cmp #132
		bcs upl5a
upl5:
		ldx savbuf
		ldy chrnum
		lda padchr
		jsr putbuf
		jsr docheck
		inc chrnum
		lda chrnum
		cmp #132
		bcc upl5
upl5a:
		ldx savbuf
		ldy #132
		lda chksum
		jsr putbuf
		jmp upl8
upl6:
		inc chrnum
		lda chrnum
		cmp #132
		bne upl4
		ldx savbuf
		ldy #132
		lda chksum
		jsr putbuf
		inc savbuf
		lda savbuf
		cmp #nbufs+1
		beq upl7
		jmp upl3
upl7:
		dec savbuf
upl8:
		lda ridbe
		sta ridbs
		lda blknum
		sec
		sbc savbuf
		sta blknum
;transmit all blocks
		jsr reset
		lda #0
		sta savbuf
upl9:
		inc savbuf
		inc blknum
;transmit next block
upl10:
		ldy #1
upl11:
		ldx savbuf
		jsr getbuf
		jsr putchr
		iny
		cpy #133
		bne upl11
upl12:
		lda #1
		sta tmer2
upl13:
		jsr getnum
		bcc upl14
		ldy #1
		jsr delay
		inc tmer2
		lda tmer2
		cmp #t2
		bne upl13
		lda #nak
upl14:
		cmp #ack
		beq upl17 ;good
		cmp #nak
		beq upl18 ;bad
		cmp #can
		bne upl12 ;abort
		jmp ext1
;block checked good
upl17:
		jsr dobytes
		lda savbuf
		cmp #nbufs
		bne upl15
		lda endblk
		bne upl15
		jmp upl2
upl15:
		lda endblk
		cmp savbuf
		bne upl9
;finished
upl16:
		lda #0
		sta endblk
		lda #eot
		jsr putchr
		jmp ext2
;bad block
upl18:
		jsr badblok
		ldy #2
		jsr delay
		jsr clrbuf
		jmp upl10

setup:
		lda #52
		ldx #16
		ldy #3
		jsr usetbl1
		lda var+1
		sta oldtrans
		lda #52
		ldx #16
		ldy #0
		jmp usetbl1

; check carrier/abort

exit:
		lda $028d
		cmp #2
		beq ext1
		lda $dd01
		and #$10
		eor mxor
		beq ext3
ext1:
		ldx stack
		txs
		jsr sendcan
ext2:
		jsr clrchn
		lda #52
		ldx #16
		ldy oldtrans
		jsr usetbl1
		lda bytes
		ldx bytes+1
		ldy bytes+2
ext3:
		rts

; wait for character

waitch:
		sta tout+1
		lda #0
		sta tout
waitch1:
		jsr getnum
		bcc waitch4
		lda tout
		bne waitch2
		lda tout+1
		beq waitch3
		dec tout+1
waitch2:
		dec tout
		jmp waitch1
waitch3:
		sec
		lda #0
waitch4:
		rts
tout:
		word 0

; get character

getnum:
		jsr exit
getnum1:
		lda #0
		sta charval
		lda ridbe
		cmp ridbs
		beq get1
		tya
		pha
		txa
		pha
		jsr getmdm
		sta charval
		pla
		tax
		pla
		tay
		lda #0
		sta $96
		clc
		jmp get2
get1:
		lda #2
		sta $96
		sec
get2:
		lda charval
		rts

;add # of bytes to total

dobytes:
		lda #128
		clc
		adc bytes
		sta bytes
		bcc dobytes1
		inc bytes+1
		bne dobytes1
		inc bytes+2
		bne dobytes1
dobytes1:
		jmp goodblok

nobytes:
		lda #0
		sta bytes
		sta bytes+1
		sta bytes+2
		sta errcnt
		sta blknum
		rts

;make the screen

screen:
		ldy #0
scr1:
		lda #32
		sta $518,y
		sta $620,y
		sta $59c,y
		sta $6a4,y
		lda #3
		sta $d918,y
		sta $da20,y
		lda #7
		sta $d99c,y
		sta $daa4,y
		iny
		cpy #132
		bne scr1
		ldy #0
scr2:
		lda msg1,y
		sta $748,y
		lda #1
		sta $db48,y
		lda msg2,y
		sta $770,y
		lda #1
		sta $db70,y
		iny
		cpy #40
		bne scr2
		ldx #13
		ldy #4
		lda #34
		jsr putfnm
scr4:
		dey
		dey
		lda ($bb),y
		jsr putfnm
		iny
		iny
		iny
		cpy $b7
		bcc scr4
		lda #34
		jsr putfnm
		jmp nobytes

putfnm:
		pha
		and #192
		beq putfnm1
		cmp #192
		beq putfnm1
		pla
		eor #64
		pha
putfnm1:
		pla
		and #127
		sta $748,x
		lda #1
		sta $db48,x
		inx
		rts

msg1:
		byte "good
		0000                              "
goodblok:
		ldx #3
gdb1:
		inc $74e,x
		lda $74e,x
		cmp #$3a
		bne gdb2
		lda #$30
		sta $74e,x
		dex
		bpl gdb1
gdb2:
		rts

msg2:
		byte " bad
		0000                              "
badblok :
		ldx #3
bdb1:
		inc $776,x
		lda $776,x
		cmp #$3a
		bne bdb2
		lda #$30
		sta $776,x
		dex
		bpl bdb1
bdb2:
		rts
notime:
		lda #0
		sta tmer1
		sta tmer1+1
		rts

docheck:
		clc
		adc chksum
		sta chksum
		rts

;reset nmi routine

reset:
		jsr $ef7e
		lda $02a1
		cmp #$80
		beq reset
		cmp #$92
		beq reset
		rts

;calls to resident ml

getln:
		lda #35
		jmp usetbl1
putln:
		lda #36
		jmp usetbl1
getmdm:
		lda #4
		jmp usetbl1
usevar:
		lda #29
		jmp usetbl1
putvar:
		lda #30
		jmp usetbl1
tenwait:
		lda #22
		jmp usetbl1

		byte version$

