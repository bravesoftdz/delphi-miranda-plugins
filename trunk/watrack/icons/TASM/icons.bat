@echo off
brcc32 icons.rc -i%1
tasm32 watrack_buttons.asm
tlink32 -Tpd watrack_buttons.obj,watrack_buttons.dll,,,,icons.res
del *.map
del *.obj
del *.res
move watrack_buttons.dll ..\..\..\bin