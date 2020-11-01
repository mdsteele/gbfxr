;;;=========================================================================;;;

SECTION "NR-Value-Functions", ROM0

;;; @return a The value to be used for rNR10.
Func_GetNR10Value_a::
    ld a, %00101101  ; TODO
    ret

;;; @return a The value to be used for rNR11.
Func_GetNR11Value_a::
    ld a, [Ram_Ch1Duty]
    rrca
    rrca
    ld hl, Ram_Ch1Length
    or [hl]
    ret

;;; @return a The value to be used for rNR12.
Func_GetNR12Value_a::
    ld a, %01000010  ; TODO
    ret

;;; @return a The value to be used for rNR13.
Func_GetNR13Value_a::
    ld a, [Ram_Ch1Frequency_u16]
    ret

;;; @return a The value to be used for rNR14.
Func_GetNR14Value_a::
    ld a, [Ram_Ch1Length]
    or a
    jr z, .noLength
    ld a, [Ram_Ch1Frequency_u16 + 1]
    or %11000000
    ret
    .noLength
    ld a, [Ram_Ch1Frequency_u16 + 1]
    or %10000000
    ret

;;; @return a The value to be used for rNR21.
Func_GetNR21Value_a::
    ld a, %10010000  ; TODO
    ret

;;; @return a The value to be used for rNR22.
Func_GetNR22Value_a::
    ld a, %01000010  ; TODO
    ret

;;; @return a The value to be used for rNR23.
Func_GetNR23Value_a::
    ld a, %11100000  ; TODO
    ret

;;; @return a The value to be used for rNR24.
Func_GetNR24Value_a::
    ld a, %10000111  ; TODO
    ret

;;; @return a The value to be used for rNR30.
Func_GetNR30Value_a::
    ld a, %00101101  ; TODO
    ret

;;; @return a The value to be used for rNR31.
Func_GetNR31Value_a::
    ld a, %10010000  ; TODO
    ret

;;; @return a The value to be used for rNR32.
Func_GetNR32Value_a::
    ld a, %01000010  ; TODO
    ret

;;; @return a The value to be used for rNR33.
Func_GetNR33Value_a::
    ld a, %11100000  ; TODO
    ret

;;; @return a The value to be used for rNR34.
Func_GetNR34Value_a::
    ld a, %10000111  ; TODO
    ret

;;; @return a The value to be used for rNR41.
Func_GetNR41Value_a::
    ld a, %10010000  ; TODO
    ret

;;; @return a The value to be used for rNR42.
Func_GetNR42Value_a::
    ld a, %01000010  ; TODO
    ret

;;; @return a The value to be used for rNR43.
Func_GetNR43Value_a::
    ld a, %11100000  ; TODO
    ret

;;; @return a The value to be used for rNR44.
Func_GetNR44Value_a::
    ld a, %10000111  ; TODO
    ret

;;;=========================================================================;;;
