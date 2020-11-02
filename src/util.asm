INCLUDE "src/hardware.inc"
INCLUDE "src/macros.inc"

;;;=========================================================================;;;

SECTION "Utility-Functions", ROM0

;;; Copies bytes.
;;; @param hl Destination start address.
;;; @param de Source start address.
;;; @param bc Num bytes to copy.
Func_MemCopy::
    .loop
    ld a, b
    or c
    ret z
    ld a, [de]
    ld [hl+], a
    inc de
    dec bc
    jr .loop

;;; Zeroes bytes.
;;; @param hl Destination start address.
;;; @param bc Num bytes to zero.
;;; @preserve de
Func_MemZero::
    .loop
    ld a, b
    or c
    ret z
    xor a
    ld [hl+], a
    dec bc
    jr .loop

;;; Copies bytes from a NUL-terminated string.
;;; @param hl Destination start address.
;;; @param de Source start address.
;;; @preserve bc
Func_StrCopy::
    .loop
    ld a, [de]
    or a
    ret z
    ld [hl+], a
    inc de
    jr .loop

;;; Blocks until the next VBlank, then performs an OAM DMA.
Func_WaitForVblankAndPerformDma::
    di    ; "Lock"
    xor a
    ldh [Hram_VBlankFlag], a
    .loop
    ei    ; "Await condition variable" (which is "notified" when an interrupt
    halt  ; occurs).  Note that the effect of an ei is delayed by one
    di    ; instruction, so no interrupt can occur here between ei and halt.
    ldh a, [Hram_VBlankFlag]
    or a
    jr z, .loop
    call Func_PerformDma
    reti  ; "Unlock"

;;; Reads and returns state of D-pad/buttons.
;;; @return b The 8-bit button state.
;;; @preserve c, de, hl
Func_GetButtonState_b::
    ld a, P1F_GET_DPAD
    ld [rP1], a
    REPT 2  ; It takes a couple cycles to get an accurate reading.
    ld a, [rP1]
    ENDR
    cpl
    and $0f
    swap a
    ld b, a
    ld a, P1F_GET_BTN
    ld [rP1], a
    REPT 6  ; It takes several cycles to get an accurate reading.
    ld a, [rP1]
    ENDR
    cpl
    and $0f
    or b
    ld b, a
    ld a, P1F_GET_NONE
    ld [rP1], a
    ret

;;; Prints an unsigned 8-bit value to the background map as an 8-digit binary
;;; number.
;;; @param e The 8-bit value to print (0-255).
;;; @param hl The BG map address for the start of the printed number.
Func_PrintBinaryU8::
    ld c, 9
    .loop
    dec c
    ret z
    sla e
    jr c, .one
    .zero
    ld a, "0"
    ld [hl+], a
    jr .loop
    .one
    ld a, "1"
    ld [hl+], a
    jr .loop

;;; Prints an unsigned 8-bit value to the background map as a 1-digit decimal
;;; number.
;;; @param e The 8-bit value to print (0-9).
;;; @param hl The BG map address for the start of the printed number.
Func_Print1DigitU8::
    ld a, e
    add "0"
    ld [hl], a
    ret

;;; Prints a signed 8-bit value to the background map as a 1-digit decimal
;;; number, with a sign if nonzero.
;;; @param e The signed 8-bit value to print (-9-+9).
;;; @param hl The BG map address for the start of the printed number.
Func_Print1DigitI8::
    ld a, e
    if_neg jr, .negative
    ld a, "+"
    ld [hl+], a
    jr .printE
    .negative
    ld a, "-"
    ld [hl+], a
    ld a, e
    cpl
    add 1
    jr .printA
    .printE
    ld a, e
    .printA
    add "0"
    ld [hl], a
    ret

;;; Prints an unsigned 8-bit value to the background map as a 2-digit decimal
;;; number.
;;; @param e The 8-bit value to print (0-99).
;;; @param hl The BG map address for the start of the printed number.
Func_Print2DigitU8::
    ;; Convert original value (in e) into BCD.
    xor a
    ld d, 8  ; loop counter
    .loop
    sla e
    adc a
    daa
    dec d
    jr nz, .loop
    ld e, a
    ;; Print 10's place.
    swap a
    and $0f
    add "0"
    ld [hl+], a
    ;; Print 1's place.
    ld a, e
    and $0f
    add "0"
    ld [hl], a
    ret

;;; Prints an unsigned 8-bit value to the background map as a 3-digit decimal
;;; number.
;;; @param e The 8-bit value to print (0-255).
;;; @param hl The BG map address for the start of the printed number.
Func_Print3DigitU8::
    ;; Convert original value (in e) into BCD (in bc).
    xor a
    ld b, a
    ld d, 8  ; loop counter
    .loop
    sla e
    adc a
    daa
    ld c, a
    ld a, b
    adc a
    ld b, a
    ld a, c
    dec d
    jr nz, .loop
    ld c, a
    ;; Print 100's place.
    ld a, b
    add "0"
    ld [hl+], a
    ;; Print 10's place.
    ld a, c
    swap a
    and $0f
    add "0"
    ld [hl+], a
    ;; Print 1's place.
    ld a, c
    and $0f
    add "0"
    ld [hl], a
    ret

;;; Prints an unsigned 8-bit value to the background map as a 4-digit decimal
;;; number.
;;; @param de The 16-bit value to print (0-9999).
;;; @param hl The BG map address for the start of the printed number.
Func_Print4DigitU16::
    push hl
    ;; Convert high byte of original value (in d) into BCD (in bc).
    xor a
    ld b, a
    ld h, 8  ; loop counter
    .highLoop
    sla d
    adc a
    daa
    dec h
    jr nz, .highLoop
    ld c, a
    ;; Multiply bc by 256, using BCD arithmetic.
    ld h, 8  ; loop counter
    .mulLoop
    ld a, c
    add a
    daa
    ld c, a
    ld a, b
    adc b
    daa
    ld b, a
    dec h
    jr nz, .mulLoop
    ;; Convert low byte of original value (in e) into BCD (in de).
    xor a
    ld d, a
    ld h, 8  ; loop counter
    .lowLoop
    sla e
    adc a
    daa
    ld l, a
    ld a, d
    adc a
    ld d, a
    ld a, l
    dec h
    jr nz, .lowLoop
    ld e, a
    ;; Add de to bc, using BCD arithmetic.
    ld a, c
    add e
    daa
    ld c, a
    ld a, b
    adc d
    daa
    ld b, a
    ;; Print 1000's place.
    pop hl
    ld a, b
    swap a
    and $0f
    add "0"
    ld [hl+], a
    ;; Print 100's place.
    ld a, b
    and $0f
    add "0"
    ld [hl+], a
    ;; Print 10's place.
    ld a, c
    swap a
    and $0f
    add "0"
    ld [hl+], a
    ;; Print 1's place.
    ld a, c
    and $0f
    add "0"
    ld [hl], a
    ret

;;;=========================================================================;;;
