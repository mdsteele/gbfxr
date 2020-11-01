INCLUDE "src/consts.inc"
INCLUDE "src/hardware.inc"
INCLUDE "src/macros.inc"

;;;=========================================================================;;;

SECTION "ChangeRowValue", ROM0

;;; Changes the current row value down if LEFT is held, up otherwise.
;;; @param b The current button state.
Func_ChangeRowValue::
    ld a, [Ram_MenuCursorRow]
    or a
    jr z, _ChangeRowValue_Channel
    ld a, [Ram_Channel]
    if_eq 1, jp, _ChangeRowValue_Ch1
    if_eq 2, jp, _ChangeRowValue_Ch2
    if_eq 3, jp, _ChangeRowValue_Ch3
    if_eq 4, jp, _ChangeRowValue_Ch4
    ret

_ChangeRowValue_Channel:
    ld a, 1
    ld [Ram_ChangedChannel], a
    ld a, b
    and PADF_LEFT
    jr nz, _ChangeRowValue_ChannelDown
_ChangeRowValue_ChannelUp:
    ld a, [Ram_Channel]
    inc a
    if_le 4, jr, .noOverflow
    ld a, 1
    .noOverflow
    ld [Ram_Channel], a
    ret
_ChangeRowValue_ChannelDown:
    ld a, [Ram_Channel]
    dec a
    jr nz, .noUnderflow
    ld a, 4
    .noUnderflow
    ld [Ram_Channel], a
    ret

_ChangeRowValue_Ch1:
    ld a, [Ram_MenuCursorRow]
    ;; TODO others
    if_eq 1, jr, _ChangeRowValue_Ch1Duty
    if_eq 3, jr, _ChangeRowValue_Ch1EnvStart
    if_eq 5, jr, _ChangeRowValue_Ch1Frequency
    ret

_ChangeRowValue_Ch1Duty:
    ld a, 1
    ld [Ram_ChangedCh1Duty], a
    ld a, b
    and PADF_LEFT
    jr z, _ChangeRowValue_Ch1DutyUp
_ChangeRowValue_Ch1DutyDown:
    ld a, [Ram_Ch1Duty]
    sub 1
    jr nc, .noUnderflow
    ld a, MAX_CH1_DUTY
    .noUnderflow
    ld [Ram_Ch1Duty], a
    ret
_ChangeRowValue_Ch1DutyUp:
    ld a, [Ram_Ch1Duty]
    add 1
    if_le MAX_CH1_DUTY, jr, .noOverflow
    xor a
    .noOverflow
    ld [Ram_Ch1Duty], a
    ret

_ChangeRowValue_Ch1EnvStart:
    ld a, 1
    ld [Ram_ChangedCh1EnvStart], a
    ld a, b
    and PADF_LEFT
    jr z, _ChangeRowValue_Ch1EnvStartUp
_ChangeRowValue_Ch1EnvStartDown:
    ld a, [Ram_Ch1EnvStart]
    sub 1
    jr nc, .noUnderflow
    ld a, MAX_CH1_ENV_START
    .noUnderflow
    ld [Ram_Ch1EnvStart], a
    ret
_ChangeRowValue_Ch1EnvStartUp:
    ld a, [Ram_Ch1EnvStart]
    add 1
    if_le MAX_CH1_ENV_START, jr, .noOverflow
    xor a
    .noOverflow
    ld [Ram_Ch1EnvStart], a
    ret

_ChangeRowValue_Ch1Frequency:
    ld a, 1
    ld [Ram_ChangedCh1Frequency], a
    ld a, b
    and PADF_LEFT
    jr z, _ChangeRowValue_Ch1FrequencyUp
_ChangeRowValue_Ch1FrequencyDown:
    ld hl, Ram_Ch1Frequency_u16
    ld a, [hl]
    sub 1
    ld [hl+], a
    ld a, [hl]
    sbc 0
    jr nc, .noUnderflow
    ld hl, Ram_Ch1Frequency_u16
    ld a, %11111111
    ld [hl+], a
    ld a, %111
    .noUnderflow
    ld [hl], a
    ret
_ChangeRowValue_Ch1FrequencyUp:
    ld hl, Ram_Ch1Frequency_u16
    ld a, [hl]
    add 1
    ld [hl+], a
    ld a, [hl]
    adc 0
    if_lt %1000, jr, .noOverflow
    ld hl, Ram_Ch1Frequency_u16
    xor a
    ld [hl+], a
    .noOverflow
    ld [hl], a
    ret

_ChangeRowValue_Ch2:
_ChangeRowValue_Ch3:
_ChangeRowValue_Ch4:
    ;; TODO
    ret

;;;=========================================================================;;;
