{Last.fm Player}
unit pl_LastFM;

interface

implementation

uses windows,common,messages,syswin,srv_player,wat_api;


const
  LFMName  = 'Last.fm Player';
  LFMText  = 'Last.fm';
  LFMClass = 'QWidget';

const
  UserName:pWideChar=nil;

function Check(wnd:HWND;aflags:integer):HWND;cdecl;
var
  tmp,EXEName:PAnsiChar;
begin
  if wnd<>0 then
  begin
    result:=0;
    exit;
  end;
  result:=FindWindow(LFMClass,nil{LFMName});
  if result<>0 then
  begin
    tmp:=Extract(GetEXEByWnd(result,EXEName),true);
    if lstrcmpia(tmp,'LASTFM.EXE')<>0 then
      result:=0;
    mFreeMem(tmp);
    mFreeMem(EXEName);
    if result<>0 then
      result:=GetWindow(result,GW_OWNER);
  end;
  if result=0 then
    mFreeMem(UserName);
end;

function GetWndText(wnd:HWND):pWideChar;
var
  ps:array [0..255] of WideChar;
  p:pWideChar;
begin
  SendMessageW(wnd,WM_GETTEXT,255,dword(@ps));
  p:=StrPosW(ps,' | ');
  if p<>nil then
  begin
    mFreeMem(UserName);
    StrDupW(UserName,p+3);
    p^:=#0;
  end;
  StrDupW(result,ps);
end;

function GetFileName(wnd:HWND;flags:integer):PWideChar;cdecl;
var
  buf:array [0..1023] of WideChar;
  p:pWideChar;
begin
//  lstrcpyw(buf,'http://');
buf[0]:=#0;
  p:=GetWndText(wnd);
  StrCatW(buf,p);
  StrCatW(buf,'.mp3');
  StrDupW(result,buf);
  mFreeMem(p);
end;

function GetStatus(wnd:HWND):integer; cdecl;
var
  txt:pWideChar;
begin
  txt:=GetWndText(wnd);
  if StrCmpW(txt,LFMText,Length(LFMText))<>0 then
    result:=WAT_MES_PLAYING
  else
    result:=WAT_MES_STOPPED;
  mFreeMem(txt);
end;

function GetInfo(var SongInfo:tSongInfo;aflags:integer):integer;cdecl;
begin
  result:=0;
  with SongInfo do
  begin
    fsize:=1;
    if (aflags and WAT_OPT_CHANGES)<>0 then
    begin
      wndtext:=GetWndText(plwnd);
    end
    else
    begin
    end;
  end;
end;

const
  plRec:tPlayerCell=(
    Desc     :'Last.fm';
    flags    :WAT_OPT_LAST or WAT_OPT_SINGLEINST or WAT_OPT_HASURL;
    Icon     :0;
    Init     :nil;
    DeInit   :nil;
    Check    :@Check;
    GetStatus:@GetStatus;
    GetName  :@GetFileName;
    GetInfo  :@GetInfo;
    Command  :nil;
    URL      :'http://www.lastfm.com/';
    Notes    :'Works by window title analysing only');

initialization
  ServicePlayer(WAT_ACT_REGISTER,dword(@plRec));
end.
{
  can obtain album cover
  http://ws.audioscrobbler.com/2.0/?method=track.search&track=  &artist=  &api_key=

<?xml version="1.0" encoding="utf-8"?>
<lfm status="ok">
<results for="Believe" xmlns:opensearch="http://a9.com/-/spec/opensearch/1.1/">
<opensearch:Query role="request" searchTerms="Believe" startPage="1" />
<opensearch:totalResults>24836</opensearch:totalResults>
<opensearch:startIndex>0</opensearch:startIndex>
<opensearch:itemsPerPage>20</opensearch:itemsPerPage>
<trackmatches>
<track>
    <name>Believe Me Natalie</name>
    <artist>The Killers</artist>
    <url>http://www.last.fm/music/The+Killers/_/Believe+Me+Natalie</url>
    <streamable fulltrack="0">1</streamable>
    <listeners>265187</listeners>
            <image size="small">http://userserve-ak.last.fm/serve/34/8634917.jpg</image>
    <image size="medium">http://userserve-ak.last.fm/serve/64/8634917.jpg</image>
    <image size="large">http://userserve-ak.last.fm/serve/126/8634917.jpg</image>
    </track>

}