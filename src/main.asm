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

    ;; Initialize background palette.
    ld a, %11100100
    ldh [rBGP], a

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
