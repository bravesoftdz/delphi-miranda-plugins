{$IMAGEBASE $13000000}
{$include compilers.inc}
library WATrack;
uses
  m_api,dbsettings,activex,winampapi,
  Windows,messages,commctrl,//uxtheme,
  srv_format,srv_player,wat_api,wrapper,
  common,syswin,HlpDlg,mirutils
  ,global,waticons,io,macros
  ,lastfm    in 'lastfm\lastfm.pas'
  ,statlog   in 'stat\statlog.pas'
//  ,frameunit in 'frame\frameunit.pas'
  ,popups    in 'popup\popups.pas'
  ,proto     in 'proto\proto.pas'
  ,status    in 'status\status.pas'
  ,tmpl      in 'status\tmpl.pas'
  ,templates in 'templates\templates.pas'

  ,kolframe  in 'kolframe\kolframe.pas'

  {$include lst_players.inc}
  {$include lst_formats.inc}
;

{$include res\i_const.inc}

{$Resource dlgopt.res}
{$Resource ver.res}

{$include i_vars.inc}

const
  PluginInfo:TPLUGININFOEX=(
    cbSize     :sizeof(TPLUGININFOEX);
    shortName  :PluginName;
    version    :$0000060C;
    description:'Paste played music info into message window or status text';
    author     :'Awkward';
    authorEmail:'panda75@bk.ru; awkward@land.ru';
    copyright  :'';
    homepage   :'http://awkward.miranda.im/';
    flags      :UNICODE_AWARE;
    replacesDefaultModule:0;
//    uuid:'{FC6C81F4-837E-4430-9601-A0AA43177AE3}'
  );

var
  PluginInterfaces:array [0..1] of MUUID;

const
  MenuDisablePos = 500050000;

// Updater compatibility data
const
  VersionURL        = 'http://addons.miranda-im.org/details.php?action=viewfile&id=2345';
  VersionPrefix     = '<span class="fileNameHeader">WATrack ';
  UpdateURL         = 'http://addons.miranda-im.org/feed.php?dlfile=2345';
  BetaVersionURL    = 'http://awkward.miranda.im/index.htm';
  BetaVersionPrefix = 'WATrack beta version ';
  BetaUpdateURL     = 'http://awkward.miranda.im/watrack.zip';
  BetaChangelogURL  = nil; //'http://awkward.mirandaim.ru/watrack.txt';

function MirandaPluginInfo(mirandaVersion:DWORD):PPLUGININFO; cdecl;
begin
  result:=@PluginInfo;
  PluginInfo.cbSize:=SizeOf(TPLUGININFO);
  PluginInfo.uuid  :=MIID_WATRACK;
end;

function MirandaPluginInfoEx(mirandaVersion:DWORD):PPLUGININFOEX; cdecl;
begin
  result:=@PluginInfo;
  PluginInfo.cbSize:=SizeOf(TPLUGININFOEX);
  PluginInfo.uuid  :=MIID_WATRACK;
end;

{$include i_options.inc}
{$include i_timer.inc}
{$include i_gui.inc}
{$include i_opt_dlg.inc}
{$include i_cover.inc}

function ReturnInfo(enc:integer;cp:integer=CP_ACP):pointer;
begin
  if enc<>WAT_INF_UNICODE then
  begin
    ClearTrackInfo(@SongInfoA);
    ClearPlayerInfo(@SongInfoA);
    mFreeMem(SongInfoA.wndtext);
    move(SongInfo,SongInfoA,SizeOf(tSongInfo));
    with SongInfoA do
    begin
      FastWideToANSI(SongInfo.url,url);
      if enc=WAT_INF_ANSI then
      begin
        WideToANSI(SongInfo.artist ,artist ,cp);
        WideToANSI(SongInfo.title  ,title  ,cp);
        WideToANSI(SongInfo.album  ,album  ,cp);
        WideToANSI(SongInfo.genre  ,genre  ,cp);
        WideToANSI(SongInfo.comment,comment,cp);
        WideToANSI(SongInfo.year   ,year   ,cp);
        WideToANSI(SongInfo.mfile  ,mfile  ,cp);
        WideToANSI(SongInfo.wndtext,wndtext,cp);
        WideToANSI(SongInfo.player ,player ,cp);
        WideToANSI(SongInfo.txtver ,txtver ,cp);
        WideToANSI(SongInfo.lyric  ,lyric  ,cp);
        WideToANSI(SongInfo.cover  ,cover  ,cp);
        WideToANSI(SongInfo.url    ,url    ,cp);
      end
      else
      begin
        WideToUTF8(SongInfo.artist ,artist);
        WideToUTF8(SongInfo.title  ,title);
        WideToUTF8(SongInfo.album  ,album);
        WideToUTF8(SongInfo.genre  ,genre);
        WideToUTF8(SongInfo.comment,comment);
        WideToUTF8(SongInfo.year   ,year);
        WideToUTF8(SongInfo.mfile  ,mfile);
        WideToUTF8(SongInfo.wndtext,wndtext);
        WideToUTF8(SongInfo.player ,player);
        WideToUTF8(SongInfo.txtver ,txtver);
        WideToUTF8(SongInfo.lyric  ,lyric);
        WideToUTF8(SongInfo.cover  ,cover);
        WideToUTF8(SongInfo.url    ,url);
      end;
    end;
    result:=@SongInfoA;
  end
  else
    result:=@SongInfo;
end;

function WATReturnGlobal(wParam:WPARAM;lParam:LPARAM):int;cdecl;
begin
  if wParam=0 then wParam:=WAT_INF_UNICODE;
  if lParam=0 then lParam:=MirandaCP;

  result:=int(ReturnInfo(wParam,lParam));
end;

function WATGetFileInfo(wParam:WPARAM;lParam:LPARAM):int;cdecl;
var
//  si:TSongInfo;
  dst:PSongInfo;
  extw:array [0..7] of WideChar;
  f:THANDLE;
  p:PWideChar;
begin
  result:=1;
  if (lParam=0) or (pSongInfo(lParam).mfile=nil) then exit;
  dst:=pointer(lParam);
  StrDupW(p,dst^.mfile);
  ClearTrackInfo(dst);
  dst^.mfile:=p;
//  FillChar(dst,SizeOf(dst),0);
//  FillChar(si,SizeOf(si),0);
{
  if flags and WAT_INF_ANSI<>0 then
    AnsiToWide(dst^.mfile,si.mfile)
  else if flags and WAT_INF_UTF<>0 then
    UTFToWide(dst^.mfile,si.mfile)
  else
    si.mfile:=dst^.mfile;
}  
  f:=Reset(dst^.mfile);
  if dword(f)<>INVALID_HANDLE_VALUE then
    GetFileTime(f,nil,nil,@dst^.date);
  CloseHandle(f);
  dst^.fsize:=GetFSize(dst^.mfile);
  GetExt(dst^.mfile,extw);
  if CheckFormat(extw,dst^)<>WAT_RES_NOTFOUND then
  begin
    with dst^ do
    begin
      if (cover=nil) or (cover^=#0) then
        GetCover(cover,mfile);
      if (lyric=nil) or (lyric^=#0) then
        GetLyric(lyric,mfile);
    end;
    result:=0;
//    ReturnInfo(si,dst,wParam and $FF);
  end;
end;

function WATGetMusicInfo(wParam:WPARAM;lParam:LPARAM):int;cdecl;
type
  ppointer = ^pointer;
const
  LastTime:dword=0;
  LastPlayer:PWideChar=nil;
  giused:bool=false; //!!
  oldresult:int=WAT_PLS_NOTFOUND;
var
  flags:dword;
  i:integer;
  NewStatus:integer;
  p,buf:PWideChar;
begin

  if giused then
  begin
    result:=oldresult;
    if lParam<>0 then
    begin
      if result<>WAT_PLS_NOTFOUND then
        ppointer(lParam)^:=ReturnInfo(wParam and $FF)
      else
        ppointer(lParam)^:=nil;
    end;
    exit;
  end;
//AddEvent(0,EVENTTYPE_WAT_REQUEST,DBEF_READ,nil,0,0);

  result:=WAT_PLS_NOTFOUND;
  SongInfo.status:=WAT_MES_UNKNOWN;
  if DisablePlugin=dsPermanent then
    exit;
  flags:=0;
  if CheckTime <>BST_UNCHECKED then flags:=flags or WAT_OPT_CHECKTIME;
  if UseImplant<>BST_UNCHECKED then flags:=flags or WAT_OPT_IMPLANTANT;
  if MTHCheck  <>BST_UNCHECKED then flags:=flags or WAT_OPT_MULTITHREAD;
  if KeepOld   <>BST_UNCHECKED then flags:=flags or WAT_OPT_KEEPOLD;
  if CheckAll  <>BST_UNCHECKED then flags:=flags or WAT_OPT_CHECKALL;
  if (wParam and WAT_INF_CHANGES)<>0 then
    flags:=flags or WAT_OPT_CHANGES;

  flags:=flags or HiddenOption;
  
  giused:=true;
  i:=GetInfo(SongInfo,flags);
  giused:=false;
  if i=WAT_RES_NEWFILE then
    NewStatus:=WAT_RES_OK
  else
    NewStatus:=i;

  if (i<>WAT_RES_NOTFOUND) and (SongInfo.status=WAT_MES_STOPPED) then //!!
    NewStatus:=WAT_PLS_NOMUSIC;

  if LastStatus<>NewStatus then
  begin
    LastStatus:=NewStatus;
    PluginLink^.NotifyEventHooks(hHookWATStatus,WAT_EVENT_PLAYERSTATUS,LastStatus);
  end;

  if i<>WAT_RES_NOTFOUND then
  begin

    if (LastPlayer=nil) or (StrCmpW(LastPlayer,SongInfo.player)<>0) then
    begin
      mFreeMem(LastPlayer);
      StrDupW(LastPlayer,SongInfo.player);
      PluginLink^.NotifyEventHooks(hHookWATStatus,WAT_EVENT_NEWPLAYER,dword(@SongInfo));
    end;

    if SongInfo.mfile=nil then //!!
      result:=WAT_PLS_NOMUSIC
    else
      result:=WAT_PLS_NORMAL;

    if i=WAT_RES_NEWFILE then
    begin
      if (SongInfo.cover=nil) or (SongInfo.cover^=#0) then
        GetCover(SongInfo.cover,SongInfo.mfile)
      else
      begin
        mGetMem(buf,MAX_PATH*SizeOf(WideChar));
        GetTempPathW(MAX_PATH,buf);
        if StrCmpW(buf,SongInfo.cover,StrLenW(buf))=0 then
        begin
//          StrCopyW(buf,SongInfo.cover);
          p:=StrEndW(buf);
//          while p^<>'\' do dec(p);
          StrCopyW(p,'\wat_cover.');
          GetExt(SongInfo.cover,p+11);
          DeleteFileW(buf);
          MoveFileW(SongInfo.cover,buf);
          mFreeMem(SongInfo.cover);
          SongInfo.cover:=buf;
        end
        else
          mFreeMem(buf);
      end;
      if (SongInfo.lyric=nil) or (SongInfo.lyric^=#0) then
        GetLyric(SongInfo.lyric,SongInfo.mfile);
      PluginLink^.NotifyEventHooks(hHookWATStatus,WAT_EVENT_NEWTRACK,dword(@SongInfo));
    end;
    if lParam<>0 then
      ppointer(lParam)^:=ReturnInfo(wParam and $FF);
  end
  else if lParam<>0 then
    ppointer(lParam)^:=nil;

  oldresult:=result;
end;

function PressButton(wParam:WPARAM;lParam:LPARAM):int;cdecl;
var
  flags:integer;
begin
  if DisablePlugin=dsPermanent then
    result:=0
  else
  begin
    flags:=0;
    if UseImplant<>BST_UNCHECKED then flags:=flags or WAT_OPT_IMPLANTANT;
    if mmkeyemu  <>BST_UNCHECKED then flags:=flags or WAT_OPT_APPCOMMAND;
    if CheckAll  <>BST_UNCHECKED then flags:=flags or WAT_OPT_CHECKALL;
    result:=SendCommand(wParam,lParam,flags);
  end;
end;

function WATPluginStatus(wParam:WPARAM;lParam:LPARAM):int;cdecl;
var
  f1:integer;
begin
  if wParam=2 then
  begin
    result:=PluginInfo.version;
    exit;
  end;
  if DisablePlugin=dsPermanent then
    result:=1
  else
    result:=0;
  if (wParam<0) or (wParam=MenuDisablePos) then
  begin
    if result=0 then
      wParam:=1
    else
      wParam:=0;
  end;
  case wParam of
    0: begin
      if DisablePlugin=dsPermanent then //??
      begin
        StartTimer;
        DisablePlugin:=dsEnabled;
      end;
      f1:=0;
    end;
    1: begin
      StopTimer;
      DisablePlugin:=dsPermanent;
      f1:=CMIF_CHECKED;
    end;
  else
    exit;
  end;
  DBWriteByte(0,PluginShort,opt_disable,DisablePlugin);

  ChangeMenuIcons(f1);

  PluginLink^.NotifyEventHooks(hHookWATStatus,WAT_EVENT_PLUGINSTATUS,DisablePlugin);
end;

function WaitAllModules(wParam:WPARAM;lParam:LPARAM):int;cdecl;
var
  ptr:pwModule;
begin
  result:=0;

  CallService(MS_SYSTEM_REMOVEWAIT,wParam,0);

  ptr:=ModuleLink;
  while ptr<>nil do
  begin
    if @ptr^.Init<>nil then
      ptr^.ModuleStat:=ptr^.Init(true);
    ptr:=ptr^.Next;
  end;

  if mTimer<>0 then
    TimerProc(0,0,0,0);

  StartTimer;

  PluginLink^.NotifyEventHooks(hHookWATLoaded,0,0);
end;

function OnModulesLoaded(wParam:WPARAM;lParam:LPARAM):int;cdecl;
var
  buf:array [0..511] of AnsiChar;
  upd:TUpdate;
  hEvent:THANDLE;
  p:PAnsiChar;
begin
   PluginLink^.UnhookEvent(onloadhook);

  if PluginLink^.ServiceExists(MS_TTB_ADDBUTTON)<>0 then
    onloadhook:=pluginlink^.HookEvent(ME_TTB_MODULELOADED,@OnTTBLoaded);

  if PluginLink^.ServiceExists(MS_UPDATE_REGISTER)<>0 then
  begin
    with upd do
    begin
      cbSize              :=SizeOf(upd);
      szComponentName     :=PluginInfo.ShortName;
      szVersionURL        :=VersionURL;
      pbVersionPrefix     :=VersionPrefix;
      cpbVersionPrefix    :=length(VersionPrefix);
      szUpdateURL         :=UpdateURL;
      szBetaVersionURL    :=BetaVersionURL;
      pbBetaVersionPrefix :=BetaVersionPrefix;
      cpbBetaVersionPrefix:=length(pbBetaVersionPrefix);
      szBetaUpdateURL     :=BetaUpdateURL;
      pbVersion           :=CreateVersionStringPlugin(@pluginInfo,buf);
      cpbVersion          :=StrLen(pbVersion);
      szBetaChangelogURL  :=BetaChangelogURL;
    end;
    PluginLink^.CallService(MS_UPDATE_REGISTER,0,dword(@upd));
  end;

  CallService('DBEditorpp/RegisterSingleModule',dword(PluginShort),0);

  hTimer:=0;

  OleInitialize(nil);

  if RegisterIcons then
    wsic:=PluginLink^.HookEvent(ME_SKIN2_ICONSCHANGED,@IconChanged)
  else
    wsic:=0;

  CreateMenus;

  p:=GetAddonFileName(nil,'player','plugins','ini');
  if p<>nil then
  begin
    LoadFromFile(p);
    mFreeMem(p);
  end;

  p:=GetAddonFileName(nil,'watrack_icons','icons','dll');
  if p<>nil then
  begin
    SetPlayerIcons(p);
    mFreeMem(p);
  end;

  hEvent:=CreateEvent(nil,true,true,nil);
  if hEvent<>0 then
  begin
    p:='WAT_INIT';
    hWATI:=CreateServiceFunction(p,WaitAllModules);
    CallService(MS_SYSTEM_WAITONHANDLE,hEvent,integer(p));
  end;

  loadopt;
  if DisablePlugin=dsPermanent then
    CallService(MS_WAT_PLUGINSTATUS,1,0);

  result:=0;

end;

procedure FreeVariables;
begin
  ClearTrackInfo (@SongInfo);
  ClearPlayerInfo(@SongInfo);
  mFreeMem(SongInfo.wndtext);
  mFreeMem(CoverPaths);
  ClearFormats;
  ClearPlayers;
  FreeInfoVariables;
end;

procedure FreeServices;
begin
  PluginLink^.DestroyServiceFunction(hGFI);
  PluginLink^.DestroyServiceFunction(hRGS);

  PluginLink^.DestroyServiceFunction(hWI);
  PluginLink^.DestroyServiceFunction(hGMI);
  PluginLink^.DestroyServiceFunction(hPS);
  PluginLink^.DestroyServiceFunction(hPB);
  PluginLink^.DestroyServiceFunction(hWATI);
  PluginLink^.DestroyServiceFunction(hWC);

//  PluginLink^.DestroyServiceFunction(hTMPL);

  PluginLink^.DestroyServiceFunction(hFMT);
  PluginLink^.DestroyServiceFunction(hPLR);

  PluginLink^.DestroyServiceFunction(hINS);
end;

function PreShutdown(wParam:WPARAM;lParam:LPARAM):int;cdecl;
var
  buf:array [0..511] of WideChar;
  fdata:WIN32_FIND_DATAW;
  fi:THANDLE;
  p:PWideChar;
  ptr:pwModule;
begin

  if hwndTooltip<>0 then
    DestroyWindow(hwndTooltip);

  StopTimer;
  ptr:=ModuleLink;
  while ptr<>nil do
  begin
    if @ptr^.DeInit<>nil then
      ptr^.DeInit(false);
    ptr:=ptr^.Next;
  end;

//  PluginLink^.UnhookEvent(plStatusHook);
  PluginLink^.UnhookEvent(hHookShutdown);
  PluginLink^.UnhookEvent(opthook);
  if wsic<>0 then PluginLink^.UnhookEvent(wsic);

  FreeServices;
  FreeVariables;

  PluginLink^.DestroyHookableEvent(hHookWATLoaded);
  PluginLink^.DestroyHookableEvent(hHookWATStatus);

  OleUnInitialize;

  //delete cover files
  buf[0]:=#0;
  GetTempPathW(511,buf);
  p:=StrEndW(buf);
  StrCopyW(p,'wat_cover.*');

  fi:=FindFirstFileW(buf,fdata);
  if dword(fi)<>INVALID_HANDLE_VALUE then
  begin
    repeat
      StrCopyW(p,fdata.cFileName);
      DeleteFileW(buf);
    until not FindNextFileW(fi,fdata);
    FindClose(fi);
  end;

  result:=0;
end;

function Load(link:PPLUGINLINK):int; cdecl;
begin
  result:=0;
  PluginLink:=Pointer(link);
  InitMMI;

  DisablePlugin:=dsPermanent;

  hHookWATLoaded:=PluginLink^.CreateHookableEvent(ME_WAT_MODULELOADED);
  hHookWATStatus:=PluginLink^.CreateHookableEvent(ME_WAT_NEWSTATUS);
  hHookShutdown :=PluginLink^.HookEvent(ME_SYSTEM_OKTOEXIT,@PreShutdown);
  opthook       :=PluginLink^.HookEvent(ME_OPT_INITIALISE ,@OnOptInitialise);

  hGFI:=PluginLink^.CreateServiceFunction(MS_WAT_GETFILEINFO  ,@WATGetFileInfo);
  hRGS:=PluginLink^.CreateServiceFunction(MS_WAT_RETURNGLOBAL ,@WATReturnGlobal);

  hGMI:=PluginLink^.CreateServiceFunction(MS_WAT_GETMUSICINFO ,@WATGetMusicInfo);
  hPS :=PluginLink^.CreateServiceFunction(MS_WAT_PLUGINSTATUS ,@WATPluginStatus);
  hPB :=PluginLink^.CreateServiceFunction(MS_WAT_PRESSBUTTON  ,@PressButton);
  hWI :=PluginLink^.CreateServiceFunction(MS_WAT_WINAMPINFO   ,@WinampGetInfo);
  hWC :=PluginLink^.CreateServiceFunction(MS_WAT_WINAMPCOMMAND,@WinampCommand);

  hFMT:=PluginLink^.CreateServiceFunction(MS_WAT_FORMAT,@ServiceFormat);
  hPLR:=PluginLink^.CreateServiceFunction(MS_WAT_PLAYER,@ServicePlayer);

  FillChar(SongInfoA,SizeOf(SongInfoA),0);
  FillChar(SongInfo ,SizeOf(SongInfo),0);
  onloadhook:=PluginLink^.HookEvent(ME_SYSTEM_MODULESLOADED,@OnModulesLoaded);
end;

function Unload:int; cdecl;
begin
  result:=0;
end;

function MirandaPluginInterfaces:PMUUID; cdecl;
begin
  PluginInterfaces[0]:=PluginInfo.uuid;
  PluginInterfaces[1]:=MIID_LAST;
  result:=@PluginInterfaces;
end;

exports
  Load, Unload,
  MirandaPluginInfo
  ,MirandaPluginInterfaces,MirandaPluginInfoEx;

begin
end.
