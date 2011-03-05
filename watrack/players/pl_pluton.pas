{Pluton player}
unit pl_Pluton;
{$include compilers.inc}

interface

implementation
uses windows,syswin,wrapper,common,srv_player,wat_api;

const
  PlutonExe   = 'PLUTON.EXE';
  PlutonClass = 'TApplication';

function Check(wnd:HWND;flags:integer):HWND;cdecl;
var
  tmp,EXEName:PAnsiChar;
  ltmp:boolean;
begin
  result:=0;
  if wnd<>0 then
    exit;
  repeat
    result:=FindWindowEx(0,result,PlutonClass,nil);
    if result=0 then
      break;
    tmp:=Extract(GetEXEByWnd(result,EXEName),true);
    mFreeMem(EXEName);
    ltmp:=lstrcmpia(tmp,PlutonExe)=0;
    mFreeMem(tmp);
    if ltmp then
      break;
  until false;
end;

function GetElapsedTime(wnd:HWND):integer;
var
  a:PAnsiChar;
  i:integer;
begin
  result:=0;
  a:=GetDlgText(wnd,true);
  if a<>nil then
  begin
    i:=StrScan(a,'/')-a+1;
    if i>0 then
    begin
      a[i-1]:=#0;
      while (i>0) and (a[i]<>' ') do dec(i);
      result:=TimeToInt(a+1);
    end;
    mFreeMem(a);
  end;
end;

function GetWndText(wnd:HWND):pWideChar;
var
  p:pWideChar;
begin
  result:=GetDlgText(wnd);
  if result<>nil then
  begin
    p:=StrRScanW(result,'-');
    if (p<>nil) and (p>result) then
      (p-1)^:=#0;
  end;
end;

function GetInfo(var SongInfo:tSongInfo;flags:integer):integer;cdecl;
begin
  result:=0;
  if (flags and WAT_OPT_CHANGES)<>0 then
    with SongInfo do
    begin
      time   :=GetElapsedTime(SongInfo.plwnd);
      wndtext:=GetWndText    (SongInfo.plwnd);
    end;
end;

const
  plRec:tPlayerCell=(
    Desc     :'Pluton';
    flags    :WAT_OPT_HASURL;
    Icon     :0;
    Init     :nil;
    DeInit   :nil;
    Check    :@Check;
    GetStatus:nil;
    GetName  :nil;
    GetInfo  :@GetInfo;
    Command  :nil;
    URL      :'http://pluton.oss.ru/';
    Notes    :nil);

var
  LocalPlayerLink:twPlayer;

procedure InitLink;
begin
  LocalPlayerLink.Next:=PlayerLink;
  LocalPlayerLink.This:=@plRec;
  PlayerLink          :=@LocalPlayerLink;
end;

initialization
//  ServicePlayer(WAT_ACT_REGISTER,dword(@plRec));
  InitLink;
end.
