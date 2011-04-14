@echo off
if /i '%1' == 'fpc' (
  ..\FPC\bin\fpc.exe watrack.dpr %2 %3 %4 %5 %6 %7 %8 %9
) else if /i '%1' == 'fpc64' (
  ..\FPC\bin64\ppcrossx64.exe watrack.dpr %2 %3 %4 %5 %6 %7 %8 %9
) else (
  ..\delphi\brcc32.exe res\watrack.rc         -fo..\bin\dcu\watrack.res
  ..\delphi\brcc32.exe lastfm\lastfm.rc       -fo..\bin\dcu\lastfm.res
  ..\delphi\brcc32.exe popup\popup.rc         -fo..\bin\dcu\popup.res
  ..\delphi\brcc32.exe proto\proto.rc         -fo..\bin\dcu\proto.res
  ..\delphi\brcc32.exe stat\stat.rc           -fo..\bin\dcu\stat.res
  ..\delphi\brcc32.exe status\status.rc       -fo..\bin\dcu\status.res
  ..\delphi\brcc32.exe templates\templates.rc -fo..\bin\dcu\templates.res
  ..\delphi\dcc32 watrack.dpr %2 %3 %4 %5 %6 %7 %8 %9
)
