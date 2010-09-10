@echo off
if '%1'=='' exit
echo LANGUAGE 0,0 >ver.rc

echo VS_VERSION_INFO VERSIONINFO>>ver.rc
echo  FILEVERSION 0,0,6,%1 >>ver.rc
echo  PRODUCTVERSION 0,0,6,%1 >>ver.rc
echo  FILEFLAGSMASK $3F>>ver.rc
echo  FILEOS 4 >>ver.rc
echo  FILETYPE 2 >>ver.rc
echo  FILESUBTYPE 0 >>ver.rc
echo BEGIN>>ver.rc
echo   BLOCK "StringFileInfo">>ver.rc
echo   BEGIN>>ver.rc
echo     BLOCK "000004b0">>ver.rc
echo     BEGIN>>ver.rc
echo       VALUE "CompanyName","">>ver.rc
echo       VALUE "Comments", "Plugin to get, insert to messages and show currently played song info">>ver.rc
echo       VALUE "FileDescription", "WATrack plugin for Miranda IM">>ver.rc
echo       VALUE "FileVersion", "0, 0, 6, %1 "0 >>ver.rc
echo       VALUE "InternalName", "WATrack">>ver.rc
echo       VALUE "OriginalFilename", "watrack.dll">>ver.rc
echo       VALUE "ProductName", " WATrack Dynamic Link Library (DLL)">>ver.rc
echo       VALUE "ProductVersion", "0, 0, 6, %1 "0 >>ver.rc
date /t>tmptmp
set /p d=<tmptmp
del tmptmp
echo       VALUE "SpecialBuild", "%d%"0 >>ver.rc
echo     END>>ver.rc
echo   END>>ver.rc
echo   BLOCK "VarFileInfo">>ver.rc
echo   BEGIN>>ver.rc
echo       VALUE "Translation",0,1200 >>ver.rc
echo   END>>ver.rc
echo END>>ver.rc
