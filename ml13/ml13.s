revision = 1
version_string = "07/31/90 03:55a"
serial = $1003
;

include "equat.s"

org $a000, "ml13.prg"


; jump table for &'s
jmptbl: word outastr ;&
word inline ;&,1
word dskin ;&,2
word read0 ;&,3
word getmdm ;&,4
word getversn ;&,5
word password ;&,6
word prgfile ;&,7
word dskdir ;&,8
word btmvar ;&,9
word term ;&,10
word clrarr ;&,11
word newuser ;&,12
word inchr ;&,13
word dumparr ;&,14
word convan ;&,15
word 49152 ;&,16
word 49155 ;&,17
word setmode ;&,18
word disp1 ;&,19
word disp2 ;&,20
word disp3 ;&,21
word tenwait ;&,22
word xgetin ;&,23
word xchrout1 ;&,24
word sound ;&,25
word getmdm ;&,26
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
word ecschk ;&,42
word chatchk ;&,43
word memory ;&,44
word prtvar ;&,45
word prtvar0 ;&,46
word carchk ;&,47
word getkbd ;&,48
word getmod ;&,49
word outscn ;&,50
word outmod ;&,51
word chkflags ;&,52
word disp4 ;&,53
word useeditr ;&,54
word output ;&,55
word chatmode ;&,56
word setvars ;&,57
word setalm ;&,58
word putintr ;&,59
word getintr ;&,60
word poscrsr ;&,61
word settim ;&,62
;*
;* string output routines *
;*
;
;* output string
outstr:		lda #0
		sta $96
		lda var
		sta len1
		lda var+1
		sta $71
		lda var+2
		sta $72
		lda tsr
		beq outstr0
		lda flag
		bne outstr5
outstr0:        lda mjump
               beq outstr1
               dec mjump
               beq outstr1
               bne outstr5
outstr1:        jsr zero
               ldx #17
               jsr putvar ;rc
               ldx #15
               jsr usevar ;lp
               ldx #0
               lda var
               beq outstr2
               ldx #1
outstr2:        stx wrapflg
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
outstr3:        lda wrapflg
               beq outstr6
               lda lastout
               cmp #32
               beq outstr5
outstr4:        lda #13
               sta $fe
               jsr output
outstr5:        jsr zero
               ldx #15
               jsr putvar ;lp
outstr6:        rts
;
lastout: byte 0
;
outstr7: lda #0
sta chat
jsr carchk
cmp #1
bne outstr8
lda #"/"
sta chat
rts
outstr8: lda len1
beq outstr11
outstr9: ldy $96
lda [$71],y
sta $fe
sta lastout
jsr domci
lda chat
beq outstr10
lda wrapflg
beq outstr10
lda readmode
bne outstr10
rts
outstr10:      inc $96
              lda $96
              cmp len1
              bcc outstr9
outstr11:      rts
;
;* convert an$ to date *
convan: cpx #0
bne convan3
ldx #0
jsr usevar ;an$
ldy #10
convan1: lda [var+1],y
sta datebuf,y
dey
bpl convan1
jsr convert
lda #20
jsr makeroom
ldy #19
convan2: lda date1+4,y
sta [var+1],y
dey
bpl convan2
ldx #0
jmp putvar ;an$
convan3: jmp convstr
;
;* months and days
months:               cbm "Jan Feb Mar Apr "
                     cbm "May Jun Jul Aug "
                     cbm "Sep Oct Nov Dec "
days:                 cbm "Sun Mon Tue Wed "
                     cbm "Thu Fri Sat "
;
; carry clear if control
ctrlchk: pha
lda editor
and #1
beq ctrlch0
pla
ctrlchk1:jsr colorchk
bcc ctrlch2
jsr ctrlchk2
bcc ctrlch2
pha
ctrlch0: pla
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
ctrlch2: sec
rts
ctrlch1: clc
rts
;
; carry clear if color chr
colorchk:sty cytmp
ldy #15
colrch0: cmp colors,y
beq colrch1
dey
bne colrch0
ldy cytmp
sec
rts
colrch1:          ldy cytmp
                 clc
                 rts
;
ctrlchk2:         cmp #$12         ; reverse-on
                 beq ctrlch2a
                 cmp #$92         ; reverse-off
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
ctrlch2a:         clc
                 rts
;
;* message command interpreter
;
;* mci routines follow *
domci0: jmp notc1
domci: cmp #$5c  ; british-pound
bne domci0
ldx mci
bne domci0
inc $96
ldy $96
lda [$71],y
cmp #$5c      ; british-pound
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
comjmp: jmp $ffff
combad: jmp notc
mcom: byte 0
mnum: byte 3
mchr: byte 0
mnum2: byte 0
mchr2: byte 0
mval: byte 0
mchr3: byte 0
;
comtbl:		word notc, coma, comb, comc, comd, come, comf, comg
		word comh, comi, comj, comk, coml, notc, comn, como
		word comp, comq, comr, coms, comt, comu, comv, comw
		word comx, notc, notc, notc, notc, notc, notc, ctab
		word notc, notc, notc, clen, cstr, cnum, notc, notc
;
mcivars:	cbm "d1","ld","na","rn","ph","bn","b"
		byte $80
		cbm "an","d2","d3","ak","lt","d4","ag","cc","dd"
;
mcivar:		txa
		asl
		tay
		lda mcivars+1,y
		ora #$80
		tax
		lda mcivars,y
		jmp usevar0

colors:		byte $9f ; cyan (default color)
		byte $05 ; white
		byte $1c ; red
		byte $9f ; cyan
		byte $9c ; purple
		byte $1e ; green
		byte $1f ; blue
		byte $9e ; yellow
		byte $81 ; orange
		byte $95 ; brown
		byte $96 ; lt-red
		byte $97 ; gray1
		byte $98 ; gray2
		byte $99 ; lt-green
		byte $9a ; lt-blue
		byte $9b ; gray3
;
;* a - compare to variable
coma: ldx mnum
jsr mcivar
lda var+1
sta coma2+1
lda var+2
sta coma2+2
ldx #0
coma1: inc $96
ldy $96
lda [$71],y
cmp #$5c
beq coma3
coma2: cmp $ffff,x
bne coma4
inx
jmp coma1
coma3: lda #1
sta mresult
rts
coma4: lda #0
sta mresult
coma5: inc $96
ldy $96
cpy #80
beq coma6
lda [$71],y
cmp #$5c ; british pound
bne coma5
coma6: rts
;
;* b - send bells
comb: lda #7
jmp repchr0
;
;* c - set color
comc: lda mnum
bne comc1
lda comqc
comc1: sta mcolor
tay
lda colors,y
sta $fe
jmp output
;
;* d - branch on not equal
comd: lda mresult
bne comd1
jmp comj
comd1: rts
;
;* e - branch on equal
come: lda mresult
beq come1
jmp comj
come1: rts
;
;* f - send form feed
comf: lda #$93
sta $fe
jmp output
;
;* g - get character
comg: lda mnum
and #1
sta case
jmp inchr
;
;* h - send backspaces
comh: lda #20
jmp repchr0
;
;* i - input to buffer
comi: lda mnum
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
;
;* j - skip lines
comj: lda mnum
comj1: cmp #0
beq comj2
sta mjump
lda #240
sta $96
comj2: rts
;
;* k - kolorific
comk: lda mnum
cmp #0
bne comk1
sta mkolor
rts
comk1: sta mkolor
jmp comc
;
;* l - send output to printer
coml: lda mnum
and #1
sta mprtr
rts
;
;* n - send carriage returns
comn: lda #13
jmp repchr0
;
;* o - output 19 characters
como: lda #19
sta mnum
lda mchr
jmp repchr
;
;* p - set print mode
comp: lda mnum
sta mprint
rts
;
;* q - reset mci settings
comq: lda mnum
beq comq1
sta comqc
comq1: lda #0
sta mjump
sta mnum
sta mreverse
sta mprtr
sta mprint
sta mspeed
sta mkolor
sta mci
jsr comc
lda #0
jmp comu1
comqc: byte 3
;
;* r - reverse mode
comr: lda mnum
and #1
sta mreverse
lsr
ror
eor #$92
sta $fe
jmp outchr
;
;* s - set print speed
coms: lda mnum
sta mspeed
rts
;
;* t - compare to buffer
comt: lda mnum
cmp #2
bne comt1
ldx #24
jsr usevar ;ac%
lda var+1
and #$0f
ora #$30
sta buffer
comt1: lda #<buffer
sta coma2+1
lda #>buffer
sta coma2+2
ldx #0
jmp coma1
;
;* u - uppercase mode
comu: lda mnum
comu1: and #1
sta mupcase
lsr
ror
eor #$0e
sta $fe
jmp outchr
;
;* v - print variable
comv: ldx mnum
stx mcom
jsr mcivar
comv0: lda var
sta comv1+1
lda var+1
sta comv3+1
lda var+2
sta comv3+2
lda #0
sta comv2+1
comv1: lda #$ff
comv2: cmp #$ff
beq comv6
ldy comv2+1
comv3: lda $ffff,y
sta $fe
ldx mcom
cpx #2
bcs comv4
sta datebuf,y
jmp comv5
comv4: jsr domode
comv5: inc comv2+1
jmp comv1
comv6: ldx mcom
cpx #2
bcs comv8
jsr convert
lda #0
sta comv2+1
comv7: ldy comv2+1
lda date1,y
sta $fe
jsr output
inc comv2+1
lda comv2+1
cmp #25
bcc comv7
comv8: rts
;
;* w - wait
comw: lda mnum
beq comw2
inc mnum
comw1: lda scs
cmp mcom
beq comw1
sta mcom
dec mnum
bne comw1
comw2: rts
;
;* x - abort file read
comx: lda #240
jmp comj1
;
;* # - length of field / fill chr
clen:		lda mchr
		cmp #$30
		bcc clen1
		cmp #$3a
		bcs clen1
		lda mnum
		cmp #5
		bcc clen0
		lda #5
clen0:		sta mdigits
		lda #$30
clen1:		sta cnumc
		rts
;
;* $ - print string variable
cstr: lda #2
sta mcom
lda mchr
ldx #$80
jsr usevar0
jmp comv0
;
;* % - print integer variable
cnum: lda mchr
ora #$80
ldx #$80
jsr usevar0
ldx var
lda var+1
prax: jsr decimal
ldy #0
sty cnumf
ldx mdigits
beq cnum1
lda #5
sec
sbc mdigits
tay
cnum1: sty cnumd
lda decchr,y
cpy #4
bcs cnum2
ldx cnumf
bne cnum2
cmp #$30
bne cnum2
ldx mdigits
beq cnum3
lda cnumc
sta $fe
jsr domode
jmp cnum3
cnum2: sta $fe
jsr domode
inc cnumf
cnum3: ldy cnumd
iny
cpy #5
bne cnum1
rts
cnumf: byte 0
cnumd: byte 0
cnumc: byte $30
;
; mci tab
ctab: inc $96
lda mval
cmp scnpos
bcc ctab0
beq ctab0
cmp #40
bcs ctab0
ctab1: lda #$20
sta $fe
jsr output
lda mval
cmp scnpos
bne ctab1
ctab0: rts
;
;* repeat a character(|b,|h,|n,|o)
repchr: sta tmp5
lda mnum
beq repchr2
sta tmp2
repchr1: lda tmp5
sta $fe
jsr domode
dec tmp2
bne repchr1
repchr2: rts
repchr0: ldx mnum
repchr5: stx tmp6
sta tmp7
lda tmp6
beq repchr4
repchr3: lda tmp7
sta $fe
jsr output
dec tmp6
bne repchr3
repchr4: rts
;
;* not an mci command
notc: dec $96
dec $96
lda #$5c ; british pound
notc1: cmp #$04
bne domode
;
;* handle ctrl-d in string
ldx #0
dodate: inc $96
ldy $96
lda [$71],y
sta datebuf,x
inx
cpx #11
bne dodate
jsr convert
lda #0
sta index
ldy index
dodate1: lda date1,y
sta $fe
jsr output
inc index
ldy index
cpy #25
bne dodate1
rts
;
;* do print modes
domode: sta tmp4
jsr chkspcl
and #$7f
cmp #$20
bcs domode1
lda tmp4
sta $fe
jmp output
domode1: lda mprint
and #$0f
asl
tax
lda pmodetbl,x
sta domode2+1
inx
lda pmodetbl,x
sta domode2+2
domode2: lda $ffff
beq domode5
cmp #$ff
beq domode6
domode3: sta $fe
jsr output
inc domode2+1
bne domode2
inc domode2+2
bne domode2
domode5: rts
domode6: jsr dospeed
lda tmp4
jmp domode3
;
;* do print speed
dospeed: ldx mspeed
beq dokolor
jsr tenwait
;* do kolorific
dokolor: lda mkolor
beq donone
ldx mcolor
dokolor1:inx
txa
and #15
beq dokolor1
sta mnum
jsr comc
donone: rts
;
; wait for .x tenths of a second
tenwait: cpx #0
beq tnw3
tnw1: lda ten
tnw2: cmp ten
beq tnw2
dex
bne tnw1
tnw3: rts
;
;* character output routines *
;* last revision: 8/30/87 *
;
;* output character in .a
;* preserve registers
xchrout: sta $fe
xchrout1:tya
pha
txa
pha
jsr outchr
pla
tax
pla
tay
lda $fe
rts

;* output character, and
;* get response character
output: jsr outchr
jsr getchr
ldx #$a0
lda $fe
beq output1a
cmp #$13 ; home
beq output2
output0: ldx #$a0
cmp #"/"
beq output1
cmp #$20
beq output1
cmp #3
bne output1a
output1:       sta chat
              ldx #$c1  ; capital reverse A
output1a:      stx $420
              rts
output2:       lda #$d0  ; capital reverse P
              sta $41e
              jsr xgetchr
              lda #$a0
              sta $41e
              lda $fe
              jmp output0
;
;* output character
outchr: lda $fe
jsr chkspcl
outchr1: sta $fe
and #127
cmp #32
bcc outchr1a
ldx passmode
beq outchr2
lda mask
sta $fe
jmp outchr2
outchr1a:lda mci
bpl outchr2
lda $fe
jsr ctrlchk1
bcc outchr2
outchr1d:ora #64
pha
lda mreverse
bne outchr1b
lda #$12  ; reverse-on
jsr outchr1c
pla
jsr outchr1c
lda #$92 ; reverse-off
pha
outchr1b:pla
outchr1c:sta $fe
outchr2: ldx wrapflg
bne outchr4
outchr3: jsr outscn
jsr outmdm
jmp outptr
;
outchr4: lda $fe
ldx wrapind
outchr5: sta wrapbuf,x
inx
stx wrapind
and #$7f
cpx #80
bcs outchr6
cmp #32
beq outchr6
bcc outchr6
rts
outchr6: lda #13
sta $fe
txa
pha
clc
adc scnclm
cmp #41
bcc outchr6a
jsr outscn
outchr6a:pla
pha
clc
adc ptrclm
tay
dey
cpy ptrclmn
bcc outchr6b
jsr outptr
outchr6b:pla
clc
adc modclm
tay
dey
cpy modclmn
bcc outchr6c
jsr outmdm
outchr6c:ldy #0
sty wrapdmp
outchr7: cpy wrapind
beq outchr7a
lda wrapbuf,y
sta $fe
jsr outchr3
inc wrapdmp
ldy wrapdmp
bne outchr7
outchr7a:lda #0
sta wrapind
rts
;
outmdm: lda wrapflg
beq outmdm0
lda $fe
cmp #32
bne outmdm0
ldx modclm
inx
cpx modclmn
bcc outmdm0
lda #13
sta $fe
outmdm0: lda inchat
bne outmdm1
jsr carchk4
bne outmdm2
outmdm1: jsr outmod
outmdm2: rts
;
outptr: lda $fe
cmp #13
beq outptr0
jsr colorchk
bcc outptr4
jsr ctrlchk2
bcc outptr4
outptr0: ldx ptrclm
ldy ptrclmn
jsr outadj
stx ptrclm
lda mprtr
bne outptr1
ldx #12
ldy #5
jsr chkflags
beq outptr4
outptr1: ldx #4
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
outptr2: lda #0
sta mprtr
outptr3: jmp clrchn
outptr4: rts
;
;* output routine to fix 1200 and
;* do the transmit window
outm: sta $9e
txa
pha
tya
pha
jmp out1
out: sta $9e
txa
pha
tya
pha
lda $9a
cmp #2
beq out1
ldx #1
jsr setmode
lda $9e
jsr $e716
jmp out6
out1: lda scnmode
bne out3
ldx #0
out2: lda $7dd,x
sta $7dc,x
inx
cpx #$09
bne out2
lda $9e
sta $7e5
out3: lda $9e
jsr rsout
out6: pla
tay
pla
tax
lda $9e
clc
rts
out0: sta $9e
txa
pha
tya
pha
jmp out3

;* output carriage return
prcr: lda #$0d
jmp xchrout
;* output delete character
prdel: lda #$14
jmp xchrout

;********************************
;* character input routines *
;* last revision: 8/30/87 *
;********************************

;* get character into .a
;* handle mci access
xgetin: jsr xgetchr
cmp #$13 ; home
beq xgetin
cmp #$5c ; british pound
bne xgetin2
lda editor
and #$08
bne xgetin1
jmp xgetin
xgetin1: lda #$5c ; british pound
xgetin2: rts
;
xgetchr: jsr getchr
jsr carchk
bne xgetchr1
jsr chatchk
bne xgetchr1
lda $fe
beq xgetchr
rts
xgetchr1:lda #$0d
rts
;
;* input character to an$
;* waits for character
inchr: jsr xgetin
lda $fe
sta buffer
lda #$01
sta var
lda #<buffer
sta var+1
lda #>buffer
sta var+2
ldx #$00
jmp putvar ;an$
;
;* get character
;* with case setting
getchr: jsr getkbd
bne getchr1
jsr carchk4
bne getchr7
jsr getmod
getchr1: cmp #$60
bcc getchr3
cmp #$80
bcs getchr3
adc #$60
getchr3: cmp #$a0
bcc getchr4
cmp #$bf
bcs getchr4
adc #$40
getchr4: cmp #$e0
bne getchr5
lda #$20
getchr5: cmp #$de
bne getchr6
lda #$ff
getchr6: tax
lda editor
and #$01
bne getchr8
cpx #$e0
bcs getchr7
cpx #$7b
bcc getchr8
cpx #$80
bcs getchr8
getchr7: ldx #0
getchr8: stx $fe
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
sta tsr
pla
getchr8a:jsr dspidle
getchr9: lda $fe
ldx case
beq getchr11
cmp #$41
bcc getchr11
cmp #$5b
bcs getchr11
ora #$80
getchr11:ldx #7
getchr12:cmp spchars,x
beq getchr13
dex
bpl getchr12
bmi getchr14
getchr13:cpx #6
beq getchr14
txa
clc
adc #$85
getchr14:sta $fe
rts
;
dspidle: sta idlesec
stx idleten
sty idlemin
lda scnmode
bne dspidle1
lda curdsp
cmp #1
bne dspidle1
lda idlesec
ora #$b0
sta $4e1
txa
ora #$b0
sta $4e0
tya
ora #$b0
sta $4de
dspidle1: rts
;
getkbd: jsr crsron
getkbd0: ldx fkeybuf
beq getkbd2
inc fkeybuf
lda fkeybuf,x
bne getkbd1
lda #0
sta fkeybuf
getkbd2: jsr $f142
cmp #$85
bcc getkbd1
cmp #$8d
bcs getkbd1
lda #0
getkbd1: cmp #0
rts
;
;* get character from the modem
;* and move recieve window
getmdm: jsr rsinabl
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
getmdm1: lda scnmode
bne getmdm5
lda #0
pha
ldx #24
ldy #5
jsr chkflags
beq getmdm1a
pla
lda #6
pha
getmdm1a:pla
tay
getmdm2: lda $7c3,y
sta $7c2,y
iny
cpy #9
bne getmdm2
pla
pha
and #127
cmp #32
pla
pha
bcc getmdm4
ldx passmode
beq getmdm4
lda mask
getmdm4: sta $7cb
getmdm5: pla
rts
getmdm6: lda #0
rts

;********************************
;* misc character routines *
;* last revision: 8/30/87 *
;********************************

spchars: byte ",:",34,"*?=",13,$5e

chkspcl:	stx cxsav
chkspcl1:	cmp #$85
		bcc chkspcl2
		cmp #$8d
		bcs chkspcl2
		tax
		lda spchars-$85,x
chkspcl2:	ldx cxsav
		rts

;check carrier
; returns:
;0 if carrier / local
;1 if carrier dropped
;2 if time out

carchk: lda local
bne carchk2
ldx #4
ldy #5
jsr chkflags
bne carchk2
jsr carchk3
beq carchk1
lda #0
sta tsr
jsr disptime
lda #1
rts
carchk1: lda tsr
bne carchk2
lda editor
and #$40
bne carchk2
lda #2
rts
carchk2: lda #0
rts
; check actual carrier
; 0 = ok
; 1 = drop
carchk3: lda carrst
and #127
rts
;
;check if it's ok to use the modem
; 0 = ok
; <>0 = no
carchk4: ldx #4
ldy #5
jsr chkflags
bne carchk5
lda local
bne carchk5
jmp carchk3
carchk5:rts
;
chatchk: ldx #8
ldy #5
jmp chkflags
;
inable = $4303
disabl = $4306
;
modtype:byte 0
modst: word prgstart
;
modtbl: word prgstart ;0
word lmpstart ;1
word protostart ;2
word mmpstart ;3
word bmpstart ;4
word imstart ;5
word imstart ;6
word pmodetbl ;7
;
;* program load routines
;
serial3a:byte >serial,<serial
serial3b:word 65536-serial
;
;* load various types of modules
;
prgfile: cpx #0
bne prg0
ldx #8
prg0: stx filenum
sty modtype
cpy #8
bcc prg1
rts
prg1: lda serial3a
and #$0f
sta bsnval+1
lda serial3a+1
sta bsnval
lda $2b
sta modtbl
lda $2c
sta modtbl+1
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
jsr disabl
lda #0
ldx modst
ldy modst+1
jsr loadf
php
jsr inable
plp
bcc prg2
rts
prg2: ldy modtype
beq prg3
cpy #1
beq module
cpy #3
beq module
cpy #4
beq module
cpy #5
beq immod
cpy #6
beq immod
rts
;
;link program to module
module: jsr relink
jsr follow
lda modst
sta [$ac],y
iny
lda modst+1
sta [$ac],y
;
;link module to im
prg3: lda $2b
pha
lda $2c
pha
ldx modst
ldy modst+1
stx $2b
sty $2c
jsr relink
jsr follow
lda #<imstart
sta [$ac],y
iny
lda #>imstart
sta [$ac],y
prg4: pla
sta $2c
pla
sta $2b
rts
;
;relink im program/modules
immod: lda $2b
pha
lda $2c
pha
ldx #<imstart
ldy #>imstart
stx $2b
sty $2c
jsr relink
jsr follow
ldx $ac
ldy $ad
stx modtbl+12
sty modtbl+13
jmp prg4
;
;follow to end or to immdline
;whatever comes first
follow: ldx $2b
ldy $2c
stx $ac
sty $ad
follow1: ldy #0
lda [$ac],y
sta $71
iny
lda [$ac],y
sta $72
tax
lda [$71],y
beq follow2
lda $71
sta $ac
stx $ad
iny
lda [$ac],y
iny
cmp #<immdline
lda [$ac],y
sbc #>immdline
bcc follow1
ldy #0
follow2: tay
rts

;* read disk directory
dskdir: sty dflag
cpx #0
beq dskdir0
        stx filenum
dskdir0: cpy #0
bne dskdir1
ldx filenum
jsr chkin
jsr chrin
jsr chrin
dskdir1: jsr dir
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
dskdir2: rts

;* read single line of directory

dir:		ldx filenum
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
dir3:		lda decchr,y
		cmp #$30
		beq dir3a
		inx
dir3a:		cpx #0
		bne dir3b
		lda #$20
dir3b:		sta buf2,y
		iny
		cpy #5
		bcc dir3
dir4:		ldy #5
		lda #$20
		sta buf2,y
		iny
dir0:		jsr chrin
		cmp #$20
		beq dir0
		sta buf2,y
		iny
dir1:		jsr chrin
		beq dir2
		sta buf2,y
		iny
		lda $90
		beq dir1
dir2:		lda buf2-1,y
		cmp #$20
		bne dir5
		dey
		bne dir2
dir5:		sty var
		lda #<buf2
		sta var+1
		lda #>buf2
		sta var+2
		ldx #$01
		jsr putvar ;a$
		jmp clrchn

;* input from disk
dskin:		cpx #0
		bne dskin0a
		stx filenum
dskin0a:	cpy #0
		bne bytin
dskin0:		jsr chkin
		lda #0
		sta index
dskin1:		jsr getin
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
		lda #$5e
		sta buf2
		lda #$40
		sta $90
		ldy #1
dskin3:		sty var
		lda #<buf2
		sta var+1
		lda #>buf2
		sta var+2
		ldx #$01
		jsr putvar ;a$
		jmp clrchn
;
bytin: jsr chkin
cpy #80
bcc bytin0
ldy #80
bytin0: sty index
ldy #0
bytin1: jsr chrin
sta buf2,y
iny
cpy index
bne bytin1
jmp dskin3
;
dumparr: sty dumparr4+1
jsr chkout
ldx #0
dumparr1:inx
txa
pha
jsr getarr
ldy #0
dumparr2:cpy var
beq dumparr3
lda [var+1],y
jsr chrout
iny
bne dumparr2
dumparr3:lda #13
jsr chrout
pla
tax
dumparr4:cpx #0
bcc dumparr1
jmp clrchn
;
;*irq routine

;* counter to execute a different
;* part of the routine each jiffy
;
irq: jsr irq9
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
irq0: ldy #0
lda irqtbl,y
sta irqjmp+1
iny
lda irqtbl,y
sta irqjmp+2
iny
cpy #18
bcc irq0a
ldy #0
irq0a: sty irq0+1
irqjmp: jmp $ffff
irqtbl: word irq1 ;page
word irq2 ;time
word irq3 ;blanker
word irq4 ;lightbar
word irq5 ;carrier
word irq6 ;flag
word irq7 ;lightbar
word irq4 ;lightbar
word irq11 ;alarm

;* chat page

irq1:		ldy #4
		dey
		bpl irq1a
		ldy #4
irq1a:		sty irq1+1
irq1z:		ldx #5
		dex
		bpl irq1b
		ldx #5
irq1b:		stx irq1z+1
		lda scnmode
		bne irq1e
		lda chatpage
		bne irq1c
		ldx #0
irq1c:		lda pagecol,x
		ldx #15
irq1d:		sta $dbcc,x
		dex
		bpl irq1d
crsrflg = *+1
irq1e:		lda #$00
		beq nocrsr
		lda sline
		cmp topline
		bcc nocrsr
		cmp botline
		beq irq1f
		bcs nocrsr
irq1f:		lda irq1+1
		and #2
		beq irq1g
		lda #$80
irq1g:		eor undchr
		ldx mcolor
docrsr:		ldy 2
curptr=*+1
		sta $0518,y
		txa
colptr=*+1
		sta $d918,y
nocrsr:		rts

crsron: lda crsrflg
bne crsron1
lda sline
cmp topline
bcc crsron1
cmp botline
beq crsron0
bcs crsron1
crsron0: ldy 2
lda curptr
sta $fb
lda curptr+1
sta $fc
lda [$fb],y
sta undchr
lda colptr
sta $fb
lda colptr+1
sta $fc
lda [$fb],y
sta undcol
lda #1
sta crsrflg
lda #3
sta irq1+1
crsron1: jmp irq1e
;
crsroff: php
sei
lda crsrflg
beq crsroff1
lda #0
sta crsrflg
lda undchr
ldx undcol
jsr docrsr
crsroff1:plp
rts
;
;* update time on screen
;
timeflag:byte 0
;
irq2: lda min
ldx timeflag
bne irq2a
cmp bootdate+5
beq ha872
irq2a: sta bootdate+5
ldx #0
stx timeflag
jsr dotsr
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
ha832: ldy bootdate+1
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
ha84d: lda bootdate+2
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
ha86e: cld
ha86f: jsr makdate
ha872: lda scs
jsr bcdtoa
pha
txa
tay
pla
ldx #$17
jsr dispdt
tya
jsr dispdt
lda tsr
beq ha083
lda #$59
sed
sec
sbc scs
cld
; display tsr
ha083: jsr bcdtoa
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
lda tsr
beq tchk1
lda #<copyrite
sta jmptbl
lda #>copyrite
sta jmptbl+1
tchk1: lda tsr
cmp tsr2
sta tsr2
bne tchk2
jsr disptime
tchk2: rts
;
;* make string out of current date
;* for d1$ (convert from 6 byte to
;* 11 byte format)
;
makdate:	lda bootdate
		ora #$30
		sta d1str
		lda bootdate+1
		jsr bcdtoa
		sta d1str+3
		stx d1str+4
		lda bootdate+2
		jsr bcdtoa
		sta d1str+5
		stx d1str+6
		lda bootdate+3
		jsr bcdtoa
		sta d1str+1
		stx d1str+2
		lda bootdate+4
		jsr bcdtoa
		sta d1str+7
		stx d1str+8
		lda bootdate+5
		jsr bcdtoa
		sta d1str+9
		stx d1str+10
dispdate:	ldy bootdate
		dey
		tya
		asl
		asl
		tay
		ldx #0
dispd1:		lda days,y
		jsr dispdt
		iny
		cpx #4
		bne dispd1
		lda bootdate+1
		cmp #$10
		bcc dispd1a
		sbc #6
dispd1a:	tay
		dey
		tya
		asl
		asl
		tay
dispd2:		lda months,y
		jsr dispdt
		iny
		cpx #8
		bne dispd2
		lda d1str+5
		cmp #$30
		bne dispd3
		lda #$20
dispd3:		jsr dispdt
		lda d1str+6
		jsr dispdt
		lda #","
		jsr dispdt
		lda #$20
		jsr dispdt
		lda #$31
		jsr dispdt
		lda #$39
		jsr dispdt
		lda d1str+1
		jsr dispdt
		lda d1str+2
		jsr dispdt
		lda #$20
		jsr dispdt
		lda d1str+7
		and #$31
		cmp #$30
		bne dispd4
		lda #$20
dispd4:		jsr dispdt
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
		lda #$20
		jsr dispdt
		lda d1str+7
		cmp #$38
		bcs dispd5
		lda #$c1        ; capital A
		bne dispd6
dispd5:		lda #$d0        ; capital P
dispd6:		jsr dispdt
		lda #$cd        ; capital M
		jsr dispdt
		lda #$20
;* convert to screen, store it
dispdt:		pha
		and caseflag
		cmp #128
		bcs dispdt1
dispdt2:	cmp #64
		bcc dispdt1
		and #63
dispdt1:	ora #$80
		sta $0401,x
dispdt3:	inx
		pla
		rts

;* convert bcd to ascii
bcdtoa: tax
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

dotsr: lda tsr
beq dotsr1
cmp #101
bcs dotsr1
dec tsr
dotsr1:rts
;
irq8: lda tsr
cmp oldtsr
bne disptime
rts
disptime:ldx #32
lda #$20
lda #$20
jsr dispdt
lda tsr
beq dt0
cmp #101
bcc dt01
lda #101
sta tsr
lda #"-"
tay
bne dt3
dt01: sec
sbc #1
dt0: ldy #$30
dt1: cmp #10
bcc dt2
sbc #10
iny
bne dt1
dt2: ora #$30
dt3: pha
tya
jsr dispdt
pla
jsr dispdt
lda #":"
jmp dispdt
;
irq3: jsr chkblnk
beq irq3a
lda blnkflag
bne irq3a
inc blnkcntr
bne irq3b
scrnoff: lda #1
ldx #11
ldy #0
beq scrnon1
scrnon: lda #0
ldx #27
ldy #11
scrnon1: jsr scrnset
irq3a: lda #0
sta blnkcntr
irq3b: rts
chkblnk: ldx #11
jmp chkflag
;
; toggle full screen
setmode0:rts
setmode: cpx scnmode
bne setmode0
setmode1:cpx #0
bne halfscn
fullscn: jsr toglscn
fullscn1:ldx #1
ldy #24
lda #1
setsize: stx topline
sty botline
sta scnmode
rts
halfscn: jsr crsroff
jsr toglscn
halfscn1:ldx #7
ldy #22
lda #0
beq setsize
;
toglscn: ldy #0
loop: lda $428,y
tax
lda tempscn,y
sta $428,y
txa
sta tempscn,y
lda $d828,y
tax
lda tempcol,y
sta $d828,y
txa
sta tempcol,y
iny
cpy #240
bne loop
ldy #0
loop: lda $798,y
tax
lda tempbott,y
sta $798,y
txa
sta tempbott,y
lda $db98,y
tax
lda tempbotc,y
sta $db98,y
txa
sta tempbotc,y
iny
cpy #80
bne loop
rts
;
bits: byte 1,2,4,8,16,32,64,128
;
serial4b:word serial
;* put check on screen for carrier
irq5: ldx #$fa
lda carrier
eor mxor
and #$10
beq irq5a
lda #1
sta carrst
ldx #$a0
bne irq5d
irq5a: lda carrst
ora #128
sta carrst
irq5d: lda topline
beq irq5c
stx $427
lda #$a0
pha
ldx #16
ldy #5
jsr chkflags
bne irq5b
pla
lda #$fa
pha
irq5b: pla
sta $400
irq5c: lda serial4a
cmp serial4b
bne irq5e
lda serial4a+1
cmp serial4b+1
bne irq5e
rts
irq5e: ldx #1
jmp setmode
serial4a:word serial
;
irq6: lda carrst
and #127
irq6a: cmp #1
beq irq6b
sta irq6a+1
cmp #0
bne irq6b
lda #1
sta flag
irq6b: ldx #4
ldy #5
jsr chkflags
irq6c: cmp #0
beq irq6d
sta irq6c+1
cmp #0
beq irq6d
lda carrst
and #127
beq irq6d
lda #1
sta flag
irq6d: rts
;
;* display lightbar checkmarks
irq7: ldy #1
lda bar
and #15
sta bar
cpy #0
beq irq7z
lda #0
sta irq7+1
lda scnmode
bne irq7z
lda $14
pha
lda $15
pha
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
lsr
lsr
lsr
asl
tax
lda bartbl+0,x
sta $14
lda bartbl+1,x
sta $15
lda chktbl+1,x
pha
lda chktbl+0,x
ldx #0
ldy #0
irq7b: jsr irq7h
cpx #20
bcc irq7b
pla
irq7c: jsr irq7h
cpx #40
bcc irq7c
pla
sta tmpbar
pla
sta $15
pla
sta $14
irq7z: rts
;
irq7d: lsr
pha
lda #$20
bcc irq7e
lda #$7a
irq7e: jsr irq7f
pla
rts
;
irq7f: ora #$80
sta light,x
irq7g: lda #$f1
sta $d8f0,x
inx
rts
;
irq7h: pha
lda #$fc
cpx tmpbar
bne irq7i
lda #$f1
irq7i: sta irq7g+1
pla
jsr irq7d
pha
lda [$14],y
jsr irq7f
iny
lda [$14],y
jsr irq7f
iny
lda [$14],y
jsr irq7f
iny
pla
jmp irq7d
;
chkflag: ldy #5
chkflags:lda $ff
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
chkflag6: sta chktbl,x
chkflag7: inc irq7+1
chkflag8: tax
pla
sta $ff
txa
rts
;
chkflag0:eor #$ff
and chktbl,x
jmp chkflag6
chkflag1:ora chktbl,x
jmp chkflag6
chkflag2:eor chktbl,x
jmp chkflag6
chkflag3:ldy #0
sty var
and chktbl,x
beq chkflg3a
iny
chkflg3a:sty var+1
ldx #30
jsr putvar ;a%
jmp chkflag8
chkflag4:lda $ff
sta bar
jmp chkflag7
chkflag5:and chktbl,x
jmp chkflag8
;
tmp14:		byte 0
tmp15:		byte 0
tmpbar:		byte 0
tmpchk1:	byte 0
tmpchk2:	byte 0
chktbl:		byte 0,0,0,0
bartbl:		word ltbar1,ltbar2
ltbar1:		scn "SysAcsLocTsrChtNewPrtU/D"
ltbar2:		scn "AscAnsExpUnvTrcBelNetFn1"

fkey:		ldx tmpkey
		lda 653
		and #4
		bne fkey1
		inx
fkey1:		txa
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
fkey2:		lda [3],y
		sta fkeybuf+1,y
		iny
		dex
		bne fkey2
		lda #0
		sta fkeybuf+1,y
		lda #1
		sta fkeybuf
fkey3:		pla
		sta 4
		pla
		sta 3
fkey4:		rts

irq9: jsr $ffea
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
irq9e: eor #$80
jsr $ea1c
irq9f: jmp $ea87
;
irq10: lda sndtim1
beq irq10a
dec sndtim1
bne irq10d
lda sndwav1
ldx sndwav2
ldy sndwav3
jsr irq10c
irq10a: lda sndtim2
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
irq10b: lda sndtim1a
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
irq10c: sta $d404
stx $d40b
sty $d412
irq10d: rts
;
irq11: lda $dc0d
and #4
beq irq11z
ldx #28
ldy #5
jsr chkflags
beq irq11z
ldx #29
ldy #1
jsr chkflags
irq11z: rts
;
settim: lda #$08
byte $2c
setalm: lda #$88
sta $dc0f
cmp #$88
beq settim2
lda #1
sta timeflag
cpx #12
bne settim1
ldx #92
bne settim2
settim1: cpx #92
bne settim2
ldx #12
settim2: txa
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
settim3: ldx #0
settim4: cmp #10
bcc settim5
sbc #10
inx
bne settim4
settim5: sta $ff
txa
asl
asl
asl
asl
ora $ff
rts
;
irq4: lda 197
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
irq4a: jmp $ffff
irq4b: lda ktbl1,y
irq4c: rts
irq4d: jmp fkey
;
tmpkey: byte 0
oldkey: byte 64
shfkey: byte 0
;
ktbl1: word t1fk1,t1fk2
word t1fk3,t1fk4
word t1fk5,t1fk6
word t1fk7,t1fk7
;
t1init: ldy #0
jsr chkflags
ldx #<ktbl1
ldy #>ktbl1
usekey: stx irq4b+1
sty irq4b+2
rts
t1fk1: ldx scnlock
bne t1fk3b
ldx scnmode
jmp setmode1
t1fk2: lda blnkflag
bne t1fk2a
jmp scrnoff
t1fk2a: jmp scrnon
t1fk3: dec bar
t1fk3a: inc irq7+1
t1fk3b: rts
t1fk4: sec
lda bar
sbc #8
t1fk4a: sta bar
jmp t1fk3a
t1fk5: inc bar
jmp t1fk3a
t1fk6: clc
lda bar
adc #8
jmp t1fk4a
t1fk7: lda bar
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
rts
t1fk7a: jmp t3init ;acs
t1fk7b: jmp t2init ;tsr
;
;edit users time
ktbl2: word t2fk1,t2fk2
word t2fk3,t2fk4
word t2fk5,t2fk6
word t2fk7,t2fk7
;
t2init: ldx #<ktbl2
ldy #>ktbl2
jmp usekey
t2fk1: lda #0
byte $2c
t2fk2: lda #101
t2fk2a: sta tsr
jmp disptime
t2fk3: lda tsr
cmp #101
bcs t2fk3a
inc tsr
jmp disptime
t2fk3a:rts
t2fk4: lda tsr
cmp #101
bcs t2fk3a
adc #10
bcc t2fk2a
t2fk5: lda tsr
beq t2fk3a
dec tsr
jmp disptime
t2fk6: lda tsr
cmp #10
bcc t2fk3a
sbc #10
bcs t2fk2a
t2fk7: ldx #6
jmp t1init
;
;edit users access
ktbl3: word t3fk1,t3fk2
word t3fk5,t3fk5
word t3fk3,t3fk3
word t3fk7,t3fk7
;
t3init: ldx #<ktbl3
ldy #>ktbl3
jsr usekey
lda access
and #$7f
ora #$b0
sta $049c
rts
t3fk3: dec $049c
lda $049c
cmp #$b0
bcs t3fk3a
t3fk2: lda #$b9
sta $049c
t3fk3a: rts
t3fk5: inc $049c
lda $049c
cmp #$ba
bcc t3fk5a
t3fk1: lda #$b0
sta $049c
t3fk5a: rts
t3fk7: lda $049c
and #$7f
sta $049c
and #$0f
ora #$80
sta access
ldx #2
jmp t1init
;
;
inable = $4303
disabl = $4306
;
;********************************
;* display routines
;********************************

;* display bottom
;* also clear screen, and
;* home cursor, set color memory
disp3: lda #2
jsr disp
lda #$93 ; clear-screen
sta $fe
jsr outscn
inc irq7+1
rts
;
;* display top #2 : idle
disp2: lda #0
jsr disptop
lda #0
sta chatpage
sta tsr
jsr disptime
sta sndrept
ldx #4
ldy #0
jsr chkflags
ldx #5
ldy #0
jmp chkflags
;
;* display top #1 : user online
disp1: lda #1
jsr disptop
inc irq7+1
rts
;
disp4: lda #3
jmp disptop
;
dname: cbm "0:scn.t1"
disptop: sta curdsp
disp: stx dspdev
clc
adc #$31
sta dname+7
tya
ora #$30
sta dname
		ldx #1
		jsr setmode
		lda #$54 ; "t"
		jsr loadscn
		lda #$43 ; "c"
		jsr loadscn
		lda #$13 ; home
		jsr chrout
lda #11
sta var
lda #<d1str
sta var+1
lda #>d1str
sta var+2
ldx #4
jsr putvar ;d1$
ldx #39
lda #1
cltp1: sta $d800,x
dex
bpl cltp1
lda #$a0
sta $420
sta $41e
sta $41f
rts
;
loadscn: sta dname+6
ldx #<dname
ldy #>dname
lda #8
jsr $ffbd
lda #1
tay
ldx dspdev
jsr $ffba
jsr disabl
lda #0
jsr $ffd5
jmp inable
dspdev: byte 8
;
setbaud:txa
jmp rsbaud
;
bsnpre = $02fd
bsnval = $02fe
;
;********************************
;* variable handling routines *
;********************************

;* get descriptor for tt$(.x)
getarr:jsr findarr
ldy #2
jmp usevar1
;
;* get and copy memory to buffer
getln:jsr getarr
ldy var
sty index
getln0:dey
cpy #$ff
beq getln1
cpy #80
bcs getln0
lda [var+1],y
sta buffer,y
jmp getln0
getln1:rts
;
;* print tt$(.a)
prtln: jsr getarr
jmp outstr
;
;* put descriptor for tt$(.x) and
;* store buffer in memory
putarr:jsr findarr
ldy #2
jmp putvar1
;
;* put and store string
putln: txa
pha
lda index
jsr makeroom
ldy index
beq putln2
dey
putln1:lda buffer,y
sta [var+1],y
dey
bpl putln1
putln2: pla
tax
jmp putarr
;
;* find descriptor for tt$(.x)
findarr:stx $47
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
;
;* find basic variable
varnam: txa
asl
tay
lda vars+1,y
sta $48
lda vars,y
sta $47
rts
findvar: sta $45
stx $46
jmp findvar1
;
;* output a$
outastr: ldx #1
jsr chrgot
beq prtvar
jsr getstr
sta var
stx var+1
sty var+2
jmp outstr
;
;* print string variable
prtvar: jsr usevar
jmp outstr
;
;* print string variable w/mci
prtvar0: lda mci
pha
lda #0
sta mci
jsr prtvar
pla
sta mci
rts
;
;* get variable descriptor
usevar: jsr varnam
jmp usevar2
usevar0: jsr findvar
usevar2: ldy #4
usevar1: lda [$47],y
sta var,y
dey
bpl usevar1
rts
;
;* put variable descriptor
putvar: jsr varnam
jmp putvar2
putvar0: jsr findvar
putvar2: ldy #4
putvar1: lda var,y
sta [$47],y
dey
bpl putvar1
rts
;
zero: lda #0
ldy #4
zero1: sta var,y
dey
bpl zero1
rts
minusone:jsr zero
lda #$81
sta var
rts

;********************************
;* variables used by ml *
;********************************

vars:
varanstr=(*-vars)/2
	byte $41, $ce         ;  0 an$
varastr =(*-vars)/2
	byte $41, $80         ;  1 a$
varbstr =(*-vars)/2
	byte $42, $80         ;  2 b$
vartrstr=(*-vars)/2
	byte $54, $d2         ;  3 tr$
vard1str=(*-vars)/2
	byte $44, $b1         ;  4 d1$
vard2str=(*-vars)/2
	byte $44, $b2         ;  5 d2$
vard3str=(*-vars)/2
	byte $44, $b3         ;  6 d3$
vard4str=(*-vars)/2
	byte $44, $b4         ;  7 d4$
vard5str=(*-vars)/2
	byte $44, $b5         ;  8 d5$
varldstr=(*-vars)/2
	byte $4c, $c4         ;  9 ld$
varttstr=(*-vars)/2
	byte $54, $d4         ; 10 tt$
varnastr=(*-vars)/2
	byte $4e, $c1         ; 11 na$
varrnstr=(*-vars)/2
	byte $52, $ce         ; 12 rn$
varphstr=(*-vars)/2
	byte $50, $c8         ; 13 ph$
varakstr=(*-vars)/2
	byte $41, $cb         ; 14 ak$
varlpnum=(*-vars)/2
	byte $4c, $50         ; 15 lp
varplnum=(*-vars)/2
	byte $50, $4c         ; 16 pl
varrcnum=(*-vars)/2
	byte $52, $43         ; 17 rc
varshnum=(*-vars)/2
	byte $53, $48         ; 18 sh
varmwnum=(*-vars)/2
	byte $4d, $57         ; 19 mw
	byte $4e, $4c         ; 20 nl
	byte $55, $4c         ; 21 ul
	byte $51, $45         ; 22 qe
	byte $52, $51         ; 23 rq
	byte $c1 ,$c3         ; 24 ac%
	byte $45 ,$46         ; 25 ef
	byte $4c ,$46         ; 26 lf
	byte $57 ,$80         ; 27 w$
	byte $50 ,$80         ; 28 p$
	byte $d4 ,$d2         ; 29 tr%
	byte $c1 ,$80         ; 30 a%
	byte $c2 ,$80         ; 31 b$
	byte $c4 ,$d6         ; 32 dv%
	byte $44 ,$d2         ; 33 dr$
	byte $43 ,$b1         ; 34 c1$
	byte $43 ,$b2         ; 35 c2$
	byte $43 ,$cf         ; 36 co$
	byte $43 ,$c8         ; 37 ch$
	byte $cb ,$d0         ; 38 kp%
	byte $43 ,$b3         ; 39 c3$
	byte $46 ,$b1         ; 40 f1$
	byte $46 ,$b2         ; 41 f2$
	byte $46 ,$b3         ; 42 f3$
	byte $46 ,$b4         ; 43 f4$
	byte $46 ,$b5         ; 44 f5$
	byte $46 ,$b6         ; 45 f6$
	byte $46 ,$b7         ; 46 f7$
	byte $46 ,$b8         ; 47 f8$

;********************************
;* decimal to ascii routine *
;********************************
decimal: sta binary
stx binary+1
ldy #$00
dec0: lda dectbl1,y
ldx dectbl2,y
dec1: sta binary+2
stx binary+3
ldx #$30
dec2: lda binary
cmp binary+2
lda binary+1
sbc binary+3
bcc dec3
sta binary+1
lda binary
sbc binary+2
sta binary
inx
bne dec2
dec3: txa
sta decchr,y
iny
cpy #5
bne dec0
rts
dectbl1: byte <10000,<1000,<100,<10,<1
dectbl2: byte >10000,>1000,>100,>10,>1
;********************************
;* memory and trace update
;********************************
swapgc: lda #>gc
ldy #>gchide
ldx #gclen
jmp swapper
;
memory: clc
lda 51
cmp 49
lda 52
sbc 50
bne memory0
jsr forcegc
clc
lda 51
cmp 49
lda 52
sbc 50
bne memory0
; less than 256 bytes free, force
; out of memory error for safety
ldx #0
jsr clrarr
ldx #16
jmp farerr
memory0: lda #0
sta var
lda tsr
cmp tsr1
beq memory0a
sta tsr1
sta var+1
ldx #29
jsr putvar ;tr%
memory0a:inc scnlock
lda scnmode
bne memory0b
jsr memory1
memory0b:dec scnlock
rts
;
memory1: sec
lda 51
sbc 49
sta num
lda 52
sbc 50
sta num+1
lda 49
cmp oldmem
bne memory2
lda 50
cmp oldmem+1
beq trace
memory2: lda num
sta oldmem
lda num+1
sta oldmem+1
lda #<$79b
ldx #>$79b
jsr prdec
trace: lda 57
ldx 58
sta num
stx num+1
cmp oldline
bne trace1
cpx oldline+1
bne trace1
rts
trace1: sta oldline
stx oldline+1
ldx #24
ldy #5
jsr chkflags
beq trace4
ldy #1
lda [$7a],y
sta $7c7
ldx #0
ldy #200
trace2: lda 653
and #1
beq trace3
dex
bne trace2
dey
bne trace2
trace3: lda #<$7c2
ldx #>$7c2
jsr prdec
trace4: rts
;
prdec: sta $fb
stx $fc
lda num
ldx num+1
jsr decimal
ldy #4
prdec1: lda decchr,y
ora #$80
prdec2: sta [$fb],y
dey
bpl prdec1
prdec3: rts
num: word 0
oldline: word 0
oldmem: word 0
tsr1: byte 0
token:byte 0

forcegc:	lda #$c7 ; capital reverse G
		sta $41f
		jsr swapgc
		jsr gc
		jsr swapgc
		lda #$a0 ; reverse space
		sta $41f
		rts

outscn: lda wrapflg
beq outscn1
lda $fe
cmp #32
bne outscn1
ldx scnpos
cpx #39
bne outscn1
lda #13
sta $fe
outscn1: lda #0
sta idlejif
tax
tay
jsr dspidle
jsr chkblnk
beq sc1
jsr scrnon
sc1: jsr crsroff
jsr swap2
jsr swap
lda 214
cmp topline
bcs sc1a
lda topline
sta 214
sc1a: lda 214
cmp botline
beq sc1b
bcc sc1b
jsr scroll
jmp sc1a
sc1b: jsr sccrsr
lda $fe
and #127
cmp #32
bcs sc4
lda $fe
ldy #nchrs-1
sc2: cmp chrs,y
beq sc6
dey
bpl sc2
ldy #15
sc3: cmp colors,y
beq sc4
dey
bne sc3
jmp sc8
sc4: ldx 211
cpx #39
bne sc5
ldx 214
cpx botline
bne sc5
jsr scroll
sc5: lda $fe
jsr $e716
ldx 211
cpx #40
bcc sc8
lda #0
sta 211
lda #39
sta 213
sc8: jsr sccrsr
jsr swap1
jsr swap
jmp crsron
sc6: tya
asl
tay
lda chrtbl,y
sta sc7+1
lda chrtbl+1,y
sta sc7+2
lda $fe
sc7: jsr $ffff
jmp sc8
scret: ldx #0
stx mprint
stx mspeed
stx mdigits
ldx #$30
stx cnumc
jmp scdn
scupc: and #128
asl
rol
sta mupcase
rts
scclear: lda scnmode
bne sccl0
ldy #0
loop: lda #32
sta tempscn,y
lda mcolor
sta tempcol,y
iny
cpy #240
bne loop
ldy #0
loop: lda #32
sta tempbott,y
lda mcolor
sta tempbotc,y
iny
cpy #80
bne loop
sccl0: ldx topline
dex
sccl1: inx
jsr scline
jsr fixlinks
cpx botline
bcc sccl1
schome: lda topline
sta 214
lda #0
sta 211
sccrsr: ldx 214
sccrsr1: jsr $e9f0
jmp $ea24
scrt: ldx 211
cpx #39
bne scrt1
scdn: ldx 214
cpx botline
bne scrt1
pha
jsr scroll
pla
scrt1: jmp $e716
scdel:
sclf: ldx 211
bne scrt1
scup: ldx 214
dex
cpx topline
bcs scrt1
rts
scrvs: jmp $e716
scbell: ldx #26
ldy #5
jsr chkflags
beq scbell1
ldx #2
ldy #0
jsr sound
scbell1: rts
;
scroll: lda $ac
pha
lda $ad
pha
lda $ae
pha
lda $af
pha
lda scnmode
bne scroll0
ldy #0
loop: lda tempscn+40,y
sta tempscn,y
lda tempcol+40,y
sta tempcol,y
iny
cpy #200
bne loop
ldy #0
loop: lda $518,y
sta tempscn+200,y
lda $d918,y
sta tempcol+200,y
iny
cpy #40
bne loop
scroll0: ldx topline
scroll1: inx
jsr sccrsr1
lda $d1
sta $ac
lda $d2
sta $ad
lda $f3
sta $ae
lda $f4
sta $af
dex
jsr sccrsr1
jsr $e9d2
inx
jsr fixlinks
cpx botline
bcc scroll1
jsr scline
pla
sta $af
pla
sta $ae
pla
sta $ad
pla
sta $ac
dec 214
jsr sccrsr
lda scnmode
bne scroll2
ldy #39
loop: lda tempbott,y
sta $770,y
lda tempbotc,y
sta $db70,y
lda tempbott+40,y
sta tempbott,y
lda tempbotc+40,y
sta tempbotc,y
lda #32
sta tempbott+40,y
lda mcolor
sta tempbotc+40,y
dey
bpl loop
scroll2:rts
scline:  jsr $e9f0
jsr $ea24
ldy #$27
scline1:       lda 646
             sta [$f3],y
             lda #32
             sta [$d1],y
             dey
             bpl scline1
             rts

chrtbl:        word scupc, scupc
             word scrvs, scrvs
             word schome, scclear
             word scrt, sclf
             word scdn, scup
             word scret, scdel
             word scbell

chrs:          byte 14,142,18,146,19,147,29,157,17,145,13,20,7
nchrs = *-chrs

swap:          lda #39
             sta 213
             lda #0
             sta 212
             lda #0
             sta 216

             ldx 214
fixlinks:      lda 217,x
             ora #128
             sta 217,x
             rts

topline:       byte 7
botline:       byte 22
sline:         byte 7

swap1:         inc scnlock
             sei
             lda 646
             sta mcolor
lda 199
sta mreverse
lda 209
sta curptr
lda 210
sta curptr+1
lda 211
sta scnpos
lda 214
sta sline
lda 243
sta colptr
lda 244
sta colptr+1
cli
rts
swap2: dec scnlock
lda mcolor
sta 646
lda mreverse
sta 199
lda curptr
sta 209
lda curptr+1
sta 210
lda scnpos
sta 211
lda sline
sta 214
lda colptr
sta 243
lda colptr+1
sta 244
rts
;
poscrsr: txa
pha
tya
tax
pla
tay
clc
jmp $fff0
;
getmod: jsr getmdm
sta $fe
pha
ldx #16
ldy #5
jsr chkflags
tax
pla
cpx #0
beq getmod1
tax
lda tblatc,x
sta $fe
getmod1: cmp #0
beq getmod3
ldx getmodn
cmp getmodt,x
bne getmod2
inx
stx getmodn
cpx #5
bcc getmod3
pha
lda serial4a+1
lsr
lsr
lsr
lsr
ora #$c0
jsr outm
lda serial4a+1
jsr outh
lda serial4a
lsr
lsr
lsr
lsr
jsr outh
lda serial4a
jsr outh
pla
getmod2: ldx #0
stx getmodn
getmod3: cmp #0
rts
getmodn: byte 0
getmodt: byte 9,13,1,7,5 ;image
outh: and #$0f
ora #$30
cmp #$3a
bcc outh1
adc #6
outh1: jmp outm
;
outmod:               lda $fe
                    ldx modclm
                    ldy modclmn
                    jsr outadj
                    stx modclm
                    ldx #16
                    ldy #5
                    jsr chkflags
                    tax
                    lda $fe
                    cpx #0
                    bne outmod0
                    jmp outm
outmod0:              ldx #19
                    ldy #5
                    jsr chkflags
                    tax
                    lda $fe
                    and #$1f
                    tay
                    lda $fe
                    cpx #0
                    beq outmod0e
                    cmp #96         ;   0- 95 pass
                    bcc outmod0e
                    cmp #128        ;  96-127 use tblctoa2
                    bcc outmod0a
                    cmp #160        ; 128-159 pass
                    bcc outmod0e
                    cmp #192        ; 160-191 use tblctoa1
                    bcc outmod0d
                    cmp #224        ; 192-223 use tblctoa2
                    bcs outmod0e    ; 224-255 pass
outmod0a:             lda mupcase
                    bne outmod0c
                    lda tblctoa2,y
                    bne outmod1
outmod0c:             lda tblctoa3,y
                    bne outmod1
outmod0d:             lda tblctoa1,y
                    bne outmod1
outmod0e:             tax
lda tblcta,x
beq outmod3
outmod1: pha
and #$7f
cmp #32
pla
bcs outmod2
               cmp #08        ; backspace
               beq outmodh
               cmp #13        ; carriage-return
               beq outmodm
               cmp #$92       ; reverse-off
               beq outmodr0
               cmp #$12       ; reverse-on
               beq outmodr1
               cmp #$91       ; cursor-up
               beq outmodup
               cmp #$11       ; cursor-down
               beq outmoddn
               cmp #$1d       ; cursor-right
               beq outmodrt
               cmp #$9d       ; cursor-left
               beq outmodlf
               jsr colorchk
               bcc outmodc
outmod2:         jmp outm
outmod3:         rts
;
outmodh:         ldx interm
               bne outmodh1
               jsr outm
               lda #$20
               jsr outm
outmodh1:        lda #dish
               jmp outm
;
outmodm: lda interm
bne outmodm1
jsr outmodr0
outmodm1:ldx #17
ldy #5
jsr chkflags
beq outmodm2
lda #13
jsr outm
lda #10
jmp outm
outmodm2:lda #13
jmp outm
;
outmodup:lda #$41
bne outmodcm
outmoddn:lda #$42
bne outmodcm
outmodrt:lda #$43
bne outmodcm
outmodlf:lda #$44
outmodcm:pha
ldx #18
ldy #5
jsr chkflags
bne outmodmc
pla
rts
outmodmc:          lda #27
                 jsr outm
                 lda #91 ; bracket
                 jsr outm
                 pla
                 jmp outm
;
outmodr0:          lda #$33
                 ldx #$34
                 jmp outmodr
outmodr1:          lda #$34
                 ldx #$33
outmodr:           sta ansir1+1
                 stx ansir2+1
                 jmp ansi
;
outmodc: ldx #15
outmodc2:cmp colors,x
beq outmodc3
dex
bne outmodc2
outmodc3:lda ansiclrs,x
sta ansicol+1
lda ansiints,x
sta ansiint+1
jmp ansi

ansiclrs:	byte "7716524333107247"
ansiints:	byte "0100000100110110"

noansi:		rts

ansi:		ldx #18
		ldy #5
		jsr chkflags
		beq noansi

		lda #27
		jsr outm
		lda #"["
		jsr outm
ansiint:	lda #$30 ; "0"
		jsr outm
		lda #";"
		jsr outm
ansir1:		lda #$33 ; "3"
		jsr outm
ansicol:	lda #$31 ; "1"
		jsr outm
		lda #";"
		jsr outm
ansir2:		lda #$34 ; "4"
		jsr outm
ansibak:	lda #$30 ; "0"
		jsr outm
		lda #$6d ; "m"
		jmp outm

;
;* translation tables *
;

tblcta:		byte $00, $01, $02, $03, $04, $05, $06, $07
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

tblatc:		byte $00,$00,$02,$00,$04,$00,$00,$00
		byte $14,$09,$00,$00,$93,$0d,$0e,$0f
		byte 0,$11,0,$13,20,$15,$16,$17,$18,$19,0,27,0,0,0,0
		byte " !",34,"#$%&'()*+,-./"
		byte "0123456789:;<=>?"
		cbm "`ABCDEFGHIJKLMNOPQRSTUVWXYZ{|}~", 127
		cbm 0,"abcdefghijklmnopqrstuvwxyz",0,0,0,0,20
tblctoa1:	byte 032,221,220,196,095,179,178,179
		byte 220,047,222,195,201,192,191,220
		byte 218,193,194,180,221,221,222,223
		byte 223,220,217,187,200,217,188,176
tblctoa2:	byte 196,065,066,067,068,069,070,071
		byte 072,073,074,075,076,077,078,079
		byte 080,081,082,083,084,085,086,087
		byte 088,089,090,197,221,179,178,092
tblctoa3:       byte 196,042,179,196,196,196,196,179
		byte 179,191,192,217,192,092,047,218
		byte 191,254,196,042,179,218,042,254
		byte 042,179,042,197,221,179,227,092
;
docall: cmp callpage
beq calljmp
sta calltemp
lda callpage
beq docall1
pha
jsr callswap
lda calltemp
sta callpage
jsr callswap
jsr calljmp
jsr callswap
sta calltemp
pla
sta callpage
jsr callswap
lda calltemp
rts
docall1: lda calltemp
sta callpage
jsr callswap
jsr calljmp
jsr callswap
pha
lda #0
sta callpage
pla
rts
;
callswap:pha
txa
pha
tya
pha
lda callpage
ldy #>$c000
ldx #4
jsr swapper
pla
tay
pla
tax
pla
rts
;
calljmp: jmp $c000
;
callpage:byte $00
calltemp:byte $00
serial2a:word serial +$00ff
;
callf000:sta calljmp+1
lda #>$f000
jmp docall
callf400:sta calljmp+1
lda #>$f400
jmp docall
callf800:sta calljmp+1
lda #>$f800
jmp docall
callfc00:sta calljmp+1
lda #>$fc00
jmp docall
;
inline: lda #$00
byte $2c
inline0: lda #$03
byte $2c
password:lda #$06
jmp callf000
useeditr:lda #$09
jsr callf000
pha
lda serial2a
cmp serial2b
bne useedit1
lda serial2a+1
cmp serial2b+1
bne useedit1
pla
rts
useedit1:pla
ldx #1
txa
rts
;
term: lda #$00
byte $2c
chatmode:lda #$03
byte $2c
clrarr: lda #$06
byte $2c
setvars: lda #$09
byte $2c
btmvar: lda #$0c
jmp callf400
;
read0: lda #$00
byte $2c
newuser: lda #$03
byte $2c
arraysav:lda #$06
byte $2c
arrayres:lda #$09
jmp callf800
copyrite:lda #$0c
jsr callf800
jmp outastr
sound: lda #$0f
jsr callf800
ldx #2
lda serial2a-1,x
lsr
lsr
lsr
lsr
ora #$c0
sta bsnpre-1,x
lda serial2a-2,x
sec
sbc #$ff
sta bsnval-2,x
lda serial2a-1,x
sbc #0
and #$0f
sta bsnval-1,x
rts
serial2b:word serial +$00ff
;
convert: lda #$00
byte $2c
convstr: lda #$03
jmp callfc00
;
; put intro program in
;
dup 0,$c000-*
;
; intro is a proto
jmp loadpic
jmp setup
byte $ff ;intro
serial1a: word serial
serial1b: word serial+$0123
;
;
;* intro program
;
;* load files
;* then display
loadpic: ldx $ba
stx devnum
lda picflag
beq loadpic1
lda #1
ldx devnum
ldy #1
jsr $ffba
lda file1
ldx #(<file1+1)
ldy #>(file1+1)
jsr $ffbd
ldx #1
lda #$02
sta hmm,x
dex
txa
jsr $ffd5
lda $90
bpl loadpic1
lda #0
sta picflag
loadpic1:jsr dopic
checkchk:jsr checksn
lda checkbad
cmp #2
bne notbad
hmm: lda #2
sta checkbad
jsr checksn
;
;load "im" file
notbad: lda #<imstart
sta $2b
lda #>imstart
sta $2c
lda #1
ldx devnum
ldy #0
jsr $ffba
lda file2
ldx #<(file2+1)
ldy #>(file2+1)
jsr $ffbd
lda #0
ldx $2b
ldy $2c
jsr $ffd5
stx $2d
sty $2e
jsr $a533
jsr padimprg
ldx $2d
ldy $2e
stx $2f
sty $30
stx $31
sty $32
lda #<prgstart
sta $2b
lda #>prgstart
sta $2c
jsr psetup
jsr nopic
;
lda #$60
ldy #0
loop: sta rs232,y
dey
bne loop

;
; load ml.extra
;
		lda #$10
		ldy #$d0
		ldx #48
		jsr swapper
		lda #1
		ldx devnum
		ldy #1
		jsr $ffba
		lda file4
		ldx #<(file4+1)
		ldy #>(file4+1)
		jsr $ffbd
		lda #0
		jsr $ffd5
		lda #$10
		ldy #$d0
		ldx #48
		jsr swapper

		ldx #dopic-run1
		stx $c6
putkey:		lda run1-1,x
		sta $0276,x
		dex
		bne putkey
		lda #$00
		sta 646
		jmp [$0302]

run1:		cbm " run"
		byte 13

;* uncrunch picture
dopic:		lda picflag
		beq dopic1
		jmp $5f03

dopic1:		rts

;
;* remove picture
;
nopic:		lda checkchk
		cmp #$20
		bne nopic
		lda checkchk+1
		cmp #<checksn
		bne nopic
		lda checkchk+2
		cmp #>checksn
		bne nopic
		lda picflag
		beq nopic1
		lda #$17
		sta $d018
		lda #$1b
		sta $d011
		lda #$c8
		sta $d016
		lda #$c7
		sta $dd00
		lda #$93
		jsr $ffd2
		lda #$00
		sta $d021
nopic1:		rts

;
;* load p.setup
;

psetup:		lda file3
		sta var
		lda #<(file3+1)
		sta var+1
		lda #>(file3+1)
		sta var+2
		lda devnum ;device
		jmp pload ;load

;
;* filenames
;

file1:		byte 10
		cbm "screen 1.3"
file2:		byte 2
		cbm "im"
file3:		byte 5
		cbm "setup"
file4:		byte 8
		cbm "ml.extra"

devnum:		byte 8
picflag:	byte 1
;
;********************************
;* setup routines *
;* last revision: 8/30/87 *
;********************************

;* main setup routine
setup: lda #0
tay
loop: sta basintr,y
iny
cpy #sizintr
bne loop
ldy #0
loop: lda date2,y
sta date1,y
iny
cpy #28
bne loop
lda #80
sta ptrclmn
lda #40
sta modclmn
lda #1
sta local
ldy #0
lda #32
loop: sta $4000,y
sta $4100,y
sta $4200,y
dey
bne loop
		lda #$60
		ldy #0
loop:		sta rs232,y
		dey
		bne loop
		ldy #31
loop:		lda #>(pmodetbl+32)
		sta pmodetbl,y
		dey
		lda #<(pmodetbl+32)
		sta pmodetbl,y
		dey
		bpl loop

		lda #$ff
		sta pmodetbl+32
		lda #$00
		sta pmodetbl+33
		lda #$d8 ; "X"
		sta mask
lda #2
sta bar
lda #0
sta scnmode
jsr iosetup
jsr setirq
jsr setmem
jsr setptrs
lda #$36
sta $01
jsr setscrn
jsr comq
jsr rsinb
lda #$37
sta $01
lda serial1a+1
lsr
lsr
lsr
lsr
ora #$c0
sta bsnpre
lda serial1a+1
and #$0f
sta bsnval+1
lda serial1a
sta bsnval
rts
;
;* setup i/o windows
;* also 1200 baud fix
iosetup:lda $0326
cmp #<newout
bne hcb0e
lda $0327
cmp #>newout
beq hcb28
hcb0e: lda $0326
sta oldout+1
lda $0327
sta oldout+2
lda #<newout
sta $0326
lda #>newout
sta $0327
hcb28:rts
;* setup irq vector
;
;
setirq: lda #127
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
setscrn: lda #$0b
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
;
setmem: lda 776
ldx 777
sta oldvec+1
stx oldvec+2
lda #<mem
ldx #>mem
sta 776
stx 777
rts
;
;* check serial number
checksn: ldx #13
sec
lda serial1b-13,x
sbc serial1a-13,x
php
cmp #$23
bne checkbad
plp
lda serial1b-12,x
sbc serial1a-12,x
cmp #$01
bne checkbad
lda checkbad
eor #98
sta checkrts
checkrts:rts
checkbad:byte 2
;* find basic variable
getvarp: txa
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
	byte $c1 ,$c3         ; 24 ac%
	byte $45 ,$46         ; 25 ef
	byte $4c ,$46         ; 26 lf
	byte $57 ,$80         ; 27 w$
	byte $50 ,$80         ; 28 p$
	byte $d4 ,$d2         ; 29 tr%
	byte $c1 ,$80         ; 30 a%
	byte $c2 ,$80         ; 31 b$
	byte $c4 ,$d6         ; 32 dv%
	byte $44 ,$d2         ; 33 dr$
	byte $43 ,$b1         ; 34 c1$
	byte $43 ,$b2         ; 35 c2$
	byte $43 ,$cf         ; 36 co$
	byte $43 ,$c8         ; 37 ch$
	byte $cb ,$d0         ; 38 kp%
	byte $43 ,$b3         ; 39 c3$
	byte $46 ,$b1         ; 40 f1$
	byte $46 ,$b2         ; 41 f2$
	byte $46 ,$b3         ; 42 f3$
	byte $46 ,$b4         ; 43 f4$
	byte $46 ,$b5         ; 44 f5$
	byte $46 ,$b6         ; 45 f6$
	byte $46 ,$b7         ; 46 f7$
	byte $46 ,$b8         ; 47 f8$

;
;find all vars used by ml, and
;get their pointers
;
setptrs: lda #47
sta tmp1
setp1: ldx tmp1
jsr getvarp
lda tmp1
asl
tay
lda $47
sta vars,y
lda $48
sta vars+1,y
dec tmp1
bpl setp1
rts
;
pload: ldx $2b
ldy $2c
jsr pload2
bcc pload1
rts
pload1: ldx $2b
ldy $2c
stx $ac
sty $ad
ldx #<imstart
ldy #>imstart
jmp plink
pload2: stx $ac
sty $ad
cmp #7
bcs pload3
lda #8
pload3: sta filenum
lda #0
jsr $ff90
lda #1
ldx filenum
       ldy #$00
       jsr $ffba
lda var
ldx var+1
ldy var+2
jsr $ffbd
lda #0
ldx $ac
ldy $ad
jmp $ffd5
;
plink: txa
pha
tya
pha
lda $2b
pha
lda $2c
pha
ldx $ac
ldy $ad
stx $2b
sty $2c
jsr relink
pla
sta $2c
pla
sta $2b
plink1: ldy #0
lda [$ac],y
sta $71
iny
lda [$ac],y
sta $72
sta $72
lda [$71],y
beq plink2
lda $71
sta $ac
lda $72
sta $ad
jmp plink1
plink2: pla
sta [$ac],y
dey
pla
sta [$ac],y
rts

date2:		cbm "Wed Feb 14, 1990 12:25 PM   "

padimprg:	lda #<imstart
		sta $14
		lda #>imstart
		sta $15
padim1:		ldy #1
		lda [$14],y
		beq padim2
		iny
		lda [$14],y
		iny
		cmp #<immdline
		lda [$14],y
		sbc #>immdline
		bcs padim2
		ldy #0
		lda [$14],y
		tax
		iny
		lda [$14],y
		sta $15
		stx $14
		jmp padim1
padim2: ldx $14
ldy $15
stx modtbl+12
sty modtbl+13
clc
lda $14
adc #2
sta $2d
lda $15
adc #8
sta $2e
rts
;
;
;* skip rest of proto area *
;
dup 0,$ca80-*
;
swapper: sta swappg1
sty swappg2
stx swapsiz
swapagn: jsr rsdisab
sei
lda 1
pha
lda #$34
sta 1
lda swappg1
sta $6a
lda swappg2
sta $6c
lda swapsiz
sta $6d
ldy #0
sty $69
sty $6b
swapr1: lda [$69],y
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
jmp rsinabl
;
swappg1:byte 0
swappg2: byte 0
swapsiz:byte 0
;
ecschk: txa
pha
tya
pha
lda #>ecs
ldy #>ecshide
ldx #ecslen
jsr swapper
pla
tay
pla
tax
jsr ecs
jmp swapagn
;
putintr: cpx #sizintr
bcs putintr1
tya
sta basintr,x
putintr1:rts
;
getintr:	cpx #sizintr
		bcs putintr1
		lda #0
		sta var
		lda basintr,x
		sta var+1
		ldx #30
		jmp putvar

dup 0,$cb00-*

;
; rs232 input buffer
;

rsinb:		lda #1
		sta local
		ldx #0
		jsr setmode
		lda #5
		jsr usetbl1
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
;
bootvers:	byte $93
		cbm " ML 1.3 Revision "
		byte $5c ; british pound
		cbm "%a"
		byte 139
		cbm " "
		byte $5c ; british pound
		cbm "$a"
		byte 139
verslen = *-bootvers

dup 0,$cc00-*

;
; interrupt/parameter page
;
word outastr
;
; get a comma and a parameter
;
getparm: jsr chrgot
ldx #0
cmp #","
bne getparm1
jsr getbytc
getparm1:rts
;
; get 3 paramters
;
usetbl2: jsr getparm
stx 780
jsr getparm
stx 781
jsr getparm
stx 782
lda 780
ldx 781
ldy 782
rts
;
; far call to the error handler
;
farerr: lda #$37
sta 1
jmp $a437
;
; raster interrupt routine
;
raster: lda #$00
bne rast1
lda scnmode
bne rast0
lda #23
sta $d018
rast0: lda #106
sta $d012
lda #1
sta $d019
inc raster+1
jmp $febc
;
rast1: nop
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
jmp newirq
;
gettbl: asl
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
pla
sta 1
rts
;
getversn:lda #15
sta var
lda #<version
sta var+1
lda #>version
sta var+2
ldx #1
jsr putvar ;a$
ldy #4
loop: lda versnum,y
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
;
trapoff: lda #<$e38b
ldx #>$e38b
jmp trap1
trapon: lda #<trap
ldx #>trap
trap1: sta $300
stx $301
rts
;
outadj: sty outadjs
cmp #13
beq outadj1
cmp #20
beq outadj2
cmp #cursor_right
beq outadj3
cmp #cursor_left
beq outadj2
and #$7f
cmp #32
bcs outadj3
rts
outadj1: ldx #1
outadj2: dex
dex
outadj3: inx
cpx outadjs
bcc outadj4
ldx #0
outadj4: rts
;
scrnset: sta blnkflag
sta $d030
stx $d011
sty $d020
rts
;
dup 0,$cd00-*
;
; interface page
;
usetbl: jsr usetbl2
usetbl1: sta 780
stx 781
sty 782
jsr gettbl
sty jump+1
stx jump+2
lda 1
pha
lda #$36
sta 1
ldx 781
ldy 782
jump: jsr $ffff
sta 780
pla
sta 1
lda 780
rts
;
; new system chrout routine
;
newout: pha
lda $9a
cmp #4
bcs nout1
lda 1
sta rom3
lda #$36
sta 1
pla
jsr out
pha
lda rom3
sta 1
pla
rts
nout1: pla
oldout: jmp $ffff
;
; find a basic variable
;
findvar1:lda 1
pha
lda #$37
sta 1
jsr ptrget1
jmp exitint
;
; relink basic program lines
;
relink: lda 1
pha
lda #$37
sta 1
jsr linkprg
jmp exitint
;
; make a dynamic string
;
makeroom: tax
lda $01
pha
lda #$37
sta $01
txa
jsr makerm1
exitint: pla
sta 1
rts
;
; the error trap routine
;
trap: stx $030c
lda $39
sta $030d
lda $3a
sta $030e
lda #<trapline
sta $14
lda #>trapline
sta $15
ldx #$fa
txs
jsr $a8a3
jmp $a7ae
;
; the wedge to print free memory
;
mem:		lda #$36
		sta $01
		jsr memory
		lda #$37
		sta $01
		jsr chrget
mem1:		cmp #"&"
		bne mem2
		jsr chrget
		jsr usetbl
		jsr chrgot
		jmp mem1
mem2:		lda $7a
		bne mem3
		dec $7b
mem3:		dec $7a
oldvec:		jmp $ffff
;
; the new system irq routine
;
newirq: lda 1
pha
lda #54
sta 1
irqt: lda #$00
beq newirq0
dec irqt+1
bne newirq1
newirq0: jsr irq
lda irqcount
sta irqt+1
newirq1: pla
sta 1
jmp $ea81
;
getstr: lda 1
pha
lda #55
sta 1
jsr $ad9e
jsr $b6a3
tax
pla
sta 1
txa
ldx $22
ldy $23
rts
;
pagecol: byte 1,15,12,11,12,15
caseflag:byte 255
;
dup 0,$ce00-*
;
; buffer page
;
d1str:           cbm "           "
               cbm "Tue Jan  1, 1988 12:00 PM   "

buf2:            dup $20, 80
buffer:          dup $20, 80
;
; date in 6 byte bcd format
;
bootdate:
dateday:        byte $05
datemon:        byte $03
datedate:       byte $10
dateyear:       byte $88
              byte $12,$00
;
; storage for conversion routines
;
binary: byte 0,0,0,0
;
; days in each month in bcd
;
ha560:		byte $31,$28,$31,$30,$31,$30,$31,$31,$30,$00
decchr:		byte $30,$30,$30,$30,$30,$31,$30,$31
;
; storage for rom bank values
;
rom2: byte 0
rom3: byte 0
;
; the revision number of this ml
;
rvisnum: word revision
;
; the date this ml was made
;
version: cbm version_string

;
; version 1.3
;
versnum: byte $81,$26,$66,$66,$66
;
