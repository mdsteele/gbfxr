INCLUDE "src/hardware.inc"

;;;=========================================================================;;;

SECTION "Menu-State", WRAM0

MenuStateZero::
HoldingDpad::
    DB
HoldingStart::
    DB
ChangedChannel::
    DB
ChangedCh1Duty::
    DB
ChangedCh1EnvStart::
    DB
ChangedCh1Frequency::
    DB
MenuCursorRow::
    DB
MenuStateZeroEnd::
MenuChannel::
    DB

Ch1Duty::
    DB
Ch1Length::
    DB
Ch1EnvStart::
    DB
Ch1EnvSweep::
    DB
Ch1Frequency::
    DW
Ch1SweepLen::
    DB
Ch1SweepAmp::
    DB

Ch2Duty::
    DB
Ch2Length::
    DB
Ch2EnvStart::
    DB
Ch2EnvSweep::
    DB
Ch2Frequency::
    DW

Ch3Length::
    DB
Ch3Level::
    DB
Ch3Frequency::
    DW

Ch4Length::
    DB
Ch4EnvStart::
    DB
Ch4EnvSweep::
    DB
Ch4Frequency::
    DB
Ch4Step::
    DB
Ch4Div::
    DB

;;;=========================================================================;;;

SECTION "Shadow-OAM", WRAM0, ALIGN[8]
ShadowOam::
UNION
    DS sizeof_OAM_ATTRS * OAM_COUNT
NEXTU

ObjCursor::
    DS sizeof_OAM_ATTRS

ENDU
ShadowOamEnd::

;;;=========================================================================;;;

SECTION "VRAM", VRAM[$8000]
VramObjTiles::
    DS $800
VramSharedTiles::
    DS $800
VramBgTiles::
    DS $800
VramBgMap::
    DS $400
VramWindowMap::
    DS $400

;;;=========================================================================;;;

SECTION "OAM-Routine-ROM", ROMX
OamDmaCode::
    ld a, HIGH(ShadowOam)
    ldh [rDMA], a  ; Start DMA transfer.
    ;; We need to wait 160 microseconds for the transfer to complete; the
	;; following loop takes exactly that long.
    ld a, 40
    .loop
    dec a
    jr nz, .loop
    ret
OamDmaCodeEnd::

SECTION "OAM-Routine-HRAM", HRAM
PerformOamDma::
    DS OamDmaCodeEnd - OamDmaCode

;;;=========================================================================;;;

;;; Store the stack at the back of RAM bank 0.
SECTION "Stack", WRAM0[$CF00]
    DS $100
InitStackPointer::

;;;=========================================================================;;;
