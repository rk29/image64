version = "9003140521"

include "equat.s"

org $c000, "proto1.prg"

chrack = 6
chrnak = 21
chreot = 4
chrcan = 24
chrsoh = 1
chrstx = 2

;flagbyte:

; 1 = 0=normal,1=relaxed
; 2 = 0=128b,1=1k
; 4 =

		jmp xsend
		jmp xrecv
		jmp xsendnam
		jmp xrecvnam

protonum:
		byte 1
defflag:
		byte 0
flagbyte:
		byte 0
versiond:
		byte version

t1:
		byte 60,240

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
		jsr usetbl1
		ldx #7
scr1:
		jsr $e9ff
		inx
		cpx #15
		bcc scr1
		ldy #9
setup1:
		lda line1,y
		sta $518,y
		lda line2,y
		sta $540,y
		lda #1
		sta $d918,y
		sta $d940,y
		dey
		bpl setup1
		lda #0
		sta errors
		lda #0
		sta endflag
		lda #0
		sta abrtflag
		lda #0
		sta lastbuf
		lda #0
		sta bytes
		sta bytes+1
		sta bytes+2
		lda defflag
		sta flagbyte
		lda flagbyte
		and #2
		bne setup2
		ldx #<128
		ldy #>128
		lda #0
		beq setup3
setup2:
		ldx #<1024
		ldy #>1024
		lda #1
setup3:
		sta kflag
		stx blocksiz
		sty blocksiz+1
		rts

goodblk:
		clc
		lda blocksiz
		adc bytes
		sta bytes
		lda blocksiz+1
		adc bytes+1
		sta bytes+1
		lda #0
		sta errors
		adc bytes+2
		sta bytes+2
		ldx #<$521
		bne incblk

badblk:
		inc errors
		lda errors
		cmp #21
		bcc badblk1
		jmp exit1
badblk1:
		ldx #<$549
incblk:
		ldy #5
incblk1:
		inc $500,x
		lda $500,x
		cmp #":"
		bne incblk2
		lda #"0"
		sta $500,x
		dex
		dey
		bne incblk1
incblk2:
		rts

calcsum:
		pha
		clc
		adc checksum
		sta checksum
		pla
		pha
		eor crc
		sta crc
		txa
		pha
		ldx #8
calcsum1:
		asl crc+1
		rol crc
		bcc calcsum2
		lda #>$1021
		eor crc
		sta crc
		lda #<$1021
		eor crc+1
		sta crc+1
calcsum2:
		dex
		bne calcsum1
		pla
		tax
		pla
		rts

line1:
		byte "good:00000"
line2:
		byte "bad:00000"

exit:
		lda $028d
		cmp #2
		beq exit1
		lda $dd01
		and #$10
		eor mxor
		beq exit3
exit1:
		ldx stack
		txs
		lda #chrcan
		jsr sendbyte
		jsr sendbyte
		jsr sendbyte
		jsr sendbyte
		jsr sendbyte
exit2:
		lda #52
		ldx #16
		ldy oldtrans
		jsr usetbl1
		lda bytes
		ldx bytes+1
		ldy bytes+2
exit3:
		rts

getbyte:
		jsr exit
getbyte1:
		lda #0
		sta charval
		lda ridbe
		cmp ridbs
		beq getbyte2
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
		jmp getbyte3
getbyte2:
		lda #2
		sta $96
		sec
getbyte3:
		lda charval
		rts

sendbyte:
		pha
		ldx #131
		jsr chkout
		pla
		jsr chrout
		pha
		jsr clrchn
		pla
		rts

waitch10:
		lda #10
		bne waitch
waitch02:
		lda #2
waitch:
		sta waitsec
waitch1:
		lda #0
		sta jiffy
waitch2:
		jsr getbyte
		bcc waitch3
		lda flagbyte
		and #1
		tax
		lda jiffy
		cmp t1,x
		bcc waitch2
		dec waitsec
		bne waitch1
		lda #0
		sec
waitch3:
		rts

xsendcrc:
		lda #0
		sta crcflag
xsendc0:
		jsr waitch10
		bcs xsendc0
		cmp #chrnak
		beq xsendc2
		cmp #"c"
		beq xsendc1
		cmp #chrcan
		beq xsendc3
xsendc1:
		lda #1
		sta crcflag
xsendc2:
		rts
xsendc3:
		jmp exit1

sendblk0:
		jsr badblk
sendblk:
		lda kflag
		beq sendblk1
		lda #chrstx
		byte $2c
sendblk1:
		lda #chrsoh
		jsr sendbyte
		lda blocknum
		jsr sendbyte
		eor #255
		jsr sendbyte
		jsr sendbuf
		jsr sendchk
sendblk3:
		jsr waitch10
		bcs sendblk3
sendblk4:
		cmp #chrnak
		beq sendblk0
		cmp #chrack
		beq sendblk5
		cmp #chrcan
		bne sendblk3
		jsr waitch10
		bcs sendblk3
		cmp #chrcan
		bne sendblk4
		lda #1
		sta abrtflag
sendblk5:
		inc bufnum
		inc blocknum
		jsr goodblk
		clc
		lda kflag
		bne sendbl4
		lda $b0
		adc #128
		sta $b0
		lda $b1
		adc #0
		sta $b1
		rts
sendbl4:
		lda lastbuf
		beq sendbl5
		sta bufnum
sendbl5:
		rts

sendbuf:
		ldy #0
		lda #0
		sta checksum
		sta crc
		sta crc+1
		lda kflag
		beq sendbuf1
		lda #<xbuf
		sta $b0
		lda #>xbuf
		sta $b1
		lda #1
		sta bufnum
sendbuf1:
		lda [$b0],y
		jsr sendbyte
		jsr calcsum
		sta $590,y
		lda #1
		sta $d990,y
		iny
		cpy #128
		bcc sendbuf1
		lda lastbuf
		cmp bufnum
		bne sendbuf2
		lda #1
		sta endflag
sendbuf2:
		lda kflag
		beq sendbuf3
		clc
		ldy #0
		lda $b0
		adc #128
		sta $b0
		lda $b1
		adc #0
		sta $b1
		inc bufnum
		lda bufnum
		cmp #9
		bne sendbuf1
sendbuf3:
		rts

sendchk:
		lda crcflag
		bne sendchk1
		lda checksum
		jmp sendbyte
sendchk1:
		lda crc
		jsr sendbyte
		lda crc+1
		jmp sendbyte

fillbuf:
		ldx #2
		jsr chkin
		lda #<xbuf
		sta $b0
		lda #>xbuf
		sta $b1
		ldx #1
		stx bufnum
fillbuf0:
		ldy #0
fillbuf1:
		jsr chrin
		sta [$b0],y
		iny
		jsr readst
		bne fillbuf2
		cpy #128
		bcc fillbuf1
		lda $b0
		adc #127
		sta $b0
		lda $b1
		adc #0
		sta $b1
		inc bufnum
		ldx bufnum
		cpx #9
		bcc fillbuf0
		bcs fillbuf5
fillbuf2:
		stx lastbuf
		cpy #128
		bcs fillbuf4
fillbuf3:
		lda #26
		sta [$b0],y
		iny
		cpy #128
		bcc fillbuf3
fillbuf4:
		ldy #0
		lda $b0
		adc #127
		sta $b0
		lda $b1
		adc #0
		sta $b1
		inx
		cpx #9
		bcc fillbuf3
fillbuf5:
		lda #<xbuf
		sta $b0
		lda #>xbuf
		sta $b1
		lda #1
		sta bufnum
		jmp clrchn

xsend:
		tsx
		stx stack
		jsr setup
		lda #1
		sta blocknum
		jsr xsendcrc
xsend2:
		jsr fillbuf
xsend3:
		jsr sendblk
		lda abrtflag
		bne xsend6
		lda endflag
		bne xsend4
		lda bufnum
		cmp #9
		bcs xsend2
		bcc xsend3
xsend4:
		lda #chreot
		jsr sendbyte
xsend5:
		jsr waitch10
		bcs xsend5
		cmp #chrack
		bne xsend4
		jmp exit2
xsend6:
		jmp exit1

xrecvcrc:
		lda #1
		sta crcflag
		lda #3
		sta bufnum
xrecvc1:
		lda #"c"
		jsr sendbyte
		jsr waitch10
		bcc xrecvc3
		dec bufnum
		bne xrecvc1
		lda #3
		sta bufnum
		lda #0
		sta crcflag
xrecvc2:
		lda #chrnak
		jsr sendbyte
		jsr waitch10
		bcc xrecvc3
		dec bufnum
		bne xrecvc2
		jmp xrecvcrc
xrecvc3:
		rts

xrecv:
		tsx
		stx stack
		jsr setup
		lda #1
		sta blocknum
		lda #0
		sta lastbuf
		jsr xrecvcrc
		jsr recvblk0
		jmp xrecv2
xrecv1:
		jsr recvblk
xrecv2:
		cpx #0
		beq xrecv1
		cpx #1
		beq xrecv3
		jmp exit2
xrecv3:
		jmp exit1

errmsg:
; sta $580
		lda #1
		sta $d980
		rts

recvblk:
		jsr waitch02
		bcs recvblk2
recvblk0:
		ldx #0
		stx kflag
		cmp #chrsoh
		beq recvblk5
		cmp #chrstx
		beq recvblk1
		cmp #chrcan
		beq recvblk3
		cmp #chreot
		beq recvblk4
recvblk2:
		jsr waitch02
		bcc recvblk2
		lda #chrnak
		jsr sendbyte
		jsr badblk
		jmp recvblk
recvblk3:
		jsr waitch02
		bcs recvblk2
		cmp #chrcan
		bne recvblk2
		ldx #1
		rts
recvblk4:
		lda #chrack
		jsr sendbyte
		ldx #2
		rts
recvblk1:
		ldx #1
		stx kflag
recvblk5:
		jsr waitch02
		bcs recvblk2
		sta blockrcv
		jsr waitch02
		bcs recvblk2
		sta blockrcv+1
		jsr recvbuf
		bcs recvblk2
		jsr waitch02
		bcs recvblk2
		cmp crc
		beq recvblk6
		lda #"c"
		jsr errmsg
		jmp recvblk2
recvblk6:
		lda crcflag
		beq recvblk8
		jsr waitch02
		bcs recvblk2
		cmp crc+1
		beq recvblk8
		lda #"c"
		jsr errmsg
		jmp recvblk2
recvblk7:
		lda #"m"
		jsr errmsg
		jmp recvblk2
recvblk8:
		lda blockrcv+1
		eor #255
		cmp blockrcv
		bne recvblk7
		lda blockrcv
		cmp blocknum
		beq recvblk9
		sec
		sbc #1
		cmp blocknum
		bne recvblk7
		lda #"l"
		jsr errmsg
		lda #chrack
		jsr sendbyte
		jmp recvblk
recvblk9:
		jsr savebuf
		jsr goodblk
		lda #chrack
		jsr sendbyte
		inc blocknum
		ldx #0
		rts

savebuf:
		ldx #2
		jsr chkout
		ldy #0
		lda #<xbuf
		sta $b0
		lda #>xbuf
		sta $b1
		lda #1
		sta bufnum
savebuf1:
		lda [$b0],y
		jsr chrout
		sta $590,y
		lda #1
		sta $d990,y
		iny
		cpy #128
		bcc savebuf1
		ldy #0
		lda $b0
		adc #127
		sta $b0
		lda $b1
		adc #0
		sta $b1
		inc bufnum
		lda bufnum
		cmp #9
		beq savebuf2
		lda kflag
		bne savebuf1
savebuf2:
		jmp clrchn

recvbuf:
		ldy #0
		sty checksum
		sty crc
		sty crc+1
		lda #<xbuf
		sta $b0
		lda #>xbuf
		sta $b1
		lda #1
		sta bufnum
recvbuf1:
		jsr waitch02
		bcs recvbuf3
		jsr calcsum
		sta [$b0],y
		iny
		cpy #128
		bcc recvbuf1
		ldy #0
		lda $b0
		adc #127
		sta $b0
		lda $b1
		adc #0
		sta $b1
		inc bufnum
		lda bufnum
		cmp #9
		beq recvbuf2
		lda kflag
		bne recvbuf1
recvbuf2:
		clc
		rts
recvbuf3:
		sec
		rts

blocknum:
		byte 0
blockrcv:
		byte 0,0
blocksiz:
		word 1024
crcflag:
		byte 0
kflag:
		byte 1
bufnum:
		byte 0
abrtflag:
		byte 0
endflag:
		byte 0
lastbuf:
		byte 0
waitsec:
		byte 0
stack:
		byte 0
oldtrans:
		byte 0
bytes:
		byte 0,0,0
crc:
		word 0
crc1:
		word 0
checksum:
		byte 0
charval:
		byte 0
errors:
		byte 0

xsendnam:
		tsx
		stx stack
		jsr setup
		lda #0
		sta blocknum
		jsr xsendcrc
xsendn2:
		ldx #0
		jsr usevar ;an$
		ldy #0
		lda var
		beq xsendn4
xsendn3:
		lda [var+1],y
		sta xbuf,y
		iny
		cpy var
		bcc xsendn3
		lda #0
xsendn4:
		sta xbuf,y
		iny
		cpy #128
		bcc xsendn4
		jsr sendblk
		jmp exit2
xsendn6:
		jmp exit1

xrecvnam:
		tsx
		stx stack
		jsr setup
		lda #0
		sta blocknum
		jsr xrecvcrc
		jsr xrecvblk0
		ldy #0
xrecvn1:
		lda xbuf,y
		beq xrecvn2
		sta buffer,y
		iny
		cpy #16
		bcc xrecvn1
xrecvn2:
		sty var
		lda #<buffer
		sta var+1
		lda #>buffer
		sta var+2
		ldx #0
		jsr putvar ;an$
		jmp exit2

getmdm:
		lda #4
		jmp usetbl1
usevar:
		lda #29
		jmp usetbl1
putvar:
		lda #30
		jmp usetbl1

xbuf:

