@echo off
..\delphi\brcc32.exe qs.rc -foqs.res
if /i '%1' == 'fpc' (
  ..\FPC\bin\fpc.exe quicksearch.dpr %2 %3 %4 %5 %6 %7 %8 %9
) else if /i '%1' == 'fpc64' (
  ..\FPC\bin64\ppcrossx64.exe quicksearch.dpr %2 %3 %4 %5 %6 %7 %8 %9
) else (
  ..\delphi\dcc32 quicksearch.dpr %2 %3 %4 %5 %6 %7 %8 %9
)
