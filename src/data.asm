INCLUDE "src/consts.inc"

;;;=========================================================================;;;

SECTION "BG-Tile-Data", ROMX
RomFontTiles::
    INCBIN "out/data/font.2bpp"
    .end::

SECTION "Obj-Tile-Data", ROMX
RomObjTiles::
    INCBIN "out/data/sprites.2bpp"
    .end::

;;;=========================================================================;;;

SECTION "Strings", ROMX
Strings::
    .channel::
    DB "Channel:   1", 0
    .duty::
    DB "Duty:      {d:INIT_CH1_DUTY}", 0
    .length::
    DB "Length:    00", 0
    .envInit::
    DB "Env start: 00", 0
    .envSweepAmt::
    DB "Env sweep:+0", 0
    .freqInit::
    DB "Frequency: {d:INIT_CH1_FREQUENCY}", 0
    .freqSweepAmt::
    DB "Sweep amt:+0", 0
    .freqSweepLen::
    DB "Sweep len: 0", 0
    .reg0::
    DB "rNR10: %00101101", 0
    .reg1::
    DB "rNR11: %{b:INIT_CH1_DUTY}000000", 0
    .reg2::
    DB "rNR12: %01000010", 0
    .reg3::
    DB "rNR13: %{b:INIT_CH1_FREQUENCY_LO}", 0
    .reg4::
    DB "rNR14: %10000{b:INIT_CH1_FREQUENCY_HI}", 0

;;;=========================================================================;;;
