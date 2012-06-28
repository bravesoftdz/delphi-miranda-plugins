{QCD player}
unit pl_QCD;
{$include compilers.inc}

interface

implementation
uses windows,common,syswin,wrapper,winampapi,srv_player,wat_api;

const
  QCDExe = 'QCDPLAYER.EXE';
  QMPExe = 'QMPLAYER.EXE';
  Canvas = 'PlayerCanvas';

function Check(wnd:HWND;flags:integer):HWND;cdecl;
var
  tmp,EXEName:PAnsiChar;
begin
  result:=0;
  if wnd<>0 then
    exit;
  repeat
    result:=FindWindowEx(0,result,Canvas,nil);
    if result=0 then
      break;
    tmp:=Extract(GetEXEByWnd(result,EXEName),true);
    mFreeMem(EXEName);
    if lstrcmpia(tmp,QMPExe)<>0 then
      if lstrcmpia(tmp,QCDExe)<>0 then
        result:=0;
    mFreeMem(tmp);
    if result<>0 then
      break;
  until false;

end;

function GetStatus(wnd:HWND):integer; cdecl;
begin
  result:=WinampGetStatus(wnd)
end;

function GetInfo(var SongInfo:tSongInfo;flags:integer):integer;cdecl;
begin
  if SongInfo.winampwnd=0 then
    SongInfo.winampwnd:=WinampFindWindow(SongInfo.plwnd);
  if SongInfo.winampwnd<>0 then
  begin
    result:=WinampGetInfo(int_ptr(@SongInfo),flags);
  end
  else
    result:=0;
  if (flags and WAT_OPT_CHANGES)<>0 then
    SongInfo.wndtext:=GetDlgText(SongInfo.plwnd);
end;

function Command(wnd:HWND;cmd:integer;value:integer):integer;cdecl;
var
  WinampWindow:HWND;
begin
  WinampWindow:=WinampFindWindow(wnd);
  if WinampWindow<>0 then
    result:=WinampCommand(WinampWindow,cmd+(value shl 16))
  else
    result:=0;
end;

const
  plRec:tPlayerCell=(
    Desc     :'QCD';
    flags    :WAT_OPT_WINAMPAPI or WAT_OPT_HASURL;
    Icon     :0;
    Init     :nil;
    DeInit   :nil;
    Check    :@Check;
    GetStatus:@GetStatus;
    GetName  :nil;
    GetInfo  :@GetInfo;
    Command  :@Command;
    URL      :'http://quinnware.com/';
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
