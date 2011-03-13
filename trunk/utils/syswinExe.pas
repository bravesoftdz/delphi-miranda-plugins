unit SysWinExe;
{$include compilers.inc}

interface

uses windows;

function GetEXEbyWnd(w:HWND; var dst:pWideChar):pWideChar; overload;
function GetEXEbyWnd(w:HWND; var dst:PAnsiChar):PAnsiChar; overload;
function IsExeRunning(exename:PWideChar):boolean; {hwnd}

implementation

uses
  {$IFDEF FPC}jwapsapi{$ELSE}PSAPI{$ENDIF},common;
{
  shellapi - 1-FindExecutable
  psapi    - 2-GetModuleFileNameEx, 3-EnumProcesses

  IsExeRunning: 2,3
  GetEXEByWind: 2
  ExecuteWait: 1
}

function GetEXEbyWnd(w:HWND; var dst:pWideChar):pWideChar;
var
  hProcess:THANDLE;
  ProcID:DWORD;
  ModuleName: array [0..300] of WideChar;
begin
  dst:=nil;
  GetWindowThreadProcessId(w,@ProcID);
  if ProcID<>0 then
  begin
    hProcess:=OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ,False,ProcID);
    if hProcess<>0 then
    begin
      ModuleName[0]:=#0;
      GetModuleFilenameExW(hProcess,0,ModuleName,SizeOf(ModuleName));
      StrDupW(dst,ModuleName);
      CloseHandle(hProcess);
    end;
  end;
  result:=dst;
end;

function GetEXEbyWnd(w:HWND; var dst:PAnsiChar):PAnsiChar;
var
  hProcess:THANDLE;
  ProcID:DWORD;
  ModuleName: array [0..300] of AnsiChar;
begin
  dst:=nil;
  GetWindowThreadProcessId(w,@ProcID);
  if ProcID<>0 then
  begin
    hProcess:=OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ,False,ProcID);
    if hProcess<>0 then
    begin
      ModuleName[0]:=#0;
      GetModuleFilenameExA(hProcess,0,ModuleName,SizeOf(ModuleName));
      StrDup(dst,ModuleName);
      CloseHandle(hProcess);
    end;
  end;
  result:=dst;
end;

function IsExeRunning(exename:PWideChar):boolean;{hwnd}
const
  nCount = 4096;
var
  Processes:array [0..nCount-1] of dword;
  nProcess:dword;
  hProcess:THANDLE;
  ModuleName: array [0..300] of WideChar;
  i:integer;
begin
  result:=false;
  EnumProcesses(pointer(@Processes),nCount*SizeOf(DWORD),nProcess);
  nProcess:=(nProcess div 4)-1;
  for i:=2 to nProcess do //skip Idle & System
  begin
    hProcess:=OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ,
      False,Processes[i]);
    if hProcess<>0 then
    begin
      GetModuleFilenameExW(hProcess,0,ModuleName,SizeOf(ModuleName));
      result:=lstrcmpiw(extractw(ModuleName,true),exename)=0;
      CloseHandle(hProcess);
      if result then exit;
    end;
  end;
end;

initialization
finalization
end.
