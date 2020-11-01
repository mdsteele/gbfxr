INCLUDE "src/consts.inc"
INCLUDE "src/hardware.inc"

;;;=========================================================================;;;

SECTION "State", WRAM0

Ram_MenuStateZero_start::

Ram_HoldingDpad::
    DB
Ram_HoldingStart::
    DB
Ram_ChangedChannel::
    DB
Ram_ChangedCh1Duty::
    DB
Ram_ChangedCh1EnvStart::
    DB
Ram_ChangedCh1Frequency::
    DB
Ram_MenuCursorRow::
    DB
Ram_MenuChannel::
    DB

Ram_Ch1Duty::
    DB
Ram_Ch1Length::
    DB
Ram_Ch1EnvStart::
    DB
Ram_Ch1EnvSweep::
    DB
Ram_Ch1Frequency_u16::
    DW
Ram_Ch1SweepLen::
    DB
Ram_Ch1SweepAmp::
    DB

Ram_Ch2Duty::
    DB
Ram_Ch2Length::
    DB
Ram_Ch2EnvStart::
    DB
Ram_Ch2EnvSweep::
    DB
Ram_Ch2Frequency_u16::
    DW

Ram_Ch3Length::
    DB
Ram_Ch3Level::
    DB
Ram_Ch3Frequency_u16::
    DW

Ram_Ch4Length::
    DB
Ram_Ch4EnvStart::
    DB
Ram_Ch4EnvSweep::
    DB
Ram_Ch4Frequency::
    DB
Ram_Ch4Step::
    DB
Ram_Ch4Div::
    DB

Ram_MenuStateZero_end::

;;;=========================================================================;;;

SECTION "InitState", ROM0

;;; Initializes all state variables for program startup.
Func_InitState::
    ;; Zero the state:
    ld hl, Ram_MenuStateZero_start                          ; dest
    ld bc, Ram_MenuStateZero_end - Ram_MenuStateZero_start  ; count
    call Func_MemZero
    ;; Initialize variables:
    ld a, 1
    ld [Ram_MenuChannel], a
    ld a, INIT_CH1_DUTY
    ld [Ram_Ch1Duty], a
    ld a, LOW(INIT_CH1_FREQUENCY)
    ld [Ram_Ch1Frequency_u16 + 0], a
    ld a, HIGH(INIT_CH1_FREQUENCY)
    ld [Ram_Ch1Frequency_u16 + 1], a

;;;=========================================================================;;;

SECTION "Vram", VRAM[$8000]

Vram_ObjTiles::
    DS $800
Vram_SharedTiles::
    DS $800
Vram_BgTiles::
    DS $800
Vram_BgMap::
    DS $400
Vram_WindowMap::
    DS $400

;;;=========================================================================;;;
