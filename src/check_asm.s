	.allow_undocumented

; ============================================================================
; Parameters are passed according to __sdcccall(1) found here:
; https://sdcc.sourceforge.net/doc/sdccman.pdf

    .area _CODE

; ----------------------------------------------------------------------------
; CONSTANTS
    BIOS_CHPUT      .equ 0x00A2
    CALSLT          .equ 0x001C
    RDSLT           .equ 0x000C
    EXPTBL          .equ 0xFCC1

    MASTER          .equ 0xF348 ; main disk rom slot id
    WIZ_ADDR        .equ 0x5851 ; wizardry address  

signature:
    .ascii "ABoWve"
    .db 0

; ----------------------------------------------------------------------------
; Guessing that "MASTER" is 0 on normal MSXs without disk support
; or some non-valid value. Weak?
_disk_support::

    ld      a,(MASTER)
    or      a
    jr      z,no_disk

    sub     #0b10001111+1 ; max slotid + 1
    jr      nc,no_disk

    ld      a,#1
    ret

no_disk:
    xor     a
    ret

; ----------------------------------------------------------------------------
; lets check that the ROM is a known format disk ROM (ABoWve).
_has_signature::

    ld      de,#signature
    ld      hl,#0x4000    ; diskrom is always in page 1

loopie:

    ld      a,(de)
    or      a
    jr      z,end_ok

    ld      b,a
    push    bc
    push    de
    ld      a,(MASTER)
    call    RDSLT           ; changes AF, BC, DE
    pop     de
    pop     bc
    cp      b
    jr      nz,end_not_ok

    inc     hl
    inc     de
    jr      loopie

end_ok:
    ld      a,#1
    ret

end_not_ok:
    xor     a
    ret


; ----------------------------------------------------------------------------
; Get the number of drives in the system in an absolute hacky way.
; Source: NYYRIKKI here:
; https://www.msx.org/forum/msx-talk/development/best-way-to-identify-the-msx-model-at-runtime?page=2#comment-472986
;
_get_drive_count::
    push    ix

    ; first check that the calling address is in the range 0x7nnn
    ld      hl,#WIZ_ADDR+1  ; high byte first
    ld      a,(MASTER)
    call    RDSLT           ; changes AF, BC, DE
    ld      ixh,a
    and     #0b11110000
    cp      #0b01110000     ; should be 0x7n
    jr      nz,ret_err

    dec     hl
    ld      a,(MASTER)
    call    RDSLT           ; changes AF, BC, DE

    ld      ixl,a
    ld      a,(MASTER)
    ld      iyh,a

    ; in a,(0x2e)
    xor     a; zero flag MUST be reset up front
    call    CALSLT          ; result should be in L
    ld      a,l

ret_ok:
    pop     ix
    ret

ret_err:
    pop     ix
    ld      a,#255
    ret

; --------------------
; Tiny internal helper
; IN:       IX: address of BIOS routine
callSlot:
    ld      iy, (EXPTBL-1)       ;BIOS slot in iyh
    jp      CALSLT               ;interslot call

; ----------------------------------------------------------------------------
; Print to console. Both '\r\n' is needed for a carriage return and newline.
; Heavy(!), as it does interslot calls per character (but print performance is
; of no concern in this program)
; IN:       HL - pointer to zero-terminated string
; MODIFIES: ? (BIOS...)
; void print(u8* szMessage)
_print::

    ; BIOS variant (heavy)
    push    ix
loop:
	ld      a, (hl)
	and     a
	jr      z, leave_me
    ld      ix, #BIOS_CHPUT
    call    callSlot

	inc     hl
	jr      loop

leave_me:
    pop     ix
    ret
