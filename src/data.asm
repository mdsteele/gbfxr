INCLUDE "src/consts.inc"

;;;=========================================================================;;;

SECTION "BG-Tile-Data", ROM0
Data_FontTiles_start::
    INCBIN "out/data/font.2bpp"
Data_FontTiles_end::

SECTION "Obj-Tile-Data", ROM0
Data_ObjTiles_start::
    INCBIN "out/data/sprites.2bpp"
Data_ObjTiles_end::

;;;=========================================================================;;;

SECTION "Strings", ROM0
Data_ChannelLabel_str::
    DB "Channel:   1", 0
Data_DutyLabel_str::
    DB "Duty:      {d:INIT_CH1_DUTY}", 0
Data_LengthLabel_str::
    DB "Length:    00", 0
Data_EnvStartLabel_str::
    DB "Env start: 00", 0
Data_EnvSweepLabel_str::
    DB "Env sweep:+0", 0
Data_FrequencyLabel_str::
    DB "Frequency: {d:INIT_CH1_FREQUENCY}", 0
Data_SweepAmtLabel_str::
    DB "Sweep amt:+0", 0
Data_SweepLenLabel_str::
    DB "Sweep len: 0", 0
Data_Reg0Label_str::
    DB "rNR10: %00101101", 0
Data_Reg1Label_str::
    DB "rNR11: %{b:INIT_CH1_DUTY}000000", 0
Data_Reg2Label_str::
    DB "rNR12: %01000010", 0
Data_Reg3Label_str::
    DB "rNR13: %{b:INIT_CH1_FREQUENCY_LO}", 0
Data_Reg4Label_str::
    DB "rNR14: %10000{b:INIT_CH1_FREQUENCY_HI}", 0

;;;=========================================================================;;;
