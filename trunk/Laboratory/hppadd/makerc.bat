@echo off
set def=
if not '%2'=='' set def=-d%2
..\delphi\brcc32.exe %1 %def% -fo%1.res
