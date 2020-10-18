INCLUDE "src/hardware.inc"
INCLUDE "src/macros.inc"

;;;=========================================================================;;;

DPAD_REPEAT_DELAY EQU 24
DPAD_REPEAT_PERIOD EQU 4

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
    ld a, 1
    ld [MenuChannel], a
    xor a
    ld [HoldingDpad], a
    ld [MenuCursorRow], a
    ld [ChangedChannel], a

    ;; Clear the shadow OAM.
    ld hl, ShadowOam                 ; dest
    ld bc, ShadowOamEnd - ShadowOam  ; count
    call MemZero

    ld a, 24
    ld [ObjCursorYPos], a
    ld a, 15
    ld [ObjCursorXPos], a
    ld a, 1
    ld [ObjCursorTile], a

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
    ld a, $11
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
    call nz, UpdateBgForChannel
ReadButtons:
    call StoreButtonStateInB
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
    jp RunLoop

    ld a, b
    and PADF_LEFT
    jr z, .endLeft
    ld a, [MenuChannel]
    dec a
    ld [MenuChannel], a
    ld a, 1
    ld [ChangedChannel], a
    .endLeft
    ld a, b
    and PADF_RIGHT
    jr z, .endRight
    ld a, [MenuChannel]
    inc a
    ld [MenuChannel], a
    ld a, 1
    ld [ChangedChannel], a
    .endRight
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
    ld [ObjCursorYPos], a
    jp RunLoop

;;;=========================================================================;;;

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

;;;=========================================================================;;;
