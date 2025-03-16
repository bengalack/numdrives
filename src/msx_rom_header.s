; A rom header that delays its own execution until other roms have been initialized
; Is is dependent on that the other roms as NOT using the same trick as we do here
; author: pal.hansen@gmail.com
;
	.globl	_main

	.area _HEADER (ABS)
	.area _CODE


H_STKE .equ 0xFEDA	; seems to allow for 5 bytes before next bios value: H_ISFL
MASTER .equ 0xF348  ; main disk rom slot id

msx_rom_header::
;----------------------------------------------------------
;	ROM Header
	.db		#0x41				; ROM ID
	.db		#0x42				; ROM ID
	.dw		#init				; Program start
	.dw		#0x0000				; BASIC's CALL instruction not expanded
	.dw		#0x0000				; BASIC's IO DEVICE not expanded
	.dw		#0x0000	        	; BASIC program
	.dw		#0x0000				; Reserved
	.dw		#0x0000				; Reserved
	.dw		#0x0000				; Reserved

init: 							; will enter in DI initially

	; this init seems to be called twice during boot, but ... I don't know why, or care.
	ld		a,#0xf7				; rst 30h
	ld		(H_STKE+0),a
	ld		a,c					; rom slot number is in C
	ld		(H_STKE+1),a
	ld		hl,#dejavu
	ld		(H_STKE+2),hl		; come back here

	ret							; Back to slots scanning

dejavu:

	ld		a,#0xc9
	ld		(H_STKE),a			; Remove the hook 

	di							; my programs expect the interrupts to be disabled at this 
	jp		_main				

