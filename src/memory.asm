INCLUDE "src/hardware.inc"

;;;=========================================================================;;;

SECTION "Menu-State", WRAM0

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
Ram_MenuStateZero_end::
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

;;;=========================================================================;;;

SECTION "Shadow-OAM", WRAM0, ALIGN[8]
Ram_ShadowOam_start::
UNION
    DS sizeof_OAM_ATTRS * OAM_COUNT
NEXTU

Ram_Cursor_oama::
    DS sizeof_OAM_ATTRS

ENDU
Ram_ShadowOam_end::

;;;=========================================================================;;;

SECTION "VRAM", VRAM[$8000]
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

SECTION "OAM-Routine-ROM", ROM0
Data_DmaCode_start::
    ld a, HIGH(Ram_ShadowOam_start)
    ldh [rDMA], a  ; Start DMA transfer.
    ;; We need to wait 160 microseconds for the transfer to complete; the
	;; following loop takes exactly that long.
    ld a, 40
    .loop
    dec a
    jr nz, .loop
    ret
Data_DmaCode_end::

SECTION "OAM-Routine-HRAM", HRAM
Func_PerformDma::
    DS Data_DmaCode_end - Data_DmaCode_start

;;;=========================================================================;;;

;;; Store the stack at the back of WRAM.
SECTION "Stack", WRAM0[$DF00]
    DS $100
Ram_BottomOfStack::

;;;=========================================================================;;;
