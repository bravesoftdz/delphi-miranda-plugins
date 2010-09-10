@echo off
brc32 icons.rc
tasm32 watrack_icons.asm
tlink32 -Tpd watrack_icons.obj,watrack_icons.dll,,,,icons.res
del *.map
del *.obj
del *.res
