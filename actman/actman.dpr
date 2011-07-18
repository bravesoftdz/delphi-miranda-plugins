{$IMAGEBASE $13200000}
library actman;
{%ToDo 'actman.todo'}
{%File 'i_actlow.inc'}
{%File 'm_actions.inc'}
{%File 'm_actman.inc'}
{%File 'i_action.inc'}
{%File 'i_const.inc'}
{%File 'i_contact.inc'}
{%File 'i_opt_struct.inc'}
{%File 'i_opt_dlg2.inc'}
{%File 'i_opt_dlg.inc'}
{%File 'i_visual.inc'}
{%File 'i_options.inc'}
{%File 'i_services.inc'}
{%File 'i_vars.inc'}
{%File 'i_inoutxm.inc'}
{%File 'tasks\i_opt_dlg.inc'}
{%File 'tasks\i_options.inc'}
{%File 'tasks\i_task.inc'}
{%File 'hooks\i_options.inc'}
{%File 'hooks\i_hook.inc'}
{%File 'hooks\i_opt_dlg.inc'}
{%File 'ua\i_opt_dlg.inc'}
{%File 'ua\i_options.inc'}
{%File 'ua\i_ua.inc'}
{%File 'ua\i_uaplaces.inc'}
{%File 'ua\i_uconst.inc'}

uses
  m_api,
  Windows,
  messages,
  commctrl,
  common,
  wrapper,
  io,
  dbsettings,
  mirutils,
  syswin,
  base64,
  helpfile,
  question,
  global,
  ua in 'ua\ua.pas',
  hooks in 'hooks\hooks.pas',
  scheduler in 'tasks\scheduler.pas';

{$r options.res}

const
  PluginName  = 'Action Manager';
var
  hHookShutdown,
  onloadhook,
  opthook:cardinal;
  hevaction,hHookChanged,hevinout:cardinal;
  hsel,hinout,hfree,hget,hrun,hrung,hrunp:cardinal;

{$include m_actions.inc}
{$include m_actman.inc}

// Updater compatibility data
const
  VersionURL        = nil;//'';//'http://addons.miranda-im.org/details.php?action=viewfile&id=';
  VersionPrefix     = nil;//'';//'<span class="fileNameHeader"> ';
  UpdateURL         = nil;//'';//'http://addons.miranda-im.org/feed.php?dlfile=';
  BetaVersionURL    = 'http://awkward.miranda.im/index.htm';
  BetaVersionPrefix = 'ActMan plugin ';
  BetaUpdateURL     = 'http://awkward.miranda.im/actman.zip';
  BetaChangelogURL  = nil; //'http://awkward.miranda.im/actman.txt';

var
  PluginInterfaces:array [0..2] of MUUID;

function MirandaPluginInfoEx(mirandaVersion:DWORD):PPLUGININFOEX; cdecl;
begin
  result:=@PluginInfo;
  PluginInfo.cbSize     :=SizeOf(TPLUGININFOEX);
  PluginInfo.shortName  :='Action manager';
  PluginInfo.version    :=$0001010A;
  PluginInfo.description:='Plugin for manage hotkeys to open contact window, insert text, '+
                          'run program and call services';
  PluginInfo.author     :='Awkward';
  PluginInfo.authorEmail:='panda75@bk.ru; awk1975@ya.ru';
  PluginInfo.copyright  :='(c) 2007-2011 Awkward';
  PluginInfo.homepage   :='http://code.google.com/p/delphi-miranda-plugins/';
  PluginInfo.flags      :=UNICODE_AWARE;
  PluginInfo.replacesDefaultModule:=0;
  PluginInfo.uuid       :=MIID_ACTMAN;
end;

{$include i_const.inc}
{$include i_vars.inc}

function ActInOut(wParam:WPARAM;lParam:LPARAM):int_ptr; cdecl; forward;

{$include i_action.inc}
{$include i_actlow.inc}
{$include i_options.inc}
{$include i_contact.inc}
{$include i_opt_dlg.inc}
{$include i_inoutxm.inc}

function ActFreeList(wParam:WPARAM;lParam:LPARAM):int_ptr;cdecl;
begin
  result:=0;
  mFreeMem(PAnsiChar(lParam));
end;

function ActGetList(wParam:WPARAM;lParam:LPARAM):int_ptr;cdecl;
var
  pc:^tChain;
  p:PHKRecord;
  i,cnt:integer;
begin
  p:=@GroupList[0];
  cnt:=0;
  for i:=0 to MaxGroups-1 do
  begin
    if (p^.flags and (ACF_ASSIGNED or ACF_VOLATILE))=ACF_ASSIGNED then inc(cnt);
    inc(p);
  end;
  result:=cnt;
  if cnt>0 then
  begin
    mGetMem(pc,cnt*SizeOf(tChain)+4);
    {$IFDEF WIN64}pqword{$ELSE}pdword{$ENDIF}(lParam)^:=uint_ptr(pc);
    pdword(pc)^:=SizeOf(TChain);
    inc(PByte(pc),4);

    p:=@GroupList[0];
    for i:=0 to MaxGroups-1 do
    begin
      if (p^.flags and (ACF_ASSIGNED or ACF_VOLATILE))=ACF_ASSIGNED then
      begin
        pc^.descr:=p^.descr;
        pc^.id   :=p^.id;
        pc^.flags:=p^.flags;
        inc(pc);
      end;
      inc(p);
    end;
  end
  else
    {$IFDEF WIN64}pqword{$ELSE}pdword{$ENDIF}(lParam)^:=0;
end;

function ActRun(wParam:WPARAM;lParam:LPARAM):int_ptr;cdecl;
var
  i:integer;
  p:PHKRecord;
begin
  result:=-1;
  p:=@GroupList[0];
  for i:=0 to MaxGroups-1 do
  begin
    if ((p^.flags and ACF_ASSIGNED)<>0) and (p^.id=dword(wParam)) then
    begin
      result:=p^.firstAction;
      break;
    end;
    inc(p);
  end;
  if result>0 then
    result:=ActionStarter(result,lParam,p^.id);
end;

function ActRunGroup(wParam:WPARAM;lParam:LPARAM):int_ptr;cdecl;
var
  i:integer;
  p:PHKRecord;
begin
  result:=-1;
  p:=@GroupList[0];
  for i:=0 to MaxGroups-1 do
  begin
    if ((p^.flags and ACF_ASSIGNED)<>0) and (StrCmpW(p^.descr,pWideChar(wParam))=0) then
    begin
      result:=p^.firstAction;
      break;
    end;
    inc(p);
  end;
  if result>0 then
    result:=ActionStarter(result,lParam,p^.id);
end;

function ActRunParam(wParam:WPARAM;lParam:LPARAM):int_ptr;cdecl;
var
  i:integer;
  p:PHKRecord;
begin
  result:=-1;
  p:=@GroupList[0];
  
  if (PAct_Param(lParam)^.flags and ACTP_BYNAME)=0 then
  begin
    for i:=0 to MaxGroups-1 do
    begin
      if ((p^.flags and ACF_ASSIGNED)<>0) and (p^.id=PAct_Param(lParam)^.Id) then
      begin
        result:=p^.firstAction;
        break;
      end;
      inc(p);
    end;
  end
  else
  begin
    for i:=0 to MaxGroups-1 do
    begin
      if ((p^.flags and ACF_ASSIGNED)<>0) and
         (StrCmpW(p^.descr,pWideChar(PAct_Param(lParam)^.Id))=0) then
      begin
        result:=p^.firstAction;
        break;
      end;
      inc(p);
    end;
  end;

  if result>0 then
  begin
    if (PAct_Param(lParam)^.flags and ACTP_WAIT)=0 then
      result:=ActionStarter    (result,PAct_Param(lParam)^.wParam,p^.id,PAct_Param(lParam)^.lParam)
    else
      result:=ActionStarterWait(result,PAct_Param(lParam)^.wParam,p^.id,PAct_Param(lParam)^.lParam);
  end;
end;

function PreShutdown(wParam:WPARAM;lParam:LPARAM):int;cdecl;
var
  ptr:pActionLink;
begin
  result:=0;

  ptr:=ActionLink;
  while ptr<>nil do
  begin
    if @ptr^.DeInit<>nil then
      ptr^.DeInit;
    ptr:=ptr^.Next;
  end;

  FreeGroups;
  PluginLink^.UnhookEvent(hHookShutdown);
  PluginLink^.UnhookEvent(opthook);
  PluginLink^.DestroyHookableEvent(hHookChanged);
  PluginLink^.DestroyHookableEvent(hevinout);
  PluginLink^.DestroyHookableEvent(hevaction);
  PluginLink^.DestroyServiceFunction(hfree);
  PluginLink^.DestroyServiceFunction(hget);
  PluginLink^.DestroyServiceFunction(hrun);
  PluginLink^.DestroyServiceFunction(hrung);
  PluginLink^.DestroyServiceFunction(hrunp);
  PluginLink^.DestroyServiceFunction(hinout);
  PluginLink^.DestroyServiceFunction(hsel);
end;

function OnModulesLoaded(wParam:WPARAM;lParam:LPARAM):int;cdecl;
var
  upd:TUpdate;
  buf:array [0..63] of AnsiChar;
  ptr:pActionLink;
begin
  Result:=0;
  PluginLink^.UnhookEvent(onloadhook);

  Langpack_register;

  LoadGroups;
  InitHelpFile;
  RegisterIcons;
  
  opthook      :=PluginLink^.HookEvent(ME_OPT_INITIALISE ,@OnOptInitialise);
  hHookShutdown:=PluginLink^.HookEvent(ME_SYSTEM_SHUTDOWN{ME_SYSTEM_OKTOEXIT},@PreShutdown);
  PluginLink^.NotifyEventHooks(hHookChanged,integer(ACTM_LOADED),0);

  if PluginLink^.ServiceExists(MS_UPDATE_REGISTER)<>0 then
  begin
    with upd do
    begin
      cbSize              :=SizeOf(upd);
      szComponentName     :=PluginInfo.ShortName;
      szVersionURL        :=VersionURL;
      pbVersionPrefix     :=VersionPrefix;
      cpbVersionPrefix    :=StrLen(VersionPrefix);//length(VersionPrefix);
      szUpdateURL         :=UpdateURL;
      szBetaVersionURL    :=BetaVersionURL;
      pbBetaVersionPrefix :=BetaVersionPrefix;
      cpbBetaVersionPrefix:=StrLen(pbBetaVersionPrefix);//length(pbBetaVersionPrefix);
      szBetaUpdateURL     :=BetaUpdateURL;
      pbVersion           :=CreateVersionStringPlugin(@pluginInfo,buf);
      cpbVersion          :=StrLen(pbVersion);
      szBetaChangelogURL  :=BetaChangelogURL;
    end;
    PluginLink^.CallService(MS_UPDATE_REGISTER,0,tlparam(@upd));
  end;
//  CallService('DBEditorpp/RegisterSingleModule',dword(PluginShort),0);

  ptr:=ActionLink;
  while ptr<>nil do
  begin
    if @ptr^.Init<>nil then
      ptr^.Init;
    ptr:=ptr^.Next;
  end;

  CallService(MS_ACT_RUNBYNAME,TWPARAM(AutoStartName),0);
end;

function Load(link:PPLUGINLINK):int; cdecl;
begin
  Result:=0;
  PluginLink:=Pointer(link);
  InitMMI;

  hHookChanged:=PluginLink^.CreateHookableEvent(ME_ACT_CHANGED);
  hevinout    :=PluginLink^.CreateHookableEvent(ME_ACT_INOUT);
  hevaction   :=PluginLink^.CreateHookableEvent(ME_ACT_ACTION);

  hfree :=PluginLink^.CreateServiceFunction(MS_ACT_FREELIST ,@ActFreeList);
  hget  :=PluginLink^.CreateServiceFunction(MS_ACT_GETLIST  ,@ActGetList);
  hrun  :=PluginLink^.CreateServiceFunction(MS_ACT_RUNBYID  ,@ActRun);
  hrung :=PluginLink^.CreateServiceFunction(MS_ACT_RUNBYNAME,@ActRunGroup);
  hrunp :=PluginLink^.CreateServiceFunction(MS_ACT_RUNPARAMS,@ActRunParam);
  hinout:=PluginLink^.CreateServiceFunction(MS_ACT_INOUT    ,@ActInOut);
  hsel  :=PluginLink^.CreateServiceFunction(MS_ACT_SELECT   ,@ActSelect);

  onloadhook:=PluginLink^.HookEvent(ME_SYSTEM_MODULESLOADED,@OnModulesLoaded);
end;

function Unload: int; cdecl;
begin
  Result:=0;
end;

function MirandaPluginInterfaces:PMUUID; cdecl;
begin
  PluginInterfaces[0]:=PluginInfo.uuid;
  PluginInterfaces[1]:=MIID_USEACTIONS;
  PluginInterfaces[2]:=MIID_LAST;
  result:=@PluginInterfaces;
end;

exports
  Load, Unload,
  MirandaPluginInterfaces,MirandaPluginInfoEx;

end.
