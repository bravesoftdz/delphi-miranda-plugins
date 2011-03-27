unit Hooks;

interface

procedure Init;
procedure DeInit;
function AddOptionPage(var tmpl:pAnsiChar;var proc:pointer;var name:PAnsiChar):integer;

implementation

uses
  windows, commctrl, messages,
  common, dbsettings, io, m_api, wrapper,
  global;

{$R hooks.res}

{$include m_actman.inc}

{$include i_hook.inc}
{$include i_hconst.inc}
{$include i_options.inc}
{$include i_opt_dlg.inc}

// ------------ base interface functions -------------

procedure Init;
begin
//!!  hHookInOut :=PluginLink^.HookEvent(ME_ACT_INOUT{ME_SYSTEM_OKTOEXIT},@InOut);

  MessageWindow:=CreateWindowEx(0,'STATIC',nil,0,1,1,1,1,dword(HWND_MESSAGE),0,hInstance,nil);
  if MessageWindow<>0 then
    SetWindowLongPtrW(MessageWindow,GWL_WNDPROC,LONG_PTR(@HookWndProc));

  if LoadHooks=0 then
  begin
    MaxHooks:=8;
    GetMem  (HookList ,MaxHooks*SizeOf(tHookRec));
    FillChar(HookList^,MaxHooks*SizeOf(tHookRec),0);
{
  with HookList^[0] do
  begin
    flags  :=ACF_ASSIGNED;
    StrDup(name,'CList/PreBuildContactMenu');
    StrDupW(descr,'sample');
    handle :=0;
    action :=763391581;
    message:=WM_FIRSTHOOK;
  end;
}
  end
  else
    SetAllHooks;
end;

procedure DeInit;
begin
  ClearHooks;
  DestroyWindow(MessageWindow);
end;

function AddOptionPage(var tmpl:pAnsiChar;var proc:pointer;var name:PAnsiChar):integer;
begin
  result:=0;
  tmpl:=PAnsiChar(IDD_HOOKS);
  proc:=@DlgProcOpt;
  name:='Hooks';
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