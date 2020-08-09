offset $1800-*
namespace "editor"

editor_version = "01/22/91 06:51p"

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
		jmp getnumx

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
		cbm "Image BBS 3.0 Editor ("+editor_version+")"
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
getnumx:
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
