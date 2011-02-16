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
call make.bat %1 %2 %3 %4 %5 %6 %7 %8 %9
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

echo.
echo -----------------------------------------
echo. Start to compile Google Translate Frame
cd .\translate\
call make.bat %1 %2 %3 %4 %5 %6 %7 %8 %9
cd ..\

echo.
echo -----------------------------------------
echo. Start to compile Hooks for ActMan
cd .\hooks\
call make.bat %1 %2 %3 %4 %5 %6 %7 %8 %9
cd ..\

:echo.
:echo -----------------------------------------
:echo. Start to compile Langs (not finished)
:cd .\lang\
:call make.bat %1 %2 %3 %4 %5 %6 %7 %8 %9
:cd ..\

