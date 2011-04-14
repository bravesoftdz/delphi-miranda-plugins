@echo off
if /i '%1' == 'fpc' (
  ..\FPC\bin\fpc.exe mradio.dpr %2 %3 %4 %5 %6 %7 %8 %9
) else if /i '%1' == 'fpc64' (
  ..\FPC\bin64\ppcrossx64.exe mradio.dpr %2 %3 %4 %5 %6 %7 %8 %9
) else (
  ..\delphi\brcc32.exe mradio.rc -fo..\bin\dcu\mradio.res
  ..\delphi\dcc32 mradio.dpr %2 %3 %4 %5 %6 %7 %8 %9
)