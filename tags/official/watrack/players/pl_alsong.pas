{ALSong}
unit pl_alsong;
{$include compilers.inc}

interface

implementation
uses windows,wrapper,srv_player,common,wat_api;

const
  ALSongClass  = 'ALSongKernelWindow';
  ALShowClass  = 'ALShowMainWindow';
  ALShowClass1 = 'ALShowShellWindow';

// "Language Learner" -> MM : SS Title - Artist

function ALSongCheck(wnd:HWND;flags:integer):HWND;cdecl;
begin
  if wnd<>0 then
  begin
    result:=0;
    exit;
  end;
  result:=FindWindowEx(0,wnd,ALSongClass,NIL);
end;

function ALShowCheck(wnd:HWND;flags:integer):HWND;cdecl;
begin
  if wnd<>0 then
  begin
    result:=0;
    exit;
  end;
  result:=FindWindowEx(0,wnd,ALShowClass1,NIL);
  if result=0 then
    result:=FindWindowEx(0,wnd,ALShowClass,NIL);
end;

function ALShowGetElapsedTime(wnd:HWND):integer;
var
  a:cardinal;
  p,pp:PWideChar;
begin
  pp:=GetDlgText(wnd);
  a:=StrLenW(pp);
  p:=pp+a;
  repeat
    dec(p);
  until (p^='[') or (p=pp);
  if p<>pp then
    result:=TimeToInt(p+1)
  else
    result:=0;
  mFreeMem(pp);
end;

function ALShowGetInfo(var SongInfo:tSongInfo;flags:integer):integer;cdecl;
begin
  result:=0;
  if (flags and WAT_OPT_CHANGES)<>0 then
  begin
    SongInfo.time   :=ALShowGetElapsedTime(SongInfo.plwnd);
    SongInfo.wndtext:=GetDlgText(SongInfo.plwnd);
  end;
end;

const
  plRecA:tPlayerCell=(
    Desc     :'ALSong';
    flags    :WAT_OPT_HASURL;
    Icon     :0;
    Init     :nil;
    DeInit   :nil;
    Check    :@ALSongCheck;
    GetStatus:nil;
    GetName  :nil;
    GetInfo  :nil;
    Command  :nil;
    URL      :'http://www.altools.net/';
    Notes    :nil);

const
  plRecV:tPlayerCell=(
    Desc     :'ALShow';
    flags    :WAT_OPT_HASURL;
    Icon     :0;
    Init     :nil;
    DeInit   :nil;
    Check    :@ALShowCheck;
    GetStatus:nil;
    GetName  :nil;
    GetInfo  :nil;
    Command  :nil;
    URL      :'http://www.altools.net/';
    Notes    :nil);

var
  LocalPlayerLinkA,
  LocalPlayerLinkV:twPlayer;

procedure InitLink;
begin
  LocalPlayerLinkA.Next:=PlayerLink;
  LocalPlayerLinkA.This:=@plRecA;
  PlayerLink           :=@LocalPlayerLinkA;

  LocalPlayerLinkV.Next:=PlayerLink;
  LocalPlayerLinkV.This:=@plRecV;
  PlayerLink           :=@LocalPlayerLinkV;
end;

initialization
//  ServicePlayer(WAT_ACT_REGISTER,dword(@plRecA));
//  ServicePlayer(WAT_ACT_REGISTER,dword(@plRecV));
  InitLink;
end.
