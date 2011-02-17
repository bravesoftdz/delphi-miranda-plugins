@echo off
porc /i%1 icons.rc
poasm watrack_buttons.asm
polink /DLL /RELEASE /NODEFAULTLIB /NOENTRY /NOLOGO /OUT:watrack_buttons.dll watrack_buttons.obj icons.res
del *.obj
del *.res
move watrack_buttons.dll ..\..\..\bin