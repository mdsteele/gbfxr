INCLUDE "src/consts.inc"
INCLUDE "src/hardware.inc"
INCLUDE "src/macros.inc"

;;;=========================================================================;;;

;;; Store the stack at the back of WRAM.
SECTION "Stack", WRAM0[$DF00]
    DS $100
Ram_BottomOfStack:

;;;=========================================================================;;;

SECTION "Main", ROM0[$0150]
Main::
    ;; Initialize the stack.
    ld sp, Ram_BottomOfStack

    ;; Set up the OAM DMA routine.
    call Func_InitDmaCode

    ;; Initialize RAM state.
    call Func_InitState

    ;; Initialize the shadow OAM.
    call Func_ClearOam
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

    ld a, [Ram_ChangedCh1EnvStart]
    or a
    jr z, .ch1EnvStartUnchanged
    call Func_UpdateBgForCh1EnvStart
    .ch1EnvStartUnchanged

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
    call nz, Func_ChangeRowValue
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
    swap a
    srl a
    add 24
    ld [Ram_Cursor_oama + OAMA_Y], a
    jp RunLoop

;;;=========================================================================;;;

;;; Plays the sound for the current channel.
Func_PlaySound:
    ld a, [Ram_Channel]
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
    ld a, [Ram_Channel]
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
    ld a, [Ram_Channel]
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

;;; Updates the BG map after the ch1 env start is changed, then sets
;;; Ram_ChangedCh1EnvStart to zero.
Func_UpdateBgForCh1EnvStart:
    ;; Update "Env start" row:
    ld a, [Ram_Ch1EnvStart]
    ld hl, Vram_BgMap + 13 +  4 * SCRN_VX_B  ; dest
    ld e, a                                  ; value
    call Func_Print2DigitU8
    ;; Update "rNR12" row:
    call Func_GetNR12Value_a
    ld hl, Vram_BgMap + 10 + 14 * SCRN_VX_B  ; dest
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
