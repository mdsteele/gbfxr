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

    ;; Clear the shadow OAM.
    ld hl, ShadowOam                 ; dest
    ld bc, ShadowOamEnd - ShadowOam  ; count
    call MemZero

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

    ;; Initialize background palette.
    ld a, %11100100
    ldh [rBGP], a

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
    call StoreButtonStateInB
    jp RunLoop

;;;=========================================================================;;;
