unit UA;

interface

procedure Init;
procedure DeInit;
function AddOptionPage(var tmpl:pAnsiChar;var proc:pointer;var name:PAnsiChar):integer;

implementation

uses
  windows, commctrl, messages,
  mirutils, common, dbsettings, io, m_api, wrapper,
  global;

{$R ua.res}

{$include m_actman.inc}

{$include i_uconst.inc}
{$include i_uavars.inc}
{$include i_uaplaces.inc}
{$include i_options.inc}
{$include i_opt_dlg.inc}
{$include i_ua.inc}

// ------------ base interface functions -------------

var
  ontabbtnpressed,
  onactchanged:THANDLE;
  hPreBuildMMenu,
  hPreBuildCMenu,
  hPreBuildTMenu:THANDLE;

procedure Init;
begin
  GetModuleFileNameW(hInstance,szMyPath,MAX_PATH);

  hServiceWithLParam:=CreateServiceFunction(SERVICE_WITH_LPARAM_NAME,@ServiceCallWithLParam);
  hMTBService       :=CreateServiceFunction(MTB_SERVICE_NAME        ,@MTBServiceCall);
  CheckPlacesAbility;

  CreateUActionList;

  ontabbtnpressed:=PluginLink^.HookEvent(ME_MSG_BUTTONPRESSED,@OnTabButtonPressed);
  onactchanged   :=PluginLink^.HookEvent(ME_ACT_CHANGED      ,@ActListChange);

  hPreBuildMMenu:=PluginLink^.HookEvent(ME_CLIST_PREBUILDMAINMENU   , PreBuildMainMenu);
  hPreBuildCMenu:=PluginLink^.HookEvent(ME_CLIST_PREBUILDCONTACTMENU, PreBuildContactMenu);
  hPreBuildTMenu:=PluginLink^.HookEvent(ME_CLIST_PREBUILDTRAYMENU   , PreBuildTrayMenu);
end;

procedure DeInit;
begin
  SetLength(arMenuRec,0);

  PluginLink^.UnhookEvent(hPreBuildMMenu);
  PluginLink^.UnhookEvent(hPreBuildCMenu);
  PluginLink^.UnhookEvent(hPreBuildTMenu);

  PluginLink^.UnhookEvent(ontabbtnpressed);
  PluginLink^.UnhookEvent(onactchanged);
  PluginLink^.DestroyServiceFunction(hServiceWithLParam);
  PluginLink^.DestroyServiceFunction(hMTBService);
end;

function AddOptionPage(var tmpl:pAnsiChar;var proc:pointer;var name:PAnsiChar):integer;
begin
  result:=0;
  tmpl:=PAnsiChar(IDD_UA);
  proc:=@DlgProcOpt;
  name:='Use Actions';
end;

var
  amLink:tActionLink;

procedure InitLink;
begin
  amLink.next     :=ActionLink;
  amLink.Init     :=@Init;
  amLink.DeInit   :=@Deinit;
  amLink.AddOption:=@AddOptionPage;
  ActionLink      :=@amLink;
end;

initialization
  InitLink;
end.
