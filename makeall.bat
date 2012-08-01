@echo off

echo.
echo -----------------------------------------
echo. Start to compile mRadio
cd .\mradio
call make.bat %1 %2 %3 %4 %5 %6 %7 %8 %9
cd ..\

echo.
echo -----------------------------------------
echo. Start to compile WATrack
cd .\watrack\
call make.bat %1 %2 %3 %4 %5 %6 %7 %8 %9
cd ..\

echo.
echo -----------------------------------------
echo. Start to compile WATrack frame icons
cd .\watrack\icons\
call make-buttons.bat %1 %2 %3 %4 %5 %6 %7 %8 %9
cd ..\..\

echo.
echo -----------------------------------------
echo. Start to compile WATrack player icons
cd .\watrack\icons\
call make-players.bat %1 %2 %3 %4 %5 %6 %7 %8 %9
cd ..\..\

echo.
echo -----------------------------------------
echo. Start to compile ActMan
cd .\actman\
call make.bat %1 %2 %3 %4 %5 %6 %7 %8 %9
cd ..\

echo.
echo -----------------------------------------
echo. Start to compile QuickSearch
cd .\quicksearch\
call make.bat %1 %2 %3 %4 %5 %6 %7 %8 %9
cd ..\
