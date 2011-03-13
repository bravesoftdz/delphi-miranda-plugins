{$include compilers.inc}
unit swrapper;

interface

uses windows;

function GetScreenRect():TRect;
procedure SnapToScreen(var rc:TRect;dx:integer=0;dy:integer=0{;
          minw:integer=240;minh:integer=100});

function GetDlgText(Dialog:HWND;idc:integer;getAnsi:boolean=false):pointer; overload;
function GetDlgText(wnd:HWND;getAnsi:boolean=false):pointer; overload;

function CB_SelectData(cb:HWND;data:dword):lresult; overload;
function CB_SelectData(Dialog:HWND;id:cardinal;data:dword):lresult; overload;
function CB_GetData   (cb:HWND;idx:integer=-1):lresult;
function CB_AddStrData (cb:HWND;astr:pAnsiChar;data:integer=0;idx:integer=-1):HWND;
function CB_AddStrDataW(cb:HWND;astr:pWideChar;data:integer=0;idx:integer=-1):HWND;

function StringToGUID(const astr:PAnsiChar):TGUID; overload;
function StringToGUID(const astr:PWideChar):TGUID; overload;

implementation

uses messages,common;

const
  EmptyGUID:TGUID = '{00000000-0000-0000-0000-000000000000}';

{$IFNDEF DELPHI7_UP}
const
  SM_XVIRTUALSCREEN  = 76;
  SM_YVIRTUALSCREEN  = 77;
  SM_CXVIRTUALSCREEN = 78;
  SM_CYVIRTUALSCREEN = 79;
{$ENDIF}

function GetScreenRect():TRect;
begin
  result.left  := GetSystemMetrics( SM_XVIRTUALSCREEN  );
  result.top   := GetSystemMetrics( SM_YVIRTUALSCREEN  );
  result.right := GetSystemMetrics( SM_CXVIRTUALSCREEN ) + result.left;
  result.bottom:= GetSystemMetrics( SM_CYVIRTUALSCREEN ) + result.top;
end;

procedure SnapToScreen(var rc:TRect;dx:integer=0;dy:integer=0{;
          minw:integer=240;minh:integer=100});
var
  rect:TRect;
begin
  rect:=GetScreenRect;
  if rc.right >rect.right  then rc.right :=rect.right -dx;
  if rc.bottom>rect.bottom then rc.bottom:=rect.bottom-dy;
  if rc.left  <rect.left   then rc.left  :=rect.left;
  if rc.top   <rect.top    then rc.top   :=rect.top;
end;

function GetDlgText(wnd:HWND;getAnsi:boolean=false):pointer;
var
  a:cardinal;
begin
  result:=nil;
  if getAnsi then
  begin
    a:=SendMessageA(wnd,WM_GETTEXTLENGTH,0,0)+1;
    if a>1 then
    begin
      mGetMem(PAnsiChar(result),a);
      SendMessageA(wnd,WM_GETTEXT,a,lparam(result));
    end;
  end
  else
  begin
    a:=SendMessageW(wnd,WM_GETTEXTLENGTH,0,0)+1;
    if a>1 then
    begin
      mGetMem(pWideChar(result),a*SizeOf(WideChar));
      SendMessageW(wnd,WM_GETTEXT,a,lparam(result));
    end;
  end;
end;

function GetDlgText(Dialog:HWND;idc:integer;getAnsi:boolean=false):pointer;
begin
  result:=GetDlgText(GetDlgItem(Dialog,idc),getAnsi);
end;

//----- Combobox functions -----

function CB_SelectData(cb:HWND;data:dword):lresult; overload;
var
  i:integer;
begin
  result:=0;
  for i:=0 to SendMessage(cb,CB_GETCOUNT,0,0)-1 do
  begin
    if data=dword(SendMessage(cb,CB_GETITEMDATA,i,0)) then
    begin
      result:=i;
      break;
    end;
  end;
  result:=SendMessage(cb,CB_SETCURSEL,result,0);
end;

function CB_SelectData(Dialog:HWND;id:cardinal;data:dword):lresult; overload;
begin
  result:=CB_SelectData(GetDlgItem(Dialog,id),data);
end;

function CB_GetData(cb:HWND;idx:integer=-1):lresult;
begin
  if idx<0 then
    idx:=SendMessage(cb,CB_GETCURSEL,0,0);
  result:=SendMessage(cb,CB_GETITEMDATA,idx,0);
end;

function CB_AddStrData(cb:HWND;astr:pAnsiChar;data:integer=0;idx:integer=-1):HWND;
begin
  result:=cb;
  if idx<0 then
    idx:=SendMessage(cb,CB_ADDSTRING,0,lparam(astr))
  else
    idx:=SendMessage(cb,CB_INSERTSTRING,idx,lparam(astr));
  SendMessage(cb,CB_SETITEMDATA,idx,data);
end;

function CB_AddStrDataW(cb:HWND;astr:pWideChar;data:integer=0;idx:integer=-1):HWND;
begin
  result:=cb;
  if idx<0 then
    idx:=SendMessageW(cb,CB_ADDSTRING,0,lparam(astr))
  else
    idx:=SendMessageW(cb,CB_INSERTSTRING,idx,lparam(astr));
  SendMessage(cb,CB_SETITEMDATA,idx,data);
end;

function StringToGUID(const astr:PAnsiChar):TGUID;
var
  i:integer;
begin
  result:=EmptyGUID;
  if StrLen(astr)<>38 then exit;
  result.D1:=HexToInt(PAnsiChar(@astr[01]),8);
  result.D2:=HexToInt(PAnsiChar(@astr[10]),4);
  result.D3:=HexToInt(PAnsiChar(@astr[15]),4);

  result.D4[0]:=HexToInt(PAnsiChar(@astr[20]),2);
  result.D4[1]:=HexToInt(PAnsiChar(@astr[22]),2);
  for i:=2 to 7 do
  begin
    result.D4[i]:=HexToInt(PAnsiChar(@astr[21+i*2]),2);
  end;
end;

function StringToGUID(const astr:PWideChar):TGUID;
var
  i:integer;
begin
  result:=EmptyGUID;
  if StrLenW(astr)<>38 then exit;
  result.D1:=HexToInt(pWideChar(@astr[01]),8);
  result.D2:=HexToInt(pWideChar(@astr[10]),4);
  result.D3:=HexToInt(pWideChar(@astr[15]),4);

  result.D4[0]:=HexToInt(pWideChar(@astr[20]),2);
  result.D4[1]:=HexToInt(pWideChar(@astr[22]),2);
  for i:=2 to 7 do
  begin
    result.D4[i]:=HexToInt(pWideChar(@astr[21+i*2]),2);
  end;
end;

end.
