include "equat.s"

org $c000, "proto6.prg"

t3 = 70

t1= 35 ;code accept timing
t2= 16 ;recieve timing
mfile = 131 ;modem file number
dfile = 2 ;disk file number
errch = 15 ;disk error channel

bsnpre = 765
bsnval = 766

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
reset = $4303

		jmp entry
		byte 6 ;proto 6

snpre:
		byte "A"
snval:
		word 3

entry:
		txa
		tsx
		stx stack
		tax
		lda #$37
		sta 1
		tya
		cpx #0
		beq jbuild ;0
		dex
		beq jaccept ;1
		dex
		beq jsend ;2
		dex
		beq jupname ;3
		dex
		beq jdnname ;4
		dex
		beq jupload ;3
		dex
		beq jdnload ;4
		rts

jbuild:
		jmp build
jsend:
		jmp nsendcod
jaccept:
		jmp naccept
jupname:
		jmp trantype
jdnname:
		jmp rectype
jupload:
		jmp transmit
jdnload:
		jmp receive

; check for code(s)
naccept:
		sta bitpat
		jsr reset
		lda #$00
		sta codebuf
		sta codebuf+1
		sta codebuf+2
nacc1:
		lda #$00
		sta tmer1
		sta tmer1+1
nacc2:
		jsr getnum
		bcs nacc5
nacc3:
		ldx codebuf+1
		stx codebuf
		ldx codebuf+2
		stx codebuf+1
		sta codebuf+2
		jsr nchkcod
		beq nacc1
		sec
		lda #$00
nacc4:
		rol
		dex
		bne nacc4
		and bitpat
		beq nacc2
		jsr getnum
		bcc nacc3
		lda #0
		sta $96
		jmp nacc7
nacc5:
		inc tmer1
		bne nacc6
		inc tmer1+1
nacc6:
		lda tmer1+1
		cmp #t3
		bne nacc2
		lda #1
		sta $96
nacc7:
		lda bitcnt
		sta var+1
		lda #0
		sta var
		ldx #30
		jmp putvar

nchkcod:
		ldx #8
nchc1:
		lda codebuf
		cmp nchar1-1,x
		bne nchc2
		lda codebuf+1
		cmp nchar2-1,x
		bne nchc2
		lda codebuf+2
		cmp nchar3-1,x
		beq nchc3
nchc2:
		dex
		bne nchc1
nchc3:
		stx bitcnt
		txa
		rts

;codes.........12345678
nchar1:
		byte "        "
nchar2:
		byte "        "
nchar3:
		byte "        "

nsendcod:
		pha
		ldx #mfile
		jsr chkout
		pla
		tax
		lda nchar1-1,x
		jsr chrout
		lda nchar2-1,x
		jsr chrout
		lda nchar3-1,x
		jsr chrout
		jsr clrchn
		ldx #1
		jmp tenwait
;build code table
build:
		ldx #8
		stx bitcnt
loop:
		ldx bitcnt
		jsr getln
		ldx bitcnt
		dex
		lda buffer
		sta nchar1,x
		lda buffer+1
		sta nchar2,x
		lda buffer+2
		sta nchar3,x
		dec bitcnt
		bne loop
		rts

; check carrier/abort
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
		jsr nobytes
ext2:
		rts

; get # bytes and exit
xfer1:
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
		bcs acc5
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
		jsr getnum
		bcc acc3
		lda #0
		sta $96
		rts
acc5:
		inc tmer1
		bne acc6
		inc tmer1+1
acc6:
		lda tmer1+1
		cmp #t1
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
		jsr chrout
		lda char2-1,x
		jsr chrout
		lda char3-1,x
		jsr chrout
		jsr clrchn
		ldx #1
		jmp tenwait

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

trh0:
		jmp ext1
tranhand:
		lda #$01
		sta delay
		lda #30
		sta repeat
trh1:
		dec repeat
		beq trh0
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
		lda #"*"
		jsr prtdash
		ldx #3
		jsr sendcode ;ack
		lda #%01000
		jsr accept ;s/b
		lda $96
		bne trh8
		lda #$0a
		sta bufcount
trh9:
		ldx #5
		jsr sendcode ;syn
		lda #%10000
		jsr accept ;syn
		lda $96
		bne trha
		dec bufcount
		bne trh9
trha:
		lda #3
		sta bufcount
trhb:
		ldx #4
		jsr sendcode ;s/b
		lda #%00000
		jsr accept ;just wait
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
		jmp clrchn
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
		lda tmer1+1
		cmp #t2
		bne rcm2
		lda #$02
		sta $96
		cpy #$00
		beq rcm7
		lda #$04
		sta $96
rcm7:
		jsr dodelay
		jmp clrchn
rcm8:
		lda #$08
		sta $96
		jmp clrchn

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
		ldy #7
dum1:
		jsr chrin
		sta [$64],y
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
		lda #<$0518
		sta $64
		lda bufpnt
		clc
		adc #>$0518
		sta $65
		rts

altbuf:
		lda #<$0518
		sta $64
		lda bufpnt
		eor #1
		clc
		adc #>$0518
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
		ldy #4
		lda #7
		sta [$64],y
		jsr thisbuf
		ldy #5
		lda #0
		sta [$64],y
		iny
		sta [$64],y
tra1:
		jsr tranhand
		beq tra1
tra2:
		jmp xfer1

receive:
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
		lda #7
		sta $051c
		lda #1
rec1:
		jsr rechand
		lda endflag
		bne tra2
		jsr match
		bne rec5
		lda bufcount
		cmp #7
		beq rec3
		ldx #dfile
		jsr chkout
		ldy #7
rec2:
		lda $0518,y
		jsr chrout
		iny
		cpy bufcount
		bne rec2
		jsr clrchn
rec3:
		lda $051e
		cmp #$ff
		bne rec4
		lda #1
		sta endflag
rec4:
		jsr goodblok
		jsr dobytes
		jsr reset
		lda #1
		jmp rec1
rec5:
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
		jsr screen
		jsr reset
		lda #$00
		sta blocknum
		sta blocknum+1
		sta endflag
		sta bufpnt
		sta skpdelay
		lda #7+150
		sta $051c
		sta recsize
		lda #1
rct1:
		jsr rechand
		lda endflag
		bne rct3
		jsr match
		bne rct2
		ldy #7
		ldx #2
		jsr buf2var ;b$
		lda #1
		sta endflag
		lda #1
		jmp rct1
rct2:
		lda recsize
		sta $051c
		lda #2
		jmp rct1
rct3:
		lda #0
		sta $0200
		rts

trantype:
		jsr screen
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
		ldy #4
		lda #7+150
		sta [$64],y
		jsr thisbuf
		ldy #5
		lda #$ff
		sta [$64],y
		iny
		sta [$64],y
		ldy #7
		ldx #2
		jsr var2buf ;b$
		lda #1
		sta specmode
trt1:
		jsr tranhand
		beq trt1
		lda #0
		sta $0200
		rts

var2buf:
		lda $64
		sta var2buf3+1
		lda $65
		sta var2buf3+2
		tya
		pha
		jsr usevar
		ldy #0
		pla
		tax
var2buf2:
		cpy var
		beq var2buf4
		lda [var+1],y
var2buf3:
		sta $ffff,x
		iny
		inx
		bne var2buf2
var2buf4:
		txa
		tay
		lda var2buf3+1
		sta $64
		lda var2buf3+2
		sta $65
		lda #13
		sta [$64],y
		iny
		rts

buf2var:
		txa
		pha
		tya
		tax
		ldy #0
buf2var1:
		lda $0518,x
		cmp #13
		beq buf2var2
		sta buffer,y
		iny
		inx
		bne buf2var1
buf2var2:
		inx
		txa
		pha
		tya
		jsr makerm1
		ldy #0
buf2var3:
		cpy var
		beq buf2var4
		lda buffer,y
		sta [var+1],y
		iny
		bne buf2var3
buf2var4:
		pla
		tax
		pla
		tay
		txa
		pha
		jsr putvar
		pla
		tay
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
		bne dod5
dod1:
		lda delay
		beq dod5
dod2:
		ldx #$00
dod3:
		ldy #$00
dod4:
		iny
		bne dod4
		inx
		cpx #$78
		bne dod3
dod5:
		rts

prtdash:
		pha
		lda blocknum
		ora blocknum+1
		beq prd1
		lda dontdash
		bne prd1
		pla
		jsr dodash
		pha
prd1:
		pla
		rts

dodash:
		sta dash
		cmp #"*"
		beq dsh2
		cmp #"-"
		beq dsh1
		jmp badblok
dsh1:
		jsr goodblok
dsh2:
		jmp dobytes

scr0:
		jmp ext1
screen:
		ldx #7
scr1:
		jsr $e9ff
		inx
		cpx #23
		bne scr1
		lda bsnpre-23,x
		cmp snpre-23,x
		bne scr0
		lda bsnval-23,x
		cmp snval-23,x
		bne scr0
		lda bsnval-22,x
		cmp snval-22,x
		bne scr0
		ldy #0
scr2:
		lda #0
		sta $d918,y
		lda #0
		sta $da18,y
		iny
		bne scr2
		ldy #9
scr3:
		lda text1,y
		sta $748,y
		lda text2,y
		sta $770,y
		lda #1
		sta $db48,y
		lda #1
		sta $db70,y
		dey
		bpl scr3
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
		byte "good:0000"
text2:
		byte " bad:0000"

dobytes:
		lda bufcount
		sec
		sbc #7
		pha
		clc
		adc bytes
		sta bytes
		bcc dobytes1
		inc bytes+1
		bne dobytes1
		inc bytes+2
dobytes1:
		pla
		clc
		adc bytec
		sta bytec
		bcs dobytes2
		inc bytec+1
dobytes2:
		lda bytec
		bne dobytes3
		lda bytec
		cmp #254
		bcs dobytes3
		rts
dobytes3:
		lda bytec
		sec
		sbc #254
		sta bytec
		lda bytec+1
		sbc #0
		sta bytec+1
		inc blocks
		bne dobytes4
		inc blocks+1
dobytes4:
		rts

bytes:
		byte 0,0,0
bytec:
		word 0
blocks:
		word 0
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
dontdash:
		byte $00
specmode:
		byte $00
dash:
		byte $00
codebuf:
		byte "   "
numx:
		byte 0
repeat:
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

;increment good blocks
goodblok:
		ldx #9
gdb1:
		inc $748,x
		lda $748,x
		cmp #$3a
		bne gdb2
		lda #$30
		sta $748,x
		dex
		bpl gdb1
gdb2:
		rts

;increment bad blocks
badblok :
		ldx #9
bdb1:
		inc $770,x
		lda $770,x
		cmp #$3a
		bne bdb2
		lda #$30
		sta $770,x
		dex
		bpl bdb1
bdb2:
		rts
