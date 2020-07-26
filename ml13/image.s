prefix = $41 ; "A"
serialn = 3
msg = "Image 1.3"

include "equat.s"

org $02a7, "image13.prg"

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

; kernal messages off

		jsr $ff90

; position cursor for centered message

		lda #clear_screen
		jsr $ffd2
		ldx #11
		ldy #(40-msglen)/2
		clc
		jsr $fff0

; print it

		lda #<text1
		ldy #>text1
		jsr $ab1e

; load the ml

		lda file
		ldx #<(file+1)
		ldy #>(file+1)
		jsr $ffbd
		lda #1
		sta $b9
		lda #0
		jsr $ffd5

; jump into the intro part of it

		jmp $c000

; the filename for the ml file

file:
		byte 6
		cbm "ml 1.3"

text1:
		byte dish, cursor_white, swlc
msgstart:
		cbm msg
msglen = * - msgstart
		byte 0

; serial number info

		byte (not prefix) and 255
		byte (not <serialn) and 255
		byte (not >serialn) and 255

; pad to line up with prefix
		dup 0, bsnpre-*
; bsnpre:
		byte prefix

; pad to line up with serial
		dup 0, bsnval-*
; bsnval:
		byte <serialn
		byte >serialn

; the boot vector

		word $e38b,boot
