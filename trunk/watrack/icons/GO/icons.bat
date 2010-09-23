@echo off
GoRC /r icons.rc
GoAsm watrack_buttons.asm
GoLink /dll watrack_buttons.obj icons.res
del *.obj
del *.res
