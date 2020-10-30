INCLUDE "src/consts.inc"
INCLUDE "src/hardware.inc"
INCLUDE "src/macros.inc"

;;;=========================================================================;;;

SECTION "Main", ROM0[$0150]
Main::
    ;; Initialize the stack.
    ld sp, InitStackPointer

    ;; Set up the OAM DMA routine.
    ld hl, PerformOamDma               ; dest
    ld de, OamDmaCode                  ; src
    ld bc, OamDmaCodeEnd - OamDmaCode  ; count
    call MemCopy

    ;; Initialize menu state.
    ld hl, MenuStateZero                     ; dest
    ld bc, MenuStateZeroEnd - MenuStateZero  ; count
    call MemZero

    ld a, 1
    ld [MenuChannel], a
    ld a, INIT_CH1_DUTY
    ld [Ch1Duty], a
    xor a
    ld [MenuCursorRow], a
    ld [Ch1Length], a
    ld [Ch1EnvStart], a
    ld [Ch1EnvSweep], a
    ld [Ch1SweepLen], a
    ld [Ch1SweepAmp], a
    ld [Ch2Duty], a
    ld [Ch2Length], a
    ld [Ch2EnvStart], a
    ld [Ch2EnvSweep], a
    ld [Ch3Length], a
    ld [Ch3Level], a
    ld [Ch4Length], a
    ld [Ch4EnvStart], a
    ld [Ch4EnvSweep], a
    ld [Ch4Frequency], a
    ld [Ch4Step], a
    ld [Ch4Div], a
    ld hl, Ch2Frequency
    ld [hl+], a
    ld [hl], a
    ld hl, Ch3Frequency
    ld [hl+], a
    ld [hl], a

    ld hl, Ch1Frequency
    ld a, (INIT_CH1_FREQUENCY & $ff)
    ld [hl+], a
    ld a, ((INIT_CH1_FREQUENCY >> 8) & $ff)
    ld [hl], a

    ;; Clear the shadow OAM.
    ld hl, ShadowOam                 ; dest
    ld bc, ShadowOamEnd - ShadowOam  ; count
    call MemZero

    ld a, 24
    ld [ObjCursor + OAMA_Y], a
    ld a, 15
    ld [ObjCursor + OAMA_X], a
    ld a, 1
    ld [ObjCursor + OAMA_TILEID], a

    ;; Turn off the LCD.
    .waitForVBlank
    ldh a, [rLY]
    if_ne SCRN_Y, jr, .waitForVBlank
    ld a, LCDCF_OFF
    ld [rLCDC], a

    ;; Write BG tiles into VRAM.
    ld hl, VramBgTiles + 16 * 33            ; dest
    ld de, RomFontTiles                     ; src
    ld bc, RomFontTiles.end - RomFontTiles  ; count
    call MemCopy

    ;; Write obj tiles into VRAM.
    ld hl, VramObjTiles + 16 * 1          ; dest
    ld de, RomObjTiles                    ; src
    ld bc, RomObjTiles.end - RomObjTiles  ; count
    call MemCopy

    ;; Initialize palettes.
    ld a, %11100100
    ldh [rBGP], a
    ldh [rOBP0], a
    ldh [rOBP1], a

    ;; Initialize background map.
    ld hl, VramBgMap + 2 +  1 * 32  ; dest
    ld de, Strings.channel          ; src
    call StrCopy
    ld hl, VramBgMap + 2 +  2 * 32  ; dest
    ld de, Strings.duty             ; src
    call StrCopy
    ld hl, VramBgMap + 2 +  3 * 32  ; dest
    ld de, Strings.length           ; src
    call StrCopy
    ld hl, VramBgMap + 2 +  4 * 32  ; dest
    ld de, Strings.envInit          ; src
    call StrCopy
    ld hl, VramBgMap + 2 +  5 * 32  ; dest
    ld de, Strings.envSweepAmt      ; src
    call StrCopy
    ld hl, VramBgMap + 2 +  6 * 32  ; dest
    ld de, Strings.freqInit         ; src
    call StrCopy
    ld hl, VramBgMap + 2 +  7 * 32  ; dest
    ld de, Strings.freqSweepAmt     ; src
    call StrCopy
    ld hl, VramBgMap + 2 +  8 * 32  ; dest
    ld de, Strings.freqSweepLen     ; src
    call StrCopy
    ld hl, VramBgMap + 2 + 12 * 32  ; dest
    ld de, Strings.reg0             ; src
    call StrCopy
    ld hl, VramBgMap + 2 + 13 * 32  ; dest
    ld de, Strings.reg1             ; src
    call StrCopy
    ld hl, VramBgMap + 2 + 14 * 32  ; dest
    ld de, Strings.reg2             ; src
    call StrCopy
    ld hl, VramBgMap + 2 + 15 * 32  ; dest
    ld de, Strings.reg3             ; src
    call StrCopy
    ld hl, VramBgMap + 2 + 16 * 32  ; dest
    ld de, Strings.reg4             ; src
    call StrCopy

    ;; Initialize obj palettes.
    ld a, %11100100
    ldh [rOBP0], a
    ldh [rOBP1], a

    ;; Enable sound.
    ld a, AUDENA_ON
    ldh [rAUDENA], a
    ld a, $ff
    ldh [rAUDTERM], a
    ld a, $77
    ldh [rAUDVOL], a

    ;; Turn on the LCD.
    ld a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJON | LCDCF_WIN9C00
    ldh [rLCDC], a

    ;; Enable VBlank interrupt.
    ld a, IEF_VBLANK
    ldh [rIE], a
    ei

RunLoop:
    call AwaitRedraw
UpdateBg:
    ld a, [ChangedChannel]
    or a
    jr z, .channelUnchanged
    call UpdateBgForChannel
    jr RunLoop
    .channelUnchanged

    ld a, [ChangedCh1Duty]
    or a
    jr z, .ch1DutyUnchanged
    call UpdateBgForCh1Duty
    .ch1DutyUnchanged

    ld a, [ChangedCh1Frequency]
    or a
    jr z, .ch1FrequencyUnchanged
    call UpdateBgForCh1Frequency
    .ch1FrequencyUnchanged
ReadButtons:
    call StoreButtonStateInB
    ld a, b
    and PADF_START
    jr z, .startButtonNotHeld
    ld a, [HoldingStart]
    or a
    jr nz, .checkDpad
    ld a, 1
    ld [HoldingStart], a
    call PlaySound
    jr RunLoop
    .startButtonNotHeld
    xor a
    ld [HoldingStart], a
    .checkDpad
    ld a, b
    and PADF_UP | PADF_DOWN | PADF_LEFT | PADF_RIGHT
    jr nz, .dpadActive
    xor a
    ld [HoldingDpad], a
    jr RunLoop
    .dpadActive
    ld a, [HoldingDpad]
    inc a
    if_lt DPAD_REPEAT_DELAY + DPAD_REPEAT_PERIOD, jr, .noRepeat
    ld a, DPAD_REPEAT_DELAY
    .noRepeat
    ld [HoldingDpad], a
    if_eq 1, jr, MoveCursor
    if_eq DPAD_REPEAT_DELAY, jr, MoveCursor
    jr RunLoop
MoveCursor:
    ld a, b
    and PADF_DOWN
    jp nz, MoveCursorDown
    ld a, b
    and PADF_UP
    jp nz, MoveCursorUp
    ld a, b
    and PADF_LEFT | PADF_RIGHT
    jp z, RunLoop
    ld a, [MenuCursorRow]
    or a
    jp z, ChangeChannel
    call ChangeRow
    jr RunLoop

MoveCursorUp:
    call StoreNumMenuRowsInB
    ld a, [MenuCursorRow]
    or a
    jr nz, .decrement
    ld a, b
    .decrement
    dec a
    jr SetCursorRowToA
MoveCursorDown:
    call StoreNumMenuRowsInB
    ld a, [MenuCursorRow]
    inc a
    if_lt b, jr, SetCursorRowToA
    xor a
SetCursorRowToA:
    ld [MenuCursorRow], a
    sla a
    sla a
    sla a
    add 24
    ld [ObjCursor + OAMA_Y], a
    jp RunLoop

ChangeChannel:
    ld a, b
    and PADF_LEFT
    jr nz, ChangeChannelDown
ChangeChannelUp:
    ld a, [MenuChannel]
    inc a
    if_le 4, jr, SetChannelToA
    ld a, 1
    jr SetChannelToA
ChangeChannelDown:
    ld a, [MenuChannel]
    dec a
    jr nz, SetChannelToA
    ld a, 4
SetChannelToA:
    ld [MenuChannel], a
    ld a, 1
    ld [ChangedChannel], a
    jp RunLoop

;;;=========================================================================;;;

;;; Changes the current row value down if LEFT is held, up otherwise.
;;; @param b The current button state.
ChangeRow:
    ld a, [MenuChannel]
    if_eq 4, jr, ChangeRowCh4
    if_eq 3, jr, ChangeRowCh3
    if_eq 2, jr, ChangeRowCh2
ChangeRowCh1:
    ld a, [MenuCursorRow]
    ;; TODO others
    if_eq 1, jr, ChangeRowCh1Duty
    if_eq 5, jr, ChangeRowCh1Frequency
    ret
ChangeRowCh1Duty:
    ld a, 1
    ld [ChangedCh1Duty], a
    ld a, b
    and PADF_LEFT
    jr z, ChangeRowCh1DutyUp
ChangeRowCh1DutyDown:
    ld a, [Ch1Duty]
    sub 1
    jr nc, .noUnderflow
    ld a, 3
    .noUnderflow
    ld [Ch1Duty], a
    ret
ChangeRowCh1DutyUp:
    ld a, [Ch1Duty]
    add 1
    if_lt %100, jr, .noOverflow
    xor a
    .noOverflow
    ld [Ch1Duty], a
    ret
ChangeRowCh1Frequency:
    ld a, 1
    ld [ChangedCh1Frequency], a
    ld a, b
    and PADF_LEFT
    jr z, ChangeRowCh1FrequencyUp
ChangeRowCh1FrequencyDown:
    ld hl, Ch1Frequency
    ld a, [hl]
    sub 1
    ld [hl+], a
    ld a, [hl]
    sbc 0
    jr nc, .noUnderflow
    ld hl, Ch1Frequency
    ld a, %11111111
    ld [hl+], a
    ld a, %111
    .noUnderflow
    ld [hl], a
    ret
ChangeRowCh1FrequencyUp:
    ld hl, Ch1Frequency
    ld a, [hl]
    add 1
    ld [hl+], a
    ld a, [hl]
    adc 0
    if_lt %1000, jr, .noOverflow
    ld hl, Ch1Frequency
    xor a
    ld [hl+], a
    .noOverflow
    ld [hl], a
    ret
ChangeRowCh2:
ChangeRowCh3:
ChangeRowCh4:
    ;; TODO
    ret

;;;=========================================================================;;;

;;; Plays the sound for the current channel.
PlaySound:
    ld a, [MenuChannel]
    if_eq 4, jr, .channel4
    if_eq 3, jr, .channel3
    if_eq 2, jr, .channel2
    .channel1
    call StoreNR10ValueInA
    ldh [rNR10], a
    call StoreNR11ValueInA
    ldh [rNR11], a
    call StoreNR12ValueInA
    ldh [rNR12], a
    call StoreNR13ValueInA
    ldh [rNR13], a
    call StoreNR14ValueInA
    ldh [rNR14], a
    ret
    .channel2
    call StoreNR21ValueInA
    ldh [rNR21], a
    call StoreNR22ValueInA
    ldh [rNR22], a
    call StoreNR23ValueInA
    ldh [rNR23], a
    call StoreNR24ValueInA
    ldh [rNR24], a
    ret
    .channel3
    call StoreNR30ValueInA
    ldh [rNR30], a
    call StoreNR31ValueInA
    ldh [rNR31], a
    call StoreNR32ValueInA
    ldh [rNR32], a
    call StoreNR33ValueInA
    ldh [rNR33], a
    call StoreNR34ValueInA
    ldh [rNR34], a
    ret
    .channel4
    call StoreNR41ValueInA
    ldh [rNR41], a
    call StoreNR42ValueInA
    ldh [rNR42], a
    call StoreNR43ValueInA
    ldh [rNR43], a
    call StoreNR44ValueInA
    ldh [rNR44], a
    ret

;;; @return b The number of menu rows for the current channel.
StoreNumMenuRowsInB:
    ld a, [MenuChannel]
    if_ge 3, jr, .check3
    if_ne 1, jr, .is2
    ld b, 8
    ret
    .is2
    ld b, 6
    ret
    .check3
    if_ne 3, jr, .is4
    ld b, 5
    ret
    .is4
    ld b, 7
    ret

;;; Updates the BG map after the channel is changed, then sets ChangedChannel
;;; to zero.
UpdateBgForChannel:
    ld a, [MenuChannel]
    add "0"
    ld [VramBgMap + 13 + 1 * 32], a
    ld [VramBgMap + 5 + 12 * 32], a
    ld [VramBgMap + 5 + 13 * 32], a
    ld [VramBgMap + 5 + 14 * 32], a
    ld [VramBgMap + 5 + 15 * 32], a
    ld [VramBgMap + 5 + 16 * 32], a
    xor a
    ld [ChangedChannel], a
    ret

;;; Updates the BG map after the ch1 duty is changed, then sets
;;; ChangedCh1Duty to zero.
UpdateBgForCh1Duty:
    ;; Update "Duty" row:
    ld a, [Ch1Duty]
    ld hl, VramBgMap + 13 +  2 * 32  ; dest
    ld e, a                          ; value
    call Print1DigitU8
    ;; Update "rNR11" row:
    call StoreNR11ValueInA
    ld hl, VramBgMap + 10 + 13 * 32  ; dest
    ld e, a                          ; value
    call PrintBinaryU8
    ret

;;; Updates the BG map after the ch1 frequency is changed, then sets
;;; ChangedCh1Frequency to zero.
UpdateBgForCh1Frequency:
    ;; Update "Frequency" row:
    ld a, [Ch1Frequency]
    ld e, a
    ld a, [Ch1Frequency + 1]
    ld d, a
    ld hl, VramBgMap + 13 +  6 * 32  ; dest
    call Print4DigitU16
    ;; Update "rNR13" row:
    call StoreNR13ValueInA
    ld hl, VramBgMap + 10 + 15 * 32  ; dest
    ld e, a                          ; value
    call PrintBinaryU8
    ;; Update "rNR14" row:
    call StoreNR14ValueInA
    ld hl, VramBgMap + 10 + 16 * 32  ; dest
    ld e, a                          ; value
    call PrintBinaryU8
    ret

;;;=========================================================================;;;
