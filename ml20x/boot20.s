prefix = cbm("A")
serialn=0001

include "equat.s"

org $02a7, "boot20.prg"

; the boot program!

; put back correct basic main loop
; address

boot:
		lda #<$a483
		sta $302
		lda #>$a483
		sta $303

; our screen colors

		lda #$00
		sta $d020
		sta $d021
		lda #clear_screen
		jsr $e716

; kernal messages off

		jsr $ff90

; load the ml

		lda #filename_length
		ldx #<file
		ldy #>file
		jsr $ffbd
		lda #1
		sta $b9
		lda #0
		jsr $ffd5

; run it

		jsr $a533
		lda #0
		jsr $a871
		jmp $a7ae

; the filename for the ml file

file:
		cbm "image 2.0"
filename_length = * - file

; serial number info

		dup 0, $2fa-*
enc 255
		byte prefix
		byte <serialn
		byte >serialn
enc 0

; pad to line up with prefix
		dup 0, bsnpre-*
; bsnpre:
		byte prefix

; pad to line up with serial
		dup 0, bsnval-*
; bsnvar:
		byte <serialn
		byte >serialn

; the boot vector

		word $e38b,boot
