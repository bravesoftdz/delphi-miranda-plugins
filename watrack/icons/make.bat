@echo off
set asm=tasm
set iconpack=true+256-solid
@echo off
cd %asm%
call icons.bat ..\iconsets\%iconpack% %1 %2 %3 %4 %5 %6 %7 %8 %9
cd ..\
