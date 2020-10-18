INCLUDE "src/hardware.inc"

;;;=========================================================================;;;

SECTION "Menu-State", WRAM0
HoldingDpad::
    DB
MenuCursorRow::
    DB
MenuChannel::
    DB
ChangedChannel::
    DB

;;;=========================================================================;;;

SECTION "Shadow-OAM", WRAM0, ALIGN[8]
ShadowOam::
UNION
    DS 4 * 40
NEXTU

ObjCursorYPos::
    DB
ObjCursorXPos::
    DB
ObjCursorTile::
    DB
    DB

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
