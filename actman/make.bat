@echo off
..\delphi\brcc32.exe options.rc -fooptions.res
if /i '%1' == 'fpc' (
  ..\FPC\bin\fpc.exe actman.dpr %2 %3 %4 %5 %6 %7 %8 %9
) else if /i '%1' == 'fpc64' (
  ..\FPC\bin64\ppcrossx64.exe actman.dpr %2 %3 %4 %5 %6 %7 %8 %9
) else (
  ..\delphi\dcc32 actman.dpr  %2 %3 %4 %5 %6 %7 %8 %9
)
