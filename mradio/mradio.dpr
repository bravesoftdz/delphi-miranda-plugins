{.$DEFINE CHANGE_NAME_BUFFERED}
{$IMAGEBASE $13300000}
library MRadio;

uses
//  FastMM4,
  kol,Windows,messages,commctrl
  ,common,io,wrapper,syswin
  ,Dynamic_Bass,dynbasswma
  ,m_api,dbsettings,mirutils,playlist,icobuttons,KOLCCtrls;

{$include mr_rc.inc}
{$resource mr.res}
{$resource ver.res}

{$include i_vars.inc}

const
  PluginName:PAnsiChar = 'mRadio';

const                 
  PluginInfo:TPLUGININFOEX=(
    cbSize     :sizeof(TPLUGININFOEX);
    shortName  :'mRadio Mod';
    version    :$00000107;
    description:'This plugin plays and records Internet radio streams.'+
                ' Also local media files can be played.';
    author     :'Awkward';
    authorEmail:'panda75@bk.ru';
    copyright  :'(c) 2007-2010 Awkward';
    homepage   :'http://awkward.miranda.im/';
    flags      :UNICODE_AWARE;
    replacesDefaultModule:0;
//    uuid:'{EEBC474C-B0AD-470F-99A8-9DD9210CE233}';
  );

var
  PluginInterfaces:array [0..1] of MUUID;

const
  VersionURL        = nil;//'http://addons.miranda-im.org/details.php?action=viewfile&id=3285';
  VersionPrefix     = nil;//'<span class="fileNameHeader">QuickSearch Mod ';
  UpdateURL         = nil;//'http://addons.miranda-im.org/feed.php?dlfile=3285';
  BetaVersionURL    = 'http://awkward.miranda.im/index.htm';
  BetaVersionPrefix = '>My mRadio mod ';
  BetaUpdateURL     = 'http://awkward.miranda.im/mradio.zip';
  BetaChangelogURL  = nil;

procedure SetStatus(hContact:THANDLE;Status:integer); forward;

function  ControlCenter(code:WPARAM;arg:LPARAM):integer; cdecl; forward;
procedure ConstructMsg(astr:PWideChar;status:integer=-1;astr1:PWideChar=nil); forward;

{$include i_search.inc}
{$include i_bass.inc}
{$include i_cc.inc}
{$include i_variables.inc}
{$include i_service.inc}
{$include i_myservice.inc}
{$include i_frame.inc}
{$include i_tray.inc}
{$include i_visual.inc}
{$include i_optdlg.inc}

procedure SetStatus(hContact:THANDLE;Status:integer);
begin
  if (Status=ID_STATUS_INVISIBLE) and (asOffline<>BST_UNCHECKED) then
    Status:=ID_STATUS_OFFLINE;

  if Status=ID_STATUS_OFFLINE then
    MyStopBass;

  if hContact=0 then
  begin
    hContact:=CallService(MS_DB_CONTACT_FINDFIRST,0,0);
    while hContact<>0 do
    begin
      if StrCmp(PAnsiChar(CallService(MS_PROTO_GETCONTACTBASEPROTO,hContact,0)),PluginName)=0 then
      begin
        DBWriteWord(hContact,PluginName,optStatus,Status);
      end;
      hContact:=CallService(MS_DB_CONTACT_FINDNEXT,hContact,0);
    end;
  end
  else
    DBWriteWord(hContact,PluginName,optStatus,Status);
end;

function MirandaPluginInfo(mirandaVersion:DWORD):PPLUGININFOEX; cdecl;
begin
  result:=@PluginInfo;
  PluginInfo.cbSize:=SizeOf(TPLUGININFO);
  PluginInfo.uuid  :=MIID_MRADIO;
end;

function MirandaPluginInfoEx(mirandaVersion:DWORD):PPLUGININFOEX; cdecl;
begin
  result:=@PluginInfo;
  PluginInfo.cbSize:=SizeOf(TPLUGININFOEX);
  PluginInfo.uuid  :=MIID_MRADIO;
end;

function OnModulesLoaded(wParam:WPARAM;lParam:LPARAM):int;cdecl;
var
  nlu:TNETLIBUSER;
  szTemp:array [0..255] of AnsiChar;
  i:integer;
  upd:TUpdate;
begin
  PluginLink^.UnhookEvent(onloadhook);

  SetStatus(0,ID_STATUS_OFFLINE);

  DBWriteDWord(0,PluginName,optVersion,PluginInfo.version);

  if PluginLink^.ServiceExists(MS_UPDATE_REGISTER)<>0 then
  begin
    with upd do
    begin
      cbSize              :=SizeOf(upd);
      szComponentName     :=PluginInfo.ShortName;
      szVersionURL        :=VersionURL;
      pbVersionPrefix     :=VersionPrefix;
      cpbVersionPrefix    :=0;//length(VersionPrefix);
      szUpdateURL         :=UpdateURL;
      szBetaVersionURL    :=BetaVersionURL;
      pbBetaVersionPrefix :=BetaVersionPrefix;
      cpbBetaVersionPrefix:=length(pbBetaVersionPrefix);
      szBetaUpdateURL     :=BetaUpdateURL;
      pbVersion           :=CreateVersionStringPlugin(@pluginInfo,szTemp);
      cpbVersion          :=StrLen(pbVersion);
      szBetaChangelogURL  :=BetaChangelogURL;
    end;
    PluginLink^.CallService(MS_UPDATE_REGISTER,0,dword(@upd));
  end;

  szTemp[0]:='E';
  szTemp[1]:='Q';
  szTemp[2]:='_';
  szTemp[4]:=#0;
  for i:=0 to 9 do
  begin
    szTemp[3]:=AnsiChar(ORD('0')+i);
    eq[i].param.fGain:=DBReadByte(0,PluginName,szTemp,15)-15;
  end;
  LoadPresets;

  RegisterIcons;
  CreateMenu;
  CreateMIMTrayMenu;

  tbUsed:=false;
  onloadhook:=PluginLink^.HookEvent(ME_TTB_MODULELOADED,@OnTTBLoaded);

  FillChar(nlu,SizeOf(nlu),0);
  StrCopy(szTemp,Translate('%s server connection'));
  StrReplace(szTemp,'%s',PluginName);
  nlu.szDescriptiveName.a:=szTemp;
  nlu.cbSize             :=SizeOf(nlu);
  nlu.flags              :=NUF_HTTPCONNS or NUF_NOHTTPSOPTION or NUF_OUTGOING;
  nlu.szSettingsModule   :=PluginName;
  hNetlib:=CallService(MS_NETLIB_REGISTERUSER,0,dword(@nlu));

  CallService(MS_RADIO_COMMAND,MRC_RECORD,2);

  recpath:=DBReadUnicode(0,PluginName,optRecPath);

  sPreBuf:=DBReadWord(0,PluginName,optPreBuf,75);
  BASS_SetConfig(BASS_CONFIG_NET_PREBUF,sPreBuf);

  sBuffer:=DBReadWord(0,PluginName,optBuffer,5000);
  BASS_SetConfig(BASS_CONFIG_NET_BUFFER,sBuffer);

  sTimeout:=DBReadWord(0,PluginName,optTimeout,5000);
  BASS_SetConfig(BASS_CONFIG_NET_TIMEOUT,sTimeout);

  doLoop    :=DBReadByte(0,PluginName,optLoop);
  doShuffle :=DBReadByte(0,PluginName,optShuffle);
  doContRec :=DBReadByte(0,PluginName,optContRec);
  PlayFirst :=DBReadByte(0,PluginName,optPlay1st);
  isEQ_OFF  :=DBReadByte(0,PluginName,optEQ_OFF);
  asOffline :=DBReadByte(0,PluginName,optOffline);
  AuConnect :=DBReadByte(0,PluginName,optConnect);
  gVolume   :=DBReadByte(0,PluginName,optVolume,50);
  NumTries  :=DBReadByte(0,PluginName,optNumTries,1);
  ForcedMono:=DBReadByte(0,PluginName,optForcedMono);
  if NumTries<1 then NumTries:=1;

  StatusTmpl:=DBReadUnicode(0,PluginName,optStatusTmpl,'%radio_title%');

  if Auconnect<>BST_UNCHECKED then
    ActiveContact:=DBReadDWord(0,PluginName,optLastStn)
  else
    ActiveContact:=0;

  PlayStatus:=RD_STATUS_NOSTATION;
  RegisterVariables;

  onsetting:=Pluginlink^.HookEvent(ME_DB_CONTACT_SETTINGCHANGED,@OnSettingsChanged);
  ondelete :=PluginLink^.HookEvent(ME_DB_CONTACT_DELETED       ,@OnContactDeleted);
  randomize;
  CreateFrame(0);
  result:=0;
end;

function PreShutdown(wParam:WPARAM;lParam:LPARAM):int;cdecl;
begin
  DestroyHiddenWindow;
  DestroyFrame();
  MyFreeBASS;
  DBWriteDWord(0,PluginName,optLastStn,ActiveContact);

  with PluginLink^ do
  begin
    DestroyServiceFunction(hsPlayStop);
    DestroyServiceFunction(hsRecord);
    DestroyServiceFunction(hsSettings);
    DestroyServiceFunction(hsSetVol);
    DestroyServiceFunction(hsGetVol);
    DestroyServiceFunction(hsMute);
    DestroyServiceFunction(hsCommand);
    DestroyServiceFunction(hsEqOnOff);

    DestroyServiceFunction(hsExport);
    DestroyServiceFunction(hsImport);

    DestroyHookableEvent(hhRadioStatus);

    UnhookEvent(onsetting);
    UnhookEvent(hHookShutdown);
    UnhookEvent(hDblClick);
    UnhookEvent(opthook);
    UnhookEvent(contexthook);
  end;

  CallService(MS_NETLIB_CLOSEHANDLE,hNetLib,0);
  mFreeMem(storage);
  mFreeMem(storagep);
  mFreeMem(recpath);
  mFreeMem(StatusTmpl);
  mFreeMem(basspath);
  FreePresets;

  result:=0;
end;

function Load(link:PPLUGINLINK): int; cdecl;
var
  desc:TPROTOCOLDESCRIPTOR;
  szTemp:array [0..MAX_PATH-1] of WideChar;
  pc:pWideChar;
  custom:pWideChar;
begin
  PluginLink:=Pointer(link);
  InitMMI;

  GetModuleFileNameW(0,szTemp,MAX_PATH-1);
  pc:=StrEndW(szTemp);
  repeat
    dec(pc);
  until pc^='\';
  inc(pc);
  pc^:=#0;

  custom:=DBReadUnicode(0,PluginName,optBASSpath,nil);

  if MyLoadBASS(szTemp,custom) then
  begin
    StrCopyW(pc,'plugins\mradio.ini');
//    StrDup(storage,szTemp);
    FastWideToAnsi(szTemp,storage);
    mGetMem(storagep,MAX_PATH+32);
    CallService(MS_DB_GETPROFILEPATH,MAX_PATH-1,dword(storagep));
    StrCat(storagep,'\mradio.ini');

    desc.cbSize:=PROTOCOLDESCRIPTOR_V3_SIZE;//SizeOf(desc);
    desc.szName:=PluginName;
    desc._type :=PROTOTYPE_PROTOCOL;
    CallService(MS_PROTO_REGISTERMODULE,0,dword(@desc));

    with PluginLink^ do
    begin
      hhRadioStatus:=PluginLink^.CreateHookableEvent(ME_RADIO_STATUS);

      hsPlayStop:=CreateServiceFunction(MS_RADIO_PLAYSTOP,@Service_RadioPlayStop);
      hsRecord  :=CreateServiceFunction(MS_RADIO_RECORD  ,@Service_RadioRecord);
      hsSettings:=CreateServiceFunction(MS_RADIO_SETTINGS,@Service_RadioSettings);
      hsSetVol  :=CreateServiceFunction(MS_RADIO_SETVOL  ,@Service_RadioSetVolume);
      hsGetVol  :=CreateServiceFunction(MS_RADIO_GETVOL  ,@Service_RadioGetVolume);
      hsMute    :=CreateServiceFunction(MS_RADIO_MUTE    ,@Service_RadioMute);
      hsCommand :=CreateServiceFunction(MS_RADIO_COMMAND ,@ControlCenter);
      hsEqOnOff :=CreateServiceFunction(MS_RADIO_EQONOFF ,@Service_EqOnOff);

      hsExport  :=CreateServiceFunction(MS_RADIO_EXPORT ,@ExportAll);
      hsImport  :=CreateServiceFunction(MS_RADIO_IMPORT ,@ImportAll);

      CreateProtoServices;
      onloadhook   :=HookEvent(ME_SYSTEM_MODULESLOADED     ,@OnModulesLoaded);
      hHookShutdown:=HookEvent(ME_SYSTEM_SHUTDOWN{ME_SYSTEM_OKTOEXIT},@PreShutdown);
      hDblClick    :=HookEvent(ME_CLIST_DOUBLECLICKED      ,@Service_RadioPlayStop{@DblClickProc});
      opthook      :=HookEvent(ME_OPT_INITIALISE           ,@OnOptInitialise);
      contexthook  :=HookEvent(ME_CLIST_PREBUILDCONTACTMENU,@OnContactMenu);
    end;

    PluginStatus:=ID_STATUS_OFFLINE;
  end;
  mFreeMem(custom);

  Result:=0;
end;

function Unload: int; cdecl;
begin
  Unload_BASSDLL;
  Result:=0;
end;

function MirandaPluginInterfaces:PMUUID; cdecl;
begin
  PluginInterfaces[0]:=PluginInfo.uuid;
  PluginInterfaces[1]:=MIID_LAST;
  result:=@PluginInterfaces;
end;

exports
  Load, Unload,
  MirandaPluginInfo,
  MirandaPluginInterfaces,MirandaPluginInfoEx;

begin
end.
