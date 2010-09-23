@echo off
brc32 icons.rc
tasm32 watrack_buttons.asm
tlink32 -Tpd watrack_buttons.obj,watrack_buttons.dll,,,,icons.res
del *.map
del *.obj
del *.res
