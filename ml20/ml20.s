revision = 1
version_string = "06/07/91 03:42p"
serial = $1003 ; "A0003"

include "equat.s"

org $6c00, "ml20.prg"

; $0c00 - wedge

offset $0c00-*
namespace "wedge"

; jump table

; xx00: install w/o error trap
; xx03: install w/error trap
; xx06: load after filename is set
; xx09: save array pointers
; xx0c: restore array pointers

start:
		jmp install
		jmp install0
		jmp openroom
		jmp arraysv0
		jmp arrayrs0
		jmp collect
wgone0:
		jmp wgone
weval0:
		jmp weval
wtrap0:
		jmp wtrap

tload:
		jsr collect
		jsr chrget
		jsr getfile
		jsr openroo1
		jmp gone2

openroom:
		jsr collect
		lda $ba
		sta $49
openroo1:
		ldx $31
		ldy $32
		stx $ac
		sty $ad
		ldx $33
		ldy $34
		stx $ae
		sty $af
		stx $31
		sty $32
		ldx #$2f
		jsr oprm
		ldx #$2d
		jsr oprm

loadfile:
		lda #8
		ldx $49
		ldy #0
		jsr setlfs
		jsr openf
		ldx #8
		jsr chkin
		jsr chrin
		jsr chrin
		jsr chrin
		jsr chrin
		jsr chrin
		sta l1
		jsr chrin
		sta l2
		jsr clrchn
		lda #8
		jsr closef
		jsr scan0
		lda #8
		ldx $49
		ldy #0
		jsr setlfs
		lda #0
		ldx $ae
		ldy $af
		jsr loadf
		bcc loadfil1
		jsr chopfile
loaderr:
		ldx #29
		jmp error
loadfil1:
		jsr linkprg

chopfile:
		ldx #<65535
		ldy #>65535
chopfil1:
		stx l1
		sty l2
		jsr scan0
		ldy #0
		tya
		sta [$ae],y
		iny
		sta [$ae],y
		clc
		lda #2
		adc $ae
		sta $ae
		lda #0
		adc $af
		sta $af

closroom:
		ldx $2d
		ldy $2e
		stx $ac
		sty $ad
		ldx $ae
		ldy $af
		stx $2d
		sty $2e
		ldx #$2f
		jsr clrm
		ldx #$31

clrm:
		sei
		ldy #0
		lda 0,x
		sta $b0
		lda 1,x
		sta $b1
clrm1:
		lda [$ac],y
		sta [$ae],y
		lda $ac
		cmp 0,x
		bne clrm0
		lda $ad
		cmp 1,x
		beq clrm4
clrm0:
		inc $ac
		bne clrm2
		inc $ad
clrm2:
		inc $ae
		bne clrm3
		inc $af
clrm3:
		jmp clrm1
clrm4:
		lda $ae
		sta 0,x
		lda $af
		sta 1,x
		cli
		rts

scan0:
		ldx $2b
		ldy $2c
		stx $ae
		sty $af
		stx $ac
		sty $ad
scan1:
		ldy #3
		lda [$ae],y
l2 = *+1
		cmp #0
		bne scan2
		dey
		lda [$ae],y
l1 = *+1
		cmp #0
		beq scan3
scan2:
		lda $ae
		ldx $af
		sta $ac
		stx $ad
		ldy #1
		lda [$ae],y
		tax
		dey
		lda [$ae],y
		cpx #0
		beq scan3
		sta $ae
		stx $af
		jmp scan1
scan3:
		rts

oprm:
		sei
		ldy #0
		lda 0,x
		sta $b0
		lda 1,x
		sta $b1
oprm1:
		lda $ac
		cmp 0,x
		bne oprm0
		lda $ad
		cmp 1,x
		beq oprm4
oprm0:
		lda $ac
		bne oprm2
		dec $ad
oprm2:
		dec $ac
		lda $ae
		bne oprm3
		dec $af
oprm3:
		dec $ae
		lda [$ac],y
		sta [$ae],y
		jmp oprm1
oprm4:
		lda $ae
		sta 0,x
		lda $af
		sta 1,x
		cli
		rts

pokefix:
		lda $15
		cmp #$40
		bcc pokefix1
		cmp #$43
		bcc pokefix0
		cmp #$46
		bcc pokefix1
		cmp #$4a
		bcs pokefix1
		sec
		sbc #$03
pokefix0:
		sec
		sbc #$30
		sta $15
pokefix1:
		rts

tpoke:
		jsr chrget
		jsr getnum
		jsr pokefix
		ldy #0
		txa
		sta [$14],y
		jmp gone2

tsys:
		jsr chrget
		jsr frmnum
		jsr getadr
		lda $15
		cmp #$ff
		beq tsys1
		cmp #$c0
		beq tsys1
		jmp ilqerr
tsys1:
		jsr syscll
		jmp gone2

tnew:
		jsr chrget
		jsr linget
		ldx $14
		ldy $15
		jsr chopfil1
		jmp gone2

thex:
		ldx #0
		stx $62
		stx $63
thex1:
		jsr chrget
		bcc thex2
		cmp #cbm("g")
		bcs thex5
		cmp #cbm("a")
		bcc thex5
		sbc #7
thex2:
		and #$f
		ldx #4
thex3:
		asl $63
		rol $62
		bcs thex4
		dex
		bne thex3
		ora $63
		sta $63
		bcc thex1
thex4:
		jmp ilqerr
thex5:
		ldx #$90
		sec
		jmp retval

tpeek:
		jsr chrget
		jsr parchk
		lda $14
		pha
		lda $15
		pha
		jsr getadr
		jsr pokefix
		ldy #0
		lda [$14],y
		tay
		pla
		sta $15
		pla
		sta $14
		jmp retbyt

tampr:
		jsr chrget
		jsr getaxy
		jsr usetbl1
		jmp gone2

wgone:
		lda 51
		cmp 49
		lda 52
		sbc 50
		bne wgone1
		jsr collect
		lda 51
		cmp 49
		lda 52
		sbc 50
		bne wgone1
; less than 256 bytes free, force
; out of memory error for safety
		ldx #1
		jsr arrayrs0
		ldx #16
		jmp error ;outofm
wgone1:
		lda #$36
		sta 1
		jsr trace
		lda #$37
		sta 1
		jsr chrget
		cmp #cbm("&")
		beq ampr0
		cmp #poketok
		beq poke0
		cmp #systok
		beq sys0
		cmp #loadtok
		beq load0
		cmp #newtok
		beq new0
		jsr chrgot
		jmp gone1

weval:
		jsr chrget
		ldx #0
		stx $d
		cmp #cbm("$")
		beq hex0
		cmp #peektok
		beq peek0
		jsr chrgot
		jmp eval1

ampr0:
		jmp tampr
poke0:
		jmp tpoke
sys0:
		jmp tsys
load0:
		jmp tload
new0:
		jmp tnew
hex0:
		jmp thex
peek0:
		jmp tpeek

getaxy:
		jsr getparm
		stx 780
		jsr getparm
		stx 781
		jsr getparm
		stx 782
		lda 780
		ldx 781
		ldy 782
		rts

getparm:
		jsr chrgot
		ldx #0
		cmp #cbm(",")
		bne getparm1
		jsr getbytc
getparm1:
		rts

wtrap:
		stx $030c
		lda $39
		sta $030d
		lda $3a
		sta $030e
		lda #<$e38b
		sta $300
		lda #>$e38b
		sta $301
		ldx #$fa
		txs
		lda #25
		sta 22
		lda #<trapline
		sta $14
		lda #>trapline
		sta $15
		jsr $a8a3
		jmp $a7ae

install:
		lda #<$e38b
		ldx #>$e38b
		jmp install1
install0:
		lda #<wtrap0
		ldx #>wtrap0
install1:
		sta $300
		stx $301
		lda #<wgone0
		ldx #>wgone0
		sta $308
		stx $309
		lda #<weval0
		ldx #>weval0
		sta $30a
		stx $30b
		rts

arrayoff:
		txa
		and #7
		asl
		asl
		tax
		ldy #2
		rts

;* copy pointers for arrays *
arraysv0:
		jsr arrayoff
arsv1:
		sec
		lda $2f,y
		sbc $2d
		sta arryptrs+0,x
		lda $30,y
		sbc $2e
		sta arryptrs+1,x
		inx
		inx
		dey
		dey
		bpl arsv1
		rts

;* restore pointers for arrays *
arrayrs0:
		lda $2f
		sta $ac
		lda $30
		sta $ad
		jsr arrayoff
arrs1:
		clc
		lda arryptrs+0,x
		adc $2d
		sta $2f,y
		lda arryptrs+1,x
		adc $2e
		sta $30,y
		inx
		inx
		dey
		dey
		bpl arrs1
		lda $2f
		sta $ae
		lda $30
		sta $af
		ldy #0
		beq arrs2
arrs3:
		inc $ac
		bne arrs3a
		inc $ad
arrs3a:
		inc $ae
		bne arrs2
		inc $af
arrs2:
		lda [$ac],y
		sta [$ae],y
		lda $ae
		cmp $31
		bne arrs3
		lda $af
		cmp $32
		bne arrs3
		rts

collect:
		lda #>gc
		ldy #>gchide
		ldx #gclen
		jsr swapper
		jsr gc
		jmp swapagn

offset 0
namespace ""

; pad to the start of the next module
		dup 0,$7000-*

; $d000 - editor

editor_version = "01/22/91 06:51p"

offset $1800-*
namespace "editor"

;* editor sub-system


temp = $6f
temp1 = $5f
temp2 = $60
delx = $52
numx = $14
numy = $15

		jmp entry1 ;no text
		jmp entry2 ;re-enter main
		jmp entry3 ;re-enter not command

;exits:

; .x=0 - aborted
; .x=1 - save .a=lines
; .x=2 - command typed .a=char
; .x=3 - help command


done:
		sta 780
		stx 781
		sty 782
		ldx stack
		txs
		ldy #0
		sty mci
		lda 780
		ldx 781
		ldy 782
		rts

passflag:
		byte 0

entry2:
		lda case
		sta case1
		lda #0
		sta passflag
		jmp main

entry1:
		lda case
		sta case1
		jsr cleartt
		lda #1
		sta cline
		sta mline
		lda #0
		sta passflag

main0:
		jsr prcolor
		jsr prcr

main:
		tsx
		stx stack
		lda #0
		sta mci
		jsr doline
		lda #0
		sta mjump
		sta mprint
		sta mspeed

getc1:
		lda mline
		cmp lines
		beq getc2
		bcs command

getc2:
		ldx modes
		ldy passflag
		jsr inline
		lda chat
		beq ret
getc3:
		cmp #1
		bne getc4 ;dot
		jmp command
getc4:
		cmp #3
		bne ret ;drop
drop:
		ldx #0
		jmp done

ret:
		jsr line
		jmp main
command:
		jmp dodot

xdels:
		cpx #0
		bne xdel1
		rts
xdel1:
		jsr prdel
		dex
		jmp xdels

line:
		ldx mline
		cpx lines
		bcc line1
		beq line1
		rts
line1:
		lda flags
		and #1
		beq store
insln:
		ldx cline
		jmp inslnx
store:
		ldx cline
		jsr putlnx
		inc cline
		inc mline
		rts

dotmsg:
		byte 8
		cbm "Command:"
dodot:
		lda #0
		sta passflag
		lda dotmsg
		ldx #<(dotmsg+1)
		ldy #>(dotmsg+1)
		jsr prmsg
		lda flags
		and #1
		beq com1
		lda #cbm("x")
		ldx #0
		beq getcom0
com1:
		jsr xgetin
		and #$7f
		sta comchar
		ldx #4
		ldy #5
		jsr chkflags
		bne com2
		lda carrst
		and #127
		beq com2
		jmp drop
com2:
		lda comchar
		cmp #cbm(".")
		bne getcom0
		ldx dotmsg
		jsr xdels
		lda #cbm(".")
		jmp getc1
entry3:
		ldx dotmsg
		jsr xdels
		jmp getc1
getcom0:
		cmp #20
		beq entry3
		ldx #0
		tay
getcom:
		lda comlist,x
		beq gotcom0
		tya
		cmp comlist,x
		beq gotcom
		txa
		clc
		adc #6
		tax
		jmp getcom
gotcom0:
		tya
		ldx #2
		jmp done
gotcom:
		stx compoint
		lda comlist+1,x
		and #1
		beq gotcom1
		ldy mline
		dey
		bne gotcom1
		jmp com1
gotcom1:
		lda comlist+4,x
		sta comjump+1
		lda comlist+5,x
		sta comjump+2
		lda comlist+3,x
		tay
		lda comlist+2,x
		tax
		jsr prmsg3
		ldx compoint
		lda comlist+1,x
		and #%1110
		tax
		lda paramrtn,x
		sta prmjump+1
		lda paramrtn+1,x
		sta prmjump+2
		lda #0
		sta comflag
prmjump:
		jsr $ffff
comjump:
		jsr $ffff
		jmp main0
stack:
		byte 0
comchar:
		byte 0
compoint:
		byte 0
comflag:
		byte 0

; offset 1 in comlist is %aaab
; aaa= which parameter routine
; b= dissallow if buffer empty

paramrtn:
		word getcr ;000x
		word lastline ;001x
		word alllines ;010x
		word firstlin ;011x
		word gettxm ;100x
		word getzero ;101x
		word nothing ;110x
		word prcr ;111x

comlist:

		byte cbm("a"),%0000
		word tabrt,abort
		byte cbm("b"),%1000
		word tbnnr,banner
		byte cbm("c"),%1010
		word tmrgn,margin
		byte cbm("d"),%0011
		word tdele,delet
		byte cbm("e"),%0011
		word tedit,editlns
		byte cbm("f"),%0101
		word tfind,find
		byte cbm("h"),%1110
		word thelp,help
		byte cbm("i"),%0111
		word tinst,insert
		byte cbm("j"),%1101
		word tjust,justify
		byte cbm("k"),%0101
		word trepl,repl
		byte cbm("l"),%0101
		word tlist,clist
		byte cbm("m"),%0101
		word tmcir,mciread
		byte cbm("n"),%0001
		word tclrt,clrtx
		byte cbm("o"),%1100
		word tline,linnum
		byte cbm("r"),%0101
		word tread,cread
		byte cbm("s"),%0001
		word tsave,csave
		byte cbm("t"),%1110
		word ttext,ctext
		byte cbm("v"),%1110
		word tvers,cvers
		byte cbm("x"),%1100
		word texit,exit
		byte cbm("y"),%0011
		word tmove,cmove
		byte cbm("z"),%0011
		word tcopy,ccopy
		byte ensh,%1110
		word thelp,help
		byte cbm("#"),%1110
		word tscal,scale
		byte 0

tabrt:
		cbm "Abort",0
tbnnr:
		cbm "Banner",0
tdele:
		cbm "Delete",0
tedit:
		cbm "Edit",0
tfind:
		cbm "Find",0
thelp:
		cbm "Help!",0
tinst:
		cbm "Insert",0
tjust:
		cbm "Justify (C,E,I,L,P,R,U)",0
trepl:
		cbm "Replace",0
tlist:
		cbm "List",0
tmcir:
		cbm "MCI Read",0
tclrt:
		cbm "Clear Text",0
tread:
		cbm "Read",0
tsave:
		cbm "Save Text",0
ttext:
		cbm "Text Transfer On",0
texit:
		cbm "Exit",0
tline:
		cbm "Line Numbers",0
tmrgn:
		cbm "Columns",0
tcopy:
		cbm "Copy",0
tmove:
		cbm "Move",0
tscal:
		cbm "Scale",0
tvers:
		cbm "Version",0

;get params/default to last line
lastline:
		ldx mline
		dex
		txa
		tay
		jmp getxy

;get params/default to all lines
alllines:
		ldx #1
		ldy mline
		dey
		jmp getxy

;get param/default to 1st line
firstlin:
		ldx #1
		jmp getx

;no parameters/instant command
nothing:
		rts

;get param/default to zero
getzero:
		ldx #0
		jmp getnum

abort:
		lda #0
		ldx #0
		jmp done

banchr:
		stx tmpx1
		ldx index
		cpx #78
		bcs banchr1
		sta buffer,x
		inc index
banchr1:
		ldx tmpx1
		rts

banner:
		lda index
		beq banner5
		ldy #0
loop:
		lda buffer,y
		jsr convert
		sta buf2,y
		iny
		cpy index
		bcc loop
		sty blen
		ldx #0
banner1:
		ldy #0
		sty index
		lda #reverse_off
		sta rvsflag
banner2:
		lda buf2,y
		pha
		and #127
		cmp #32
		pla
		bcs banner3
		jsr banchr
		jmp banner4
banner3:
		jsr quad
banner4:
		iny
		cpy blen
		bcc banner2
		lda #reverse_off
		jsr banchr
		stx tmpx
		ldx mline
		cpx lines
		bcs banner5
		jsr putlnx
		inc mline
		inc cline
		ldx tmpx
		inx
		cpx #4
		bcc banner1
banner5:
		rts
blen:
		byte 0

delet:
		ldx #<delmsg1
		ldy #>delmsg1
		jsr prmsg3
dele2:
		lda numx
		cmp numy
		beq dele3
		lda #cbm("s")
		jsr xchrout
		jsr prspc
		lda numx
		jsr prtnum
		ldx #<delmsg2
		ldy #>delmsg2
		jsr prmsg3
dele3:
		jsr prspc
		lda numy
		jsr prtnum
dele4:
		ldx #<delmsg3
		ldy #>delmsg3
		jsr prmsg3
		jmp dellns
delet1:
		jmp dontdo
delmsg1:
		cbm "(Line",0
delmsg2:
		cbm " To",0
delmsg3:
		cbm " Deleted.)",13,0

find:
		inc comflag
		ldx #<tfind1
		ldy #>tfind1
		jsr prmsg3
		jsr gettxm
		ldy index
		beq find2
		ldy #0
findloop:
		lda buffer,y
		sta buf2,y
		iny
		cpy index
		bne findloop
		sty flen
		lda #$81
		sta mci
		lda #$80
		sta flag1
		jsr findlns
find2:
		rts

tfind1:
		cbm "Search Phrase:",0

repl:
		inc comflag
		ldx #<trepl1
		ldy #>trepl1
		jsr prmsg3
		jsr gettxm
		ldy index
		beq repl2
		ldy #0
replloop:
		lda buffer,y
		sta buf2,y
		iny
		cpy index
		bne replloop
		sty flen
		ldx #<trepl2
		ldy #>trepl2
		jsr prmsg3
		jsr gettxm
		ldy #0
		cpy index
		beq repl3
		cpy index
		beq repl3
replloop2:
		lda buffer,y
		sta 512,y
		iny
		cpy index
		bne replloop2
repl3:
		sty rlen
		lda #$81
		sta mci
		lda #$80
		sta flag1
		jsr repllns
repl2:
		rts

trepl1:
		cbm "Search Phrase:",0
trepl2:
		cbm "Replace With :",0

help:
		ldx #3
		jmp done

insert:
		ldx numx
		beq insert1
		cpx mline
		bcs insert1
		stx cline
		lda flags
		ora #1
		sta flags
insert1:
		rts

justify:
		jsr xgetin
		and #$7f
		ldx #$ff
		cmp #cbm("c")
		bne justif0a
		ldx #0
justif0a:
		cmp #cbm("e")
		bne justif0b
		ldx #1
justif0b:
		cmp #cbm("p")
		bne justif0c
		ldx #2
justif0c:
		cmp #cbm("l")
		bne justif0d
		ldx #3
justif0d:
		cmp #cbm("r")
		bne justif0e
		ldx #4
justif0e:
		cmp #cbm("i")
		bne justif0f
		ldx #5
justif0f:
		cmp #cbm("u")
		bne justif0g
		ldx #6
justif0g:
		cpx #$ff
		bne justify1
justif0:
		jmp dontdo

tcen:
		cbm "Center",0
texp:
		cbm "Expand",0
tpak:
		cbm "Packed",0
tlft:
		cbm "Left",0
trgt:
		cbm "Right",0
tind:
		cbm "Indent",0
tund:
		cbm "Un-Indent",0

justcom:
		byte 0
justtxt:
		word tcen,texp,tpak,tlft
		word trgt,tind,tund
justcoms:
		word jcenter,jexpand
		word jpacked,jleft
		word jright,jindent
		word jundent

justify1:
		stx justcom
		ldx #15
		jsr xdels
		ldx justcom
		txa
		asl
		tay
		lda justtxt,y
		tax
		lda justtxt+1,y
		tay
		jsr prmsg3
		lda justcom
		asl
		tay
		lda justcoms+1,y
		tax
		lda justcoms,y
		jmp repjust

clist:
		lda #$81
		sta mciflg
		lda #$80
		sta flag1
		jmp read0

mciread:
		lda #$00
		sta mciflg
		lda #$00
		sta flag1
		lda #$01
		sta wrapfl
		jmp read0

clrtx:
		ldx stack
		txs
		jmp entry1

cread:
		lda #$81
		sta mciflg
		lda #$00
		sta flag1
read0:
		jsr prcr
		lda mciflg
		sta mci
		jsr prtlns
		lda #0
		sta wrapfl
		lda #0
		sta mci
		rts
read1:
		jmp dontdo
mciflg:
		byte 0
wrapfl:
		byte 0

csave:
		lda cline
		ldx #1
		jmp done

ctext:
		lda #2
		sta passflag
		rts

exit:
		lda flags
		and #1
		beq exit1
		lda mline
		sta cline
		lda flags
		and #$fe
		sta flags
		jmp prcr
exit1:
		jmp dontdo

linnum:
		lda flags
		eor #2
		sta flags
		and #2
		beq proff
		ldy #0
		beq pr1
proff:
		ldy #6
pr1:
		lda msg4,y
		beq pr2
		jsr xchrout
		iny
		bne pr1
pr2:
		rts
msg4:
		cbm " On.",13,0
		cbm " Off.",13,0

margin:
		ldx numx
		cpx #81
		bcs margin1
		cpx #22
		bcc margin1
		dex
		dex
		stx llen
margin1:
		ldx #<marmsg
		ldy #>marmsg
		jsr prmsg3
mar2:
		ldx llen
		inx
		inx
		txa
		jsr prtnum
		jmp prcr
marmsg:
		cbm "Set To: ",0

ccopy:
		ldx #<cpymsg
		ldy #>cpymsg
		jsr prmsg3
		lda numx
		pha
		ldx mline
		jsr getnumm
		lda numx
		beq copy1
		cmp mline
		beq copy0a
		bcs copy1
copy0a:
		sta cline
		pla
		sta numx
		ldx cline
		cpx numx
		bcc copy0
		dex
		cpx numy
		bcc copy1
copy0:
		jmp cpylns
copy1:
		lda mline
		sta cline
		jmp dontdo
cpymsg:
		cbm "Copy To:",0

cmove:
		ldx #<movmsg
		ldy #>movmsg
		jsr prmsg3
		lda numx
		pha
		ldx mline
		jsr getnumm
		lda numx
		beq move1
		cmp mline
		beq move0a
		bcs move1
move0a:
		sta cline
		pla
		sta numx
		ldx cline
		cpx numx
		bcc move0
		dex
		cpx numy
		bcc move1
move0:
		jmp movlns
move1:
		lda mline
		sta cline
		jmp dontdo
movmsg:
		cbm "Move To:",0

scale:
		lda #scalelen
		ldx #<scalemsg
		ldy #>scalemsg
		jmp prmsg0
scalemsg:
		byte function_key_6
		byte british_pound, "_101"
		byte british_pound, "_202"
		byte british_pound, "_303"
		byte function_key_6
		cbm "0123456789012345678901234567890123456789"
		byte function_key_6
scalelen = * - scalemsg

cvers:
		lda #verslen
		ldx #<versmsg
		ldy #>versmsg
		jmp prmsg0
versmsg:
		byte function_key_6
		cbm "Image 1.3 Editor ("+editor_version+")"
		byte function_key_6
verslen = *-versmsg

delc:
		sty temp
		cpy index
		beq delc2
delc1:
		lda buffer+1,y
		sta buffer,y
		iny
		cpy index
		bcc delc1
delc2:
		ldy index
		beq delc3
		dec index
delc3:
		ldy temp
		rts

insc:
		sty temp
		ldy index
		beq insc2
		cpy temp
		bcc insc2
		cpy llen
		bcs insc3
insc1:
		lda buffer,y
		sta buffer+1,y
		dey
		cpy temp
		bpl insc1
insc2:
		inc index
insc3:
		ldy temp
		lda #cbm(" ")
		sta buffer,y
		rts

repjust:
		sta jump+1
		stx jump+2
		lda delx
		clc
		adc #8
		sta delx
		jsr alllines
doj0:
		ldx numx
		dex
		cpx numy
		bcs doj2
		inx
		jsr getlnx
		ldx index
		beq doj1
		dex
		cpx llen
		bcs doj1
		lda index
		jsr jump
		ldx numx
		jsr putlnx
doj1:
		ldx numx
		cpx numy
		beq doj2
		inc numx
		bne doj0
doj2:
		ldx #<jdone
		ldy #>jdone
		jmp prmsg3
jump:
		jmp $ffff
jdone:
		cbm "Done.",0

jleft:
		lda index
		beq jleft1
		lda buffer
		cmp #cbm(" ")
		bne jleft1
		ldy #0
		jsr delc
		jmp jleft
jleft1:
		rts

jright:
		lda index
		cmp llen
		bcs jright1
		ldy #$00
		jsr insc
		jmp jright
jright1:
		rts

jcenter:
		jsr jleft
		lda llen
		sec
		sbc index
		beq jcenter2
		bcc jcenter2
		ldy #$00
		lsr
		tax
jcenter1:
		jsr insc
		dex
		bne jcenter1
jcenter2:
		rts

jpacked:
		jsr jleft
		lda index
		beq jpacked4
		ldy #$00
jpacked1:
		lda buffer,y
		iny
		cmp #cbm(" ")
		bne jpacked2
		cpy index
		bcs jpacked3
		bcs jpacked3
		lda buffer,y
		cmp #cbm(" ")
		bne jpacked2
		dey
		jsr delc
jpacked2:
		cpy index
		bcc jpacked1
jpacked3:
		ldy index
		beq jpacked4
		dey
		beq jpacked4
		lda buffer,y
		cmp #cbm(" ")
		bne jpacked4
		sty index
jpacked4:
		rts

jexpand:
		jsr jpacked
jexpand1:
		ldx #$00
		lda index
		cmp llen
		bcs jexpand5
		ldy #$00
jexpand2:
		lda buffer,y
		cmp #cbm(" ")
		bne jexpand4
		jsr insc
		inx
		lda index
		cmp llen
		bcs jexpand5
jexpand3:
		lda buffer,y
		cmp #cbm(" ")
		bne jexpand4
		iny
		cpy index
		bcc jexpand3
		bcs jexpand1
jexpand4:
		iny
		cpy index
		bcc jexpand2
		cpx #$00
		beq jexpand5
		cpy index
		bcs jexpand1
jexpand5:
		rts

jindent:
		ldy #0
		jmp insc
jundent:
		ldy #0
		jmp delc

prtlns:
		lda mciflg
		sta mci
		ldx numx
		jsr prtlnx
		lda chat
		bne prtln1
		ldx numx
		cpx numy
		beq prtln1
		inc numx
		bne prtlns
prtln1:
		rts

prtlnx:
		txa
		pha
		lda flag1
		bpl prtlnx1
		txa
		jsr prtnum
		jsr prcol
		jsr prcr
prtlnx1:
		lda wrapfl
		beq prtlnx2
		lda #129
		sta var
		lda #0
		sta var+1
		sta var+2
		sta var+3
		sta var+4
		ldx #15
		jsr putvar ;lp
prtlnx2:
		pla
		tax
		jsr prtln
		lda wrapfl
		bne prtlnx3
		jsr prcr
prtlnx3:
		rts

findlns:
		ldx numx
		jsr getlnx
		ldx #0
		stx ftmpx
findln5:
		ldy #0
findln2:
		lda buffer,x
		cmp buf2,y
		bne findln3
		iny
		cpy flen
		bcs findln6
		inx
		cpx index
		bcc findln2
findln3:
		inc ftmpx
		ldx ftmpx
		cpx index
		bcc findln5
findln7:
		inc numx
		ldx numx
		dex
		cpx numy
		bcc findlns
		rts
findln6:
		ldx numx
		jsr prtlnx
		jmp findln7
flen:
		byte 0
ftmpx:
		byte 0
rtmpx:
		byte 0
rlen:
		byte 0
fflg:
		byte 0

repllns:
		ldx numx
		jsr getlnx
		ldx #0
		stx ftmpx
		stx fflg
replln5:
		ldy #0
replln2:
		lda buffer,x
		cmp buf2,y
		bne replln3
		iny
		cpy flen
		bcs replln6
		inx
		cpx index
		bcc replln2
replln3:
		inc ftmpx
		ldx ftmpx
		cpx index
		bcc replln5
replln7:
		lda fflg
		beq repllna
		ldx numx
		jsr prtlnx
repllna:
		inc numx
		ldx numx
		dex
		cpx numy
		bcc repllns
		rts
replln6:
		lda fflg
		bne replln9
		ldx numx
		jsr prtlnx
replln9:
		inc fflg
		ldx numx
		jsr getlnx
		lda index
		sec
		sbc flen
		clc
		adc rlen
		cmp llen
		bcs replln1
		ldx flen
replln_loop1:
		stx rtmpx
		cpx #0
		beq replln4
		ldy ftmpx
		jsr delc
		ldx rtmpx
		dex
		bne replln_loop1
replln4:
		ldx rlen
		beq replln8
		dex
replln_loop2:
		stx rtmpx
		cpx #0
		bmi replln8
		ldy ftmpx
		jsr insc
		ldx rtmpx
		lda 512,x
		ldy ftmpx
		sta buffer,y
		dex
		bpl replln_loop2
replln8:
		ldx numx
		jsr putlnx
		lda ftmpx
		clc
		adc rlen
		tax
		dex
		stx ftmpx
		jmp replln3
replln1:
		ldx #<trepln
		ldy #>trepln
		jsr prmsg3
		jmp replln7
trepln:
		cbm "Too Big. Can't Replace.",13,0

dellns:
		ldx numy
		jsr dellnx
		ldx numy
		cpx numx
		beq dellns1
		dec numy
		bne dellns
dellns1:
		rts

editlns:
		ldx numx
		jsr editlnx
		ldx numx
		cpx numy
		beq editlns1
		inc numx
		bne editlns
editlns1:
		rts

dellnx:
		stx temp
		inx
		jsr getdes
		ldx temp
		jsr putdes
		inc temp
		ldx temp
		cpx mline
		bcc dellnx
		dec mline
		dec cline
		rts

inslnx:
		stx temp
		cpx mline
		bcs insln2
		ldx mline
		cpx lines
		bcs insln4
		dex
insln1:
		stx temp1
		jsr getdes
		ldx temp1
		inx
		jsr putdes
		ldx temp1
		dex
		cpx temp
		bcs insln1
insln2:
		ldx temp
		jsr putlnx
		ldx mline
		cpx lines
		bcs insln4
		ldx cline
		cpx temp
		bcc insln3
		inc cline
insln3:
		inc mline
insln4:
		rts

editlnx:
		stx temp3
		jsr getlnx
		ldx #27
		jsr putvar ;w$
		lda temp3
		jsr prtnum
		jsr prcol
		jsr prcr
		lda modes
		and #$ef
		ora #$a0
		tax
		lda #$81
		sta mci
		jsr inline
		lda #$00
		sta mci
		lda chat
		beq editln9
		lda buffer
		cmp #20
		beq editln10
		pla
		pla
		pla
		pla
editln5:
		lda editext
		ldx #<(editext+1)
		ldy #>(editext+1)
		jsr prmsg
		jmp main
editln9:
		ldy index
		beq editln10
		ldx temp3
		jmp putlnx
editln10:
		lda editnoc
		ldx #<(editnoc+1)
		ldy #>(editnoc+1)
		jmp prmsg
editnoc:
		byte 13
		cbm "(No Change.)",13
editext:
		byte 13
		cbm "Command:Exit",13

del11:
		ldx #$0b
		jmp xdels
getcr:
		jsr xgetin
		cmp #13
		beq getcr1
		jmp dontdo
getcr1:
		jmp xchrout

cleartt:
		ldx lines
		dex
		stx numx
clear1:
		ldx numx
		jsr clearln
		dec numx
		bne clear1
		rts

clearln:
		jsr getdes
		lda #$00
		sta var
		ldx numx
		jmp putdes

cpylns:
		ldx numx
		jsr cpylnx
		ldx numx
		cpx numy
		beq cpyln1
		inc numx
		bne cpylns
cpyln1:
		rts

movlns:
		ldx numx
		jsr movlnx
		ldx numx
		cpx numy
		beq movln1
		inc numx
		bne movlns
movln1:
		rts

cpylnx:
		jsr getlnx
		ldx mline
		cpx lines
		bcs cpylnx3
		ldx cline
		cpx mline
		beq cpylnx1
		jsr inslnx
		jmp cpylnx2
cpylnx1:
		jsr putlnx
		inc cline
		inc mline
cpylnx2:
		ldx cline
		cpx numy
		bcs cpylnx3
		inc numx
		inc numy
cpylnx3:
		rts

movlnx:
		stx temp
		cpx cline
		bcc movlnx1
		jsr getdes
		lda var
		pha
		lda var+1
		pha
		lda var+2
		pha
movlnx0a:
		ldx temp
		dex
		jsr getdes
		ldx temp
		jsr putdes
		dec temp
		ldx temp
		cpx cline
		bcs movlnx0a
		pla
		sta var+2
		pla
		sta var+1
		pla
		sta var
		ldx cline
		jsr putdes
		inc cline
		rts
movlnx1:
		jsr getdes
		lda var
		pha
		lda var+1
		pha
		lda var+2
		pha
movlnx1a:
		ldx temp
		inx
		jsr getdes
		ldx temp
		jsr putdes
		inc temp
		ldx temp
		cpx cline
		bcc movlnx1a
		pla
		sta var+2
		pla
		sta var+1
		pla
		sta var
		dec numx
		dec numy
		ldx cline
		dex
		jmp putdes

getdes:
		lda #33
		jmp usetbl1
putdes:
		lda #34
		jmp usetbl1
getlnx:
		lda #35
		jmp usetbl1
putlnx:
		lda #36
		jmp usetbl1
putvar:
		lda #30
		jmp usetbl1
outastr:
		lda #0
		jmp usetbl1
xgetin:
		lda #23
		jmp usetbl1
xchrout1:
		lda #24
		jmp usetbl1
prtln:
		lda #39
		jmp usetbl1
chkflags:
		lda #52
		jmp usetbl1
inline:
		lda #1
		ldy #0
		jmp usetbl1

prtnum:
		sta var+1
		lda mci
		pha
		lda #0
		sta var
		ldx #30
		jsr putvar ;a%
		lda #3
		ldx #<prtn
		ldy #>prtn
		jsr prmsg0
		pla
		sta mci
		rts
prtn:
		byte british_pound
		cbm "%a"

doline:
		lda mline
		cmp lines
		bcc doln1
		beq doln1
		sta cline
		lda flags
		and #4
		sta flags
		ldx #<msg3
		ldy #>msg3
		jsr prmsg3
doln1:
		lda flags
		and #1
		beq noinst
		lda #cbm("I")
		jsr xchrout
noinst:
		lda flags
		and #3
		beq noline
		lda cline
		jsr prtnum
		jsr prcol
		jsr prcr
noline:
		lda #0
		sta index
		lda case1
		sta case
		rts
msg3:
		cbm "** End Of Memory **",13
		cbm "Type 'S' To Save, Or 'H' For Help.",13,0

getnumm:
		stx numx
		jsr gettxm
		jmp getnum0
getnum:
		stx numx
		jsr gettx
getnum0:
		ldy index
		beq getnum1
		ldy #0
		lda numx
		jsr getn
		sta numx
getnum1:
		rts
getx:
		stx numx
		stx numy
		jsr gettx
getx0:
		ldy index
		beq getx1
		ldy #0
		lda numx
		jsr getn
		sta numx
		sta numy
getx1:
		jmp chknums

getxy:
		stx numx
		sty numy
		jsr gettx
		ldy index
		beq getxy1
		ldy #0
		lda numx
		jsr getn
		sta numx
		cpy index
		bcc getxy2
		lda numx
		sta numy
		jmp chknums
getxy1:
		lda temp
		cmp #$85
		bne getx1
		lda #1
		sta numx
getxy2:
		iny
		cpy index
		bcc getxy3
		ldx mline
		dex
		stx numy
		jmp chknums
getxy3:
		lda numy
		jsr getn
		sta numy
chknums:
		ldx numy
		cpx numx
		bcc dontdo0
		ldx mline
		dex
		cpx numx
		bcc dontdo0
		cpx numy
		bcc dontdo0
		ldx numx
		beq dontdo0
		ldx numy
		beq dontdo0
		rts
dontdo0:
		ldx stack
		txs
		jmp main
dontdo:
		ldx delx
		jsr xdels
		lda comflag
		bne dontdo0
		ldx stack
		txs
		jmp com1

getn:
		sta temp1
		ldx #0
getn1:
		lda buffer,y
		cmp #cbm("0")
		bcc getn3
		cmp #cbm(":")
		bcs getn3
		cpx #0
		bne getn2
		stx temp1
		inx
getn2:
		and #$0f
		sta temp
		lda temp1
		asl
		asl
		clc
		adc temp1
		asl
		clc
		adc temp
		sta temp1
		iny
		cpy index
		bcc getn1
getn3:
		lda temp1
		rts

gettxm:
		jsr prspc
		lda modes
		and #8
		ora #$c5
		tax
		ldy #$81
		jmp gettx1

gettx:
		jsr prspc
		ldx #$c4
		ldy #$00
gettx1:
		jsr gettx0
		bne gettx2
		jsr prdel
		jmp dontdo
gettx2:
		rts

gettx0:
		lda llen
		pha
		lda mci
		pha
		lda #16
		sta llen
		sty mci
		jsr inline
		pla
		sta mci
		pla
		sta llen
		lda buffer
		cmp #20
		rts

prdel:
		lda #$14
		jmp xchrout
prcr:
		lda #$0d
		jmp xchrout
bell:
		lda #ascii_bel
		jmp xchrout
prcol:
		lda #cbm(":")
		jmp xchrout
prspc:
		lda #cbm(" ")
		jmp xchrout

prcolor:
		lda #3
		ldx #<color
		ldy #>color
		jmp prmsg0
color:
		byte british_pound
		cbm "q0"

xchrout:
		sta $fe
		pha
		jsr xchrout1
		pla
		rts

prbuf:
		lda index
		ldx #<buffer
		ldy #>buffer
		jsr prmsg
		jmp prcr

prmsg0:
		pha
		lda #0
		sta mci
		jmp prmsg2
prmsg1:
		pha
		lda #1
		sta mci
prmsg2:
		pla
prmsg:
		sta var
		stx var+1
		sty var+2
		sta delx
		ldx #1
		jsr putvar ;a$
		jsr outastr
		lda #1
		sta mci
		rts
prmsg3:
		stx var+1
		sty var+2
		ldy #0
prmsg4:
		lda [var+1],y
		beq prmsg5
		sta $fe
		lda var+1
		pha
		lda var+2
		pha
		lda $fe
		jsr xchrout
		pla
		sta var+2
		pla
		sta var+1
		iny
		bne prmsg4
prmsg5:
		sty delx
		rts

tmpa:
		byte 0
tmpx:
		byte 0
tmpx1:
		byte 0
tmpy:
		byte 0

bitbuf:
		dup 0,8
rvsflag:
		byte reverse_off

quadrvs:
		dup reverse_off, 5
		dup reverse_on, 3
		dup reverse_off, 3
		dup reverse_on, 5
quadchr:
		byte $20, $ac, $bb, $a2, $bc, $a1, $bf, $be
		byte $be, $bf, $a1, $bc, $a2, $bb, $ac, $20

quad:
		sta tmpa
		stx tmpx
		sty tmpy
		jsr conver1
		sta quad1+1
		lda #0
		asl quad1+1
		rol
		asl quad1+1
		rol
		asl quad1+1
		rol
		clc
		adc #>$d800
		sta quad1+2
		jsr rsdisab
		php
		lda 1
		pha
		sei
		lda #51
		sta 1
		ldy #7
quad1:
		lda $ffff,y
		sta bitbuf,y
		dey
		bpl quad1
		pla
		sta 1
		plp
		jsr rsinabl
		ldy #3
quad2:
		lda tmpx
		asl
		tax
		lda #0
		asl bitbuf,x
		rol
		asl bitbuf,x
		rol
		asl bitbuf+1,x
		rol
		asl bitbuf+1,x
		rol
		tax
		lda quadrvs,x
		cmp rvsflag
		beq quad3
		sta rvsflag
		jsr banchr
quad3:
		lda quadchr,x
		jsr banchr
		dey
		bpl quad2
		lda tmpa
		ldx tmpx
		ldy tmpy
		rts

convert:
		cmp #133
		bcc conver0
		cmp #141
		bcs conver0
		sec
		sbc #133
		tax
		lda spchars,x
conver0:
		rts
conver1:
		cmp #64
		bcc conver1a
		cmp #128
		bcs conver1a
		eor #192
conver1a:
		and #127
		rts

spchars:
		byte ",:",34,"*?=",13,"^"

offset 0
namespace ""


; pad to the start of the next module
		dup 0,$8000-*

; $e000 - garbage collect

offset $c000-*
namespace "gc"

hi = 51
size = 128

; setup gc parameters
gc:
		lda #$c7 ; reverse uppercase G
		sta tdisp+31
		lda 3
		pha
		lda 4
		pha
		lda 5
		pha
		lda 6
		pha
		lda 7
		pha
		lda 8
		pha
		lda 49
		ldx 50
		sta lo
		stx lo+1
		lda 55
		ldx 56
		sta hi
		stx hi+1
gc0:
		lda #0
		sta index
; loop thru scalars
		lda 45
		ldx 46
		sta 3
		stx 4
gc1:
		lda 3
		cmp 47
		bne gc1a
		lda 4
		cmp 48
		beq gc4
gc1a:
		ldy #0
		lda [3],y
		bmi gc2
		iny
		lda [3],y
		bpl gc2
		lda #2
		jsr add3
		ldy #0
		jsr dostr
		lda #5
		jsr add3
		jmp gc1
gc2:
		lda #7
		jsr add3
		jmp gc1
; loop thru arrays
gc4:
		lda 3
		cmp 49
		bne gc4a
		lda 4
		cmp 50
		beq gc6
gc4a:
		ldy #0
		lda [3],y
		bmi gc5
		iny
		lda [3],y
		bpl gc5
		iny
		jsr doarray
gc5:
		ldy #2
		clc
		lda 3
		adc [3],y
		tax
		iny
		lda 4
		adc [3],y
		stx 3
		sta 4
		jmp gc4
gc6:
		lda index
		beq gc7
		jsr collect
		lda index
		cmp #size
		beq gc0
gc7:
		pla
		sta 8
		pla
		sta 7
		pla
		sta 6
		pla
		sta 5
		pla
		sta 4
		pla
		sta 3
		lda #$a0
		sta tdisp+31
		rts

add3:
		clc
		adc 3
		sta 3
		bcc add3a
		inc 4
add3a:
		rts

doarray:
		clc
		lda [3],y
		adc 3
		sta 7
		iny
		lda [3],y
		adc 4
		sta 8
		lda 3
		pha
		lda 4
		pha
		iny
		lda [3],y
		asl
		clc
		adc #5
		jsr add3
doarray1:
		lda 3
		cmp 7
		bne doarray2
		lda 4
		cmp 8
		beq doarray3
doarray2:
		ldy #0
		jsr dostr
		clc
		lda 3
		adc #3
		sta 3
		bcc doarray1
		inc 4
		jmp doarray1
doarray3:
		pla
		sta 4
		pla
		sta 3
		rts

dostr0:
		rts
dostr:
		lda [3],y
		tax
		iny
		lda [3],y
		sta 5
		iny
		lda [3],y
		sta 6
		cpx #0
		beq dostr0
		lda 5
		cmp lo
		lda 6
		sbc lo+1
		bcc dostr0
		lda 5
		cmp hi
		lda 6
		sbc hi+1
		bcs dostr0
		ldx index
		beq dostr4
		ldx #0
dostr1:
		lda 6
		cmp tbldh,x
		bcc dostr6
		bne dostr2
		lda 5
		cmp tbldl,x
		bcc dostr6
		beq dostr5
dostr2:
		stx temp
		cpx #size-1
		beq dostr4
		ldx #size-1
dostr3:
		lda tblpl-1,x
		sta tblpl,x
		lda tblph-1,x
		sta tblph,x
		lda tbldl-1,x
		sta tbldl,x
		lda tbldh-1,x
		sta tbldh,x
		dex
		cpx temp
		bne dostr3
dostr4:
		lda 3
		sta tblpl,x
		lda 4
		sta tblph,x
		lda 5
		sta tbldl,x
		lda 6
		sta tbldh,x
		lda index
		cmp #size
		beq dostr5
		inc index
dostr5:
		rts
dostr6:
		inx
		cpx index
		bcc dostr1
		cpx #size
		bcc dostr4
		rts

collect0:
		rts
collect:
		ldx #0
collect1:
		cpx index
		beq collect0
		lda tblpl,x
		sta 3
		lda tblph,x
		sta 4
		lda tbldl,x
		sta 5
		lda tbldh,x
		sta 6
		stx temp
		ldy #0
		lda [3],y
		tax
		sec
		lda hi
		sbc [3],y
		sta hi
		lda hi+1
		sbc #0
		sta hi+1
		txa
		tay
		dey
collect2:
		lda [5],y
		sta [hi],y
		dey
		dex
		bne collect2
		ldy #1
		lda hi
		sta [3],y
		iny
		lda hi+1
		sta [3],y
		ldx temp
		inx
		jmp collect1

index:
		byte 0
temp:
		byte 0
lo:
		word 0
tblpl:
		dup 0,size
tblph:
		dup 0,size
tbldl:
		dup 0,size
tbldh:
		dup 0,size

offset 0
namespace ""


; pad to the start of the next module
		dup 0,$8400-*

; $e400 - e.c.s. checker

offset $c000-*
namespace "ecs"

a=0

;short format
; 0....flag
; ..... bit 128 active command
; ..... bit .64 used =1/empty=0
; ..... bit .32 gosub=1/goto=0
; ..... bit .16 line#=1/file=0
; ..... bit ..8 short=1/long=0
; ..... bit ..4 param=1/none=0
; ..... bit ..2
; ..... bit ..1 zz lock
; 1-2..access
; 3-4..command
; 5-6..file
; 7....credits

;long format
; 0......flag (same as short)
; 1-2....access
; 3-9....command (7 chars)
; 10-23..file (14 chars)
; 24-31..password (7 chars)
; 32.....credits

ecs:
		cpx #0
		bne ecs1
		jmp ecschk
ecs1:
		dex
		bne ecs2
		jmp ecsgoto
ecs2:
		dex
		bne ecs3
		jmp ecsget
ecs3:
		dex
		bne ecs4
		jmp ecsput
ecs4:
		dex
		bne ecs5
		jmp ecsload
ecs5:
		dex
		bne ecs6
		jmp ecssave
ecs6:
		rts

ecsgoto:
		ldx #30
		jsr usevar ;a%
		lda var+1
		sta $14
		lda var
		sta $15
		lda 1
		pha
		lda #$37
		sta 1
		jsr $a8a3
		pla
		sta 1
		rts

ecschk:
		ldx #0
		jsr usevar ;an$
		ldy var
		sty index
ecsc2:
		lda [var+1],y
		sta buffer,y
		dey
		bpl ecsc2
		ldx #24
		jsr usevar ;ac%
		ldx var+1
		sec
		lda #0
		sta acc
		sta acc+1
ecsc3:
		rol acc
		rol acc+1
		dex
		bpl ecsc3
		ldx #30
		jsr usevar ;a%
		lda var+1
		sta zzf
		lda index
		beq ecsquit
		ldy #0
		lda #<ecsdefs
		sta var+3
		lda #>ecsdefs
		sta var+4
ecsscan:
		lda [var+3],y
		tax
		and #64
		beq ecsnext
		txa
		and #3
		beq ecsscan1
		and zzf
		beq ecsnext
ecsscan1:
		ldy #1
		lda [var+3],y
		and acc
		bne ecsscan2
		ldy #2
		lda [var+3],y
		and acc+1
		beq ecsnext
ecsscan2:
		ldy #0
		lda [var+3],y
		pha
		and #8
		bne ecsscan3
		jsr ecslong
		jmp ecsscan4
ecsscan3:
		jsr ecsshort
ecsscan4:
		pla
		bcc ecsnext
; got it!
		bmi ecsscan5
		lda #5
		bne ecsquit
ecsscan5:
		lsr
		lsr
		lsr
		lsr
		and #3
		clc
		adc #1
ecsquit:
		sta var+1
		lda #0
		sta var
		sta var+2
		sta var+3
		sta var+4
		ldx #30
		jmp putvar ;a%

ecsnext:
		ldy #0
		lda [var+3],y
		and #$c0
		beq ecsquit
		ldy #0
		lda [var+3],y
		ldx #8
		and #8
		bne ecsnext1
		ldx #32
ecsnext1:
		clc
		txa
		adc var+3
		sta var+3
		tya
		adc var+4
		sta var+4
		cmp #>ecsdefnd
		bne ecsscan
		lda #0
		beq ecsquit

acc:
		word 0
zzf:
		byte 0

; check long command, cc=not equal
ecslong:
		ldx #0
		ldy #3
ecslong1:
		lda [var+3],y
		beq ecslong2
		cmp buffer,x
		bne ecslong3
		iny
		inx
		cpx #7
		bne ecslong1
ecslong2:
		cpx index
		beq ecslong4
;nope
ecslong3:
		clc
		rts
;yup
ecslong4:
		ldy #24
		lda [var+3],y
		beq ecslong5
;do password later
ecslong5:
		ldy #10
		ldx #0
ecslong6:
		lda [var+3],y
		beq ecslong7
		sta buffer,x
		iny
		inx
		cpx #14
		bcc ecslong6
ecslong7:
		stx index
		stx var
		lda #<buffer
		sta var+1
		lda #>buffer
		sta var+2
		ldx #2
		jsr putvar ;b$
		ldy #24
		ldx #0
ecslong8:
		lda [var+3],y
		beq ecslong9
		sta buf2,x
		iny
		inx
		cpx #8
		bcc ecslong8
ecslong9:
		stx index
		stx var
		lda #<buf2
		sta var+1
		lda #>buf2
		sta var+2
		ldx #1
		jsr putvar ;a$
		ldy #31
		lda [var+3],y
		sta var+1
		lda #0
		sta var
		ldx #31
		jsr putvar ;b%
		sec
		rts

; check short command,cc=not equal
ecsshort:
		ldy #0
		lda [var+3],y
		and #4
		beq ecsshrt1
		lda index
		cmp #2
		bcs ecsshrt2
ecsshrt1:
		lda index
		cmp #2
		bne ecsshrt3
ecsshrt2:
		ldy #3
		lda [var+3],y
		cmp buffer
		bne ecsshrt3
		ldy #4
		lda [var+3],y
		cmp buffer+1
		beq ecsshrt4
;nope
ecsshrt3:
		clc
		rts
;yup
ecsshrt4:
		ldy #5
		lda [var+3],y
		sta buffer
		ldy #6
		lda [var+3],y
		sta buffer+1
		ldx #2
		stx index
		stx var
		lda #<buffer
		sta var+1
		lda #>buffer
		sta var+2
		ldx #2
		jsr putvar ;b$
		ldy #7
		lda [var+3],y
		sta var+1
		lda #0
		sta var
		ldx #31
		jsr putvar ;b%
		ldx #1
		jsr usevar ;a$
		lda #0
		sta var
		lda #<buf2
		sta var+1
		lda #>buf2
		sta var+2
		ldx #1
		jsr putvar ;a$
		sec
		rts

ecsget:
		ldx #0
		stx $6b
		lda #<ecsdefs
		sta $69
		lda #>ecsdefs
		sta $6a
ecsg1:
		inc $6b
		jsr ecsgetln
		lda $6a
		cmp #>ecsdefnd
		bcs ecsg2
		ldy #0
		lda [$69],y
		bne ecsg1
ecsg2:
		lda $6b
		sta var+1
		lda #0
		sta var
		sta var+2
		sta var+3
		sta var+4
		ldx #30
		jmp putvar ;a%

ecsput:
		sty $6c
		lda #0
		sta $6b
		lda #<ecsdefs
		sta $69
		lda #>ecsdefs
		sta $6a
ecsp1:
		inc $6b
		jsr ecsputln
		lda $6a
		cmp #>ecsdefnd
		bcs ecsp2
		lda $6b
		cmp $6c
		bne ecsp1
ecsp2:
		rts

ecsgetln:
		ldy #31
ecsgl1:
		lda [$69],y
		sta buffer,y
		dey
		bpl ecsgl1
		ldy #8
		lda buffer
		and #8
		bne ecsgl2
		ldy #32
ecsgl2:
		sty index
		tya
		clc
		adc $69
		sta $69
		lda #0
		adc $6a
		sta $6a
		ldx $6b
		jmp putln

ecsputln:
		ldx $6b
		jsr getln
		ldy #7
		lda buffer
		and #8
		bne ecspl1
		ldy #31
ecspl1:
		sty index
ecspl2:
		lda buffer,y
		sta [$69],y
		dey
		bpl ecspl2
		sec
		lda index
		adc $69
		sta $69
		lda #0
		adc $6a
		sta $6a
		rts

getln:
		lda #35
		jmp usetbl1
putln:
		lda #36
		jmp usetbl1
usevar:
		lda #29
		jmp usetbl1
putvar:
		lda #30
		jmp usetbl1

ecsload:
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
		ldx #<ecsdefs
		ldy #>ecsdefs
		jmp loadf

ecssave:
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
		lda #<ecsdefs
		ldx #>ecsdefs
		sta var
		stx var+1
		ldx #<ecsdefnd
		ldy #>ecsdefnd
		lda #var
		jmp savef

align 32

ecsdefs:
		byte 0
ecsdefnd = ecs+$a00

offset 0
namespace ""



; pad to the start of the next module
		dup 0, $8e00-*

; $ee00 - struct

offset $c000-*
namespace "struct"

;putstruc - put string into struct
; &,nn,0,num,arry(a,b),string$
; arry(a,b) = starting element
; num = # of bytes
; string$ = the string

;getstruc - get string from struct
; &,nn,1,num,arry(a,b),string$
; arry(a,b) = starting element
; num = # of bytes
; string$ = the string

;lodstruc - load structure
; &,nn,2,0,arry(a,b),"file",dev
; arry(a,b) = starting element
; "file" = filename
; dev = device #

;savstruc - save structure
; &,nn,3,0,arry(a,b),bytes,"file",dev
; arry(a,b) = starting element
; bytes = # of bytes
; "file" = filename
; dev = device #

;putdate - put date into struct
; &,nn,4,0,arry(a,b),string$
; arry(a,b) = starting element
; string$ = the date string

;getdate - get date from struct
; &,nn,5,0,arry(a,b),string$
; arry(a,b) = starting element
; string$ = the string

;doscan - scan structures
; &,nn,6,num,com,a(a,b),b(a,b),l,bits,test
; com = command number
; com = 0: 2 byte and, <>0
; com = 1: 2 byte and, ==0
; com = 2: 2 byte cmp, <
; com = 3: 2 byte cmp, >=
; com = 4: date cmp, <
; com = 5: date cmp, >=
; num = # of structures to scan
; a(a,b) = starting flags element
; b(a,b) = starting object element
; bits = the bits to set if true
; test = the object to test for

ilen = $61 ;1
istr = $62 ;2
iptr = $64 ;2
jlen = $69 ;1
jstr = $6a ;2
jptr = $6c ;2
temp = $14 ;2

opandy=57
opcmpy=217
opbne =208
opbcc =144
opbeq =240
opbcs =176

makerm = $b475
chkcom = $aefd
getnxt = $e206

defbase= $c600

entry1:
		jmp clrarr
entry2:
		sty count
		lda 1
		pha
		lda #$37
		sta 1
		dex
		dex
		txa
		asl
		tax
		lda functbl,x
		sta strucjmp+1
		lda functbl+1,x
		sta strucjmp+2
strucjmp:
		jsr lodstruc
		pla
		sta 1
		rts

functbl:
		word lodstruc ;2
		word savstruc ;3
		word putdate ;4
		word getdate ;5
		word doscan ;6
		word sort ;7
		word scannums ;8
		word scansum ;9
		word cpystruc ;10
		word scanstr ;11
		word gamescan ;12

putvar:
		lda #30
		jmp usetbl1

count:
		byte 0
size:
		byte 0
scanfor:
		byte 0,0,0,0,0,0
bitmask:
		word 0
invert:
		byte 0
oper:
		byte 0

fnvar:
		jsr chkcom
		jsr $b08b
		ldx $47
		ldy $48
		rts
fnvar1:
		jsr fnvar
		stx $14
		sty $15
		rts

evalbyt:
		jsr chkcom
		jsr $0079
		jmp $b79e

evalstr:
		jsr chkcom
		jsr $ad9e
		jmp $b6a3

evaldate:
		jsr evalstr
		stx $62
		sty $63
		ldy #1
		ldx #0
evald1:
		lda [$62],y
		iny
		and #15
		asl
		asl
		asl
		asl
		sta scanfor,x
		lda [$62],y
		iny
		and #15
		ora scanfor,x
		sta scanfor,x
		inx
		cpx #5
		bcc evald1
evald2:
		ldy #0
		lda [$62],y
		sta scanfor+5
		ldx scanfor+3
		txa
		and #$7f
		cmp #$12
		bne evald3
		txa
		sec
		sbc #$12
		tax
evald3:
		stx scanfor+3
		rts

getword:
		jsr $aefd
		jsr $ad8a
		jsr $b7f7
		ldx $14
		ldy $15
		rts

lodstruc:
		jsr fnvar
		tya
		pha
		txa
		pha
		jsr $aefd
		jsr 57812
		pla
		tax
		pla
		tay
		lda #0
		jmp $ffd5

savstruc:
		jsr fnvar
		tya
		pha
		txa
		pha
		jsr getword
		jsr $aefd
		jsr 57812
		clc
		pla
		sta $69
		adc $14
		tax
		pla
		sta $6a
		adc $15
		tay
		lda #$69
		jmp $ffd8

putdate:
		jsr fnvar1
		jsr evaldate
		ldy #0
putd1:
		lda scanfor,y
		sta [$14],y
		iny
		cpy #6
		bcc putd1
		rts

getdate:
		jsr fnvar1
		ldy #5
getd1:
		lda [$14],y
		sta scanfor,y
		dey
		bpl getd1
		jsr fnvar
		lda #11
		jsr makerm
		ldx scanfor+3
		txa
		and #$7f
		bne getd0
		txa
		clc
		adc #$12
		tax
getd0:
		stx scanfor+3
		lda scanfor+5
		ldx #0
		ldy #0
		sta [$62],y
		iny
getd2:
		lda scanfor,x
		inx
		pha
		lsr
		lsr
		lsr
		lsr
		ora #$30
		sta [$62],y
		iny
		pla
		and #15
		ora #$30
		sta [$62],y
		iny
		cpx #5
		bcc getd2
getd3:
		ldy #4
getd4:
		lda $61,y
		sta [$47],y
		dey
		bpl getd4
		rts

opc1:
		byte opandy,opcmpy
opc2:
		byte opbne, opbcc
opc3:
		byte opbeq, opbcs

scanbits:
		txa
		lsr
		tax
		and #1
		tay
		rts

doscan:
		jsr evalbyt
		stx oper
		txa
		and #1
		sta invert
		jsr scanbits
		lda opc1,y
		sta checkc0
		jsr scanbits
		lda opc1,y
		sta checkc1
		jsr scanbits
		lda opc2,y
		sta checkc2
		lda opc3,y
		sta checkc3
		jsr fnvar
		txa
		pha
		tya
		pha
		jsr fnvar
		txa
		pha
		tya
		pha
		jsr evalbyt
		stx size
		jsr getword
		sty bitmask
		stx bitmask+1
		lda oper
		and #64
		bne doscan1
		jsr getword
		sty scanfor
		stx scanfor+1
		lda #2
		jmp doscan2
doscan1:
		jsr evaldate
		lda #6
doscan2:
		sta checkc4+2
		pla
		sta $6c
		pla
		sta $6b
		pla
		sta $6a
		pla
		sta $69
		lda #0
		sta var
		sta var+1
		lda count
		beq doscan15
doscan3:
		lda oper
		bmi doscan6
		ldy #1
doscan5:
		lda bitmask,y
		eor #255
		and [$69],y
		sta [$69],y
		dey
		bpl doscan5
doscan6:
		ldy #0
doscan7:
		lda [$6b],y
checkc0:
		cmp scanfor,y
checkc1:
		cmp scanfor,y
		beq checkc4
checkc2:
		bne doscan9
checkc3:
		beq doscan8
checkc4:
		iny
		cpy #2
		bcc doscan7
doscan8:
		lda invert
		bne doscan10
		jmp doscan12
doscan9:
		lda invert
		bne doscan12
doscan10:
		ldy #1
doscan11:
		lda bitmask,y
		ora [$69],y
		sta [$69],y
		dey
		bpl doscan11
		inc var+1
doscan12:
		ldx #2
doscan13:
		clc
		lda size
		adc $69,x
		sta $69,x
		bcc doscan14
		inc $6a,x
doscan14:
		dex
		dex
		bpl doscan13
		dec count
		bne doscan3
doscan15:
		ldx #30
		jmp putvar ;a%

i:
		word 0
j:
		word 0
n:
		word 0
base:
		word 0

calcp:
		stx temp
		sty temp+1
		txa
		asl
		tax
		tya
		rol
		tay
		clc
		txa
		adc temp
		tax
		tya
		adc temp+1
		tay
		clc
		txa
		adc base
		tax
		tya
		adc base+1
		tay
		rts
calcs:
		stx temp
		sty temp+1
		ldy #0
		lda [temp],y
		pha
		iny
		lda [temp],y
		tax
		iny
		lda [temp],y
		tay
		pla
		rts

strcmp:
		ldy #0
strcmp1:
		lda [jstr],y
		cmp [istr],y
		bne strcmp3
		iny
		cpy jlen
		bcs strcmp2
		cpy ilen
		bcc strcmp1
strcmp2:
		ldy jlen
		cpy ilen
strcmp3:
		rts

strptn:
		ldy #0
strptn1:
		lda [jstr],y
		cmp #function_key_2
		beq strptn2
		cmp #function_key_7
		beq strptn4
		cmp [istr],y
		bne strptn4
strptn2:
		iny
		cpy jlen
		bcs strptn3
		cpy ilen
		bcc strptn1
strptn3:
		ldy jlen
		cpy ilen
strptn4:
		rts

sort:
		jsr fnvar
		stx base
		sty base+1
		jsr getword
		cpx #0
		bne sort0
		dey
sort0:
		dex
		stx n
		sty n+1
		ldx #0
		ldy #0
		stx i
		sty i+1
sort1:
		jsr calcp
		stx iptr
		sty iptr+1
		jsr calcs
		sta ilen
		stx istr
		sty istr+1
		ldx i
		ldy i+1
sort2:
		inx
		bne sort3
		iny
sort3:
		stx j
		sty j+1
		jsr calcp
		stx jptr
		sty jptr+1
		jsr calcs
		sta jlen
		stx jstr
		sty jstr+1
		jsr strcmp
		bcs sort8
		ldy #2
sort7:
		lda ilen,y
		sta [jptr],y
		lda jlen,y
		sta [iptr],y
		sta ilen,y
		dey
		bpl sort7
sort8:
		ldx j
		ldy j+1
		cpx n
		bne sort2
		cpy n+1
		bne sort2
		ldx i
		ldy i+1
		inx
		bne sort9
		iny
sort9:
		stx i
		sty i+1
		cpx n
		bne sort1
		cpy n+1
		bne sort1
		rts

; scan numbers
; &,nn,8,num,siz,acs,a(a,b),a%(a),start

scannums:
		jsr evalbyt
		stx size
		jsr getword
		stx scanfor+1
		sty scanfor
		jsr fnvar
		txa
		pha
		tya
		pha
		jsr fnvar
		txa
		pha
		tya
		pha
		jsr evalbyt
		stx var
		lda #0
		sta var+2
		sta var+1
		pla
		sta $6a
		pla
		sta $69
		pla
		sta $6c
		pla
		sta $6b
scannum1:
		lda count
		beq scannum6
		ldy #0
scannum2:
		lda [$6b],y
		and scanfor
		bne scannum3
		iny
		lda [$6b],y
		and scanfor+1
		beq scannum4
scannum3:
		ldy var+2
		lda #0
		sta [$69],y
		iny
		lda var
		sta [$69],y
		iny
		sty var+2
		inc var+1
scannum4:
		inc var
		clc
		lda size
		adc $6b
		sta $6b
		bcc scannum5
		inc $6c
scannum5:
		dec count
		bne scannum1
scannum6:
		lda #0
		sta var
		ldx #30
		jmp putvar ;a%

; sum
; &,nn,9,num,siz,a(a,b)

scansum:
		jsr evalbyt
		stx size
		jsr fnvar
		stx $6b
		sty $6c
		lda #0
		sta var
		sta var+1
scansum1:
		lda count
		beq scansum4
		ldy #1
		clc
scansum2:
		lda [$6b],y
		adc var,y
		sta var,y
		dey
		bpl scansum2
		lda size
		adc $6b
		sta $6b
		bcc scansum3
		inc $6c
scansum3:
		dec count
		bne scansum1
scansum4:
		ldx #30
		jmp putvar ;a%

; copy
; &,nn,10,size,a1(a,b),a2(a,b)

cpystruc:
		jsr fnvar
		stx cpys1+1
		sty cpys1+2
		jsr fnvar
		stx cpys2+1
		sty cpys2+2
		ldy #0
cpys1:
		lda $ffff,y
cpys2:
		sta $ffff,y
		iny
		cpy count
		bcc cpys1
		rts

; scan for string
; &,nn,11,num,siz,op,str,a1(a,b),a2(b),start

stroplo:
		byte <strcmp,<strptn
strophi:
		byte >strcmp,>strptn

scanstr:
		jsr evalbyt
		stx size
		jsr evalbyt
		txa
		and #1
		tax
		lda stroplo,x
		sta scanstr0+1
		lda strophi,x
		sta scanstr0+2
		jsr evalstr
		sta index
		tax
		ldy #0
scanstr_loop1:
		lda [$22],y
		sta buffer,y
		iny
		dex
		bne scanstr_loop1
		jsr fnvar
		txa
		pha
		tya
		pha
		jsr fnvar
		txa
		pha
		tya
		pha
		jsr evalbyt
		stx iptr
		lda #0
		sta iptr+1
		pla
		sta jptr+1
		pla
		sta jptr
		pla
		sta istr+1
		pla
		sta istr
		lda #<buffer
		sta jstr
		lda #>buffer
		sta jstr+1
		lda index
		sta jlen
scanstr1:
		lda count
		beq scanstr5
		ldy #0
loop:
		lda [istr],y
		beq scanstr2
		iny
		bne loop
scanstr2:
		sty ilen
scanstr0:
		jsr strcmp
		bne scanstr3
		ldy iptr+1
		lda #0
		sta [jptr],y
		iny
		lda iptr
		sta [jptr],y
		iny
		sty iptr+1
scanstr3:
		inc iptr
		clc
		lda size
		adc istr
		sta istr
		bcc scanstr4
		inc istr+1
scanstr4:
		dec count
		bne scanstr1
scanstr5:
		lda #0
		sta var
		lda iptr+1
		lsr
		sta var+1
		ldx #30
		jmp putvar ;a%

arrays1:
		cbm "tbdenACDEFAS"
arrays2:
		cbm "TBTDN"
		byte $80, $80, $80, $80, $80
		cbm "CO"

;* clear an array
clrarr:
		cpx #12
		bcs clrar7
		lda 47
		sta 71
		lda 48
		sta 72
clrar0:
		ldy #3
		lda [71],y
		sta 21
		dey
		lda [71],y
		sta 20
		dey
		lda [71],y
		cmp arrays2,x
		bne clrar1
		dey
		lda [71],y
		cmp arrays1,x
		beq clrar3
clrar1:
		clc
		lda 20
		adc 71
		sta 71
		lda 21
		adc 72
		sta 72
		lda 71
		cmp 49
		bne clrar2
		lda 72
		cmp 50
		beq clrar7
clrar2:
		jmp clrar0
clrar3:
		clc
		lda 71
		adc #7
		sta 71
		lda 72
		adc #0
		sta 72
		sec
		lda 20
		sbc #7
		sta 20
		lda 21
		sbc #0
		sta 21
clrar4:
		ldy #0
		tya
		sta [71],y
		inc 71
		bne clrar5
		inc 72
clrar5:
		lda 20
		bne clrar6
		dec 21
clrar6:
		dec 20
		bne clrar4
		lda 21
		bne clrar4
clrar7:
		rts

; game scan
; &,60,13,count,size,a$,a%(a,b),b$

gamescan:
		jsr evalbyt
		stx size
		jsr evalstr
		lda $22
		sta game2+1
		lda $23
		sta game2+2
		jsr fnvar1
		jsr fnvar
		lda count
		asl
		jsr makerm
		ldy #0
		sty index
game1:
		ldy #1
		lda [$14],y
		asl
		tax
		ldy index
		jsr game2
		jsr game2
		sty index
		clc
		lda $14
		adc size
		sta $14
		lda $15
		adc #0
		sta $15
		dec count
		bne game1
		ldy #4
game3:
		lda $61,y
		sta [$47],y
		dey
		bpl game3
		rts

game2:
		lda $ffff,x
		sta [$62],y
		inx
		iny
		rts

offset 0
namespace ""


; pad to the start of the next module
		dup 0, $9400-*

;;;;;
;;;;;
;;;;; $f400 - swap1
;;;;;
;;;;;

offset $c000-*
namespace "swap1"

hc000:
		jmp inline
hc003:
		jmp inline0
hc006:
		jmp password
hc009:
		jmp useeditr

; jump table routines

xgetin:
		lda #23
		jmp usetbl1
xchrout0:
		sta $fe
		lda passmode
		and #2
		beq xchrout1
		lda $fe
		rts
xchrout:
		sta $fe
xchrout1:
		pha
		txa
		pha
		tya
		pha
		lda #24
		jsr usetbl1
		pla
		tay
		pla
		tax
		pla
		rts
usevar:
		lda #29
		jmp usetbl1
putvar:
		lda #30
		jmp usetbl1
zero:
		lda #31
		jmp usetbl1
chatchk:
		lda #43
		jmp usetbl1
memory:
		lda #44
		jmp usetbl1
prtvar0:
		lda #46
		jmp usetbl1
carchk:
		lda #47
		jmp usetbl1
chatmode:
		lda #56
		jmp usetbl1

;********************************
;* string input routines
;********************************

;********************************
;* input line to an$ *
;********************************
;* on entry:*
;* pl=0 for upper/lower case *
;* pl=1 for upper case only *
;* w$ = text that was wrapped *
;* or text to edit in *
;* edit mode. *
;* p$ = text for prompt *
;* .x register holds mode *
;* .y register holds password mode
;* flags *
;********************************
;* on exit:
;* an$ = text that was typed *
;* w$ = text that was wrapped *
;* location (chat) holds:
;* 0 = normal *
;* 1 = delete on column one *
;* or dot on column one *
;* 2 = chat check hit *
;* 3 = carrier/time loss *
;********************************

inline:
		stx editor ;flags
		sty passmode
		ldx #16
		jsr usevar ;pl
		lda var ;case lock
		and #1
		sta case
inline0:
		ldy #$00
		sty index
		sty tmp1 ;chars typed
		sty mjump
		sty chat ;result code
		sty buffer
		jsr prprompt
		lda editor
		and #$30 ;word wrap
		beq in0c ;and edit mode
		ldx #27
		jsr usevar ;w$
		ldy var
		beq in1
		sty tmp1
in0:
		dey
		lda [var+1],y
		sta buffer,y
		cpy #0
		bne in0
in0c:
		ldy #0 ;print buffer
		cpy tmp1
		beq in0d
in0a:
		lda buffer,y
		jsr xchrout
		iny
		cpy tmp1
		bcc in0a
		lda tmp1
		sta index
in0d:
		lda editor ;edit mode
		and #$20
		beq in0b
		jsr prcr
		lda #0
		sta index
		jsr prprompt
in0b:
		jsr zero
		ldx #27
		jsr putvar ;w$
in1:
		jsr xgetin ;main loop
		sta $fe
		jsr carchk
		beq in1a
		lda #0
		sta index
		lda #3
		sta chat
		jmp ctrlm
in1a:
		jsr chatchk
		beq in1b
		jsr chatmode
		jmp inline0
in1b:
		lda $fe
		ldy index
		ldx #ctrlend-ctrlchrs-1
in2:
		cmp ctrlchrs,x
		beq in3
		dex
		bpl in2
		jsr ctrlchk
		bcc in1
put:
		cpy llen
		bcc put0
		jmp wrap
put0:
		sta buffer,y
		jsr xchrout0
		inc index
		ldy index
		cpy tmp1
		bcc put1
		sty tmp1
put1:
		jmp in1
ctrlchrs:
		byte $04, ensh,13,20, $15,$16,$17,$18,$19,swlc,$02, "."
ctrlend:

ctrl:
		word ctrld,ctrli,ctrlm
		word ctrlt,ctrlu,ctrlv
		word ctrlw,ctrlx,ctrly
		word ctrln,ctrlb,dot
in3:
		txa
		asl
		tax
		lda ctrl,x
		sta ctrljm+1
		lda ctrl+1,x
		sta ctrljm+2
		ldy index
ctrljm:
		jmp $ffff

ctrld:
		ldx tmp1
		beq ctrld3
		cpx index
		beq ctrld3
ctrld1:
		cpy tmp1
		bcs ctrld2
		lda buffer+1,y
		sta buffer,y
		iny
		bne ctrld1
ctrld2:
		dec tmp1
ctrld3:
		jmp in1

ctrli:
		ldx tmp1
		cpx llen
		bcs ctrli3
ctrli1:
		cpx index
		beq ctrli2
		lda buffer-1,x
		sta buffer,x
		dex
		jmp ctrli1
ctrli2:
		inc tmp1
		lda #" "
		sta buffer,y
ctrli3:
		jmp in1

ctrlm:
		lda #13
		jsr xchrout0
		lda index
		sta var
		lda #<buffer
		sta var+1
		lda #>buffer
		sta var+2
		ldx #0
		jsr putvar ;an$
		jmp memory

ctrlt:
		cpy #0
		beq ctrlt1
		lda buffer-1,y
		jsr ctrlt4
		dec index
ctrlt2:
		jmp in1
ctrlt1:
		ldx editor
		bpl ctrlt2
		lda #20
		sta buffer
		lda #1
		sta chat
		rts

ctrlt3:
		pla
		eor #128
		jmp xchrout0
ctrlt4:
		ldx mci
		bmi ctrlt6
		jsr colorchk
		bcc ctrlt5
		pha
		and #$7f
		cmp #reverse_on
		beq ctrlt3
		cmp #cursor_down
		beq ctrlt3
		cmp #cursor_right
		beq ctrlt3
		pla
ctrlt6:
		lda #20
		jmp xchrout0
ctrlt5:
		rts

ctrlu:
		cpy tmp1
		bcs ctrlu1
		lda buffer,y
		jmp put
ctrlu1:
		jmp in1

ctrlv:
		jsr prcr
		jsr prprompt
		ldy #0
ctrlv1:
		cpy index
		bcs ctrlv2
		lda buffer,y
		jsr xchrout0
		iny
		bne ctrlv1
ctrlv2:
		jmp in1

ctrlw:
		cpy #0
		beq ctrlw1
		dey
		lda buffer,y
		jsr ctrlt4
		lda buffer,y
		cmp #" "
		bne ctrlw
ctrlw1:
		sty index
		jmp in1

ctrlx:
		lda #british_pound
		jsr xchrout
		jsr prcr
		jmp inline0

ctrly:
		ldy index
		cpy tmp1
		bcs ctrly1
		lda buffer,y
		cmp #" "
		php
		jsr xchrout0
		inc index
		plp
		bne ctrly
ctrly1:
		jmp in1

ctrln:
		ldy index
		cpy tmp1
		bcs ctrln1
		lda buffer,y
		jsr xchrout0
		inc index
		jmp ctrln
ctrln1:
		jmp in1

ctrlb:
		cpy #0
		beq ctrlb2
ctrlb1:
		lda buffer-1,y
		jsr ctrlt4
		dey
		bne ctrlb1
		sty index
ctrlb2:
		jmp in1

dot:
		cpy #0
		bne dot1
		lda editor
		and #2
		beq dot1
		lda #1
		sta chat
		rts
dot1:
		lda #"."
		jmp put

wrap:
		sta tmp2
		lda editor
		and #16
		bne wrap0
		lda editor
		and #32
		bne wrap0a
		lda #7
		jsr xchrout0
wrap0a:
		jmp in1
wrap0:
		lda tmp2
		cmp #" "
		bne wrap1
		sty tmp3
		jmp wrap6
wrap1:
		sta tmp2
		dey
wrap2:
		lda buffer,y
		cmp #" "
		beq wrap3
		dey
		bne wrap2
		lda tmp2
		sta buf2
		lda #1
		sta var
		lda #<buf2
		sta var+1
		lda #>buf2
		sta var+2
		ldx #27
		jsr putvar ;w$
		jmp ctrlm
wrap3:
		ldx #0
		sty tmp3
		iny
		cpy index
		bcs wrap5
wrap4:
		lda buffer,y
		sta buf2,x
		lda #20
		jsr xchrout0
		inx
		iny
		cpy index
		bcc wrap4
wrap5:
		lda tmp2
		sta buf2,x
		inx
		stx var
		lda #<buf2
		sta var+1
		lda #>buf2
		sta var+2
		ldx #$1b
		jsr putvar ;w$
wrap6:
		ldy tmp3
		iny
		sty index
		lda #32
		sta buffer-1,y
		jmp ctrlm

prprompt:
		lda editor
		and #4
		bne prpr1
		lda passmode
		pha
		lda #0
		sta passmode
		ldx #28
		jsr prtvar0 ;p$
		lda #":"
		jsr xchrout
		lda #" "
		jsr xchrout
		pla
		sta passmode
prpr1:
		rts

; carry clear if cotrol
ctrlchk:
		pha
		lda editor
		and #1
		beq ctrlch0
		pla
ctrlchk1:
		jsr colorchk
		bcc ctrlch2
		cmp #reverse_on
		beq ctrlch2
		cmp #reverse_off
		beq ctrlch2
		cmp #cursor_down
		beq ctrlch2
		cmp #cursor_up
		beq ctrlch2
		cmp #cursor_right
		beq ctrlch2
		cmp #cursor_left
		beq ctrlch2
		pha
ctrlch0:
		pla
		cmp #32
		bcc ctrlch1
		cmp #128
		bcc ctrlch2
		cmp #160
		bcs ctrlch2
		cmp #133
		bcc ctrlch1
		cmp #141
		bcs ctrlch1
ctrlch2:
		sec
		rts
ctrlch1:
		clc
		rts

; carry clear if color chr
colorchk:
		sty cytmp
		ldy #15
colrch0:
		cmp romcolors,y
		beq colrch1
		dey
		bne colrch0
		ldy cytmp
		sec
		rts
colrch1:
		ldy cytmp
		clc
		rts

prcr:
		lda #$0d
		jmp xchrout

;* password input routine *

password:
		lda #1
		sta case
		lda #15
		sta llen
		lda #4
		sta editor
		txa
		ora #1
		sta passmode
		jsr inline0
		lda #0
		sta passmode
		rts

useeditr:
		lda edittbl,x
		sta editjmp+1
		jsr editswap
editjmp:
		jsr $1800
editswap:
		pha
		txa
		pha
		tya
		pha
		lda #$18
		ldy #$d0
		ldx #16
		jsr swapper
		pla
		tay
		pla
		tax
		pla
		rts

edittbl:
		byte 0,3,6

offset 0
namespace ""

		dup 0, $9800-*

;;;;;
;;;;;
;;;;; $f800 - swap2
;;;;;
;;;;;

offset $c000-*
namespace "swap2"

hc000:
		jmp term
hc003:
		jmp chatmode
hc006:
		jmp btmvar
hc009:
		jmp convert
hc00c:
		jmp sound

; jump table routines

xchrout:
		sta $fe
		lda #24
		jmp usetbl1
usevar:
		lda #29
		jmp usetbl1
chatchk:
		lda #43
		jmp usetbl1
prtvar:
		lda #45
		jmp usetbl1
prtvar0:
		lda #46
		jmp usetbl1
getkbd:
		lda #48
		jmp usetbl1
getmod:
		lda #49
		jmp usetbl1
outscn0:
		sta $fe
outscn:
		lda #50
		jmp usetbl1
outmod:
		lda #51
		jmp usetbl1
chkflags:
		lda #52
		jmp usetbl1
output:
		lda #55
		jmp usetbl1

;* chat mode *
chatmode:
		lda #$00
		sta $fe
		sta chatpage
		sta sndrept
		ldx #34
		jsr prtvar0 ;c1$
		lda #1
		sta inchat
		lda case
		pha
		lda #0
		sta case
chat1:
		jsr chatchk
		beq chat3
		lda carrst
		bpl chat1a
		lda #0
		sta carrst
chat1a:
		jsr getkbd
		bne chat2
		jsr getmod
		beq chat1
chat2:
		cmp #cursor_home
		beq chat1
		jsr xchrout
		jmp chat1
chat3:
		pla
		sta case
		lda #0
		sta inchat
		sta usrlin
		ldx #35
		jsr prtvar0 ;c2$
		lda editor
		and #130
		beq chat5
		ldx #39
		jsr prtvar0 ;c3$
chat5:
		ldx #36
		jmp btmvar ;co$

; terminal mode

term0:
		lda #0
		sta interm
		rts
term:
		lda #1
		sta interm
		lda 653
		cmp #6
		beq term0
		jsr getkbd
		beq term1
term2:
		sta $fe
		jsr outmod
term1:
		jsr getmod
		lda $fe
		beq term
		jsr outansi
		jmp term

;output to screen, interpret ansi
outansi:
		ldx #18
		ldy #5
		jsr chkflags
		bne outansi2
		jmp outscn
outansi1:
		inx
		stx ansiptr
		rts
outansi2:
		lda $fe
		ldx ansiptr
		sta ansibuf,x
		lda ansibuf
		cmp #27
		bne outansi0
		cpx #1
		bcc outansi1
		lda ansibuf+1
		cmp #"["
		bne outansi0
		cpx #2
		bcc outansi1
		cpx #14
		bcs outansi0
		lda ansibuf,x
		cmp #";"
		beq outansi1
		cmp #"0"
		bcc outansi3
		cmp #":"
		bcc outansi1
outansi3:
		ldx #2
		stx ansiptr
		cmp #cbm("m")
		beq ansim
		cmp #cbm("A")
		beq ansia
		cmp #cbm("B")
		beq ansib
		cmp #cbm("C")
		beq ansic
		cmp #cbm("D")
		beq ansid
		cmp #cbm("F")
		beq ansih
		cmp #cbm("H")
		beq ansih
		cmp #cbm("J")
		beq ansij
outansi0:
		ldx #0
		stx ansiptr
		stx ansibuf
		stx ansibuf+1
		rts

ansim:
		jsr ansiparm
		bcs outansi0
		cmp #0
		bne ansim1
		lda #reverse_off
		jsr outscn0
		jmp ansim
ansim1:
		cmp #7
		bne ansim2
		lda #reverse_on
		jsr outscn0
		jmp ansim
ansim2:
		cmp #30
		bcc ansim
		cmp #38
		bcs ansim
		sec
		sbc #30
		tax
		lda ansiclrs,x
ansim3:
		jsr outscn0
		jmp outansi0

ansib:
		lda #cursor_down
		byte $2c
ansic:
		lda #cursor_right
		byte $2c
ansid:
		lda #cursor_left
		byte $2c
ansia:
		lda #cursor_up
ansia1:
		sta reptchr
		jsr ansiparm
		bcc ansia2
		lda #1
ansia2:
		sta reptcnt
		jsr ansirept
		jmp outansi0

ansij:
		lda #clear_screen
		jmp ansim3

ansih:
		jsr ansiparm
		bcs outansi0
		sec
		sbc #1
		sta ansiposv
		lda 211
		sta ansiposh
		jsr ansiparm
		bcs ansih1
		sec
		sbc #1
		sta ansiposh
ansih1:
		lda #cursor_home
		jsr outscn0
		lda #cursor_down
		ldx ansiposv
		jsr ansirpt0
		lda #cursor_right
		ldx ansiposh
		jsr ansirpt0
		jmp outansi0

ansirpt0:
		sta reptchr
		stx reptcnt
ansirept:
		lda reptcnt
		beq ansirpt1
		lda reptchr
		jsr outscn0
		dec reptcnt
		jmp ansirept
ansirpt1:
		rts

reptcnt:
		byte 0
reptchr:
		byte 0
ansibuf:
		byte "                  "
ansiptr:
		byte 0
ansiposh:
		byte 0
ansiposv:
		byte 0
ansiprm:
		byte 0
ansiclrs:
		byte cursor_black, cursor_red, cursor_green, cursor_yellow
		byte cursor_blue, cursor_purple, cursor_cyan, cursor_white

ansiparm:
		lda #0
		sta ansiprm
		ldx ansiptr
		lda ansibuf,x
		inc ansiptr
		cmp #";"
		bne ansiprm2
ansiprm1:
		ldx ansiptr
		lda ansibuf,x
		inc ansiptr
ansiprm2:
		cmp #"0"
		bcc ansiprm3
		cmp #":"
		bcc ansiprm4
		clc
		lda ansiprm
		rts
ansiprm3:
		sec
		lda ansiprm
		rts
ansiprm4:
		pha
		lda ansiprm
		asl
		asl
		clc
		adc ansiprm
		asl
		sta ansiprm
		pla
		sec
		sbc #"0"
		clc
		adc ansiprm
		sta ansiprm
		jmp ansiprm1

;print string variable to bottom
btmvar:
		inc scnlock
		lda scnmode
		bne btm2
		ldy #15
		lda #$a0
btm0:
		sta adisp+24,y
		dey
		bpl btm0
		jsr usevar
		ldy #0
		ldx #0
		lda var
		beq btm2
		cmp #16
		bcs btm1
		lda #16
		sec
		sbc var
		lsr
		tax
btm1:
		lda [var+1],y
		jsr chkspcl
		cmp #0
		bmi btm1a
		cmp #64
		bcc btm1a
		eor #64
btm1a:
		ora #$80
		sta adisp+24,x
		inx
		cpx #16
		bcs btm2
		iny
		cpy var
		bcc btm1
btm2:
		dec scnlock
		rts

isalpha:
		cmp #65
		bcc isalpha0
		cmp #91
		bcc isalpha1
		cmp #193
		bcc isalpha0
		cmp #219
		bcc isalpha1
isalpha0:
		clc
		rts
isalpha1:
		sec
		rts

lotbl:
		byte <convnam,<convdsk
		byte <convimg,<chkspcl
hitbl:
		byte >convnam,>convdsk
		byte >convimg,>chkspcl

convert0:
		rts
convert:
		dex
		cpx #4
		bcs convert0
		lda lotbl,x
		sta convs2+1
		lda hitbl,x
		sta convs2+2
		ldx #0
		jsr usevar ;an$
		ldy #0
		ldx #0
convs1:
		cpy var
		beq convs3
		lda [var+1],y
convs2:
		jsr convdsk
		sta [var+1],y
		iny
		bne convs1
convs3:
		rts

convd0:
		byte ",:", function_key_5, "*?=", function_key_6, function_key_8
convdsk:
		cmp #133
		bcc convd1
		cmp #140
		bcs convd1
		sbc #132
		tax
		lda convd0,x
convd1:
		rts

convnam:
		cmp #"'"
		beq convn3
		jsr isalpha
		bcs convn1
		ldx #0
		rts
convn1:
		cpx #0
		bne convn2
		ora #$80
		inx
		rts
convn2:
		and #$7f
		inx
convn3:
		rts

convi0:
		byte "$,*?:=;"
convimg:
		ldx #6
convi1:
		cmp convi0,x
		beq convi2
		dex
		bpl convi1
		rts
convi2:
		lda #"-"
		rts

sound:
		cpx #255
		bne soundx
		lda #0
		sta sndrept
		rts
soundx:
		lda sndrept
		beq sound1
sound0:
		rts
sound1:
		sty sndrept
		cpx #0
		bne sound3
		ldx #27
		ldy #5 ;bel-r
		jsr chkflags
		bne sound0
		ldx #0
sound3:
		txa
		asl
		asl
		asl
		asl
		tax
		lda #$0f
		sta $d418
		lda #0
		sta $d404
		sta $d40b
		sta $d412
		lda sndtbl+4,x
		and #$fe
		sta sndwav1
		lda sndtbl+9,x
		and #$fe
		sta sndwav2
		lda sndtbl+14,x
		and #$fe
		sta sndwav3
		lda sndtbl+15,x
		pha
		lsr
		lsr
		lsr
		lsr
		tay
		lda timetbl,y
		sta sndtim1
		sta sndtim1a
		pla
		and #$0f
		tay
		lda timetbl,y
		sta sndtim2
		sta sndtim2a
		ldy #0
sound4:
		tya
		pha
		lda sndvec,y
		tay
		lda sndtbl,x
		sta $d400,y
		inx
		pla
		tay
		iny
		cpy #15
		bne sound4
		rts

sndvec:
		byte 0,1,5,6,4,7,8,12,13,11,14,15,19,20,18

timetbl:
		byte 010,020,030,040
		byte 050,060,070,080
		byte 090,100,110,120
		byte 150,180,240,001




offset 0
namespace ""

; pad to the start of the next module
		dup 0, $9c00-*

;;;;;
;;;;;
;;;;; $fc00 - swap3
;;;;;
;;;;;

offset $c000-*
namespace "swap3"

hc000:
		jmp read0
hc003:
		jmp newuser
hc006:
		jmp relread
hc009:
		jmp convdate
hc00c:
		jmp copyrite

; jump table routines

outastr:
		lda #0
		byte $2c
dskin:
		lda #2
		byte $2c
usevar:
		lda #29
		byte $2c
putvar:
		lda #30
		byte $2c
zero:
		lda #31
		byte $2c
minusone:
		lda #32
		byte $2c
prtvar0:
		lda #46
		byte $2c
output:
		lda #55
		jmp usetbl1

; file read routines

;* unabortable for new user
newuser:
		lda #1
		sta readmode
		jmp read0

relread:
		lda #$bf
		sta read1b+1

;* main file reader
read0:
		cpx #$00
		beq read0a
		stx filenum
read0a:
		cpy #0
		beq readf
		jmp movie
readf:
		ldx filenum
		ldy #0
		jsr dskin
		lda $90
		sta dstat
		lda index
		beq read1
		lda buf2
		cmp #"^"
		beq read2
read1:
		jsr zero
		lda index
		cmp #80
		beq read1a
		jsr minusone
read1a:
		ldx #15
		jsr putvar ;lp
		jsr zero
		ldx #17
		jsr putvar ;rc
		jsr outastr
		lda dstat
read1b:
		and #$ff
		bne read2
		lda readmode
		bne readf
		ldx #17
		jsr usevar ;rc
		lda var
		beq readf
read2:
		lda #$ff
		sta read1b+1
		lda #0
		sta readmode
		rts

; movie view

movie:
		sty movdly
movie1:
		ldx filenum
		jsr chkin
		jsr chrin
		sta $fe
		jsr readst
		pha
		jsr clrchn
		ldx movdly
		ldy#0
dl1:
		dey
		bne dl1
		dex
		bne dl1
		jsr output
		pla
		ldx chat
		bne movie2
		tax
		beq movie1
movie2:
		rts
movdly:
		byte 0

; print copyright message

copyrite:
		lda outastrp+1
		sta jmptbl
		lda outastrp+2
		sta jmptbl+1

		ldy #copylen-1
loop:
		lda copymsg,y
		eor #$ff
		sta buffer,y
		dey
		bpl loop

		lda #1
		sta var
		lda #<bsnpre
		sta var+1
		lda #>bsnpre
		sta var+2
		ldx #1
		jsr putvar ;a$

		lda bsnval
		sta var+1
		lda bsnval+1
		sta var
		ldx #31
		jsr putvar ;a%

		lda #copylen
		sta var
		lda #<buffer
		sta var+1
		lda #>buffer
		sta var+2
		ldx #0
		jsr putvar ;an$

		ldx #0
		jmp prtvar0 ;an$

enc 255

copymsg:
		byte function_key_6, british_pound, 95
		cbm "07IMAGE BBS 64 V2.0 S# "
		byte british_pound
		cbm "$a"
		byte british_pound
		cbm "#4"
		byte british_pound
		cbm "%b"
		byte function_key_6
		byte british_pound, 95
		cbm "06(C) 1991  NEW IMAGE SOFTWARE"
		byte function_key_6
enc 0
copylen = *-copymsg

mult3:
		tya
		sta mult3a+1
		asl
		clc
mult3a:
		adc #$00
		tay
		rts

;* convert date to string *
convdate:
		jsr timezone
		lda datebuf
		ldy #0
		and #15
		beq conv00
		cmp #8
		bcs conv00
		tay
conv00:
		jsr mult3
		ldx #0
convdate_loop1:
		lda daytbl,y
		sta date1,x
		iny
		inx
		cpx #3
		bcc convdate_loop1
		lda datebuf+4
		and #15
		ldx datebuf+3
		cpx #"0"
		beq conv01
		clc
		adc #10
conv01:
		ldy #13
		cmp #0
		beq conv02
		cmp #13
		bcs conv02
		tay
		dey
conv02:
		jsr mult3
		ldx #4
convdate_loop2:
		lda montbl,y
		sta date1,x
		iny
		inx
		cpx #7
		bcc convdate_loop2
		lda datebuf+1
		sta date1+14
		lda datebuf+2
		sta date1+15
		lda datebuf+5
		sta date1+8
		lda datebuf+6
		sta date1+9
		lda datebuf+9
		sta date1+20
		lda datebuf+10
		sta date1+21
		lda datebuf+7
		and #cbm("1")
		sta date1+17
		lda datebuf+8
		sta date1+18
		ldx #17
		jsr convert6
		ldx #8
		jsr convert6
		lda datebuf+7
		ldx #cbm("P")
		cmp #cbm("8")
		bcs convert5
		ldx #cbm("A")
convert5:
		stx date1+23
		rts

convert6:
		lda date1,x
		cmp #cbm("0")
		bne convert7
		lda #cbm(" ")
		sta date1,x
convert7:
		rts

atob:
		lda datebuf,y
		and #$0f
		tax
		iny
atob0:
		lda datebuf,y
		and #$0f
		iny
		cpx #0
		beq atob2
atob1:
		clc
		adc #10
		dex
		bne atob1
atob2:
		rts

btoa:
		ldx #0
btoa1:
		cmp #10
		bcc btoa2
		sbc #10
		inx
		bne btoa1
btoa2:
		pha
		txa
		jsr btoa3
		pla
btoa3:
		ora #$30
		sta datebuf,y
		iny
		rts

htom:
		cmp #12
		beq htom1
		cmp #92
		bne htom2
htom1:
		sec
		sbc #12
htom2:
		cmp #80
		bcc htom3
		sbc #68
htom3:
		rts

mtoh:
		cmp #12
		bcc mtoh1
		clc
		adc #68
mtoh1:
		cmp #0
		beq mtoh2
		cmp #80
		bne mtoh3
mtoh2:
		clc
		adc #12
mtoh3:
		rts

dday:
		byte 0
dyear:
		byte 0
dmonth:
		byte 0
ddate:
		byte 0
dhour:
		byte 0
dmin:
		byte 0

timezone:
		ldx #0
		ldy #0
		jsr atob0
		sta dday
		jsr atob
		sta dyear
		jsr atob
		sta dmonth
		jsr atob
		sta ddate
		jsr atob
		jsr htom
		sta dhour
		jsr atob
		sec
		sbc tzonem
		bcs tz01
		adc #60
		clc
tz01:
		sta dmin
		lda dhour
		sbc tzoneh
		bcs tz02
		adc #24
		clc
tz02:
		sta dhour
		bcs tz06
		ldx dday
		dex
		bne tz03
		ldx #7
tz03:
		stx dday
		ldx ddate
		dex
		bne tz05
		ldx dmonth
		dex
		bne tz04
		dec dyear
		ldx #12
tz04:
		stx dmonth
		lda daysofm-1,x
		tax
tz05:
		stx ddate

tz06:
		lda dmin
		clc
		adc uzonem
		cmp #60
		bcc tz07
		sbc #60
		sec
tz07:
		sta dmin
		lda dhour
		adc uzoneh
		cmp #24
		bcc tz08
		sbc #24
		sec
tz08:
		sta dhour
		bcc tz11
		ldx dday
		inx
		cpx #8
		bcc tz09
		ldx #1
tz09:
		stx dday
		lda ddate
		ldx dmonth
		cmp daysofm,x
		bcc tz10
		lda #0
		inx
		cpx #13
		bcc tz10
		ldx #1
		inc dyear
tz10:
		stx dmonth
		tax
		inx
		stx ddate

tz11:
		ldy #0
		lda dday
		jsr btoa3
		lda dyear
		jsr btoa
		lda dmonth
		jsr btoa
		lda ddate
		jsr btoa
		lda dhour
		jsr mtoh
		jsr btoa
		lda dmin
		jsr btoa
		rts

offset 0
namespace ""

; pad to start of next module
		dup 0, jmptbl-*


; jump table for &'s
; jmptbl:
		word outastr ;&
		word $f400 ;1-inline
		word dskin ;&,2
		word $fc00 ;3-read0
		word getmdm ;&,4
		word getversn ;&,5
		word $f406 ;6-password
		word prgfile ;&,7
		word dskdir ;&,8
		word $f806 ;9-btmvar
		word $f800 ;10-term
		word $ee00 ;11-clrarr
		word $fc03 ;12-newuser
		word inchr ;&,13
		word dumparr ;&,14
		word convan ;&,15
		word 49152 ;&,16
		word 49155 ;&,17
		word setmode ;&,18
		word getversn ;&,19
		word getversn ;&,20
		word getversn ;&,21
		word tenwait ;&,22
		word xgetin ;&,23
		word xchrout1 ;&,24
		word $f80c ;25-sound
		word callmod ;&,26
		word arraysav ;&,27
		word arrayres ;&,28
		word usevar ;&,29
		word putvar ;&,30
		word zero ;&,31
		word minusone ;&,32
		word getarr ;&,33
		word putarr ;&,34
		word getln ;&,35
		word putln ;&,36
		word trapon ;&,37
		word trapoff ;&,38
		word prtln ;&,39
		word forcegc ;&,40
		word setbaud ;&,41
		word $e400 ;42-ecs
		word chatchk ;&,43
		word trace0 ;&,44
		word prtvar ;&,45
		word prtvar0 ;&,46
		word carchk ;&,47
		word getkbd ;&,48
		word getmod ;&,49
		word outscn ;&,50
		word outmod ;&,51
		word chkflags ;&,52
		word logoff ;&,53
		word $f409 ;54-useeditr
		word output ;&,55
		word $f803 ;56-chatmoe
		word $fc06 ;57-relread
		word setalm ;&,58
		word farerr ;&,59
		word struct ;&,60
		word poscrsr ;&,61
		word settim ;&,62
		word $f403 ;63-inline1
		word $f809 ;64-convstr
		word $fc09 ;65-convert
		word calcgoto ;&,66
		word $fc0c ;67-copyrite
		word $ee03 ;68-struct
		word dispstr ;&,69
		word cursposn ;&,70
		word cursmenu ;&,71


;*
;* string output routines *
;*

;* output string
outstr:
		lda #0
		sta $96
		lda var
		sta len1
		lda var+1
		sta $71
		lda var+2
		sta $72
		jsr gettsr
		beq outstr0
		lda flag
		bne outstr5
outstr0:
		lda mjump
		beq outstr1
		dec mjump
		beq outstr1
		bne outstr5
outstr1:
		jsr zero
		ldx #17
		jsr putvar ;rc
		ldx #15
		jsr usevar ;lp
		ldx #0
		lda var
		beq outstr2
		inx
outstr2:
		stx wrapflg
		lda #0
		sta lastout
		jsr outstr7
		jsr zero
		lda chat
		sta var+1
		ldx #38
		jsr putvar ;kp%
		lda chat
		beq outstr3
		jsr minusone
		ldx #17
		jsr putvar ;rc
		jsr zero
		ldx #18
		jsr putvar ;sh
		lda chat
		cmp #"/"
		bne outstr3
		lda #$86
		sta var
		lda #$3c
		sta var+1
		ldx #18
		jsr putvar ;sh
outstr3:
		lda wrapflg
		beq outstr6
		lda lastout
		cmp #32
		beq outstr5
outstr4:
		lda #13
		sta $fe
		jsr output
outstr5:
		jsr zero
		ldx #15
		jsr putvar ;lp
outstr6:
		rts

lastout:
		byte 0

outstr7:
		jsr setoutmd
		lda #0
		sta chat
		jsr carchk
		cmp #1
		bne outstr8
		lda #"/"
		sta chat
		rts
outstr8:
		lda len1
		beq outstr11
		ldy $96
outstr9:
		sty $96
		lda [$71],y
		sta $fe
		sta lastout
		jsr domci
		jsr moreprmt
		lda chat
		beq outstr10
		lda wrapflg
		beq outstr10
		lda readmode
		bne outstr10
		rts
outstr10:
		ldy $96
		iny
		cpy len1
		bcc outstr9
outstr11:
		rts

convtbl:
		byte <convan0,<convstr
		byte <convstr,<convstr
		byte <convstr,<newdate
		byte <strscan
convtbh:
		byte >convan0,>convstr
		byte >convstr,>convstr
		byte >convstr,>newdate
		byte >strscan

; manipluate an$
convan:
		cpx #7
		bcs cjmp
		lda convtbl,x
		sta cjmp+1
		lda convtbh,x
		sta cjmp+2
cjmp:
		jmp convan0

convan0:
		ldx #0
		jsr usevar ;an$
		ldy #10
convan1:
		lda [var+1],y
		sta datebuf,y
		dey
		bpl convan1
		jsr convert
		lda #20
		jsr makeroom
		ldy #19
convan2:
		lda date1+4,y
		sta [var+1],y
		dey
		bpl convan2
		ldx #0
		jmp putvar ;an$

ctrlchk0:
		pha
		and #$7f
		cmp #32
		pla
		rts

; carry clear if control
ctrlchk:
		pha
		lda editor
		and #1
		beq ctrlch0
		pla
ctrlchk1:
		jsr colorchk
		bcc ctrlch2
		jsr ctrlchk2
		bcc ctrlch2
		pha
ctrlch0:
		pla
		cmp #32
		bcc ctrlch1
		cmp #128
		bcc ctrlch2
		cmp #160
		bcs ctrlch2
		cmp #133
		bcc ctrlch1
		cmp #141
		bcs ctrlch1
ctrlch2:
		sec
		rts
ctrlch1:
		clc
		rts

; carry clear if color chr
colorchk:
		sty cytmp
		ldy #15
colrch0:
		cmp colors,y
		beq colrch1
		dey
		bne colrch0
		ldy cytmp
		sec
		rts
colrch1:
		ldy cytmp
		clc
		rts

ctrlchk2:
		cmp #reverse_on
		beq ctrlch2a
		cmp #reverse_off
		beq ctrlch2a
		cmp #cursor_down
		beq ctrlch2a
		cmp #cursor_up
		beq ctrlch2a
		cmp #cursor_right
		beq ctrlch2a
		cmp #cursor_left
		beq ctrlch2a
		sec
		rts
ctrlch2a:
		clc
		rts

more0:
		rts
moreprmt:
		lda local
		bne more0
		lda usrlinm
		beq more0
		lda usrlin
		cmp usrlinm
		bcc more0
		ldx #34
		ldy #5
		jsr chkflags
		beq more0
		lda #0
		sta usrlin
		ldx #4
moreprmt_loop1:
		lda var,x
		pha
		dex
		bpl moreprmt_loop1
		ldx #48
		jsr usevar ;mp$
		ldy #0
moreprmt_loop2:
		lda [var+1],y
		jsr xchrout
		iny
		cpy var
		bcc moreprmt_loop2
		lda #1
		jsr comy0
		bne more1
		lda #"/"
		sta chat
more1:
		ldy #0
moreprmt_loop3:
		lda #20
		jsr xchrout
		iny
		cpy var
		bcc moreprmt_loop3
		ldx #0
moreprmt_loop4:
		pla
		sta var,x
		inx
		cpx #5
		bcc moreprmt_loop4
		rts

newdate:
		ldx #0
		jsr usevar ;an$
		lda var
		cmp #11
		bne newd0
		ldy #7
		lda [var+1],y
		and #"1"
		cmp #"1"
		bne newd2
		iny
		lda [var+1],y
		cmp #"2"
		bne newd2
		lda #"0"
		sta [var+1],y
		dey
		lda [var+1],y
		and #"8"
		sta [var+1],y
newd2:
		dec var
		inc var+1
		bne newd1
		inc var+2
newd1:
		ldx #0
		jsr putvar ;an$
newd0:
		rts

strscan:
		sty strsc2+1
		ldx #0
		jsr usevar ;an$
		ldy #0
		ldx #0
		lda var
		beq strsc3
strsc1:
		lda [var+1],y
		dec var
		inc var+1
		bne strsc2
		inc var+2
strsc2:
		cmp #32
		beq strsc3
		sta buf2,x
		inx
		lda var
		bne strsc1
strsc3:
		stx index
		ldx #0
		jsr putvar ;an$
		lda index
		sta var
		lda #<buf2
		sta var+1
		lda #>buf2
		sta var+2
		ldx #1
		jmp putvar ;a$



;* message command interpreter

;* mci routines follow *
domci0:
		jmp notc1
domci:
		cmp #british_pound
		bne domci0
		ldx mci
		bne domci0
		inc $96
		ldy $96
		lda [$71],y
		cmp #british_pound
		beq domci0
		and #63
		sta mcom
		inc $96
		iny
		lda [$71],y
		sta mchr
		and #$0f
		sta mnum
		iny
		lda [$71],y
		sta mchr2
		and #$0f
		sta mnum2
		lda mnum
		asl
		asl
		clc
		adc mnum
		asl
		clc
		adc mnum2
		sta mval
		iny
		lda [$71],y
		sta mchr3
;* actual mci routines *
		lda mcom
		cmp #40
		bcs combad
		asl
		tax
		lda comtbl,x
		sta comjmp+1
		lda comtbl+1,x
		sta comjmp+2
		lda mchr
		ldx mnum
comjmp:
		jmp $ffff
combad:
		jmp notc
mcom:
		byte 0
mnum:
		byte 3
mchr:
		byte 0
mnum2:
		byte 0
mchr2:
		byte 0
mval:
		byte 0
mchr3:
		byte 0

comtbl:
		word notc,coma,comb,comc
		word comd,come,comf,comg
		word comh,comi,comj,comk
		word coml,mcicomm,comn,como
		word comp,comq,comr,coms
		word comt,comu,comv,comw
		word comx,comy,notc,notc
		word notc,notc,notc,ctab
		word notc,cvar,notc,clen
		word cstr,cnum,notc,notc

mcivars:
		cbm "d1ldnarnphbnb"
		byte $80
		cbm "and2d3akltd4agccdd"

mcivar:
		txa
		asl
		tay
		lda mcivars+1,y
		ora #$80
		tax
		lda mcivars,y
		jmp usevar0

colors:
		byte cursor_cyan ; (default color)
		byte cursor_white
		byte cursor_red
		byte cursor_cyan
		byte cursor_purple
		byte cursor_green
		byte cursor_blue
		byte cursor_yellow
		byte cursor_orange
		byte cursor_brown
		byte cursor_lt_red
		byte cursor_gray1
		byte cursor_gray2
		byte cursor_lt_green
		byte cursor_lt_blue
		byte cursor_gray3

;* \a - compare to variable
coma:
		jsr mcivar
		lda var+1
		sta coma2+1
		lda var+2
		sta coma2+2
		ldx #0
coma1:
		inc $96
		ldy $96
		lda [$71],y
		cmp #british_pound
		beq coma3
coma2:
		cmp $ffff,x
		bne coma4
		inx
		jmp coma1
coma3:
		lda #1
		sta mresult
		rts
coma4:
		lda #0
		sta mresult
coma5:
		inc $96
		ldy $96
		cpy #80
		beq coma6
		lda [$71],y
		cmp #british_pound
		bne coma5
coma6:
		rts

;* \b - send bells
comb:
		lda #7
		jmp repchr

;* \k - kolorific
comk:
		stx mkolor
		beq comc2

;* \c - set color
comc:
		lda mnum
		bne comc1
		comqc=*+1
		ldx #3
		beq comc2
comc1:
		tay
		lda colors,y
		sta $fe
		jmp output
comc2:
		rts

;* \d - branch on not equal
comd:
		lda mresult
		beq comj
		rts

;* \e - branch on equal
come:
		lda mresult
		bne comj
		rts

;* \j - skip lines
comj:
		lda mnum
comj1:
		cmp #0
		beq comj2
		sta mjump
		lda #240
		sta $96
comj2:
		rts

;* \f - send form feed
comf:
		lda #$93
		sta $fe
		jmp output

;* \g - get character
comg:
		txa
		and #1
		sta case
		jmp inchr

;* \h - send backspaces
comh:
		lda #20
		jmp repchr

;* \i - input to buffer
comi:
		txa
		and #1
		sta case
		lda #0
		sta tmp1
		lda #4
		sta editor
		lda #0
		sta passmode
		jsr zero
		ldx #0
		jsr putvar ;an$
		lda $96
		pha
		lda $71
		pha
		lda $72
		pha
		lda len1
		pha
		jsr inline0
		pla
		sta len1
		pla
		sta $72
		pla
		sta $71
		pla
		sta $96
		rts

;* \l - send output to printer
coml:
		txa
		and #1
		sta mprtr
		rts

;* \m - margin set
mcicomm:
		ldx mnum2
		cmp #"<"
		bne comm1
		stx mleft
comm1:
		cmp #">"
		bne comm2
		stx mright
comm2:
		inc $96
		rts

;* \n - send carriage returns
comn:
		lda #13
		jmp repchr

;* \o - output 19 characters
como:
		ldx #19
		jmp repchr

;* \p - set print mode
comp:
		stx mprint
		rts

;* \q - reset mci settings
comq:
		beq comq1
		stx comqc
comq1:
		jsr comc
		lda #0
		sta mjump
		sta mnum
		sta mreverse
		sta mprtr
		sta mprint
		sta mspeed
		sta mkolor
		sta mdigits
		sta mci
		sta mleft
		sta mright
		jmp comu1

;* \r - reverse mode
comr:
		txa
		and #1
		lsr
		ror
		eor #$92
		sta $fe
		jmp outchr

;* \s - set print speed
coms:
		stx mspeed
		rts

;* \t - compare to buffer
comt:
		cpx #2
		bne comt1
		ldx #24
		jsr usevar ;ac%
		lda var+1
		and #$0f
		ora #"0"
		sta buffer
comt1:
		lda #<buffer
		sta coma2+1
		lda #>buffer
		sta coma2+2
		ldx #0
		jmp coma1

;* \u - uppercase mode
comu:
		txa
comu1:
		and #1
		sta mupcase
		lsr
		ror
		eor #$0e
		sta $fe
		jmp outchr

;* \v - print variable
comv:
		stx mcom
		jsr mcivar
comv0:
		lda var
		sta comv1+1
		lda var+1
		sta comv3+1
		lda var+2
		sta comv3+2
		lda #0
		sta comv2+1
comv1:
		lda #$ff
comv2:
		cmp #$ff
		beq comv6
		ldy comv2+1
comv3:
		lda $ffff,y
		sta $fe
		ldx mcom
		cpx #2
		bcs comv4
		sta datebuf,y
		jmp comv5
comv4:
		jsr domode
comv5:
		inc comv2+1
		jmp comv1
comv6:
		ldx mcom
		cpx #2
		bcs comv8
		jsr convert
		lda #0
		sta comv2+1
comv7:
		ldy comv2+1
		lda date1,y
		sta $fe
		jsr output
		inc comv2+1
		lda comv2+1
		cmp #25
		bcc comv7
comv8:
		rts

;* \w - wait
comw:
		beq comw2
		inx
comw1:
		lda scs
; wait for scs to change
comw1a:
		cmp scs
		beq comw1a
		dex
		bne comw1
comw2:
		rts

;* \x - abort file read
comx:
		lda #32
		sta chat
		rts

;* \y - yes/no
comy:
		txa
		and #1
		jsr comy0
		stx mresult
		rts

comy0:
		pha
		lda #1
		sta $d001
		jsr xgetchr
		tax
		pla
		cpx #cbm("N")
		bne comy1
		lda #0
comy1:
		cpx #cbm("Y")
		bne comy2
		lda #1
comy2:
		cmp #0
		rts

cvar:
		lda $96
		pha
		lda $71
		pha
		lda $72
		pha
		lda mchr
		and #$7f
		ldx #0
		jsr usevar0
		lda $62
		sta $66
		ora #$80
		sta $62
		jsr fpout
		lda #0
		sta cvar1+1
		lda $0100
		cmp #" "
		beq cvar2
cvar1:
		lda $0100
		beq cvar3
		sta $fe
		jsr output
cvar2:
		inc cvar1+1
		bne cvar1
cvar3:
		pla
		sta $72
		pla
		sta $71
		pla
		sta $96
		rts

;* \# - length of field / fill chr
clen:
		lda mchr
		cmp #$30
		bcc clen1
		cmp #$3a
		bcs clen1
		lda mnum
		cmp #5
		bcc clen0a
		lda #5
clen0a:
		sta mdigits
		lda #"0"
clen1:
		sta cnumc
		rts

;* \$ - print string variable
cstr:
		lda #2
		sta mcom
		lda mchr
		ldx #$80
		jsr usevar0
		jmp comv0

;* \% - print integer variable
cnum:
		lda mchr
		ora #$80
		ldx #$80
		jsr usevar0
		ldx var
		lda var+1
prax:
		jsr decimal
		ldy #0
		sty cnumf
		ldx mdigits
		beq cnum1
		lda #5
		sec
		sbc mdigits
		tay
cnum1:
		sty cnumd
		lda decchr,y
		cpy #4
		bcs cnum2
		ldx cnumf
		bne cnum2
		cmp #"0"
		bne cnum2
		ldx mdigits
		beq cnum3
		lda cnumc
		sta $fe
		jsr domode
		jmp cnum3
cnum2:
		sta $fe
		jsr domode
		inc cnumf
cnum3:
		ldy cnumd
		iny
		cpy #5
		bne cnum1
		rts
cnumf:
		byte 0
cnumd:
		byte 0
cnumc:
		byte "0"

;\_ - mci tab
ctab:
		inc $96
		lda mval
		cmp scnpos
		bcc ctab0
		beq ctab0
		cmp #40
		bcs ctab0
ctab1:
		lda #" "
		sta $fe
		jsr output
		lda mval
		cmp scnpos
		bne ctab1
ctab0:
		rts

;* repeat a character(\b,\h,\n,\o)
repchr:
		sta tmp5
		cpx #0
		beq repchr2
		stx tmp2
repchr1:
		lda tmp5
		sta $fe
		jsr domode
		dec tmp2
		bne repchr1
repchr2:
		rts

;* not an mci command
notc:
		dec $96
		dec $96
		lda #british_pound
notc1:
		cmp #$04
		bne domode

;* handle ctrl-d in string
		ldx #0
dodate:
		inc $96
		ldy $96
		lda [$71],y
		sta datebuf,x
		inx
		cpx #11
		bne dodate
		jsr convert
		lda #0
		sta index
dodate1:
		ldy index
		lda date1,y
		beq dodate2
		sta $fe
		jsr output
		inc index
		bne dodate1
dodate2:
		rts

;* do print modes
domode:
		sta $fe
		ldx mprint
		bne domode0
		jsr dospeed
		jmp output
domode0:
		jsr chkspcl0
		and #$7f
		cmp #32
		bcs domode1
		jmp output
domode1:
		lda $fe
		sta tmp4
		txa
		and #15
		tax
		lda pmodetbl,x
		sta domode2+1
domode2:
		ldx #16
		lda pmodetbl,x
		beq domode5
		cmp #$ff
		beq domode6
domode3:
		sta $fe
		jsr output
		inc domode2+1
		bne domode2
domode5:
		rts
domode6:
		jsr dospeed
		lda tmp4
		jmp domode3

;* do print speed
dospeed:
		ldx mspeed
		beq dokolor
		jsr tenwait
;* do kolorific
dokolor:
		lda mkolor
		beq donone
		ldx mcolor
dokolor1:
		inx
		txa
		and #15
		beq dokolor1
		sta mnum
		lda $fe
		pha
		jsr comc
		pla
		sta $fe
donone:
		rts

; wait for .x tenths of a second
tenwait:
		cpx #0
		beq tnw3
tnw1:
		lda ten
tnw2:
		cmp ten
		beq tnw2
		dex
		bne tnw1
tnw3:
		rts


;* character output routines *

;* output character in .a
;* preserve registers
xchrout:
		sta $fe
xchrout1:
		tya
		pha
		txa
		pha
		jsr outchr
xchrout2:
		pla
		tax
		pla
		tay
		lda $fe
		rts

;* output character, and
;* get response character
output:
		jsr outchr
		jsr getchr
		ldx #$a0
		lda $fe
		beq output1a
		cmp #cursor_home
		beq output2
output0:
		ldx #$a0
		cmp #"/"
		beq output1
		cmp #" "
		beq output1
		cmp #3
		bne output1a
output1:
		sta chat
		ldx #$c1 ; reverse capital "A"
output1a:
		stx tdisp+30
		rts
output2:
		lda #$d0 ; reverse capital "P"
		sta tdisp+30
		jsr xgetchr0
		lda #$a0
		sta tdisp+30
		lda $fe
		jmp output0

setoutmd:
		lda passmode
		and #1
		beq setout1
		ldx #<outchr1
		ldy #>outchr1
		bne setout4
setout1:
		lda mci
		bpl setout2
		ldx #<outchr2
		ldy #>outchr2
		bne setout4
setout2:
		lda wrapflg
		beq setout3
		ldx #<outchr4
		ldy #>outchr4
		bne setout4
setout3:
		ldx #<outchr3
		ldy #>outchr3
setout4:
		stx outchr0+1
		sty outchr0+2
		rts

;* output character
outchr:
		lda $fe
		jsr chkspcl0
		sta $fe
		jsr setoutmd
		lda $fe
outchr0:
		jmp outchr1

outchr1:
		jsr ctrlchk0
		bcc outchr3
		lda mask
		sta $fe
		jmp outchr3

outchr2:
		jsr ctrlchk0
		bcs outchr3
		cmp #13
		beq outchr3
		cmp #20
		beq outchr3
		pha
		lda #reverse_on
		jsr outchr2a
		pla
		ora #64
		jsr outchr2a
		lda #reverse_off
outchr2a:
		sta $fe

outchr3:
		jsr outscn0
		jsr outmdm0
		jmp outptr

outchr4:
		lda $fe
		ldx wrapind
outchr5:
		sta wrapbuf,x
		inx
		stx wrapind
		and #$7f
		cpx #80
		bcs outchr6
		cmp #33
		bcc outchr6
		rts
flushwrd:
		ldx wrapind
		bne outchr6
		rts
outchr6:
		lda #13
		sta $fe
		clc
		lda wrapind
		adc scnpos
		adc mright
		cmp #41
		bcc outchr6a
		jsr outscn
		clc
outchr6a:
		lda wrapind
		adc ptrclm
		adc mright
		tay
		dey
		cpy ptrclmn
		bcc outchr6b
		jsr outptr
		clc
outchr6b:
		lda wrapind
		adc modclm
		adc mright
		tay
		dey
		cpy modclmn
		bcc outchr6c
		jsr outmdm
outchr6c:
		ldy #0
		sty wrapdmp
outchr7:
		cpy wrapind
		beq outchr7a
		lda wrapbuf,y
		sta $fe
		jsr outscn
		jsr outmdm
		jsr outptr
		inc wrapdmp
		ldy wrapdmp
		bne outchr7
outchr7a:
		lda #0
		sta wrapind
		rts

outmdm:
		lda wrapflg
		beq outmdm0
		lda $fe
		cmp #32
		bne outmdm0
		ldx modclm
		inx
		cpx modclmn
		bcs outmdm2
outmdm0:
		lda $fe
		ldx modclm
		ldy usrlin
		jsr outadj
		stx modclm
		sty usrlin
		lda inchat
		bne outmdm1
		jsr carchk4
		bne outmdm2
outmdm1:
		lda $fe
		cmp #13
		bne outmdm3
		ldx mleft
		beq outmdm3
		stx outmdmc
		jsr outmod
		lda #" "
		sta $fe
outmdm4:
		jsr outmod
		dec outmdmc
		bne outmdm4
		lda #13
		sta $fe
		rts
outmdm3:
		jmp outmod
outmdm2:
		rts
outmdmc:
		byte 0

		mprtr = *+1
outptr:
		ldx #0
		bne outptr5
		outptrfl=*+1
outptr6:
		ldx #0
		bne outptr5
		rts

outptr5:
		lda $fe
		and #$7f
		cmp #32
		lda $fe
		bcs outptr0
		jsr colorchk
		bcc outptr4
		jsr ctrlchk2
		bcc outptr4
		cmp #13
		bne outptr4
outptr0:
		ldx ptrclm
		ldy ptrlin
		jsr outadj
		stx ptrclm
		sty ptrlin
outptr1:
		ldx #4
		jsr chkout
		lda $90
		bmi outptr3
		lda $fe
		jsr chrout
		cmp #13
		bne outptr3
		lda ptrlnfd
		beq outptr2
		jsr chrout
outptr2:
		lda #0
		sta mprtr
		ldx mleft
		beq outptr3
outptr7:
		lda #" "
		jsr chrout
		dex
		bne outptr7
outptr3:
		jmp clrchn
outptr4:
		rts

;* output carriage return
prcr:
		lda #$0d
		jmp xchrout
;* output delete character
prdel:
		lda #$14
		jmp xchrout

;* character input routines *

;* get character into .a
;* handle mci access
xgetin:
		jsr xgetchr
		cmp #cursor_home
		beq xgetin
		cmp #british_pound
		bne xgetin2
		lda editor
		and #$08
		bne xgetin1
		jmp xgetin
xgetin1:
		lda #british_pound
xgetin2:
		rts

xgetchr:
		jsr setoutmd
		jsr flushwrd
		lda #0
		sta usrlin
xgetchr0:
		jsr getchr
		jsr carchk
		bne xgetchr1
		jsr chatchk
		bne xgetchr1
		lda $fe
		beq xgetchr0
		rts
xgetchr1:
		lda #13
		rts

;* input character to an$
;* waits for character
inchr:
		jsr xgetin
		lda $fe
		sta buffer
		lda #1
		sta var
		lda #<buffer
		sta var+1
		lda #>buffer
		sta var+2
		ldx #$00
		jmp putvar ;an$

;* get character
;* with case setting
getchr:
		jsr getkbd
		bne getchr1
		jsr carchk4
		bne getchr7
		jsr getmod
getchr1:
		cmp #$60
		bcc getchr3
		cmp #$80
		bcs getchr3
		adc #$60
getchr3:
		cmp #$a0
		bcc getchr4
		cmp #$bf
		bcs getchr4
		adc #$40
getchr4:
		cmp #$e0
		bne getchr5
		lda #$20
getchr5:
		cmp #$de
		bne getchr6
		lda #$ff
getchr6:
		tax
		lda editor
		and #$01
		bne getchr8
		cpx #$e0
		bcs getchr7
		cpx #$7b
		bcc getchr8
		cpx #$80
		bcs getchr8
getchr7:
		ldx #0
getchr8:
		stx $fe
		lda curdsp
		beq getchr9
		ldx #4
		ldy #5
		jsr chkflags
		bne getchr9
		lda idlejif
		cmp #60
		bcc getchr9
		lda #0
		sta idlejif
		lda idlesec
		ldx idleten
		ldy idlemin
		clc
		adc #1
		cmp #10
		bcc getchr8a
		lda #0
		inx
		cpx #6
		bne getchr8a
		ldx #0
		iny
		cpy idlemax
		bcc getchr8a
		pha
		lda #0
		jsr settsr
		pla
getchr8a:
		jsr dspidle
getchr9:
		lda $fe
		ldx case
		beq getchr11
		cmp #$41
		bcc getchr11
		cmp #$5b
		bcs getchr11
		ora #$80
getchr11:
		ldx #7
getchr12:
		cmp spchars,x
		beq getchr13
		dex
		bpl getchr12
		bmi getchr14
getchr13:
		cpx #6
		beq getchr14
		txa
		clc
		adc #$85
getchr14:
		sta $fe
		rts

getkbd:
		jsr crsron
getkbd0:
		ldx fkeybuf
		beq getkbd2
		inc fkeybuf
		lda fkeybuf,x
		bne getkbd1
		lda #0
		sta fkeybuf
getkbd2:
		lda 198
		bne getkbd3
		rts
getkbd3:
		jsr $f142
		cmp #$85
		bcc getkbd1
		cmp #$8d
		bcs getkbd1
		lda #0
getkbd1:
		cmp #0
		rts

;* get character from the modem
;* and move recieve window
getmdm:
		jsr rsinabl
		sec
		jsr rsget
		bcs getmdm6
		pha
		ldx #16
		ldy #5
		jsr chkflags
		beq getmdm1
		pla
		and #$7f
		pha
getmdm1:
		pla
		rts
getmdm6:
		lda #0
		rts

;********************************
;* misc character routines *
;* last revision: 8/30/87 *
;********************************

;check carrier
; returns:

;0 if carrier / local
;1 if carrier dropped
;2 if time out

carchk:
		lda local
		bne carchk2
		ldx #4
		ldy #5
		jsr chkflags
		bne carchk2
		jsr carchk3
		beq carchk1
		lda #0
		jsr settsr
		jsr disptime
		lda #1
		rts
carchk1:
		jsr gettsr
		bne carchk2
		lda editor
		and #$40
		bne carchk2
		lda #2
		rts
carchk2:
		lda #0
		rts
; check actual carrier
; 0 = ok
; 1 = drop
carchk3:
		lda carrst
		and #127
		rts

;check if it's ok to use the modem
; 0 = ok
; <>0 = no
carchk4:
		ldx #4
		ldy #5
		jsr chkflags
		bne carchk5
		lda local
		bne carchk5
		jmp carchk3
carchk5:
		rts

chatchk:
		ldx #8
		ldy #5
		jmp chkflags

outadj:
		cmp #13
		beq outadj1
		cmp #20
		beq outadj3
		cmp #cursor_right
		beq outadj4
		cmp #cursor_left
		beq outadj3
		cmp #cursor_down
		beq outadj7
		cmp #cursor_up
		beq outadj6
		and #$7f
		cmp #cursor_home
		beq outadj8
		cmp #32
		bcs outadj4
		rts
outadj1:
		iny
outadj2:
		ldx #0
		rts
outadj3:
		cpx #0
		beq outadj5
		dex
		rts
outadj4:
		inx
outadj5:
		rts
outadj6:
		cpy #0
		bne outadj5
		dey
		rts
outadj7:
		iny
		rts
outadj8:
		ldx #0
		ldy #0
		rts



modtype:
		byte 0
modst:
		word prgstart

modtbl:
		word 0 ;0
		word 0 ;1
		word protostart ;2
		word 0 ;3
		word 0 ;4
		word imstart ;5
		word imstart ;6
		word pmodetbl ;7
		word bartbl ;8
		word alarmtb ;9
		word tblatc ;10
		word tblcta ;11
		word netalrm ;12
		word wedgemem ;13

;* program load routines

;* load various types of modules

prgfile:
		cpx #0
		bne prg0
		ldx #8
prg0:
		stx filenum
		sty modtype
		cpy #14
		bcc prg1
		rts
prg1:
		tya
		asl
		tay
		lda modtbl,y
		tax
		lda modtbl+1,y
		tay
		stx modst
		sty modst+1
		ldx #1
		jsr usevar ;a$
		lda #0
		jsr setmsg
		lda #1
		ldy #0
		ldx filenum
		jsr setlfs
		ldx var+1
		ldy var+2
		lda var
		jsr setnam
		lda modst+1
		beq prg2
		jsr rsdisab
		lda #0
		ldx modst
		ldy modst+1
		jsr loadf
		jsr rsinabl
		bcs prgerr
		rts
; load error
prgerr:
		ldx #29
		jmp farerr

prg2:
		jmp loadprg

;* read disk directory
dskdir:
		sty dflag
		cpx #0
		beq dskdir0
		stx filenum
dskdir0:
		cpy #0
		bne dskdir1
		ldx filenum
		jsr chkin
		jsr chrin
		jsr chrin
dskdir1:
		jsr dir
		lda $90
		bne dskdir2
		lda dflag
		bne dskdir2
		jsr minusone
		ldx #15
		jsr putvar ;lp
		jsr outastr
		ldx #17
		jsr usevar ;rc
		lda var
		beq dskdir1
dskdir2:
		rts
;* read single line of directory
dir:
		ldx filenum
		jsr chkin
		jsr chrin
		jsr chrin
		jsr chrin
		pha
		jsr chrin
		tax
		pla
		jsr decimal
		ldy #0
		ldx #0
dir3:
		lda decchr,y
		cmp #"0"
		beq dir3a
		inx
dir3a:
		cpx #0
		bne dir3b
		lda #" "
dir3b:
		sta buf2,y
		iny
		cpy #5
		bcc dir3
dir4:
		ldy #5
		lda #" "
		sta buf2,y
		iny
dir0:
		jsr chrin
		cmp #" "
		beq dir0
		sta buf2,y
		iny
dir1:
		jsr chrin
		beq dir2
		sta buf2,y
		iny
		lda $90
		beq dir1
dir2:
		lda buf2-1,y
		cmp #" "
		bne dir5
		dey
		bne dir2
dir5:
		sty var
		lda #<buf2
		sta var+1
		lda #>buf2
		sta var+2
		ldx #$01
		jsr putvar ;a$
		jmp clrchn

;* input from disk
dskin:
		cpx #0
		bne dskin0a
		stx filenum
dskin0a:
		cpy #0
		bne bytin
dskin0:
		jsr chkin
		lda #0
		sta index
dskin1:
		jsr getin
		ldy index
		cmp #13
		beq dskin3
		sta buf2,y
		iny
		sty index
		cpy #80
		bcs dskin3
		lda $90
		and #$42
		beq dskin1
		lda #"^"
		sta buf2
		lda #$40
		sta $90
		ldy #1
dskin3:
		sty var
		lda #<buf2
		sta var+1
		lda #>buf2
		sta var+2
		ldx #$01
		jsr putvar ;a$
		jmp clrchn

bytin:
		jsr chkin
		cpy #80
		bcc bytin0
		ldy #80
bytin0:
		sty index
		ldy #0
bytin1:
		jsr chrin
		sta buf2,y
		iny
		cpy index
		bne bytin1
		jmp dskin3

dumparr:
		sty dumparr4+1
		jsr chkout
		ldx #0
dumparr1:
		inx
		txa
		pha
		jsr getarr
		ldy #0
dumparr2:
		cpy var
		beq dumparr3
		lda [var+1],y
		jsr chrout
		iny
		bne dumparr2
dumparr3:
		lda #13
		jsr chrout
		pla
		tax
dumparr4:
		cpx #0
		bcc dumparr1
		jmp clrchn


;*irq routine

;* counter to execute a different
;* part of the routine each jiffy

irq:
		jsr irq9
		jsr irq10
		inc idlejif
		lda mupcase
		lsr
		ror
		eor #$ff
		cmp caseflag
		beq irq0
		sta caseflag
		jsr dispdate
irq0:
		ldy #0
		lda irqtbl,y
		sta irqjmp+1
		iny
		lda irqtbl,y
		sta irqjmp+2
		iny
		cpy #16
		bcc irq0a
		ldy #0
irq0a:
		sty irq0+1
irqjmp:
		jmp $ffff
irqtbl:
		word irq1 ;page
		word irq2 ;time
		word irq3 ;blanker
		word irq4 ;lightbar
		word irq5 ;carrier
		word irq6 ;flag
		word irq7 ;lightbar
		word irq4 ;lightbar

caseflag:
		byte 255

;* chat page

irq1:
		ldy #4
		dey
		bpl irq1a
		ldy #4
irq1a:
		sty irq1+1
irq1z:
		ldx #5
		dex
		bpl irq1b
		lda timeset
		bne irq1g
		lda irq1e+1
		eor #10
irq1g:
		sta irq1e+1
		ldx #5
irq1b:
		stx irq1z+1
		lda scnmode
		bne irq1e
		lda chatpage
		bne irq1c
		ldx #0
irq1c:
		lda pagecol,x
		ldx #15
irq1d:
		sta acolr+24,x
		dex
		bpl irq1d
irq1e:
		lda #1
		ldy #39
irq1f:
		sta tcolr,y
		dey
		bpl irq1f
		rts

pagecol:
		byte 1,15,12,11,12,15

;* update time on screen

timeflag:
		byte 0

irq2:
		lda min
		ldx timeflag
		bne irq2a
		cmp bootdate+5
		beq ha872
irq2a:
		sta bootdate+5
		ldx #0
		stx timeflag
		jsr gettsr
		beq irq2b
		cmp #101
		bcs irq2b
		sec
		sbc #1
		jsr settsr
irq2b:
		lda hrs
		sta bootdate+4
		ldx ten
		cmp #$12
		bne ha86f
		lda bootdate+5
		bne ha86f
		inc bootdate
		lda bootdate
		cmp #8
		bcc ha832
		lda #1
		sta bootdate
ha832:
		ldy bootdate+1
		lda bootdate+2
		cmp ha560-1,y
		bne ha84d
		lda #0
		sta bootdate+2
		lda bootdate+1
		sed
		clc
		adc #1
		sta bootdate+1
ha84d:
		lda bootdate+2
		sed
		clc
		adc #1
		sta bootdate+2
		cld
		lda bootdate+1
		cmp #$13
		bne ha86e
		lda #1
		sta bootdate+1
		lda bootdate+3
		sed
		clc
		adc #1
		sta bootdate+3
ha86e:
		cld
ha86f:
		jsr makdate
		jsr alarm
ha872:
		lda scs
		jsr bcdtoa
		pha
		txa
		tay
		pla
		ldx #$17
		jsr dispdt
		tya
		jsr dispdt
		jsr gettsr
		beq ha083
		lda #$59
		sed
		sec
		sbc scs
		cld
; display tsr
ha083:
		jsr bcdtoa
		pha
		txa
		tay
		pla
		ldx #$24
		jsr dispdt
		tya
		jsr dispdt
		lda tsr2
		bne tchk1
		jsr gettsr
		beq tchk1
		lda #<copyrite
		sta jmptbl
		lda #>copyrite
		sta jmptbl+1
tchk1:
		jsr gettsr
		cmp tsr2
		sta tsr2
		bne tchk2
		jsr disptime
tchk2:
		rts

gettsr:
		txa
		pha
		ldx #29
		jsr gvarptr ;tr%
		stx getts1+1
		sty getts1+2
		stx setts1+1
		sty setts1+2
		ldy #1
		pla
		tax
getts1:
		lda $ffff,y
		rts
settsr:
		pha
		jsr gettsr
		pla
setts1:
		sta $ffff,y
		rts

;* make string out of current date
;* for d1$ (convert from 6 byte to
;* 11 byte format)

mkdate:
		pha
		lsr
		lsr
		lsr
		lsr
		jsr mkdate1
		pla
mkdate1:
		and #$0f
		ora #$30
		sta d1str,y
		iny
		rts

mult3:
		tya
		sta mult3a+1
		asl
		clc
mult3a:
		adc #$00
		tay
		rts

makdate:
		ldy #0
		lda bootdate
		jsr mkdate1
		lda bootdate+3
		jsr mkdate
		lda bootdate+1
		jsr mkdate
		lda bootdate+2
		jsr mkdate
		lda bootdate+4
		jsr mkdate
		lda bootdate+5
		jsr mkdate
dispdate:
		ldy bootdate
		jsr mult3
		ldx #0
dispd1:
		lda daytbl,y
		jsr dispdt
		iny
		cpx #3
		bne dispd1
		lda #" "
		jsr dispdt
		lda bootdate+1
		cmp #$10
		bcc dispd1a
		sbc #6
dispd1a:
		tay
		dey
		jsr mult3
dispd2:
		lda montbl,y
		jsr dispdt
		iny
		cpx #7
		bne dispd2
		lda #" "
		jsr dispdt
		lda d1str+5
		cmp #"0"
		bne dispd3
		lda #" "
dispd3:
		jsr dispdt
		lda d1str+6
		jsr dispdt
		lda #","
		jsr dispdt
		lda #" "
		jsr dispdt
		lda #"1"
		jsr dispdt
		lda #"9"
		jsr dispdt
		lda d1str+1
		jsr dispdt
		lda d1str+2
		jsr dispdt
		lda #" "
		jsr dispdt
		lda d1str+7
		and #$31
		cmp #"0"
		bne dispd4
		lda #" "
dispd4:
		jsr dispdt
		lda d1str+8
		jsr dispdt
		lda #":"
		jsr dispdt
		lda d1str+9
		jsr dispdt
		lda d1str+10
		jsr dispdt
		lda #":"
		jsr dispdt
		lda scs
		pha
		lsr
		lsr
		lsr
		lsr
		ora #$30
		jsr dispdt
		pla
		and #$0f
		ora #$30
		jsr dispdt
		lda #" "
		jsr dispdt
		lda d1str+7
		cmp #"8"
		bcs dispd5
		lda #cbm("A")
		bne dispd6
dispd5:
		lda #cbm("P")
dispd6:
		jsr dispdt
		lda #cbm("M")
		jsr dispdt
		lda #" "
;* convert to screen, store it
dispdt:
		pha
		and caseflag
		cmp #128
		bcs dispdt1
dispdt2:
		cmp #64
		bcc dispdt1
		and #63
dispdt1:
		ora #$80
		sta tdisp+1,x
dispdt3:
		inx
		pla
		rts

;* convert bcd to ascii
bcdtoa:
		tax
		lsr
		lsr
		lsr
		lsr
		ora #$30
		tay
		txa
		and #$0f
		ora #$30
		tax
		tya
		rts

;* display time remaining

disptime:
		ldx #32
		lda #" "
		jsr dispdt
		jsr gettsr
		beq dt0
		cmp #101
		bcc dt01
		lda #101
		jsr settsr
		lda #"-"
		tay
		bne dt3
dt01:
		sec
		sbc #1
dt0:
		ldy #$30
dt1:
		cmp #10
		bcc dt2
		sbc #10
		iny
		bne dt1
dt2:
		ora #$30
dt3:
		pha
		tya
		jsr dispdt
		pla
		jsr dispdt
		lda #":"
		jmp dispdt

irq3:
		jsr chkblnk
		beq irq3a
		lda blnkflag
		bne irq3a
		inc blnkcntr
		bne irq3b
scrnoff:
		ldx #$0b
		lda #1
		bne scrnon1
scrnon:
		ldx #$1b
		lda #0
scrnon1:
		jsr scrnset
irq3a:
		lda #0
		sta blnkcntr
irq3b:
		rts
chkblnk:
		ldx #11
		jmp chkflag

bits:
		byte 1,2,4,8,16,32,64,128

;* put check on screen for carrier
irq5:
		ldx #$fa
		lda carrier
		eor mxor
		and #$10
		beq irq5a
		lda #1
		sta carrst
		ldx #$a0
		bne irq5d
irq5a:
		lda carrst
		ora #128
		sta carrst
irq5d:
		stx tdisp+39
		lda #$a0
		pha
		ldx #16
		ldy #5
		jsr chkflags
		bne irq5b
		pla
		lda #$fa
		pha
irq5b:
		pla
		sta tdisp
irq5c:
		rts

irq6:
		lda carrst
		and #127
irq6a:
		cmp #1
		beq irq6b
		sta irq6a+1
		cmp #0
		bne irq6b
		lda #1
		sta flag
irq6b:
		ldx #4
		ldy #5
		jsr chkflags
irq6c:
		cmp #0
		beq irq6d
		sta irq6c+1
		cmp #0
		beq irq6d
		lda carrst
		and #127
		beq irq6d
		lda #1
		sta flag
irq6d:
		ldx #36
		ldy #5
		jsr chkflags
		ldy #0
		tax
		beq irq6e
		ldy comqc
		sty mcolor
irq6e:
		sty fredmode
		rts

;* display lightbar checkmarks
irq7:
		ldy #1
		lda bar
		and #63
		sta bar
		cpy #0
		beq irq7z
		lda scnmode
		bne irq7z
		lda #0
		sta irq7+1
		lda tmpbar
		pha
		lda bar
		and #7
		sta tmpbar
		asl
		asl
		adc tmpbar
		sta tmpbar
		lda bar
		and #$38
		sta irq7a+1
		asl
		clc
irq7a:
		adc #0
		tay
		lda bar
		lsr
		lsr
		lsr
		asl
		tax
		lda chktbl+1,x
		pha
		lda chktbl+0,x
		ldx #0
irq7b:
		jsr irq7h
		cpx #20
		bcc irq7b
		pla
irq7c:
		jsr irq7h
		cpx #40
		bcc irq7c
		pla
		sta tmpbar
irq7z:
		rts

irq7d:
		lsr
		pha
		lda #" "
		bcc irq7e
		lda #$7a
irq7e:
		jsr irq7f
		pla
		rts

irq7j:
		lda bartbl,y
		iny
irq7f:
		ora #$80
		sta ldisp,x
irq7g:
		lda #15
		sta lcolr,x
		inx
		rts

irq7h:
		pha
		lda #15
		cpx tmpbar
		bne irq7i
		lda #1
irq7i:
		sta irq7g+1
		pla
		jsr irq7d
		pha
		jsr irq7j
		jsr irq7j
		jsr irq7j
		pla
		jmp irq7d

chkflag:
		ldy #5
chkflags:
		lda $ff
		pha
		stx $ff
		txa
		and #7
		tax
		lda bits,x
		pha
		lda $ff
		lsr
		lsr
		lsr
		and #$0f
		tax
		pla
		iny
		dey
		beq chkflag0
		dey
		beq chkflag1
		dey
		beq chkflag2
		dey
		beq chkflag3
		dey
		beq chkflag4
		dey
		beq chkflag5
chkflag6:
		sta chktbl,x
chkflag7:
		inc irq7+1
chkflag8:
		tax
		pla
		sta $ff
		txa
		rts

chkflag0:
		eor #$ff
		and chktbl,x
		jmp chkflag6
chkflag1:
		ora chktbl,x
		jmp chkflag6
chkflag2:
		eor chktbl,x
		jmp chkflag6
chkflag3:
		ldy #0
		sty var
		and chktbl,x
		beq chkflg3a
		iny
chkflg3a:
		sty var+1
		ldx #30
		jsr putvar ;a%
		jmp chkflag8
chkflag4:
		lda $ff
		sta bar
		jmp chkflag7
chkflag5:
		and chktbl,x
		jmp chkflag8

tmpbar:
		byte 0

fkey:
		ldx tmpkey
		lda 653
		and #4
		bne fkey1
		inx
fkey1:
		txa
		clc
		adc #40
		asl
		tay
		lda 3
		pha
		lda 4
		pha
		lda vars,y
		sta 3
		lda vars+1,y
		sta 4
		ldy #0
		lda [3],y
		sta fkeybuf
		iny
		lda [3],y
		tax
		iny
		lda [3],y
		sta 4
		stx 3
		ldy #0
		ldx fkeybuf
		beq fkey3
fkey2:
		lda [3],y
		sta fkeybuf+1,y
		iny
		dex
		bne fkey2
		lda #0
		sta fkeybuf+1,y
		lda #1
		sta fkeybuf
fkey3:
		pla
		sta 4
		pla
		sta 3
fkey4:
		rts

irq9:
		jsr $ffea
		lda $cc
		bne irq9f
		dec $cd
		bne irq9f
		lda #$14
		sta $cd
		ldy $d3
		lsr $cf
		ldx $0287
		lda [$d1],y
		bcs irq9e
		inc $cf
		sta $ce
		jsr $ea24
		lda [$f3],y
		sta $287
		ldx $0286
		lda $ce
irq9e:
		eor #$80
		jsr $ea1c
irq9f:
		jmp $ea87

irq10:
		lda sndtim1
		beq irq10a
		dec sndtim1
		bne irq10d
		lda sndwav1
		ldx sndwav2
		ldy sndwav3
		jsr irq10c
irq10a:
		lda sndtim2
		beq irq10d
		dec sndtim2
		bne irq10d
		lda #0
		tax
		tay
		jsr irq10c
		lda sndrept
		beq irq10d
		cmp #255
		beq irq10b
		dec sndrept
irq10b:
		lda sndtim1a
		sta sndtim1
		lda sndtim2a
		sta sndtim2
		lda sndwav3
		ora #1
		tay
		lda sndwav2
		ora #1
		tax
		lda sndwav1
		ora #1
irq10c:
		sta $d404
		stx $d40b
		sty $d412
irq10d:
		rts

settim:
		lda #$08
		byte $2c
setalm:
		lda #$88
		sta $dc0f
		cmp #$88
		beq settim2
		lda #1
		sta timeflag
		cpx #12
		bne settim1
		ldx #92
		bne settim2
settim1:
		cpx #92
		bne settim2
		ldx #12
settim2:
		txa
		jsr settim3
		sta hrs
		tya
		jsr settim3
		sta min
		lda #0
		sta scs
		sta ten
		lda #$08
		sta $dc0f
		rts
settim3:
		ldx #0
settim4:
		cmp #10
		bcc settim5
		sbc #10
		inx
		bne settim4
settim5:
		sta $ff
		txa
		asl
		asl
		asl
		asl
		ora $ff
		rts

irq4:
		lda 197
		cmp oldkey
		beq irq4c
		sta oldkey
		cmp #3
		bcc irq4c
		cmp #7
		bcs irq4c
		and #3
		asl
		sta tmpkey
		lda 653
		cmp #2
		bcs irq4d
		and #1
		sta shfkey
		ora tmpkey
		asl
		tay
		jsr irq4b
		sta irq4a+1
		iny
		jsr irq4b
		sta irq4a+2
irq4a:
		jmp $ffff
irq4b:
		lda ktbl1,y
irq4c:
		rts
irq4d:
		jmp fkey

tmpkey:
		byte 0
oldkey:
		byte 64
shfkey:
		byte 0

ktbl1:
		word t1fk1,t1fk2
		word t1fk3,t1fk4
		word t1fk5,t1fk6
		word t1fk7,t1fk7

t1init:
		ldy #0
		jsr chkflags
		ldx #<ktbl1
		ldy #>ktbl1
usekey:
		stx irq4b+1
		sty irq4b+2
		rts
t1fk1:
		ldx scnlock
		bne t1fk3b
		ldx scnmode
		jmp setmode1
t1fk2:
		lda blnkflag
		bne t1fk2a
		jmp scrnoff
t1fk2a:
		jmp scrnon
t1fk3:
		dec bar
t1fk3a:
		inc irq7+1
t1fk3b:
		rts
t1fk4:
		sec
		lda bar
		sbc #8
t1fk4a:
		sta bar
		jmp t1fk3a
t1fk5:
		inc bar
		jmp t1fk3a
t1fk6:
		clc
		lda bar
		adc #8
		jmp t1fk4a
t1fk7:
		lda bar
		asl
		ora shfkey
		pha
		tax
		ldy #2
		jsr chkflags
		pla
		cmp #2
		beq t1fk7a
		cmp #6
		beq t1fk7b
		cmp #12
		beq t1fk7c
		rts
t1fk7a:
		jmp t3init ;acs
t1fk7b:
		jmp t2init ;tsr
t1fk7c:
		lda outptrfl
		eor #1
		sta outptrfl
		rts

;edit users time
ktbl2:
		word t2fk1,t2fk2
		word t2fk3,t2fk4
		word t2fk5,t2fk6
		word t2fk7,t2fk7

t2init:
		ldx #<ktbl2
		ldy #>ktbl2
		jmp usekey
t2fk1:
		lda #0
		byte $2c
t2fk2:
		lda #101
t2fk2a:
		jmp settsr
t2fk3:
		ldx #1
		byte $2c
t2fk4:
		ldx #10
t2fk4a:
		jsr gettsr
		tay
l1:
		cpy #101
		beq t2fk4b
		iny
		dex
		bne l1
t2fk4b:
		tya
		jsr settsr
		jmp disptime
t2fk5:
		ldx #1
		byte $2c
t2fk6:
		ldx #10
t2fk6a:
		jsr gettsr
		tay
t2fk6_loop:
		cpy #0
		beq t2fk6b
		dey
		dex
		bne t2fk6_loop
t2fk6b:
		jmp t2fk4b
t2fk7:
		ldx #6
		jmp t1init

;edit users access
ktbl3:
		word t3fk1,t3fk2
		word t3fk5,t3fk5
		word t3fk3,t3fk3
		word t3fk7,t3fk7

t3init:
		ldx #<ktbl3
		ldy #>ktbl3
		jsr usekey
		ldx #24
		jsr gvarptr ;ac%
		stx t3ini1+1
		sty t3ini1+2
		stx t3fk7a+1
		sty t3fk7a+2
		ldy #1
t3ini1:
		lda $ffff,y
		and #$0f
		ora #$b0
		sta adisp+22
		rts
t3fk3:
		dec adisp+22
		lda adisp+22
		cmp #$b0
		bcs t3fk3a
t3fk2:
		lda #$b9
		sta adisp+22
t3fk3a:
		rts
t3fk5:
		inc adisp+22
		lda adisp+22
		cmp #$ba
		bcc t3fk5a
t3fk1:
		lda #$b0
		sta adisp+22
t3fk5a:
		rts
t3fk7:
		lda adisp+22
		and #$0f
		ldy #1
t3fk7a:
		sta $ffff,y
		ldx #2
		jmp t1init

minhi:
		byte 0
minlo:
		byte 0

cminute:
		txa
		pha
		lda #0
		sta minlo
		sta minhi
		tya
		and #$7f
		cmp #$12
		bne cminute1
		tya
		sec
		sbc #$12
		tay
cminute1:
		tya
		lsr
		lsr
		lsr
		lsr
		tax
		tya
		and #$0f
		cpx #0
		beq cminute3
cminute2:
		clc
		adc #10
		dex
		bne cminute2
cminute3:
		cmp #80
		bcc cminutex
		sbc #68
cminutex:
		ldy #60
		jsr cminute4
		pla
		pha
		lsr
		lsr
		lsr
		lsr
		ldy #10
		jsr cminute4
		pla
		and #$0f
		ldy #1

cminute4:
		tax
		beq cminute7
cminute5:
		clc
		tya
		adc minlo
		sta minlo
		bcc cminute6
		inc minhi
cminute6:
		dex
		bne cminute5
cminute7:
		rts

alarm:
		ldx bootdate+5
		ldy bootdate+4
		jsr cminute
		ldx #49
		jsr gvarptr ;mn%
		stx alarmy+1
		sty alarmy+2
		ldy #1
alarmx:
		lda minhi,y
alarmy:
		sta minhi,y
		dey
		bpl alarmx
		lda #0
alarm0:
		sta alarm1+1
alarm1:
		ldx #0
		lda alarmtb,x
		bne alarm2
		lda alarmtb+1,x
		tax
		ldy #5
		jsr chkflags
		bne alarm3
		beq alarm6
alarm2:
		lda alarmtb+1,x
		beq alarm6
alarm3:
		ldx alarm1+1
		lda alarmtb+2,x
		cmp minhi
		bne alarm4
		lda alarmtb+3,x
		cmp minlo
		bne alarm4
		ldy #1
		bne alarm5
alarm4:
		lda alarmtb+4,x
		cmp minhi
		bne alarm6
		lda alarmtb+5,x
		cmp minlo
		bne alarm6
		ldy #0
alarm5:
		lda alarmtb+7,x
		tax
		jsr chkflags
alarm6:
		lda alarm1+1
		clc
		adc #8
		bpl alarm0
		ldx #28
		ldy #5 ;net-l
		jsr chkflags
		beq alarm8
		ldy #0
alarm7:
		lda netalrm,y
		cmp minhi
		bne alarm10
		lda netalrm+1,y
		cmp minlo
		beq alarm9
alarm10:
		iny
		iny
		cpy #48
		bcc alarm7
alarm8:
		rts
alarm9:
		ldx #29
		ldy #1 ;net-r
		jmp chkflags


logoff:
		stx curdsp
		lda #0
		sta chatpage
		sta sndrept
		lda #11
		sta var
		lda #<d1str
		sta var+1
		lda #>d1str
		sta var+2
		ldx #4
		jsr putvar ;d1$
		lda #$a0
		sta tdisp+30
		sta tdisp+31
		sta tdisp+32
		rts

setbaud:
		txa
		jmp rsbaud

;********************************
;* variable handling routines *
;********************************

;* get descriptor for tt$(.x)
getarr:
		jsr findarr
		ldy #2
		jmp usevar1

;* get and copy memory to buffer
getln:
		jsr getarr
		ldy var
		sty index
getln0:
		dey
		cpy #$ff
		beq getln1
		cpy #80
		bcs getln0
		lda [var+1],y
		sta buffer,y
		jmp getln0
getln1:
		rts

;* print tt$(.a)
prtln:
		jsr getarr
		jmp outstr

;* put descriptor for tt$(.x) and
;* store buffer in memory
putarr:
		jsr findarr
		ldy #2
		jmp putvar1

;* put and store string
putln:
		txa
		pha
		lda index
		jsr makeroom
		ldy index
		beq putln2
		dey
putln1:
		lda buffer,y
		sta [var+1],y
		dey
		bpl putln1
putln2:
		pla
		tax
		jmp putarr

;* find descriptor for tt$(.x)
findarr:
		stx $47
		lda #0
		asl $47
		rol
		sta $48
		txa
		clc
		adc $47
		sta $47
		lda #0
		adc $48
		sta $48
		clc
		lda $2f
		adc $47
		sta $47
		lda $30
		adc $48
		sta $48
		clc
		lda #7
		adc $47
		sta $47
		lda #0
		adc $48
		sta $48
		rts

;* find basic variable
gvarptr:
		txa
		asl
		tay
		clc
		lda vars,y
		adc $2d
		tax
		lda vars+1,y
		adc $2e
		tay
		rts
varnam:
		jsr gvarptr
		stx $47
		sty $48
		rts
findvar:
		sta $45
		stx $46
		jmp findvar1

;* print string variable
prtvar:
		jsr usevar
		jmp outstr

;* print string variable w/mci
prtvar0:
		lda mci
		pha
		lda #0
		sta mci
		jsr prtvar
		pla
		sta mci
		rts

;* get variable descriptor
usevar:
		jsr varnam
		jmp usevar2
usevar0:
		jsr findvar
usevar2:
		ldy #4
usevar1:
		lda [$47],y
		sta var,y
		dey
		bpl usevar1
		rts

;* put variable descriptor
putvar:
		jsr varnam
		jmp putvar2
putvar0:
		jsr findvar
putvar2:
		ldy #4
putvar1:
		lda var,y
		sta [$47],y
		dey
		bpl putvar1
		rts

zero:
		lda #0
		ldy #4
zero1:
		sta var,y
		dey
		bpl zero1
		rts
minusone:
		jsr zero
		lda #$81
		sta var
		rts

;********************************
;* variables used by ml *
;********************************

vars:
		byte $41, $ce         ;  0 an$
		byte $41, $80         ;  1 a$
		byte $42, $80         ;  2 b$
		byte $54, $d2         ;  3 tr$
		byte $44, $b1         ;  4 d1$
		byte $44, $b2         ;  5 d2$
		byte $44, $b3         ;  6 d3$
		byte $44, $b4         ;  7 d4$
		byte $44, $b5         ;  8 d5$
		byte $4c, $c4         ;  9 ld$
		byte $54, $d4         ; 10 tt$
		byte $4e, $c1         ; 11 na$
		byte $52, $ce         ; 12 rn$
		byte $50, $c8         ; 13 ph$
		byte $41, $cb         ; 14 ak$
		byte $4c, $50         ; 15 lp
		byte $50, $4c         ; 16 pl
	 	byte $52, $43         ; 17 rc
		byte $53, $48         ; 18 sh
		byte $4d, $57         ; 19 mw
		byte $4e, $4c         ; 20 nl
		byte $55, $4c         ; 21 ul
		byte $51, $45         ; 22 qe
		byte $52, $51         ; 23 rq
		byte $c1, $c3         ; 24 ac%
		byte $45, $46         ; 25 ef
		byte $4c, $46         ; 26 lf
		byte $57, $80         ; 27 w$
		byte $50, $80         ; 28 p$
		byte $d4, $d2         ; 29 tr%
		byte $c1, $80         ; 30 a%
		byte $c2, $80         ; 31 b$
		byte $c4, $d6         ; 32 dv%
		byte $44, $d2         ; 33 dr$
		byte $43, $b1         ; 34 c1$
		byte $43, $b2         ; 35 c2$
		byte $43, $cf         ; 36 co$
		byte $43, $c8         ; 37 ch$
		byte $cb, $d0         ; 38 kp%
		byte $43, $b3         ; 39 c3$
		byte $46, $b1         ; 40 f1$
		byte $46, $b2         ; 41 f2$
		byte $46, $b3         ; 42 f3$
		byte $46, $b4         ; 43 f4$
		byte $46, $b5         ; 44 f5$
		byte $46, $b6         ; 45 f6$
		byte $46, $b7         ; 46 f7$
		byte $46, $b8         ; 47 f8$
		byte $4d, $d0         ; 48 mp$
		byte $cd, $ce         ; 49 mn%

callmod:
		ldx #<imodline
		ldy #>imodline
		jmp mlgosub

calcgoto:
		txa
		pha
		ldx #30
		jsr usevar ;a%
		ldx var+1
		ldy var
		pla
		bne calcgot1
		jmp mlgoto
calcgot1:
		jmp mlgosub

stcount:
		byte 0
stsize:
		byte 0

struct:
		sty stcount
		cpx #0
		beq putstruc
		cpx #1
		beq getstruc
		lda #68
		jmp usetbl1_code

putstruc:
		jsr fnvar1
		jsr evalstr
		sta stsize
		ldy #0
		tax
		beq puts2
puts1:
		lda [$22],y
		sta [$14],y
		iny
		cpy stcount
		bcs puts3
		dex
		bne puts1
puts2:
		lda #0
		sta [$14],y
		iny
		cpy stcount
		bcc puts2
puts3:
		rts

getstruc:
		jsr fnvar1
		jsr fnvar
		ldy #0
gets1:
		lda [$14],y
		beq gets1a
		iny
		cpy stcount
		bcc gets1
gets1a:
		sty stcount
		tya
		jsr makeroom
		ldy #0
gets2:
		lda [$14],y
		sta [$62],y
		iny
		cpy stcount
		bcc gets2
		ldy #4
gets3:
		lda $61,y
		sta [$47],y
		dey
		bpl gets3
		rts

cursmenu:
		stx cursm1+1
		sty cursmx+1
		lda #1
		sta case
		jsr fnvar
		stx curscalc+1
		sty cursc0+1
cursm1:
		ldx #0
		jsr curscalc
cursm2:
		jsr xgetin
		cmp #13
		beq cursm3
		cmp #"["
		bne cursm5
		jsr xgetin
		ldy #2
		cmp #cbm("A")
		beq cursm4
		iny
		cmp #cbm("B")
		beq cursm4
		iny
		cmp #cbm("C")
		beq cursm4
		iny
		cmp #cbm("D")
		beq cursm4
		jmp cursm2
cursm5:
		ldy #2
		cmp #cursor_up
		beq cursm4
		iny
		cmp #cursor_down
		beq cursm4
		iny
		cmp #cursor_right
		beq cursm4
		iny
		cmp #cursor_left
		beq cursm4
		ldx curscalc+1
		stx $14
		ldx cursc0+1
		stx $15
cursm6:
		ldx #0
		ldy #7
cursm7:
		cmp [$14],y
		beq cursm8
		pha
		clc
		lda $14
		adc #8
		sta $14
		lda $15
		adc #0
		sta $15
		pla
		inx
cursmx:
		cpx #1
		bcc cursm7
		jmp cursm2
cursm8:
		stx cursm1+1
		jsr curscalc
cursm3:
		lda cursm1+1
		sta var+1
		lda #0
		sta var
		ldx #30
		jmp putvar ;a%
cursm4:
		lda [$22],y
		cmp #255
		beq cursm9
		sta cursm1+1
cursm9:
		jmp cursm1

curscalc:
		lda #$00
cursc0:
		ldy #$00
		cpx #0
		beq cursc3 
cursc1:
		clc
		adc #8
		bcc cursc2
		iny
cursc2:
		dex
		bne cursc1
cursc3:
		sta $22
		sty $23
		ldy #0
		lda [$22],y
		tax
		iny
		lda [$22],y
		tay

cursposn:
		sty cursp0+1
		stx cursp2+1
		jsr cursmode
		beq cursp4
		lda #cursor_home
		jsr xchrout
cursp0:
		ldx #0
		beq cursp2
cursp1:
		lda #cursor_down
		jsr xchrout
		dex
		bne cursp1
cursp2:
		ldx #0
		beq cursp4
cursp3:
		lda #cursor_right
		jsr xchrout
		dex
		bne cursp3
cursp4:
		rts

cursmode:
		ldx #16
		jsr chkflag ;asc
		bne cursmod1
		lda #1
		rts
cursmod1:
		ldx #18
		jsr chkflag ;ans
		beq cursmod2
		lda #2
		rts
cursmod2:
		lda #0
		rts



outscn:

outscn0:
		lda #0
		sta idlejif
		tax
		tay
		jsr dspidle
scnoff:
		nop
		jsr chkblnk
		beq sc1
		jsr scrnon
sc1:
		jsr crsroff
		jsr cleanup
sc1a:
		lda sline
		cmp botline
		beq sc1b
		bcc sc1b
		jsr scroll
		jmp sc1a
sc1b:
		jsr sccrsr
		lda $fe
		and #127
		cmp #32
		bcs sc4
		lda $fe
		ldy #nchrs-1
sc2:
		cmp chrs,y
		beq sc6
		dey
		bpl sc2
		ldy #15
sc3:
		cmp colors,y
		beq sc9
		dey
		bne sc3
		jmp sccrsr
sc4:
		ldx scnpos
		cpx #39
		bne sc5
		ldx sline
		cpx botline
		bne sc8
		jsr scroll
sc8:
		lda $fe
		jsr $e716
		lda #0
		sta scnpos
		lda #39
		sta 213
		jsr fixlink
		jmp sccrsr
sc5:
		lda $fe
		jmp $e716
sc9:
		lda fredmode
		beq sc9a
		tay
sc9a:
		sty mcolor
		rts

sc6:
		tya
		asl
		tay
		lda chrtbl,y
		sta sc7+1
		lda chrtbl+1,y
		sta sc7+2
		lda $fe
sc7:
		jsr $ffff
		jmp sccrsr
scret:
		ldx #0
		stx mprint
		stx mspeed
		stx mdigits
		ldx #"0"
		stx cnumc
		jsr scdn
		ldx mleft
		beq scret0
scret1:
		lda #" "
		jsr $e716
		dex
		bne scret1
scret0:
		rts
scupc:
		and #128
		asl
		rol
		sta mupcase
		rts

scclear:
		ldx #0
sccl1:
		jsr scline
		jsr fixlinks
		inx
		cpx #24
		bcc sccl1
schome:
		lda #0
		sta sline
		lda #0
		sta scnpos
sccrsr:
		ldx sline
sccrsr1:
		jsr he9f0
		jmp hea24
scrt:
		ldx scnpos
		cpx #39
		bne scrt1
scdn:
		ldx sline
		cpx botline
		bne scrt1
		pha
		jsr scroll
		pla
scrt1:
		jmp $e716
scdel:

sclf:
		ldx scnpos
		bne scrt1
scup:
		ldx sline
		bne scrt1
		rts
scrvs:
		jmp $e716
scbell:
		ldx #26
		ldy #5
		jsr chkflags
		beq scbell1
		ldx #2
		ldy #0
		jsr sound
scbell1:
		rts

scroll:
		inc scnlock
		lda $ac
		pha
		lda $ad
		pha
		lda $ae
		pha
		lda $af
		pha
		ldx #0
		jsr he9f0
		jsr hea24
scroll0:
		inx
		cpx #24
		beq scroll2
		jsr calcscn
		sty $ac
		sta $ad
		jsr calccol
		sty $ae
		sta $af
		ldy #39
scroll1:
		lda [$ac],y
		sta [$d1],y
		lda [$ae],y
		sta [$f3],y
		dey
		bpl scroll1
		ldy $ac
		lda $ad
		sty $d1
		sta $d2
		ldy $ae
		lda $af
		sty $f3
		sta $f4
		jmp scroll0
scroll2:
		jsr scline0
		pla
		sta $af
		pla
		sta $ae
		pla
		sta $ad
		pla
		sta $ac
		dec sline
		jsr sccrsr
		dec scnlock
		rts

scline:
		jsr he9f0
		jsr hea24
scline0:
		ldy #39
scline1:
		lda 646
		sta [$f3],y
		lda #32
		sta [$d1],y
		dey
		bpl scline1
		rts

chrtbl:
		word scupc,scupc
		word scrvs,scrvs
		word schome,scclear
		word scrt,sclf
		word scdn,scup
		word scret,scdel
		word scbell
chrs:
		byte swlc, swuc
		byte reverse_on, reverse_off
		byte cursor_home, clear_screen
		byte cursor_right, cursor_left
		byte cursor_down, cursor_up
		byte carriage_return, cbm_backspace
		byte ascii_bel
nchrs = *-chrs

cleanup:
		lda #39
		sta 213
		lda #0
		sta 212
		lda #0
		sta 216

fixlink:
		ldx sline
fixlinks:
		lda 217,x
		ora #128
		sta 217,x
		rts

botline:
		byte 22

poscrsr:
		txa
		pha
		tya
		pha
		pla
		tax
		pla
		tay
		clc
		jmp $fff0

;* output routine to fix 1200 and
;* do the transmit window

out0:
		sta $9e
		txa
		pha
		tya
		pha
		jmp out3
outm:
		sta $9e
		txa
		pha
		tya
		pha
		jmp out1
out:
		sta $9e
		txa
		pha
		tya
		pha
		lda $9a
		cmp #4
		bcs out5
		cmp #2
		beq out1
		bcc out4
		ldx #1
		jsr setmode
		inc scnlock
		jsr crsroff
		lda $9e
		jsr $e716
		dec scnlock
		jmp out4
out1:

out3:
		lda $9e
		jsr rsout
out4:
		pla
		tay
		pla
		tax
		lda $9e
		clc
		rts
out5:
		pla
		tay
		pla
		tax
		lda $9e
		jsr rsdisab
		jsr oldout
		jmp rsinabl

crsroff:
		lda #1
		sta crsrflg
		lda crsrmode
		beq crsroff1
		lda undchr
		ldx undcol
		ldy #0
		sty crsrmode
		jsr $ea13
crsroff1:
		rts

crsron:
		lda sline
		cmp botline
		beq crsron0
		bcs crsron1
crsron0:
		lda #0
		sta crsrflg
		rts
crsron1:
		lda #1
		sta crsrflg
		rts

dispstr:
		stx dispstr0+1
		sty dispstr6+1
		jsr evalstr
		sta dispstr4+1
		stx dispstr1+1
		sty dispstr1+2
		jsr evalbyt
		stx dispstr5+1
		txa
		and #$80
		sta dispstr8+1
		inc scnlock
dispstr6:
		ldx #0
		beq dispstr7
		lda dispstr4+1
		beq dispstr7
		jsr calcscn0
		sty dispstr2+1
		sta dispstr2+2
		jsr calccol0
		sty dispstr3+1
		sta dispstr3+2
dispstr0:
		ldx #0
		ldy #0
dispstr5:
		lda #1
dispstr3:
		sta $d800,x
dispstr1:
		lda $0100,y
		jsr chkspcl0
		pha
		and #$7f
		cmp #32
		pla
		bcc dispstr9
		jsr convchr0
dispstr8:
		ora #$80
dispstr2:
		sta $0400,x
		inx
dispstr9:
		iny
dispstr4:
		cpy #0
		bcc dispstr5
dispstr7:
		dec scnlock
		rts

calcscn0:
		lda scnmode
		beq calcscn2
		bne calcscn1
calcscn:
		lda scnmode
		bne calcscn2
calcscn1:
		lda lobytes,x
		tay
		lda hibytes,x
		rts
calcscn2:
		lda $ecf0,x
		tay
		lda $d9,x
		and #$03
		ora #$04
		rts

calccol0:
		lda scnmode
		beq calccol2
		bne calccol1
calccol:
		lda scnmode
		bne calccol2
calccol1:
		lda lobytec,x
		tay
		lda hibytec,x
		rts
calccol2:
		lda $ecf0,x
		tay
		lda $d9,x
		and #$03
		ora #$d8
		rts

he9f0:
		tya
		pha
		jsr calcscn
		sty $d1
		sta $d2
		pla
		tay
		rts

hea24:
		tya
		pha
		jsr calccol
		sty $f3
		sta $f4
		pla
		tay
		rts

; toggle full screen
setmode:
		cpx scnmode
		beq setmode1
		rts
setmode1:
		txa
		ldx #15
		eor #1
		beq setmode2
		ldx #23
setmode2:
		sta scnmode
		stx botline
		jsr crsroff

swapscn:
		lda $d1
		pha
		lda $d2
		pha
		lda $f3
		pha
		lda $f4
		pha
		lda $ac
		pha
		lda $ad
		pha
		lda $ae
		pha
		lda $af
		pha
		lda scnmode
		pha
		ldx #0
swapscn1:
		jsr he9f0
		jsr hea24
		jsr calcscn0
		cmp $d2
		beq swapscn3
		sty $ac
		sta $ad
		jsr calccol0
		sty $ae
		sta $af
		ldy #39
swapscn2:
		lda [$d1],y
		pha
		lda [$ac],y
		sta [$d1],y
		pla
		sta [$ac],y
		lda [$f3],y
		pha
		lda [$ae],y
		sta [$f3],y
		pla
		sta [$ae],y
		dey
		bpl swapscn2
swapscn3:
		inx
		cpx #25
		bcc swapscn1
		pla
		sta scnmode
		pla
		sta $af
		pla
		sta $ae
		pla
		sta $ad
		pla
		sta $ac
		pla
		sta $f4
		pla
		sta $f3
		pla
		sta $d2
		pla
		sta $d1
		rts
;*
;* decimal to ascii routine *
;*
decimal:
		sta binary
		stx binary+1
		ldy #0
dec1:
		ldx #"0"
dec2:
		lda binary
		cmp dectbl1,y
		lda binary+1
		sbc dectbl2,y
		bcc dec3
		sta binary+1
		lda binary
		sbc dectbl1,y
		sta binary
		inx
		bne dec2
dec3:
		txa
		sta decchr,y
		iny
		cpy #5
		bne dec1
		rts

dectbl1:
		byte <10000, <1000, <100, <10, <1
dectbl2:
		byte >10000, >1000, >100, >10, >1
;*
;* memory and trace update
;*
trace0:
		inc scnlock
		lda scnmode
		bne trace1
		jsr trace2
trace1:
		dec scnlock
		rts

trace2:
		sec
		lda 51
		sbc 49
		tay
		lda 52
		sbc 50
		tax
		cpy oldmem
		bne trace3
		cpx oldmem+1
		beq trace4
trace3:
		sty oldmem
		stx oldmem+1
		tya
		jsr decimal
		ldy #4
trace3a:
		lda decchr,y
		ora #$80
		sta sdisp+14,y
		dey
		bpl trace3a
trace4:
		ldx #24
		ldy #5
		jsr chkflags
		beq trace7
		lda 57
		ldx 58
		cmp oldline
		bne trace5
		cpx oldline+1
		beq trace7
trace5:
		sta oldline
		stx oldline+1
		jsr decimal
		ldy #4
trace5a:
		lda decchr,y
		ora #$80
		sta sdisp+23,y
		dey
		bpl trace5a
		ldx #0
		ldy #200
trace6:
		lda 653
		and #4
		beq trace7
		dex
		bne trace6
		dey
		bne trace6
trace7:
		rts

oldline:
		word 0
oldmem:
		word 0

dspidle:
		sta idlesec
		stx idleten
		sty idlemin
		lda scnmode
		bne dspidle1
		lda curdsp
		beq dspidle1
		lda idlesec
		ora #$b0
		sta adisp+18
		txa
		ora #$b0
		sta adisp+17
		tya
		ora #$b0
		sta adisp+16
dspidle1:
		rts


getmod:
		jsr getmdm
		sta $fe
		ldx #9
		ldy #5 ;cht-r
		jsr chkflags
		beq getmod0
		lda #0
		sta $fe
		rts
getmod0:
		ldx #16
		ldy #5 ;asc-l
		jsr chkflags
		beq getmod1
		ldx $fe
		lda tblatc,x
		sta $fe
getmod1:
		lda $fe
		beq getmod3
		ldx getmodn
		cmp getmodt,x
		bne getmod2
		inx
		stx getmodn
		cpx #5
		bcc getmod3
		pha
		lda bsnpre
		jsr outm
		lda bsnval+1
		jsr outh
		lda bsnval
		pha
		lsr
		lsr
		lsr
		lsr
		jsr outh
		pla
		jsr outh
		pla
getmod2:
		ldx #0
		stx getmodn
getmod3:
		cmp #0
		rts
getmodn:
		byte 0
getmodt:
		byte 9,13,1,7,5 ;image
outh:
		and #$0f
		ora #$30
		cmp #$3a
		bcc outh1
		adc #6
outh1:
		jmp outm

outmodh:
		ldx interm
		bne outmodh1
		jsr outm
		lda #" "
		jsr outm
outmodh1:
		lda #dish
		jmp outm

outmod:
		ldx #16
		ldy #5 ;asc-l
		jsr chkflags
		bne outmod0
		lda $fe
		jmp outm
outmod0:
		ldx #19
		ldy #5 ;ans-r
		jsr chkflags
		tax
		lda $fe
		and #$1f
		tay
		lda $fe
		cpx #0
		beq outmod0e
		cmp #096
		bcc outmod0e
		cmp #128
		bcc outmod0a
		cmp #160
		bcc outmod0e
		cmp #192
		bcc outmod0d
		cmp #224
		bcs outmod0e
outmod0a:
		lda mupcase
		bne outmod0c
		lda tblcta2,y
		bne outmod1
outmod0c:
		lda tblcta3,y
		bne outmod1
outmod0d:
		lda tblcta1,y
		bne outmod1
outmod0e:
		tax
		lda tblcta,x
		beq outmod3
outmod1:
		pha
		and #$7f
		cmp #32
		pla
		bcc outmod1a
		jmp outm
outmod1a:
		ldx #18
		ldy #5 ;ans-l
		pha
		jsr chkflags
		tax
		pla
		cmp #dish
		beq outmodh
		cmp #13
		beq outmodm
		cmp #ascii_formfeed
		beq outmodl
		cpx #0
		beq outmod3
		cmp #cursor_up
		beq outmodup
		cmp #cursor_down
		beq outmoddn
		cmp #cursor_right
		beq outmodrt
		cmp #cursor_left
		beq outmodlf
		cmp #reverse_off
		beq outmodr0
		cmp #reverse_on
		beq outmodr1
		cmp #cursor_home
		beq outmodhm
		jsr colorchk
		bcs outmod3
		jmp outmodc
outmod3:
		rts

outmodm:
		lda interm
		bne outmodm1
		cpx #0
		beq outmodm1
		jsr outmodr0
outmodm1:
		ldx #17
		ldy #5 ;asc-r
		jsr chkflags
		php
		lda #13
		plp
		beq outmodm2
		jsr outm
		lda #10
outmodm2:
		jmp outm

outmodup:
		lda #$41
		bne ansicom
outmoddn:
		lda #$42
		bne ansicom
outmodrt:
		lda #$43
		bne ansicom
outmodlf:
		lda #$44
ansicom:
		pha
		lda #27
		jsr outm
		lda #"["
		jsr outm
		pla
		jmp outm

outmodr0:
		lda #"3"
		ldx #"4"
		bne outmodr
outmodr1:
		lda #"4"
		ldx #"3"
outmodr:
		sta ansir1
		stx ansir2
		jmp ansi

outmodl:
		cpx #0
		bne outmodl1
		jmp outm
outmodl1:
		lda #"2"
		jsr ansicom
		lda #$4a
		jmp outm

outmodhm:
		lda #"1"
		jsr ansicom
		lda #";"
		jsr outm
		lda #"1"
		jsr outm
		lda #$48
		jmp outm

outmodc:
		ldx #15
outmodc2:
		cmp colors,x
		beq outmodc3
		dex
		bne outmodc2
outmodc3:
		lda ansiclrs,x
		sta ansicol
		lda ansiints,x
		sta ansiint
ansi:
		ldy #0
ansi1:
		tya
		pha
		lda ansibuf,y
		beq ansi2
		jsr outm
		pla
		tay
		iny
		bne ansi1
ansi2:
		pla
		rts

ansiclrs:
		byte "7716524333107247"
ansiints:
		byte "0100000100110110"
ansibuf:
		byte 27, "[0;"
ansiint:
		byte "0;"
ansir1:
		byte "3"
ansicol:
		byte "1;"
ansir2:
		byte "4"
ansibak:
		byte "0", $6d, 0



inline:
		lda #00
		byte $2c
clrarr:
		lda #11
		byte $2c
sound:
		lda #25
		byte $2c
inline0:
		lda #63
		byte $2c
convstr:
		lda #64
		byte $2c
convert:
		lda #65
		jmp usetbl1_code
copyrite:
		lda #67
		jsr usetbl1_code
		jmp outastr

; passed address in x [hi],y (lo)
caller:
		sty calljmp+1
		cpx callpage
		beq caller2
		lda callpage
		beq caller1
		jsr callswap
		jsr caller1
		jsr callswap
		lda 780
		rts

caller1:
		lda callpage
		pha
		stx callpage
		jsr callswap
		jsr caller2
		jsr callswap
		pla
		sta callpage
		lda 780
		rts

caller2:
		lda 780
		ldx 781
		ldy 782
calljmp:
		jsr $c000
		sta 780
		stx 781
		sty 782
		rts

callswap:
		pha
		txa
		pha
		tya
		pha
		lda callpage
		ldx #4 ;swap1/2
		cmp #>$f400
		bcs callswp1
		ldx #6 ;struct
		cmp #>$ee00
		bcs callswp1
		ldx #10 ;ecs
		cmp #>$e400
		bcs callswp1
		ldx #4 ;gc
callswp1:
		ldy #>$c000
		jsr swapper0
		pla
		tay
		pla
		tax
		pla
		rts

callpage:
		byte 0
calltemp:
		byte 0


; put intro program in

		dup 0,$c000-*

devnum = 186

; intro is a proto
		jmp intro
		jmp setup
		byte $ff ;intro


;* intro program

intro:

;fake rs232 driver
		lda #$60
		ldy #0
intro_loop1:
		sta rs232,y
		dey
		bne intro_loop1
;move editor
		lda #$70
		ldy #$d0
		ldx #48
		jsr swapper0
;move wedge
		lda #$6c
		ldy #$0c
		ldx #4
		jsr swapper0
;load "im"
		ldx #<prgstart
		ldy #>prgstart
		stx $2b
		sty $2c
		ldx #<(prgstart+2)
		ldy #>(prgstart+2)
		stx $2d
		sty $2e
		stx $2f
		sty $30
		stx $31
		sty $32
		lda #0
		sta prgstart-1
		sta prgstart
		sta prgstart+1
		lda #1
		ldx devnum
		ldy #0
		jsr $ffba
		lda file2
		ldx #<(file2+1)
		ldy #>(file2+1)
		jsr $ffbd
		jsr loadprg
;restore screen
		lda #11
		sta $d011
		lda #$17
		sta $d018
		lda #clear_screen
		jsr $e716
		lda #27
		sta $d011
;fake lightbar table
		lda #0
		ldy #0
intro_loop2:
		sta chktbl,y
		iny
		cpy #16
		bne intro_loop2
		lda #32
		ldy #0
intro_loop3:
		sta bartbl,y
		iny
		cpy #192
		bne intro_loop3
;run program
		lda #0
		jsr $a871
		jmp $a7ae

;* filenames
file2:
		byte 2
		cbm "im"

;* setup routines *

;* main setup routine
setup:
		lda #0
		tay
setup_loop1:
		sta cassbuff,y
		iny
		cpy #1024-cassbuff
		bne setup_loop1
		ldy #0
setup_loop2:
		lda date2,y
		sta date1,y
		iny
		cpy #28
		bne setup_loop2
		lda #80
		sta ptrclmn
		lda #40
		sta modclmn
		lda #1
		sta local
		ldy #0
setup_loop3:
		lda #32
		sta tempscn+$00,y
		sta tempscn+$a0,y
		lda #1
		sta tempcol+$00,y
		sta tempcol+$a0,y
		iny
		cpy #$a0
		bne setup_loop3
		ldy #11
setup_loop4:
		lda daysofm0,y
		sta daysofm,y
		dey
		bpl setup_loop4
		jsr copytran
		ldy #15
		lda #16
setup_loop5:
		sta pmodetbl,y
		dey
		bpl setup_loop5
		lda #255
		sta pmodetbl+16
		lda #0
		sta pmodetbl+17
		ldy #0
setup_loop6:
		lda #1
		sta alarmtb,y
		lda #0
		sta alarmtb+1,y
		iny
		bpl setup_loop6
		ldy #12*3-1
setup_loop7:
		lda montbl0,y
		sta montbl,y
		dey
		bpl setup_loop7
		ldy #8*3-1
setup_loop8:
		lda daytbl0,y
		sta daytbl,y
		dey
 		bpl setup_loop8
		ldy #31
setup_loop9:
		lda date1fmt,y
		sta date1,y
		dey
		bpl setup_loop9
		ldy #64
setup_loop10:
		lda sndtbl0,y
		sta sndtbl,y
		dey
		bpl setup_loop10
		ldy #0
		ldx #0
setup_loop11:
		lda screentb,y
		iny
		sta lobytes,x
		lda screentb,y
		iny
		sta hibytes,x
		lda screentb,y
		iny
		sta lobytec,x
		lda screentb,y
		iny
		sta hibytec,x
		inx
		cpx #25
		bne setup_loop11

		lda #0
		sta passmode
		lda #cbm("X")
		sta mask
		lda #2
		sta bar
		lda #0
		sta readmode
		sta scnmode
		sta scnlock
		sta interm
		sta inchat
		jsr iosetup
		jsr setptrs
		jsr setirq
		jsr trapoff
		lda #$36
		sta $01
		jsr setscrn
		ldx #3
		jsr comq
		jsr startmsg
		lda #$37
		sta $01
		rts

;* setup i/o windows

iosetup:
		lda $0326
		sta oldout+1
		lda $0327
		sta oldout+2
		lda #<newout
		sta $0326
		lda #>newout
		sta $0327
		rts

;* setup irq vector

setirq:
		lda #127
		sta 56333
		lda #<raster
		sta 788
		lda #>raster
		sta 789
		lda #$81
		sta $d01a
		lda #$00
		sta $d012
		lda #$1b
		sta $d011
		lda #0
		sta irqcount
		rts

;* initial setup of screen
;* colors/ clear/ etc
setscrn:
		lda #$00
		sta $d020
		lda #$00
		sta $d021
		lda #$0e
		jsr chrout
		lda #$08
		jsr chrout
		lda #$05
		jsr chrout
		jsr makdate
		jmp dispdate

;* find basic variable
getvarp:
		txa
		asl
		tay
		lda varlist+1,y
		tax
		lda varlist,y
		sta $45
		stx $46
		jmp findvar1

;********************************
;* variables used by ml *
;********************************

varlist:
		byte $41, $ce         ;  0 an$
		byte $41, $80         ;  1 a$
		byte $42, $80         ;  2 b$
		byte $54, $d2         ;  3 tr$
		byte $44, $b1         ;  4 d1$
		byte $44, $b2         ;  5 d2$
		byte $44, $b3         ;  6 d3$
		byte $44, $b4         ;  7 d4$
		byte $44, $b5         ;  8 d5$
		byte $4c, $c4         ;  9 ld$
		byte $54, $d4         ; 10 tt$
		byte $4e, $c1         ; 11 na$
		byte $52, $ce         ; 12 rn$
		byte $50, $c8         ; 13 ph$
		byte $41, $cb         ; 14 ak$
		byte $4c, $50         ; 15 lp
		byte $50, $4c         ; 16 pl
	 	byte $52, $43         ; 17 rc
		byte $53, $48         ; 18 sh
		byte $4d, $57         ; 19 mw
		byte $4e, $4c         ; 20 nl
		byte $55, $4c         ; 21 ul
		byte $51, $45         ; 22 qe
		byte $52, $51         ; 23 rq
		byte $c1, $c3         ; 24 ac%
		byte $45, $46         ; 25 ef
		byte $4c, $46         ; 26 lf
		byte $57, $80         ; 27 w$
		byte $50, $80         ; 28 p$
		byte $d4, $d2         ; 29 tr%
		byte $c1, $80         ; 30 a%
		byte $c2, $80         ; 31 b$
		byte $c4, $d6         ; 32 dv%
		byte $44, $d2         ; 33 dr$
		byte $43, $b1         ; 34 c1$
		byte $43, $b2         ; 35 c2$
		byte $43, $cf         ; 36 co$
		byte $43, $c8         ; 37 ch$
		byte $cb, $d0         ; 38 kp%
		byte $43, $b3         ; 39 c3$
		byte $46, $b1         ; 40 f1$
		byte $46, $b2         ; 41 f2$
		byte $46, $b3         ; 42 f3$
		byte $46, $b4         ; 43 f4$
		byte $46, $b5         ; 44 f5$
		byte $46, $b6         ; 45 f6$
		byte $46, $b7         ; 46 f7$
		byte $46, $b8         ; 47 f8$
		byte $4d, $d0         ; 48 mp$
		byte $cd, $ce         ; 49 mn%

;find all vars used by ml,
;get their pointers

setptrs:
		lda #49
		sta tmp1
setp1:
		ldx tmp1
		jsr getvarp
		lda tmp1
		asl
		tay
		sec
		lda $47
		sbc $2d
		sta vars,y
		lda $48
		sbc $2e
		sta vars+1,y
		dec tmp1
		bpl setp1
		rts

date2:
		cbm "Wed Feb 14, 1990 12:25 PM   "

copytran:
		ldy #0
copytran_loop1:
		lda tr1,y
		sta tblatc,y
		iny
		cpy #128
		bcc copytran_loop1
		ldy #0
copytran_loop2:
		lda tr2,y
		sta tblcta,y
		iny
		bne copytran_loop2
		ldy #0
copytran_loop3:
		lda tr3,y
		sta tblcta1,y
		lda tr4,y
		sta tblcta2,y
		lda tr5,y
		sta tblcta3,y
		iny
		cpy #32
		bcc copytran_loop3
		rts

; tblatc
tr1:
		byte $00,$00,$02,$00,$04,$00,$00,$00
		byte $14,$09,$00,$00,$93,$0d,$0e,$0f
		byte 0,$11,0,$13,20,$15,$16,$17,$18,$19,0,27,0,0,0,0
		cbm " !",34,"#$%&'()*+,-./"
		cbm "0123456789:;<=>?"
		cbm "`ABCDEFGHIJKLMNOPQRSTUVWXYZ{|}~", 127
		cbm 0,"abcdefghijklmnopqrstuvwxyz",0,0,0,0,20

; tblcta
tr2:
		byte $00, $01, $02, $03, $04, $05, $06, $07
		byte $08, $09, $0a, $0b, $0c, $0d, $00, $0f
		byte $10, $11, $12, $13, $08, $15, $16, $17
		byte $18, $19, $1a, $1b, $1c, $1d, $1e, $1f
		byte " !",34,"#$%&'()*+,-./"
		byte "0123456789:;<=>?"
		byte "@abcdefghijklmnopqrstuvwxyz[\]^", $5f
		byte "-ABCDEFGHIJKLMNOPQRSTUVWXYZ*-!**"
		byte 0,129,0,0,0,0,0,0,0,0,0,0,0,$d,0,0
		byte 0,145,146,12,0,149,150,151,152,153,154,155,156,157,158,159
		byte " !---!*!-*!****-"
		byte "****!!!---******"
		byte "-ABCDEFGHIJKLMNOPQRSTUVWXYZ*!!**"
		byte " !---!*!-*!****-"
		byte "****!!!---******"

; tblcta1
tr3:
		byte 032,221,220,196,095,179,178,179
		byte 220,047,222,195,201,192,191,220
		byte 218,193,194,180,221,221,222,223
		byte 223,220,217,187,200,217,188,176

; tblcta2
tr4:
		byte 196,065,066,067,068,069,070,071
		byte 072,073,074,075,076,077,078,079
		byte 080,081,082,083,084,085,086,087
		byte 088,089,090,197,221,179,178,092

; tblcta3
tr5:
		byte 196,042,179,196,196,196,196,179
		byte 179,191,192,217,192,092,047,218
		byte 191,254,196,042,179,218,042,254
		byte 042,179,042,197,221,179,227,092

;* months and days
montbl0:
		cbm "JanFebMarAprMayJun"
		cbm "JulAugSepOctNovDec"
daytbl0:
		cbm "???SunMonTueWedThu"
		cbm "FriSat"
daysofm0:
		byte 31,28,31,30,31,30
		byte 31,31,30,31,30,31

date1fmt:
		cbm "Sat Dec  9, 1990"
		cbm " 12:00 AM EST   "

sndtbl0:

;(0) beep
		byte $00,$40,$10,$f0,$11
		byte $00,$00,$00,$00,$00
		byte $00,$00,$00,$00,$00
		byte $10
;(1) ding
		byte $44,$40,$0b,$00,$15
		byte $00,$00,$00,$00,$00
		byte $d8,$2a,$00,$00,$00
		byte $50
;(2) bell
		byte $00,$60,$09,$00,$11
		byte $00,$60,$09,$00,$11
		byte $00,$60,$09,$00,$11
		byte $20
;(3) bong
		byte $44,$10,$0d,$00,$15
		byte $30,$08,$0b,$00,$15
		byte $1c,$04,$0d,$00,$15
		byte $e0

startmsg:
		lda #1
		sta local
		ldx #0
		jsr setmode
		lda #5
		jsr usetbl1_code
		lda #verslen
		sta var
		lda #<bootvers
		sta var+1
		lda #>bootvers
		sta var+2
		ldx #0
		jsr putvar ;an$
		ldx #0
		jmp prtvar0 ;an$

bootvers:
		byte clear_screen
		cbm " Image BBS V2.0 Rev "
		byte british_pound
		cbm "%a: "
		byte british_pound
		cbm "$a"
		byte function_key_6
verslen = *-bootvers

screentb:
		word $400+000,$d800+000
		word $400+040,$d800+040
		word $400+080,$d800+080
		word $400+120,$d800+120
		word $400+160,$d800+160
		word $400+200,$d800+200
		word $400+240,$d800+240
		word $400+280,$d800+280
		word $400+320,$d800+320
		word $400+360,$d800+360
		word $400+400,$d800+400
		word $400+440,$d800+440
		word $400+480,$d800+480
		word $400+520,$d800+520
		word $400+560,$d800+560
		word $400+600,$d800+600
		word tempscn0,tempcol0
		word tempscn1,tempcol1
		word tempscn2,tempcol2
		word tempscn3,tempcol3
		word tempscn4,tempcol4
		word tempscn5,tempcol5
		word tempscn6,tempcol6
		word tempscn7,tempcol7
		word $400+960,$d800+960




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

fnvar:
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
fnvar1:
		jsr fnvar
		stx $14
		sty $15
		rts

evalstr:
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

evalbyt:
		lda 1
		sta rom0
		lda #$e7
		sta 1
		jsr chkcom
		jsr $0079
		jsr $b79e
		lda rom0
		sta 1
		rts

spchars:
		byte ",:",34,"*?=",13,"^"

		dup 0, $cd00-*

; interface page

hcd00:
		jmp outastr
hcd03:
		jmp usetbl1_code
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

convchr0:
		jsr chkspcl0
		cmp #0
		bmi convchr1
		cmp #64
		bcc convchr1
		eor #64
convchr1:
		and #127
		rts

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

usetbl1_code:
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
		cbm "Tue Jan  1, 1988 12:00 PM   "

; pad up to buf2 start
		dup 0, buf2-*

; buf2
		dup $20, 80

; pad up to buffer start
		dup 0, buffer-*

; buffer
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

; storage for rom bank values

rom0:
		byte 0
rom1:
		byte 0

; the revision number of this ml

rvisnum:
		word revision

; the date this ml was made

version:
		cbm version_string

; version 1.3

versnum:
		byte $81,$26,$66,$66,$66

