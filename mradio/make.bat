@echo off
if /i '%1' == 'fpc' ..\FPC\bin\fpc.exe mradio.dpr %2 %3 %4 %5 %6 %7 %8 %9
if /i '%1' == 'fpc64' ..\FPC\bin64\ppcrossx64.exe mradio.dpr %2 %3 %4 %5 %6 %7 %8 %9
if /i '%1' == '' ..\delphi\dcc32 mradio.dpr %2 %3 %4 %5 %6 %7 %8 %9
