version = "02/07/90 12:00a"

include "equat.s"

org $c000, "proto4.prg"

		jmp proto4
		byte 4 ;proto 4

h:
		word 0
l:
		word 0
x:
		word 0
ptrcom:
		byte "p", 2
ptr:
		word 0
ptrpos:
		byte 1,13
xlen1:
		byte 0

proto4:
		txa
		beq find ;0
		dex
		beq loadindx ;1
		dex
		beq saveindx ;2
		dex
		beq makeindx ;3
		dex
		beq instindx ;4
		dex
		beq deltindx ;5
		dex
		beq nextindx ;6
		dex
		beq setcrskp ;7
		dex
		beq findindx ;8
		rts

loadindx:
		jmp loadfile
saveindx:
		jmp savefile
makeindx:
		jmp makefile
instindx:
		jmp insert
deltindx:
		jmp delete
nextindx:
		jmp getnext
setcrskp:
		jmp setskip
findindx:
		jmp findid


; proto 4 - relfile indexer

;* search for an$ in file

; get handle to search for
find:
		ldx #0
		jsr usevar ;an$
		ldy #0
findloop:
		lda [var+1],y
		sta buffer,y
		iny
		cpy var
		bcc findloop
		lda #0
		sta buffer,y
		sty xlen1
; high = # users
		lda last
		ldx last+1
		sta h
		stx h+1
; low = 1
		lda #0
		ldx #1
		sta l
		stx l+1
; check first
		lda l
		ldx l+1
		sta x
		stx x+1
		jsr check
		beq find12
		bcs find1
;not there, put before start
		jmp xputavar
; check last
find1:
		lda h
		ldx h+1
		sta x
		stx x+1
		jsr check
		beq find12
		bcc find2
;not there, put after end
		lda h
		ldx h+1
		inx
		bne *+4
		clc
		adc #1
		sta x
		stx x+1
		jmp xputavar
;found it!
find12:
		jmp putavar
; get midpoint
find2:
		lda l
		cmp h
		bne find3
		lda l+1
		cmp h+1
		bne find3
;not there, put at x
		jmp xputavar
find3:
		clc
		lda l+1
		adc h+1
		sta x+1
		lda l
		adc h
		sta x
		lsr x
		ror x+1
		lda x
		cmp l
		bne find4
		lda x+1
		cmp l+1
		bne find4
		lda h
		ldx h+1
		sta l
		stx l+1
		sta x
		stx x+1
; do pointer command, and input
find4:
		jsr check
		beq find12
		lda x
		ldx x+1
		bcc find11
		sta l
		stx l+1
		jmp find2
find11:
		sta h
		stx h+1
		jmp find2

check:
		jsr sendptr
		lda skip
		sta skip2
		beq check2
check1:
		dec skip2
check2:
		ldx #2
		ldy #0
		jsr dskin
		lda skip2
		bne check1
		jmp compare

sendptr:
		jsr calcptr
sendcom:
		ldx #15
		jsr chkout
		ldy #0
		ldx #6
sendloop:
		lda ptrcom,y
		jsr chrout
		iny
		dex
		bne sendloop
		jmp clrchn

calcptr:
		lda x+1
		asl
		tay
		lda x
		rol
		tax
		clc
		tya
		adc #<last
		sta $fb
		txa
		adc #>last
		sta $fc
		ldy #0
		lda [$fb],y
		sta ptr+1
		iny
		lda [$fb],y
		sta ptr
		rts

compare:
		ldy #0
comploop:
		lda buffer,y
		cmp buf2,y
		bne compare1
		iny
		cpy xlen1
		beq compare2
		cpy index
		bne comploop
compare2:
		ldy xlen1
		cpy index
compare1:
		rts

;load index file to end of proto
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
		ldx #<last
		ldy #>last
		jsr loadf
		lda last
		ldx last+1
		sta var
		stx var+1
		ldx #30
		jmp putvar ;a%

;save index file
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
		lda #<last
		ldx #>last
		sta var
		stx var+1
		lda last+1
		asl
		tax
		lda last
		rol
		tay
		clc
		txa
		adc #<last
		tax
		tya
		adc #>last
		tay
		clc
		txa
		adc #2
		tax
		tya
		adc #0
		tay
		lda #var
		jmp savef

;make index
makefile:
		lda #0
		sta last
		sta last+2
		lda #0
		sta last+1
		sta last+3
		rts

xputavar:
		lda #0
		sta ptr
		sta ptr+1
putavar:
		lda ptr+1
		ldx ptr
		sta var
		stx var+1
		ldx #30
		jsr putvar ;a%
		lda x
		ldx x+1
		sta var
		stx var+1
		ldx #31
		jsr putvar ;b%
		lda ptr
		ora ptr+1
		rts

;insert into index
; a%=id, b%=pos
;x=pos
insert:
		ldx #31
		jsr usevar ;b%
		lda var
		ldx var+1
		sta x
		stx x+1
;last++
insert1:
		inc last+1
		bne *+4
		inc last
;ptr=id
		ldx #30
		jsr usevar
		lda var
		ldx var+1
		sta ptr+1
		stx ptr
;h=ptr
insert2:
		lda ptr
		ldx ptr+1
		sta h+1
		stx h
		jsr calcptr
		ldy #0
;*x=h
		lda h
		sta [$fb],y
		iny
		lda h+1
		sta [$fb],y
;if x=last then done
		lda x+1
		cmp last+1
		bne insert3
		lda x
		cmp last
		bne insert3
		rts
;x++
insert3:
		inc x+1
		bne *+4
		inc x
		jmp insert2

;delete from index
; b%=pos
delete:
		ldx #31
		jsr usevar ;b%
		lda var
		ldx var+1
		sta x
		stx x+1
;*x=*(x+1)
delete1:
		lda x
		cmp last
		bne delete2
		lda x+1
		cmp last+1
		beq delete3
delete2:
		jsr calcptr
		ldy #3
		lda [$fb],y
		pha
		dey
		lda [$fb],y
		tax
		dey
		pla
		sta [$fb],y
		dey
		txa
		sta [$fb],y
;x++
		inc x+1
		bne *+4
		inc x
		jmp delete1
;last--
delete3:
		lda last+1
		bne *+4
		dec last
		dec last+1
;done
		rts

getnext:
		ldx #31
		jsr usevar ;b%
		lda var
		ldx var+1
		sta x
		stx x+1
		inc x+1
		bne *+4
		inc x
		jsr calcptr
		jmp putavar

setskip:
		sty skip
		rts
skip:
		byte 0
skip2:
		byte 0

findid:
		ldx #30
		jsr usevar ;a%
		lda var
		sta h
		lda var+1
		sta h+1
		lda #0
		sta x
		lda #1
		sta x+1
		lda last
		bne findid1
		lda last+1
		bne findid1
		jmp xputavar
findid1:
		jsr calcptr
		lda ptr+1
		cmp h
		bne findid2
		lda ptr
		cmp h+1
		bne findid2
		jmp putavar
findid2:
		inc x+1
		bne findid3
		inc x
findid3:
		lda x
		cmp last
		bne findid4
		lda x+1
		cmp last+1
		beq findid1
findid4:
		lda x+1
		cmp last+1
		lda x
		sbc last
		bcc findid1
		jmp xputavar

usevar:
		lda #29
		jmp usetbl1
tenwait:
		lda #22
		jmp usetbl1
dskin:
		lda #2
		jmp usetbl1
putvar:
		lda #30
		jmp usetbl1
vers:
		byte version
last:
