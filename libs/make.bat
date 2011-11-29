@echo off
if /i '%2' == 'fpc' (
  ..\FPC\bin\fpc.exe %1 %3 %4 %5 %6 %7 %8 %9
) else if /i '%2' == 'fpc64' (
  ..\FPC\bin64\ppcrossx64.exe %1 %3 %4 %5 %6 %7 %8 %9
) else if /i '%2' == 'xe2' (
  ..\XE2\BIN\dcc32.exe %1 %3 %4 %5 %6 %7 %8 %9
) else if /i '%2' == 'xe64' (
  ..\XE2\BIN\dcc64.exe %1 %3 %4 %5 %6 %7 %8 %9
) else (
  ..\delphi\dcc32 %1 %2 %3 %4 %5 %6 %7 %8 %9
)