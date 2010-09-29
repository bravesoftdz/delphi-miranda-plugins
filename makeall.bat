@echo off

echo.
echo -----------------------------------------
echo. Start to compile mRadio
cd .\mradio
call make.bat
cd ..\

echo.
echo -----------------------------------------
echo. Start to compile WATrack
cd .\watrack\
call make.bat
cd ..\

echo.
echo -----------------------------------------
echo. Start to compile ActMan
cd .\actman\
call make.bat
cd ..\

echo.
echo -----------------------------------------
echo. Start to compile QuickSearch
cd .\quicksearch\
call make.bat
cd ..\

echo.
echo -----------------------------------------
echo. Start to compile Google Translate Frame
cd .\translate\
call make.bat
cd ..\

echo.
echo -----------------------------------------
echo. Start to compile Hooks for ActMan
cd .\hooks\
call make.bat
cd ..\

:echo.
:echo -----------------------------------------
:echo. Start to compile Langs (not finished)
:cd .\lang\
:call make.bat
:cd ..\

