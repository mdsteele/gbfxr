;;;=========================================================================;;;

SECTION "NR-Value-Functions", ROM0

;;; @return a The value to be used for rNR10.
StoreNR10ValueInA::
    ld a, %00101101  ; TODO
    ret

;;; @return a The value to be used for rNR11.
;;; @destroy hl
StoreNR11ValueInA::
    ld a, [Ch1Duty]
    rrca
    rrca
    ld hl, Ch1Length
    or [hl]
    ret

;;; @return a The value to be used for rNR12.
StoreNR12ValueInA::
    ld a, %01000010  ; TODO
    ret

;;; @return a The value to be used for rNR13.
StoreNR13ValueInA::
    ld a, [Ch1Frequency]
    ret

;;; @return a The value to be used for rNR14.
StoreNR14ValueInA::
    ld a, [Ch1Length]
    or a
    jr z, .noLength
    ld a, [Ch1Frequency + 1]
    or %11000000
    ret
    .noLength
    ld a, [Ch1Frequency + 1]
    or %10000000
    ret

;;; @return a The value to be used for rNR21.
StoreNR21ValueInA::
    ld a, %10010000  ; TODO
    ret

;;; @return a The value to be used for rNR22.
StoreNR22ValueInA::
    ld a, %01000010  ; TODO
    ret

;;; @return a The value to be used for rNR23.
StoreNR23ValueInA::
    ld a, %11100000  ; TODO
    ret

;;; @return a The value to be used for rNR24.
StoreNR24ValueInA::
    ld a, %10000111  ; TODO
    ret

;;; @return a The value to be used for rNR30.
StoreNR30ValueInA::
    ld a, %00101101  ; TODO
    ret

;;; @return a The value to be used for rNR31.
StoreNR31ValueInA::
    ld a, %10010000  ; TODO
    ret

;;; @return a The value to be used for rNR32.
StoreNR32ValueInA::
    ld a, %01000010  ; TODO
    ret

;;; @return a The value to be used for rNR33.
StoreNR33ValueInA::
    ld a, %11100000  ; TODO
    ret

;;; @return a The value to be used for rNR34.
StoreNR34ValueInA::
    ld a, %10000111  ; TODO
    ret

;;; @return a The value to be used for rNR41.
StoreNR41ValueInA::
    ld a, %10010000  ; TODO
    ret

;;; @return a The value to be used for rNR42.
StoreNR42ValueInA::
    ld a, %01000010  ; TODO
    ret

;;; @return a The value to be used for rNR43.
StoreNR43ValueInA::
    ld a, %11100000  ; TODO
    ret

;;; @return a The value to be used for rNR44.
StoreNR44ValueInA::
    ld a, %10000111  ; TODO
    ret

;;;=========================================================================;;;
