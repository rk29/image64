version = "9002199007"

include "equat.s"

org $c000, "proto0.prg"

; modem file number
mfile = 131

; disk file number
dfile = 2

; disk error channel
errch = 15

;on entry:

; upload - file open to #dfile
; dnload - file open to #dfile
; multiup - a%=# of files
; ..........tt$(1..a%) = filename,t
; ..........dv%,dr$ dev/drv
; multidn - a%=files limit
; ..........dv%,dr$ dev/drv
;on exit:

; upload - b%=# blocks (0 = abort)
; ........ .a,.x,.y = # bytes ^
; dnload - b%=# blocks (0 = abort)
; ........ .a,.x,.y = # bytes ^
; multiup - a%=# successful
; ........ b%=# blocks in last^
; multidn - a%=# files sent
; ........ b%=# blocks in last^

		usetbl1 = $cd03
		buffer = $ce77

		readst = $ffb7
		chkin = $ffc6
		chkout = $ffc9
		clrchn = $ffcc
		chrin = $ffcf
		chrout = $ffd2
		getin = $ffe4
		setlfs = $ffba
		setnam = $ffbd
		openf = $ffc0
		closef = $ffc3

; start - jump table
		jmp upload0 ;49152
		jmp dnload0 ;49155
		jmp multiup0 ;49158
		jmp multidn0 ;49161

protonum:
		byte 0 ; punter
flagbyte:
		byte 0
versiond:
		byte version

;code accept
t1:
		byte 50,250
;receive timing
t2:
		byte 16,30

upload0:
		jsr upload
		jmp xfer1
dnload0:
		jsr dnload
		jmp xfer1
multiup0:
		jsr multiup
		jmp xfer2
multidn0:
		jsr multidn
		jmp xfer2

; transmit file
upload:
		jsr screen
		jsr trantype
		jmp transmit
; recieve file
dnload:
		jsr screen
		jsr rectype
		jmp recieve

; multi- send
multiup:
		tsx
		stx stack1
		jsr reset
		ldx #1
		jsr usevar ;a$
		lda var
		beq multiup2
		ldx #7
		jsr sendcode;"{ensh}{ensh}{ensh}"
		ldx #5
		jsr tenwait
		ldx #mfile
		jsr chkout
		ldy #0
multiup1:
		lda buffer,y
		jsr chrout
		iny
		cpy index
		bcc multiup1
		lda #13
		jsr chrout
		jmp clrchn
multiup2:
		ldx #7
		jsr sendcode;"{ensh}{ensh}{ensh}"
		ldx #8
		jsr sendcode;"{CTRL-D}{CTRL-D}{CTRL-D}"
		ldx #9
		jmp sendcode; cr

;multi-recieve
multidn:
		tsx
		stx stack1
		jsr reset
		lda #0
		sta index
multidn1:
		jsr getnum0
		bcs multidn1
		cmp #$18 ; ctrl-x
		beq multidn4
		cmp #$04 ; ctrl-d
		beq multidn4
		cmp #ensh
		bne multidn1
multidn2:
		jsr getnum0
		bcs multidn2
		cmp #$18 ; ctrl-x
		beq multidn4
		cmp #$04 ; ctrl-d
		beq multidn4
		cmp #ensh
		beq multidn2
		lda $200
		sta buffer
		lda #1
		sta index
multidn3:
		jsr getnum0
		bcs multidn3
		ldy index
		cmp #$18 ; ctrl-x
		beq multidn6
		cmp #$04 ; ctrl-d
		beq multidn6
		cmp #13
		beq multidn4
		cpy #18
		bcs multidn3
		sta buffer,y
		inc index
		bne multidn3
multidn4:
		lda index
		sta var
		lda #<buffer
		sta var+1
		lda #>buffer
		sta var+2
		ldx #1
		jsr putvar ;a$
		lda index
		beq multidn5
		ldx #10
		jsr sendcode ;ok
multidn5:
		ldx #20
		jmp tenwait
multidn6:
		lda #0
		sta index
		jmp multidn4

; check carrier/abort
exit0:
		lda $28d
		cmp #2
		beq ext01
		lda $dd01
		and #$10
		eor mxor
		beq ext02
ext01:
		ldx stack1
		txs
ext02:
		rts

exit:
		lda $28d
		cmp #2
		beq ext1
		lda $dd01
		and #$10
		eor mxor
		beq ext2
ext1:
		ldx stack
		txs
		ldx #6
		jsr sendcode;"{CTRL-X}{CTRL-X}{CTRL-X}"
ext0:
		lda oldirqc
		sta irqcount
		jsr nobytes
ext2:
		rts

setup:
		ldx #16
		ldy #3
		jsr chkmark
		lda var+1
		sta oldtrans
		ldx #16
		ldy #0
		jsr chkmark
		lda irqcount
		sta oldirqc
		lda #11
		sta irqcount
		rts

; get # bytes and exit
xfer1:
		lda oldirqc
		sta irqcount
		ldx #16
		ldy oldtrans
		jsr chkmark
		lda blocks
		sta var+1
		lda blocks+1
		sta var
		ldx #31
		jsr putvar ;b%
		lda bytes
		ldx bytes+1
		ldy bytes+2
		rts
xfer2:
		lda #0
		sta var
		ldx numx
		dex
		stx var+1
		ldx #30
		jsr putvar ;a%
		rts
; check for code
accept:
		sta bitpat
		lda #$00
		sta codebuf
		sta codebuf+1
		sta codebuf+2
acc1:
		lda #$00
		sta tmer1
		sta tmer1+1
acc2:
		jsr getnum
		bcs acc6
acc3:
		ldx codebuf+1
		stx codebuf
		ldx codebuf+2
		stx codebuf+1
		sta codebuf+2
		jsr chkcod
		beq acc1
		sec
		lda #$00
acc4:
		rol
		dex
		bne acc4
		and bitpat
		beq acc2
		lda flagbyte
		and #1
		bne acc5
		jsr getnum
		bcc acc3
acc5:
		lda #0
		sta $96
		rts
acc6:
		inc tmer1
		bne acc7
		inc tmer1+1
acc7:
		lda flagbyte
		and #1
		tax
		lda tmer1+1
		cmp t1,x
		bne acc2
		lda #1
		sta $96
		rts

chkcod:
		ldx #6
chc1:
		lda codebuf
		cmp char1-1,x
		bne chc2
		lda codebuf+1
		cmp char2-1,x
		bne chc2
		lda codebuf+2
		cmp char3-1,x
		beq chc3
chc2:
		dex
		bne chc1
chc3:
		stx bitcnt
		txa
		cmp #6
		bne chc4
		jmp ext1
chc4:
		cmp #0
		rts

;codes.........12345678..9..10
char1:
		byte "gbass{CTRL-X}{ensh}{CTRL-D}",13,"o"
char2:
		byte "oac/y{CTRL-X}{ensh}{CTRL-D}",10,"k"
char3:
		byte "odkbn{CTRL-X}{ensh}{CTRL-D}",0,13

sendcode:
		txa
		pha
		ldx #mfile
		jsr chkout
		pla
		tax
		lda char1-1,x
		jsr chrdly
		lda char2-1,x
		jsr chrdly
		lda char3-1,x
		jsr chrdly
		jsr clrchn
		ldx #1
		jmp tenwait
chrdly:
		jsr chrout
		lda #10
		sec
chrdly1:
		sbc #1
		bcs chrdly1
		rts

getnum0:
		jsr exit0
		jmp getnum1
getnum:
		jsr exit
getnum1:
		lda #0
		sta $0200
		lda 667
		cmp 668
		beq get1
		tya
		pha
		txa
		pha
		jsr getmdm
		sta $0200
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
		lda $0200
		rts

rechand:
		sta gbsave
		lda #$00
		sta delay
rch1:
		lda #$02
		sta $62
		ldx gbsave
		jsr sendcode
rch2:
		lda #$04
		jsr accept ;ack
		lda $96
		beq rch3
		dec $62
		bne rch2
		jmp rch1
rch3:
		ldx #4
		jsr sendcode ;s/b
		lda endflag
		beq rch4
		lda gbsave
		cmp #$01
		beq rch6
rch4:
		lda $051c
		sta bufcount
		sta recsize
		jsr recmodem
		lda $96
		cmp #$01
		beq rch5
		cmp #$02
		beq rch3
		cmp #$04
		beq rch5
		cmp #$08
		beq rch3
rch5:
		rts
rch6:
		lda #$10
		jsr accept ;syn
		lda $96
		bne rch3
		lda #$0a
		sta bufcount
rch7:
		ldx #5
		jsr sendcode ;syn
		lda #$08
		jsr accept ;s/b
		lda $96
		beq rch8
		dec bufcount
		bne rch7
rch8:
		rts

tranhand:
		lda #$01
		sta delay
trh1:
		lda specmode
		beq trh2
		ldx #1
		jsr sendcode ;goo
trh2:
		lda #%01011
		jsr accept ;goo,bad,s/b
		lda $96
		bne trh1
		lda #$00
		sta specmode
		lda bitcnt
		cmp #$01
		bne trh6
		lda endflag
		bne trh8
		inc blocknum
		bne trh3
		inc blocknum+1
trh3:
		jsr thisbuf
		ldy #$05
		iny
		lda [$64],y
		cmp #$ff
		bne trh4
		lda #$01
		sta endflag
		lda bufpnt
		eor #$01
		sta bufpnt
		jsr thisbuf
		jsr dummybl1
		jmp trh5
trh4:
		jsr dummyblk
trh5:
		lda #"-"
		byte $2c
trh6:
		lda #":"
		jsr prtdash
		ldx #3
		jsr sendcode ;ack
		lda #%01000
		jsr accept ;s/b
		lda $96
		bne trh5
		jsr thisbuf
		ldy #$04
		lda [$64],y
		sta bufcount
		jsr altbuf
		ldx #mfile
		jsr chkout
		ldy #$00
trh7:
		lda [$64],y
		jsr chrout
		iny
		cpy bufcount
		bne trh7
		jsr clrchn
		lda #$00
		rts
trh8:
		ldx #3
		jsr sendcode ;ack
		lda #%01000
		jsr accept ;s/b
		lda $96
		bne trh8
		lda #10
		sta bufcount
trh9:
		ldx #5
		jsr sendcode ;syn
		lda #%10000
		jsr accept ;syn
		lda $96
		beq trha
		dec bufcount
		bne trh9
trha:
		lda #$03
		sta bufcount
trhb:
		ldx #4
		jsr sendcode ;s/b
		lda #%00000
		jsr accept ;wait
		dec bufcount
		bne trhb
		lda #$01
		rts

recmodem:
		ldy #$00
rcm1:
		lda #$00
		sta tmer1
		sta tmer1+1
rcm2:
		jsr getnum
		lda $96
		bne rcm5
		lda $0200
		sta $0518,y
		cpy #$03
		bcs rcm3
		sta codebuf,y
		cpy #$02
		bne rcm3
		lda codebuf
		cmp #"a"
		bne rcm3
		lda codebuf+1
		cmp #"c"
		bne rcm3
		lda codebuf+2
		cmp #"k"
		beq rcm4
rcm3:
		iny
		cpy bufcount
		bne rcm1
		lda #$01
		sta $96
		rts
rcm4:
		lda #$ff
		sta tmer1
		sta tmer1+1
		jmp rcm2
rcm5:
		inc tmer1
		bne rcm6
		inc tmer1+1
rcm6:
		lda tmer1
		ora tmer1+1
		beq rcm8
		lda flagbyte
		and #1
		tax
		lda tmer1+1
		cmp t2,x
		bne rcm2
		lda #$02
		sta $96
		cpy #$00
		beq rcm7
		lda #$04
		sta $96
rcm7:
		jmp dodelay
rcm8:
		lda #$08
		sta $96
		rts

dummyblk:
		lda bufpnt
		eor #$01
		sta bufpnt
		jsr thisbuf
		ldy #$05
		lda blocknum
		clc
		adc #$01
		sta [$64],y
		iny
		lda blocknum+1
		adc #$00
		sta [$64],y
		ldx #dfile
		jsr chkin
		ldy #$07
dum1:
		jsr chrin
		sta [$64],y
		jsr commbyte
		iny
		jsr readst
		bne dum2
		cpy maxsize
		bne dum1
		tya
		pha
		jmp dum3
dum2:
		tya
		pha
		ldy #$05
		iny
		lda #$ff
		sta [$64],y
		jmp dum3
dummybl1:
		pha
dum3:
		jsr clrchn
		jsr reset
		jsr dod2
		jsr reset
		ldy #$04
		lda [$64],y
		sta bufcount
		jsr altbuf
		pla
		ldy #$04
		sta [$64],y
		jsr checksum
		rts

thisbuf:
		lda #$18
		sta $64
		lda bufpnt
		clc
		adc #$05
		sta $65
		rts

altbuf:
		lda #$18
		sta $64
		lda bufpnt
		eor #$01
		clc
		adc #$05
		sta $65
		rts

checksum:
		lda #$00
		sta check1
		sta check1+1
		sta check1+2
		sta check1+3
		ldy #$04
chk1:
		lda check1
		clc
		adc [$64],y
		sta check1
		bcc chk2
		inc check1+1
chk2:
		lda check1+2
		eor [$64],y
		sta check1+2
		lda check1+3
		rol
		rol check1+2
		rol check1+3
		iny
		cpy bufcount
		bne chk1
		ldy #$00
		lda check1
		sta [$64],y
		iny
		lda check1+1
		sta [$64],y
		iny
		lda check1+2
		sta [$64],y
		iny
		lda check1+3
		sta [$64],y
		rts

transmit:
		jsr reset
		lda #$00
		sta endflag
		sta skpdelay
		sta dontdash
		lda #$01
		sta bufpnt
		lda #$ff
		sta blocknum
		sta blocknum+1
		jsr altbuf
		ldy #$04
		lda #$07
		sta [$64],y
		jsr thisbuf
		ldy #$05
		lda #$00
		sta [$64],y
		iny
		sta [$64],y
tra1:
		jsr tranhand
		beq tra1
tra2:
		lda #$00
		sta $0200
		rts

recieve:
		jsr reset
		lda #$01
		sta blocknum
		lda #$00
		sta blocknum+1
		sta endflag
		sta bufpnt
		sta $051d
		sta $051e
		sta skpdelay
		lda #$07
		sta $051c
		lda #$01
rec1:
		jsr rechand
		lda endflag
		bne tra2
		jsr match
		bne rec5
		jsr clrchn
		lda bufcount
		cmp #$07
		beq rec3
		ldx #dfile
		jsr chkout
		ldy #$07
rec2:
		lda $0518,y
		jsr chrout
		jsr commbyte
		iny
		cpy bufcount
		bne rec2
		jsr clrchn
rec3:
		lda $051e
		cmp #$ff
		bne rec4
		lda #$01
		sta endflag
		bne rec4a
rec4:
		jsr goodblok
rec4a:
		jsr reset
		lda #1
		jmp rec1
rec5:
		jsr clrchn
		jsr badblok
		lda recsize
		sta $051c
		lda #2
		jmp rec1

match:
		lda $0518
		sta check
		lda $0519
		sta check+1
		lda $051a
		sta check+2
		lda $051b
		sta check+3
		jsr thisbuf
		lda recsize
		sta bufcount
		jsr checksum
		lda $0518
		cmp check
		bne mch1
		lda $0519
		cmp check+1
		bne mch1
		lda $051a
		cmp check+2
		bne mch1
		lda $051b
		cmp check+3
		bne mch1
		lda #$00
		rts
mch1:
		lda #$01
		rts

rectype:
		jsr reset
		lda #$00
		sta blocknum
		sta blocknum+1
		sta endflag
		sta bufpnt
		sta skpdelay
		lda #$07+$01
		sta $051c
		sta recsize
		lda #$01
rct1:
		jsr rechand
		lda endflag
		bne rct3
		jsr match
		bne rct2
		lda $051f
		sta filetyp
		lda #$01
		sta endflag
		lda #$01
		jmp rct1
rct2:
		lda recsize
		sta $051c
		lda #$02
		jmp rct1
rct3:
		lda #$00
		sta $0200
		rts

trantype:
		jsr reset
		lda #$00
		sta endflag
		sta skpdelay
		lda #$01
		sta bufpnt
		sta dontdash
		lda #$ff
		sta blocknum
		sta blocknum+1
		jsr altbuf
		ldy #$04
		lda #$07
		clc
		adc #$01
		sta [$64],y
		jsr thisbuf
		ldy #$05
		lda #$ff
		sta [$64],y
		iny
		sta [$64],y
		ldy #$07
		lda filetyp
		sta [$64],y
		lda #$01
		sta specmode
trt1:
		jsr tranhand
		beq trt1
		lda #$00
		sta $0200
		rts

dodelay:
		inc skpdelay
		lda skpdelay
		cmp #$03
		bcc dod1
		lda #$00
		sta skpdelay
		lda delay
		beq dod2
		rts
dod1:
		lda delay
		beq dod5
dod2:
		ldx #$78
		ldy #$00
dod4:
		dey
		bne dod4
		dex
		bne dod4
dod5:
		rts

prtdash:
		tax
		lda blocknum
		ora blocknum+1
		beq prd1
		lda dontdash
		bne prd1
		txa
		jsr dodash
prd1:
		rts

reset:
		jsr $ef7e
		lda $02a1
		cmp #$80
		beq reset
		cmp #$92
		beq reset
		rts

dodash:
		cmp #"*"
		beq dsh2
		cmp #"-"
		beq dsh1
		jmp badblok
dsh1:
		jmp goodblok
dsh2:
		rts

screen:
		tsx
		inx
		inx
		stx stack
		ldx #7
scr1:
		jsr $e9ff
		inx
		cpx #23
		bcc scr1
		ldy #0
scr2:
		lda #3
		sta $d918,y
		lda #7
		sta $da18,y
		iny
		bne scr2
		ldy #10
scr3:
		lda text1,y
		sta $720,y
		lda text2,y
		sta $748,y
		lda text3,y
		sta $770,y
		lda #1
		sta $db20,y
		sta $db48,y
		sta $db70,y
		dey
		bpl scr3
		ldy #11
scr3a:
		lda text4,y
		sta $72d,y
		lda #1
		sta $db2d,y
		dey
		bpl scr3a
		ldx #13
		ldy #4
		lda #34
		jsr putfnm
scr4:
		dey
		dey
		lda [$bb],y
		jsr putfnm
		iny
		iny
		iny
		cpy $b7
		bcc scr4
		lda #34
		jsr putfnm
		jsr nobytes
scr7:
		jmp setup

putfnm:
		jsr convert
		sta $748,x
		lda #1
		sta $db48,x
		inx
		rts

puterr:
		jsr convert
		sta $770,x
		lda #1
		sta $db70,x
		inx
		rts

convert:
		pha
		and #192
		beq convert1
		cmp #192
		beq convert1
		pla
		eor #64
		pha
convert1:
		pla
		and #127
		rts

nobytes:
		lda #0
		sta bytes
		sta bytes+1
		sta bytes+2
		sta blocks
		sta blocks+1
		sta bytec
		sta bytec+1
		rts

text1:
		byte "blocks:0000"
text2:
		byte "good:0000"
text3:
		byte " bad:0000"
text4:
		byte "bytes:000000"


bytes:
		byte 0,0,0
bytec:
		word 0
blocks:
		word 0
limit:
		byte 0
bitpnt:
		byte $20
bitcnt:
		byte $0f
bitpat:
		byte $04
tmer1:
		word $0000
gbsave:
		byte $00
bufcount:
		byte $07
delay:
		byte $00
skpdelay:
		byte $00
endflag:
		byte $00
check:
		word $0000,$0000
check1:
		word $0000,$0000
bufpnt:
		byte $00
recsize:
		byte $07
maxsize:
		byte $ff
blocknum:
		word $0000
stack:
		byte $f6
stack1:
		byte $f6
oldirqc:
		byte 0
oldirqc1:
		byte 0
oldtrans:
		byte 0
dontdash:
		byte $00
specmode:
		byte $00
codebuf:
		byte "   "
numx:
		byte 0

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
chkmark:
		lda #52
		jmp usetbl1

;increment byte count
commbyte:
		tya
		pha
		ldy #5
		ldx #$38
		jsr counter
		inc commcnt
		lda commcnt
		cmp #254
		bne cmb5
		lda #0
		sta commcnt
		ldx #$2a
		jsr counter0
		inc blocks
		bne cmb5
		inc blocks+1
cmb5:
		inc bytes
		bne cmb6
		inc bytes+1
		bne cmb6
		inc bytes+2
cmb6:
		pla
		tay
		rts
commcnt:
		byte 0

;increment good blocks
goodblok:
		ldx #$52
		jmp counter0
;increment bad blocks
badblok :
		ldx #$7a

counter0:
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

