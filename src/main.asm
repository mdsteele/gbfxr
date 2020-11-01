INCLUDE "src/consts.inc"
INCLUDE "src/hardware.inc"
INCLUDE "src/macros.inc"

;;;=========================================================================;;;

SECTION "Main", ROM0[$0150]
Main::
    ;; Initialize the stack.
    ld sp, Ram_BottomOfStack

    ;; Set up the OAM DMA routine.
    ld hl, Func_PerformDma                        ; dest
    ld de, Data_DmaCode_start                     ; src
    ld bc, Data_DmaCode_end - Data_DmaCode_start  ; count
    call Func_MemCopy

    ;; Initialize menu state.
    ld hl, Ram_MenuStateZero_start                          ; dest
    ld bc, Ram_MenuStateZero_end - Ram_MenuStateZero_start  ; count
    call Func_MemZero

    ld a, 1
    ld [Ram_MenuChannel], a
    ld a, INIT_CH1_DUTY
    ld [Ram_Ch1Duty], a
    xor a
    ld [Ram_MenuCursorRow], a
    ld [Ram_Ch1Length], a
    ld [Ram_Ch1EnvStart], a
    ld [Ram_Ch1EnvSweep], a
    ld [Ram_Ch1SweepLen], a
    ld [Ram_Ch1SweepAmp], a
    ld [Ram_Ch2Duty], a
    ld [Ram_Ch2Length], a
    ld [Ram_Ch2EnvStart], a
    ld [Ram_Ch2EnvSweep], a
    ld [Ram_Ch3Length], a
    ld [Ram_Ch3Level], a
    ld [Ram_Ch4Length], a
    ld [Ram_Ch4EnvStart], a
    ld [Ram_Ch4EnvSweep], a
    ld [Ram_Ch4Frequency], a
    ld [Ram_Ch4Step], a
    ld [Ram_Ch4Div], a
    ld hl, Ram_Ch2Frequency_u16
    ld [hl+], a
    ld [hl], a
    ld hl, Ram_Ch3Frequency_u16
    ld [hl+], a
    ld [hl], a

    ld hl, Ram_Ch1Frequency_u16
    ld a, LOW(INIT_CH1_FREQUENCY)
    ld [hl+], a
    ld a, HIGH(INIT_CH1_FREQUENCY)
    ld [hl], a

    ;; Clear the shadow OAM.
    ld hl, Ram_ShadowOam_start                      ; dest
    ld bc, Ram_ShadowOam_end - Ram_ShadowOam_start  ; count
    call Func_MemZero

    ld a, 24
    ld [Ram_Cursor_oama + OAMA_Y], a
    ld a, 15
    ld [Ram_Cursor_oama + OAMA_X], a
    ld a, 1
    ld [Ram_Cursor_oama + OAMA_TILEID], a

    ;; Turn off the LCD.
    .waitForVBlank
    ldh a, [rLY]
    if_ne SCRN_Y, jr, .waitForVBlank
    ld a, LCDCF_OFF
    ld [rLCDC], a

    ;; Write BG tiles into VRAM.
    ld hl, Vram_BgTiles + 16 * 33                     ; dest
    ld de, Data_FontTiles_start                       ; src
    ld bc, Data_FontTiles_end - Data_FontTiles_start  ; count
    call Func_MemCopy

    ;; Write obj tiles into VRAM.
    ld hl, Vram_ObjTiles + 16 * 1                   ; dest
    ld de, Data_ObjTiles_start                      ; src
    ld bc, Data_ObjTiles_end - Data_ObjTiles_start  ; count
    call Func_MemCopy

    ;; Initialize palettes.
    ld a, %11100100
    ldh [rBGP], a
    ldh [rOBP0], a
    ldh [rOBP1], a

    ;; Initialize background map.
    ld hl, Vram_BgMap + 2 +  1 * SCRN_VX_B  ; dest
    ld de, Data_ChannelLabel_str            ; src
    call Func_StrCopy
    ld hl, Vram_BgMap + 2 +  2 * SCRN_VX_B  ; dest
    ld de, Data_DutyLabel_str               ; src
    call Func_StrCopy
    ld hl, Vram_BgMap + 2 +  3 * SCRN_VX_B  ; dest
    ld de, Data_LengthLabel_str             ; src
    call Func_StrCopy
    ld hl, Vram_BgMap + 2 +  4 * SCRN_VX_B  ; dest
    ld de, Data_EnvStartLabel_str           ; src
    call Func_StrCopy
    ld hl, Vram_BgMap + 2 +  5 * SCRN_VX_B  ; dest
    ld de, Data_EnvSweepLabel_str           ; src
    call Func_StrCopy
    ld hl, Vram_BgMap + 2 +  6 * SCRN_VX_B  ; dest
    ld de, Data_FrequencyLabel_str          ; src
    call Func_StrCopy
    ld hl, Vram_BgMap + 2 +  7 * SCRN_VX_B  ; dest
    ld de, Data_SweepAmtLabel_str           ; src
    call Func_StrCopy
    ld hl, Vram_BgMap + 2 +  8 * SCRN_VX_B  ; dest
    ld de, Data_SweepLenLabel_str           ; src
    call Func_StrCopy
    ld hl, Vram_BgMap + 2 + 12 * SCRN_VX_B  ; dest
    ld de, Data_Reg0Label_str               ; src
    call Func_StrCopy
    ld hl, Vram_BgMap + 2 + 13 * SCRN_VX_B  ; dest
    ld de, Data_Reg1Label_str               ; src
    call Func_StrCopy
    ld hl, Vram_BgMap + 2 + 14 * SCRN_VX_B  ; dest
    ld de, Data_Reg2Label_str               ; src
    call Func_StrCopy
    ld hl, Vram_BgMap + 2 + 15 * SCRN_VX_B  ; dest
    ld de, Data_Reg3Label_str               ; src
    call Func_StrCopy
    ld hl, Vram_BgMap + 2 + 16 * SCRN_VX_B  ; dest
    ld de, Data_Reg4Label_str               ; src
    call Func_StrCopy

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
    call Func_WaitForVblankAndPerformDma
UpdateBg:
    ld a, [Ram_ChangedChannel]
    or a
    jr z, .channelUnchanged
    call Func_UpdateBgForChannel
    jr RunLoop
    .channelUnchanged

    ld a, [Ram_ChangedCh1Duty]
    or a
    jr z, .ch1DutyUnchanged
    call Func_UpdateBgForCh1Duty
    .ch1DutyUnchanged

    ld a, [Ram_ChangedCh1Frequency]
    or a
    jr z, .ch1FrequencyUnchanged
    call Func_UpdateBgForCh1Frequency
    .ch1FrequencyUnchanged
ReadButtons:
    call Func_GetButtonState_b
    ld a, b
    and PADF_START
    jr z, .startButtonNotHeld
    ld a, [Ram_HoldingStart]
    or a
    jr nz, .checkDpad
    ld a, 1
    ld [Ram_HoldingStart], a
    call Func_PlaySound
    jr RunLoop
    .startButtonNotHeld
    xor a
    ld [Ram_HoldingStart], a
    .checkDpad
    ld a, b
    and PADF_UP | PADF_DOWN | PADF_LEFT | PADF_RIGHT
    jr nz, .dpadActive
    xor a
    ld [Ram_HoldingDpad], a
    jr RunLoop
    .dpadActive
    ld a, [Ram_HoldingDpad]
    inc a
    if_lt DPAD_REPEAT_DELAY + DPAD_REPEAT_PERIOD, jr, .noRepeat
    ld a, DPAD_REPEAT_DELAY
    .noRepeat
    ld [Ram_HoldingDpad], a
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
    ld a, [Ram_MenuCursorRow]
    or a
    jp z, ChangeChannel
    call Func_ChangeRowValue
    jr RunLoop

MoveCursorUp:
    call Func_GetNumMenuRows_b
    ld a, [Ram_MenuCursorRow]
    or a
    jr nz, .decrement
    ld a, b
    .decrement
    dec a
    jr SetCursorRowToA
MoveCursorDown:
    call Func_GetNumMenuRows_b
    ld a, [Ram_MenuCursorRow]
    inc a
    if_lt b, jr, SetCursorRowToA
    xor a
SetCursorRowToA:
    ld [Ram_MenuCursorRow], a
    sla a
    sla a
    sla a
    add 24
    ld [Ram_Cursor_oama + OAMA_Y], a
    jp RunLoop

ChangeChannel:
    ld a, b
    and PADF_LEFT
    jr nz, ChangeChannelDown
ChangeChannelUp:
    ld a, [Ram_MenuChannel]
    inc a
    if_le 4, jr, SetChannelToA
    ld a, 1
    jr SetChannelToA
ChangeChannelDown:
    ld a, [Ram_MenuChannel]
    dec a
    jr nz, SetChannelToA
    ld a, 4
SetChannelToA:
    ld [Ram_MenuChannel], a
    ld a, 1
    ld [Ram_ChangedChannel], a
    jp RunLoop

;;;=========================================================================;;;

;;; Changes the current row value down if LEFT is held, up otherwise.
;;; @param b The current button state.
Func_ChangeRowValue:
    ld a, [Ram_MenuChannel]
    if_eq 4, jr, _ChangeRowValue_Ch4
    if_eq 3, jr, _ChangeRowValue_Ch3
    if_eq 2, jr, _ChangeRowValue_Ch2
_ChangeRowValue_Ch1:
    ld a, [Ram_MenuCursorRow]
    ;; TODO others
    if_eq 1, jr, _ChangeRowValue_Ch1Duty
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
    ld a, 3
    .noUnderflow
    ld [Ram_Ch1Duty], a
    ret
_ChangeRowValue_Ch1DutyUp:
    ld a, [Ram_Ch1Duty]
    add 1
    if_lt %100, jr, .noOverflow
    xor a
    .noOverflow
    ld [Ram_Ch1Duty], a
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

;;; Plays the sound for the current channel.
Func_PlaySound:
    ld a, [Ram_MenuChannel]
    if_eq 4, jr, .channel4
    if_eq 3, jr, .channel3
    if_eq 2, jr, .channel2
    .channel1
    call Func_GetNR10Value_a
    ldh [rNR10], a
    call Func_GetNR11Value_a
    ldh [rNR11], a
    call Func_GetNR12Value_a
    ldh [rNR12], a
    call Func_GetNR13Value_a
    ldh [rNR13], a
    call Func_GetNR14Value_a
    ldh [rNR14], a
    ret
    .channel2
    call Func_GetNR21Value_a
    ldh [rNR21], a
    call Func_GetNR22Value_a
    ldh [rNR22], a
    call Func_GetNR23Value_a
    ldh [rNR23], a
    call Func_GetNR24Value_a
    ldh [rNR24], a
    ret
    .channel3
    call Func_GetNR30Value_a
    ldh [rNR30], a
    call Func_GetNR31Value_a
    ldh [rNR31], a
    call Func_GetNR32Value_a
    ldh [rNR32], a
    call Func_GetNR33Value_a
    ldh [rNR33], a
    call Func_GetNR34Value_a
    ldh [rNR34], a
    ret
    .channel4
    call Func_GetNR41Value_a
    ldh [rNR41], a
    call Func_GetNR42Value_a
    ldh [rNR42], a
    call Func_GetNR43Value_a
    ldh [rNR43], a
    call Func_GetNR44Value_a
    ldh [rNR44], a
    ret

;;; @return b The number of menu rows for the current channel.
Func_GetNumMenuRows_b:
    ld a, [Ram_MenuChannel]
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

;;; Updates the BG map after the channel is changed, then sets
;;; Ram_ChangedChannel to zero.
Func_UpdateBgForChannel:
    ld a, [Ram_MenuChannel]
    add "0"
    ld [Vram_BgMap + 13 + 1 * SCRN_VX_B], a
    ld [Vram_BgMap + 5 + 12 * SCRN_VX_B], a
    ld [Vram_BgMap + 5 + 13 * SCRN_VX_B], a
    ld [Vram_BgMap + 5 + 14 * SCRN_VX_B], a
    ld [Vram_BgMap + 5 + 15 * SCRN_VX_B], a
    ld [Vram_BgMap + 5 + 16 * SCRN_VX_B], a
    xor a
    ld [Ram_ChangedChannel], a
    ret

;;; Updates the BG map after the ch1 duty is changed, then sets
;;; Ram_ChangedCh1Duty to zero.
Func_UpdateBgForCh1Duty:
    ;; Update "Duty" row:
    ld a, [Ram_Ch1Duty]
    ld hl, Vram_BgMap + 13 +  2 * SCRN_VX_B  ; dest
    ld e, a                                  ; value
    call Func_Print1DigitU8
    ;; Update "rNR11" row:
    call Func_GetNR11Value_a
    ld hl, Vram_BgMap + 10 + 13 * SCRN_VX_B  ; dest
    ld e, a                                  ; value
    call Func_PrintBinaryU8
    ret

;;; Updates the BG map after the ch1 frequency is changed, then sets
;;; Ram_ChangedCh1Frequency to zero.
Func_UpdateBgForCh1Frequency:
    ;; Update "Frequency" row:
    ld a, [Ram_Ch1Frequency_u16]
    ld e, a
    ld a, [Ram_Ch1Frequency_u16 + 1]
    ld d, a
    ld hl, Vram_BgMap + 13 +  6 * SCRN_VX_B  ; dest
    call Func_Print4DigitU16
    ;; Update "rNR13" row:
    call Func_GetNR13Value_a
    ld hl, Vram_BgMap + 10 + 15 * SCRN_VX_B  ; dest
    ld e, a                                  ; value
    call Func_PrintBinaryU8
    ;; Update "rNR14" row:
    call Func_GetNR14Value_a
    ld hl, Vram_BgMap + 10 + 16 * SCRN_VX_B  ; dest
    ld e, a                                  ; value
    call Func_PrintBinaryU8
    ret

;;;=========================================================================;;;
