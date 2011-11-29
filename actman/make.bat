@echo off
..\delphi\brcc32.exe options.rc     -fooptions.res
..\delphi\brcc32.exe hooks\hooks.rc -fohooks\hooks.res
..\delphi\brcc32.exe tasks\tasks.rc -fotasks\tasks.res
..\delphi\brcc32.exe ua\ua.rc       -foua\ua.res
if /i '%1' == 'fpc' (
  ..\FPC\bin\fpc.exe actman.dpr %2 %3 %4 %5 %6 %7 %8 %9
) else if /i '%1' == 'fpc64' (
  ..\FPC\bin64\ppcrossx64.exe actman.dpr %2 %3 %4 %5 %6 %7 %8 %9
) else if /i '%1' == 'xe2' (
  ..\XE2\BIN\dcc32.exe actman.dpr %2 %3 %4 %5 %6 %7 %8 %9
) else if /i '%1' == 'xe64' (
  ..\XE2\BIN\dcc64.exe actman.dpr %2 %3 %4 %5 %6 %7 %8 %9
) else (
  ..\delphi\dcc32 actman.dpr  %1 %2 %3 %4 %5 %6 %7 %8 %9
)
