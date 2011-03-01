{J River Media center player}
unit pl_JRMC;
{$include compilers.inc}

interface

implementation
uses windows,common,srv_player,wat_api
  {$IFDEF DELPHI7_UP}
  ,variants
  {$ENDIF}
  {$IFDEF KOL_MCK}
  ,kolcomobj
  {$ELSE}
  ,ComObj
  {$ENDIF}
;

const
  JRMCClass     = 'MJFrame';
  JRMCDispClass = 'J. River Display Window';
//const
//  JRMCCOMClass:TGUID = '{BA577A46-40F2-43D3-B691-C978F2359B17}';
const
  JRMCComName = 'MediaJukebox Application';

function Check(wnd:HWND;flags:integer):HWND;cdecl;
begin
  if wnd<>0 then
  begin
    result:=0;
    exit;
  end;
  result:=FindWindow(JRMCClass,NIL);
end;

function GetVersion(const v:variant):integer;
var
  lv:variant;
begin
  try
    lv:=v.GetVersion;
    result:=(lv.Major shl 24)+(lv.Minor shl 16)+lv.Build;
  except
    result:=0;
  end;
  lv:=Null;
end;

function GetVersionText(const v:variant):PWideChar;
begin
  try
    StrDupW(result,pWideChar(Widestring(v.GetVersion.Version)));
  except
    result:=nil;
  end;
end;

function GetInfo(var SongInfo:tSongInfo;flags:integer):integer;cdecl;
var
  v:variant;
begin
  result:=0;
  if (flags and WAT_OPT_PLAYERDATA)<>0 then
  begin
    if SongInfo.plyver=0 then
    begin
      try
        v:=CreateOleObject(JRMCComName);
        with SongInfo do
        begin
          plyver:=GetVersion(v);
          txtver:=GetVersionText(v);
        end;
      except
      end;
      v:=Null;
    end;
  end;
end;

const
  plRec:tPlayerCell=(
    Desc     :'J.River Media Center';
    flags    :WAT_OPT_HASURL;
    Icon     :0;
    Init     :nil;
    DeInit   :nil;
    Check    :@Check;
    GetStatus:nil;
    GetName  :nil;
    GetInfo  :@GetInfo;
    Command  :nil;
    URL      :'http://www.jrmediacenter.com/';
    Notes    :nil);

initialization
  ServicePlayer(WAT_ACT_REGISTER,dword(@plRec));
end.
