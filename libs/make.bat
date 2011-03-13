@echo off
if /i '%2' == 'fpc' ..\FPC\bin\fpc.exe %1 %3 %4 %5 %6 %7 %8 %9
if /i '%2' == 'fpc64' ..\FPC\bin64\ppcrossx64.exe %1 %3 %4 %5 %6 %7 %8 %9
if /i '%2' == '' ..\delphi\dcc32 %1 %3 %4 %5 %6 %7 %8 %9
