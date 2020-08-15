logoff:
		stx curdsp
		lda #0
		sta chatpage
		sta sndrept
		lda #11
		sta varbuf
		lda #<d1str
		sta varbuf+1
		lda #>d1str
		sta varbuf+2
		ldx #4
		jsr putvar //d1$
		lda #$a0
		sta tdisp+30
		sta tdisp+31
		sta tdisp+32
		rts

setbaud:
		txa
		jmp rsbaud
