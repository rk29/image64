version = "9107098721"

include "equat.s"

org protostart, "punter.prg"

; modem file number
mfile = 131
; disk file number
dfile = 2
; disk error channel
errch = 15

;on entry:

; upload - file open to #dfile
; dnload - file open to #dfile
; multiup - an$=filename,t
; multidn - nothing special

;on exit:

; upload - a%=# blocks (0 = abort)
; ........ b%=# bad blocks
; ........ rc=# bytes sent
; dnload - a%=# blocks (0 = abort)
; ........ b%=# bad blocks
; ........ rc=# bytes received
; multiup -rc=1
; multidn -an$="filename,t" ""=end
; ........ rc=(1=ok, 0=aborted)

xxx = 0
goo = 1
bad = 2
ack = 3
snb = 4
syn = 5
iii = 6
ddd = 7
mjz = 8
okm = 9

gcount = 11
bcount = 23
ncount = 38
tcount = 16

pbuf0= $658
pbuf1= $400
pbuf2= $500
pbuf3= $630

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

ascii_ctrl_d = 4
ascii_ctrl_x = 24

; start - jump table
ml:
		lda defflag
		and #2
		inx
		beq protonum
		dex
		beq upload0 ;0
		dex
		beq dnload0 ;1
		dex
		beq multiup0 ;2
		dex
		beq multidn0 ;3
		dex
		beq setflag ;4
		bne getflag

defflag:
		byte 0
flagbyte:
		byte 0
versiond:
		byte version

;code accept
t1:
		byte 36,144
;receive timing
t2:
		byte 30,120

protonum:
		lda #0
		sta var
		lda #0
		sta var+1
		ldx #30
		jmp putvar ;a%

upload0:
		jsr screen
		jsr trantype
		jsr transmit
		jmp xfer1

dnload0:
		jsr screen
		jsr rectype
		jsr recieve
		jmp xfer1

multiup0:
		cmp #0
		beq multiu0a
		jsr screen
		jmp tranname
multiu0a:
		jsr multiup
		jmp xfer1

multidn0:
		cmp #0
		beq multid0a
		jsr screen
		jmp recname
multid0a:
		jsr multidn
		jmp xfer1

setflag:
		sty defflag
		rts
getflag:
		lda defflag
		sta var+1
		lda #0
		sta var
		ldx #30
		jmp putvar ;a%

; multi- send
multiup:
		jsr setup
		tsx
		stx stack
		jsr reset
		ldx #0
		jsr usevar ;an$
		lda var
		beq multiup2
		ldx #iii
		jsr sendcode
		ldx #5
		jsr tenwait
		ldx #mfile
		jsr chkout
		ldy #0
multiup1:
		lda [var+1],y
		jsr chrout
		iny
		cpy var
		bcc multiup1
		lda #13
		jsr chrout
		jsr clrchn
multiup3:
		jsr getnumx
		bcs multiup3
		bcc multiup4
multiup2:
		ldx #iii
		jsr sendcode
		ldx #5
		jsr tenwait
		ldx #ddd
		jsr sendcode
		ldx #mjz
		jsr sendcode
multiup4:
		lda #1
		sta bytes
		lda #0
		sta bytes+1
		sta bytes+2
		rts

;multi-recieve
multidn:
		jsr setup
		tsx
		stx stack
		jsr reset
		lda #0
		sta index
multidn1:
		jsr getnumx
		bcs multidn1
		cmp #ascii_ctrl_x
		beq multidn4
		cmp #ascii_ctrl_d
		beq multidn4
		cmp #ensh
		bne multidn1
multidn2:
		jsr getnumx
		bcs multidn2
		cmp #ascii_ctrl_x
		beq multidn4
		cmp #ascii_ctrl_d
		beq multidn4
		cmp #ensh
		beq multidn2
		lda $200
		sta buffer
		lda #1
		sta index
multidn3:
		jsr getnumx
		bcs multidn3
		ldy index
		cmp #ascii_ctrl_x
		beq multidn6
		cmp #ascii_ctrl_d
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
		ldx #0
		jsr putvar ;an$
		lda index
		beq multidn5
		ldx #okm
		jsr sendcode
multidn5:
		ldx #20
		jsr tenwait
		jmp multiup4
multidn6:
		lda #0
		sta index
		jmp multidn4
multidn7:
		jmp multiup4

; check carrier/abort
exit0:
		lda $28d
		cmp #2
		beq ext1
		lda carrier
		and #$10
		eor mxor
		bne ext1
		rts

exit:
		lda $28d
		cmp #2
		beq ext1
		lda carrier
		and #$10
		eor mxor
		beq ext2
ext1:
		ldx stack
		txs
		ldx #xxx
		jsr sendcode
ext0:
		lda #1
		sta irqcount
		jsr nobytes
ext2:
		rts

setup:
		lda #11
		sta irqcount
		ldx #16
		ldy #3
		jsr chkmark
		lda var+1
		sta oldtrans
		ldx #16
		ldy #0
		jsr chkmark
		lda defflag
		sta flagbyte
		rts

; get # bytes and exit
xfer1:
		lda #1
		sta irqcount
		ldx #16
		ldy oldtrans
		jsr chkmark
		lda blocks
		sta var+1
		lda blocks+1
		sta var
		ldx #30
		jsr putvar ;a%
		lda badblks
		sta var+1
		lda badblks+1
		sta var
		ldx #31
		jsr putvar ;b%
		lda bytes
		ldx bytes+1
		ldy bytes+2
		sta $64
		stx $63
		sty $62
		ldx #0
		stx $0d
		ldx #$98
		lda $62
		eor #$ff
		rol
		lda 1
		pha
		lda #$37
		sta 1
		lda #0
		sta $65
		jsr $bc4f
		pla
		sta 1
		lda $66
		ora #$7f
		and $62
		sta $62
		ldx #17
		jmp putvar ;rc

; check for code
accept:
		sta bitpat
		lda #$00
		sta codebuf
		sta codebuf+1
		sta codebuf+2
acc1:
		lda #$00
		sta jiffy
acc2:
		jsr getnumx
		bcs acc6
acc3:
		ldx codebuf+1
		stx codebuf
		ldx codebuf+2
		stx codebuf+1
		sta codebuf+2
		jsr chkcod
		beq acc1
		clc
		lda #1
acc4:
		rol
		dex
		bne acc4
		and bitpat
		beq acc2
		lda flagbyte
		and #1
		bne acc5
		jsr getnumx
		bcc acc3
acc5:
		lda #0
		sta $96
		rts
acc6:
		lda flagbyte
		and #1
		tax
		lda jiffy
		cmp t1,x
		bcc acc2
		lda #1
		sta $96
		rts

chkcod:
		ldx #syn
chc1:
		lda codebuf
		cmp char1,x
		bne chc2
		lda codebuf+1
		cmp char2,x
		bne chc2
		lda codebuf+2
		cmp char3,x
		beq chc3
chc2:
		dex
		bpl chc1
chc3:
		stx bitcnt
		txa
		cmp #xxx
		bne chc4
		jmp ext1
chc4:
		cmp #255
		rts

;codes.........01234567..8..9
char1:
		cbm ascii_ctrl_x, "gbass", ensh, ascii_ctrl_d, 13, "o"
char2:
		cbm ascii_ctrl_x, "oac/y", ensh, ascii_ctrl_d
		byte 10
		cbm "k"
char3:
		cbm ascii_ctrl_x, "odkbn", ensh, ascii_ctrl_d, 0, 13

sendcode:
		txa
		pha
		ldx #mfile
		jsr chkout
		pla
		tax
		lda char1,x
		jsr chrdly
		lda char2,x
		jsr chrdly
		lda char3,x
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
getnumx:
		jsr exit
getnum1:
		jsr displclk
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
		lda #1<<ack
		jsr accept
		beq rch3
		dec $62
		bne rch2
		jmp rch1
rch3:
		ldx #snb
		jsr sendcode
		lda endflag
		beq rch4
		lda gbsave
		cmp #goo
		beq rch6
rch4:
		lda pbuf1+4
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
		lda #1<<syn
		jsr accept
		bne rch3
		lda #$0a
		sta bufcount
rch7:
		ldx #syn
		jsr sendcode
		lda #1<<snb
		jsr accept
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
		ldx #goo
		jsr sendcode
trh2:
		lda #(1<<goo) | (1<<bad) | (1<<snb)
		jsr accept
		bne trh1
		lda #$00
		sta specmode
		lda bitcnt
		cmp #goo
		bne trh6
		lda endflag
		bne trh8
		inc blocknum
		bne trh3
		inc blocknum+1
trh3:
		jsr thisbuf
		ldy #6
		lda [$64],y
		cmp #$ff
		bne trh4
		lda #1
		sta endflag
		lda bufpnt
		eor #1
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
		ldx #ack
		jsr sendcode
		lda #1<<snb
		jsr accept
		bne trh5
		jsr thisbuf
		ldy #4
		lda [$64],y
		sta bufcount
		jsr altbuf
		ldx #mfile
		jsr chkout
		ldy #0
trh7:
		lda [$64],y
		jsr chrout
		iny
		cpy bufcount
		bne trh7
		jsr clrchn
		lda #0
		rts
trh8:
		ldx #ack
		jsr sendcode
		lda #1<<snb
		jsr accept
		bne trh8
		lda #10
		sta bufcount
trh9:
		ldx #syn
		jsr sendcode
		lda #1<<syn
		jsr accept
		beq trha
		dec bufcount
		bne trh9
trha:
		lda #3
		sta bufcount
trhb:
		ldx #snb
		jsr sendcode
		lda #0
		jsr accept
		dec bufcount
		bne trhb
		lda #1
		rts

recmodem:
		ldy #$00
rcm1:
		lda #$00
		sta jiffy
		sta toflag
rcm2:
		jsr getnumx
		lda $96
		bne rcm5
		lda $0200
		sta pbuf1,y
		cpy #$03
		bcs rcm3
		sta codebuf,y
		cpy #$02
		bne rcm3
		lda codebuf
		cmp #cbm("a")
		bne rcm3
		lda codebuf+1
		cmp #cbm("c")
		bne rcm3
		lda codebuf+2
		cmp #cbm("k")
		beq rcm4
rcm3:
		iny
		cpy bufcount
		bne rcm1
		lda #$01
		sta $96
		rts
rcm4:
		lda #1
		sta toflag
		jmp rcm2
rcm5:
		lda toflag
		beq rcm8
		lda flagbyte
		and #1
		tax
		lda jiffy
		cmp t2,x
		bcc rcm2
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
		ldy #5
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
		ldy #5
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
		lda bufpnt
		bne thisbuf1
thisbuf0:
		lda #<pbuf1
		sta $64
		lda #>pbuf1
		sta $65
		rts
thisbuf1:
		lda #<pbuf2
		sta $64
		lda #>pbuf2
		sta $65
		rts

altbuf:
		lda bufpnt
		beq thisbuf1
		bne thisbuf0

checksum:
		lda #$00
		sta check1
		sta check1+1
		sta check1+2
		sta check1+3
		ldy #4
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
		ldy #0
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
		lda #1
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
		sta [$64],y ;6
tra1:
		jsr tranhand
		beq tra1
tra2:
		lda #0
		sta $0200
		rts

recieve:
		jsr reset
		lda #1
		sta blocknum
		lda #0
		sta blocknum+1
		sta endflag
		sta bufpnt
		sta pbuf1+5
		sta pbuf1+6
		sta skpdelay
		lda #7
		sta pbuf1+4
		lda #goo
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
		lda pbuf1,y
		jsr chrout
		jsr commbyte
		iny
		cpy bufcount
		bne rec2
		jsr clrchn
rec3:
		lda pbuf1+6
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
		sta pbuf1+4
		lda #2
		jmp rec1

match:
		lda pbuf1
		sta check
		lda pbuf1+1
		sta check+1
		lda pbuf1+2
		sta check+2
		lda pbuf1+3
		sta check+3
		jsr thisbuf
		lda recsize
		sta bufcount
		jsr checksum
		lda pbuf1
		cmp check
		bne mch1
		lda pbuf1+1
		cmp check+1
		bne mch1
		lda pbuf1+2
		cmp check+2
		bne mch1
		lda pbuf1+3
		cmp check+3
		bne mch1
		lda #$00
		rts
mch1:
		lda #$01
		rts

rectype:
		lda defflag
		and #2
		beq rct0
		rts
rct0:
		jsr reset
		lda #$00
		sta blocknum
		sta blocknum+1
		sta endflag
		sta bufpnt
		sta skpdelay
		lda #8
		sta pbuf1+4
		sta recsize
		lda #goo
rct1:
		jsr rechand
		lda endflag
		bne rct3
		jsr match
		bne rct2
		lda pbuf1+7
		sta filetyp
		lda #$01
		sta endflag
		lda #goo
		jmp rct1
rct2:
		lda recsize
		sta pbuf1+4
		lda #bad
		jmp rct1
rct3:
		lda #0
		sta $0200
		rts

trantype:
		lda defflag
		and #2
		beq trt0
		rts
trt0:
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
		lda #8
		sta [$64],y ;4
		jsr thisbuf
		ldy #5
		lda #$ff
		sta [$64],y ;5
		iny
		sta [$64],y ;6
		lda filetyp
		iny
		sta [$64],y ;7
		lda #1
		sta specmode
trt1:
		jsr tranhand
		beq trt1
		lda #0
		sta $200
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
		jmp rsinabl

dodash:
		cmp #"-"
		beq dsh1
		jmp badblok
dsh1:
		jmp goodblok

screen:
		tsx
		inx
		inx
		stx stack
		ldy #0
scr2:
		lda #3
		sta pbuf1+$d400,y
		lda #7
		sta pbuf2+$d400,y
		iny
		bne scr2
		jsr nobytes
		jsr startclk
		jmp setup

nobytes:
		lda #0
		sta bytes
		sta bytes+1
		sta bytes+2
		sta blocks
		sta blocks+1
		sta badblks
		sta badblks+1
		rts

bytes:
		byte 0,0,0
blocks:
		word 0
badblks:
		word 0
limit:
		byte 0
bitpnt:
		byte $20
bitcnt:
		byte $0f
bitpat:
		byte $04
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
toflag:
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
		ldy #6
		ldx #ncount
		jsr counter
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
		inc blocks
		bne goodb1
		inc blocks+1
goodb1:
		ldx #gcount
		jmp counter0

;increment bad blocks
badblok:
		inc badblks
		bne badb1
		inc badblks+1
badb1:
		ldx #bcount

counter0:
		ldy #5
counter:
		inc pbuf0,x
		lda pbuf0,x
		cmp #":"
		bne counter1
		lda #"0"
		sta pbuf0,x
		dex
		dey
		bne counter
counter1:
		rts

recname:
		lda #$00
		sta blocknum
		sta blocknum+1
		sta endflag
		sta bufpnt
		sta skpdelay
		lda #7+18
		sta pbuf1+4
		sta recsize
		lda #goo
rcn1:
		jsr rechand
		lda endflag
		bne rcn5
		jsr match
		bne rcn4
		ldx #7
		ldy #0
rcn2:
		lda pbuf1+7,y
		beq rcn3
		sta buffer,y
		iny
		cpy #18
		bne rcn2
rcn3:
		sty var
		lda #<buffer
		sta var+1
		lda #>buffer
		sta var+2
		ldx #0
		jsr putvar
		lda #1
		sta endflag
		lda #1
		jmp rcn1
rcn4:
		lda recsize
		sta pbuf1+4
		lda #2
		jmp rcn1
rcn5:
		lda #0
		sta $0200
		rts

tranname:
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
		lda #7+18
		sta [$64],y
		jsr thisbuf
		ldy #5
		lda #$ff
		sta [$64],y
		iny
		sta [$64],y
		lda $64
		pha
		lda $65
		pha
		ldx #0
		jsr usevar ;an$
		ldy #0
		cpy var
		beq trn2
trn1:
		lda [var+1],y
		sta buffer,y
		iny
		cpy #18
		bcc trn1
trn2:
		sty index
		pla
		sta $65
		pla
		sta $64
		ldx #0
		ldy #7
trn3:
		cpy index
		beq trn4
		lda buffer,x
		sta [$64],y
		iny
		inx
		bne trn3
trn4:
		cpx #18
		beq trn5
		lda #0
		sta [$64],y
		inx
		iny
		bne trn4
		lda #1
		sta specmode
trn5:
		jsr tranhand
		beq trn5
		lda #0
		sta $0200
		rts

startclk:
		lda #0
		ldy #3
startcl1:
		sta $dd08,y
		dey
		bpl startcl1
		rts

displclk:
		pha
		txa
		pha
		tya
		pha
		ldx #0
		ldy #3
displcl1:
		lda $dd08,y
		pha
		lsr
		lsr
		lsr
		lsr
		jsr displcl3
		pla
		and #15
		jsr displcl3
		dey
		beq displcl2
		lda #":"
		jsr displcl4
		jmp displcl1
displcl2:
		lda $dd08
		pla
		tay
		pla
		tax
		pla
		rts
displcl3:
		ora #$30
displcl4:
		sta pbuf3+tcount,x
		inx
		rts
