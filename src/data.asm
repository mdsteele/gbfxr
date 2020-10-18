;;;=========================================================================;;;

SECTION "BG-Tile-Data", ROMX
RomFontTiles::
    INCBIN "out/data/font.2bpp"
    .end::

;;;=========================================================================;;;

SECTION "Strings", ROMX
Strings::
    .channel::
    DB "Channel:   1", 0
    .duty::
    DB "Duty:      0", 0
    .length::
    DB "Length:    00", 0
    .envInit::
    DB "Env start: 00", 0
    .envSweepAmt::
    DB "Env sweep:+0", 0
    .freqInit::
    DB "Frequency: 0000", 0
    .freqSweepAmt::
    DB "Sweep amt:+0", 0
    .freqSweepLen::
    DB "Sweep len: 0", 0
    .reg0::
    DB "rNR10: %00000000", 0
    .reg1::
    DB "rNR11: %00000000", 0
    .reg2::
    DB "rNR12: %00000000", 0
    .reg3::
    DB "rNR13: %00000000", 0
    .reg4::
    DB "rNR14: %10000000", 0

;;;=========================================================================;;;