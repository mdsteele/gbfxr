INCLUDE "src/hardware.inc"

;;;=========================================================================;;;

SECTION "ShadowOam", WRAM0, ALIGN[8]

Ram_ShadowOam_start:
UNION
    DS sizeof_OAM_ATTRS * OAM_COUNT
NEXTU

Ram_Cursor_oama::
    DS sizeof_OAM_ATTRS

ENDU
Ram_ShadowOam_end:

;;;=========================================================================;;;

SECTION "OamFunctions", ROM0

;;; Disables each object in the shadow OAM.  After calling this, each object
;;; will be off-screen, but in an otherwise-unspecified state.
Func_ClearOam::
    ;; TODO: Make this more efficient by just zeroing each OAMA_Y field.
    ld hl, Ram_ShadowOam_start                      ; dest
    ld bc, Ram_ShadowOam_end - Ram_ShadowOam_start  ; count
    jp Func_MemZero

;;;=========================================================================;;;

SECTION "DmaCode", ROM0

;;; Initializes the code for Func_PerformDma within HRAM.  This must be called
;;; before calling Func_PerformDma for the first time.
Func_InitDmaCode::
    ld hl, Func_PerformDma                        ; dest
    ld de, Data_DmaCode_start                     ; src
    ld bc, Data_DmaCode_end - Data_DmaCode_start  ; count
    jp Func_MemCopy

Data_DmaCode_start:
    ld a, HIGH(Ram_ShadowOam_start)
    ldh [rDMA], a  ; Start DMA transfer.
    ;; We need to wait 160 microseconds for the transfer to complete; the
	;; following loop takes exactly that long.
    ld a, 40
    .loop
    dec a
    jr nz, .loop
    ret
Data_DmaCode_end:

;;;=========================================================================;;;

SECTION "PerformDma", HRAM

;;; Copies the shadow OAM to the real OAM.  Func_InitDmaCode must be called
;;; before calling this for the first time.
Func_PerformDma::
    DS Data_DmaCode_end - Data_DmaCode_start

;;;=========================================================================;;;
