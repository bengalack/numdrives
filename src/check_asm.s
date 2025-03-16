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
    DRVTBL          .equ 0xFB21
    SLTWRK          .equ 0xFD09 ; start of table (128 bytes)

signature1:                     ; all/most msxs
    .ascii "ABoWve"
    .db 0

signature2:                     ; turboRs
    .db 0x41, 0x42, 0x3c, 0x40, 0x5c, 0x57 ; "AB<@\W"
    .db 0

; ----------------------------------------------------------------------------
; Guessing that "MASTER" is 0 on normal MSXs without disk support
; or some non-valid value. Weak?
; bool disk_support(void);
;
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
; Lets check that the ROM is a known format disk ROM
; We assume "ABoWve" or "AB<@\W", and pick the first we find
;
; RETURNS:  A - slotid (255 if none found)
;
_get_signature_slot::

    ; in a,(0x2e)

    ld      de, #signature1
    call    get_signature_slot0
    cp      #255
    ret     nz

    ; in a,(0x2e)

    ld      de, #signature2
    call    get_signature_slot0
    ret

; ----------------------------------------------------------------------------
; Lets check that the ROM starts with a given string
; IN:       A - slotid
;           DE - pointer to zero-terminated comparison string
; RETURNS:  A - slotid (255 if none found)
;
get_signature_slot0::

    ld      b,#4
    ld      hl,#DRVTBL

looper:
    push    de
    ld      a,(hl)  ; num drives
    or      a
    jr      z,tail
    inc     hl
    ld      a,(hl)  ; slotid

    push    bc
    push    hl

    ex      de,hl
    call    is_signature_slot

    pop     hl
    pop     bc
    pop     de
    ret     c

    push    de
tail:
    pop     de

    inc     hl
    djnz    looper

    ld      a,#255
    ret

; ----------------------------------------------------------------------------
; String/byte comparing between RAM and other segments
;
; IN:       A - slotid
;           HL - pointer to zero-terminated comparison string
; TRASHES:  F, BC, DE, HL, IYL 
; RETURNS:  Carry is set if true, A holds slotid
is_signature_slot::

    ex      de, hl
    ld      hl,#0x4000    ; diskrom is always in page 1
    ld      iyl, a

loopie:

    ld      a,(de)
    or      a
    jr      z,end_ok

    ld      b,a
    push    bc
    push    de
    ld      a,iyl
    call    RDSLT           ; changes AF, BC, DE
    pop     de
    pop     bc
    cp      b
    jr      nz,end_not_ok

    inc     hl
    inc     de
    jr      loopie

end_ok:
    ld      a,iyl
    scf
    ret

end_not_ok:
    ld      a,iyl
    or      a
    ret

; ----------------------------------------------------------------------------
; Get the number of drives in the system in an absolutely hacky way.
;
; IN:   HL - pointer to diskrom ram work area 
;
; unsigned char get_drive_count(unsigned char*);
;
_get_drive_count::
    push    ix

    push    hl
    pop     ix

    ld      a,6(ix)         ; v-30f
    or      a
    jr      nz,ret_ok
    ld      a,7(ix)         ; most models
    or      a
    jr      nz,ret_ok
    ld      a,8(ix)         ; sony models (including HB-F700)
    or      a
    jr      nz,ret_ok
    ld      a,9(ix)         ; National and Yamaha/Sakhr models (including FS-5000F, AX350/II/F, AX500, YIS-805-128R2, ...)

ret_ok:
    pop     ix
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
