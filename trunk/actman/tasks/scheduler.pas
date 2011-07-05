unit Scheduler;

interface

procedure Init;
procedure DeInit;
function AddOptionPage(var tmpl:pAnsiChar;var proc:pointer;var name:PAnsiChar):integer;

implementation

uses
  windows, commctrl, messages,
  common, dbsettings, io, m_api, wrapper,
  global;

{$R tasks.res}

{$include m_actman.inc}

{$include i_task.inc}
{$include i_tconst.inc}
{$include i_options.inc}
{$include i_opt_dlg.inc}

// ------------ base interface functions -------------

procedure Init;
begin
//!!  hTaskInOut :=PluginLink^.HookEvent(ME_ACT_INOUT{ME_SYSTEM_OKTOEXIT},@InOut);

  MessageWindow:=CreateWindowExW(0,'STATIC',nil,0,1,1,1,1,HWND_MESSAGE,0,hInstance,nil);
  if MessageWindow<>0 then
    SetWindowLongPtrW(MessageWindow,GWL_WNDPROC,LONG_PTR(@SchedulerWndProc));

  if LoadTasks=0 then
  begin
    MaxTasks:=8;
    GetMem  (TaskList ,MaxTasks*SizeOf(tTaskRec));
    FillChar(TaskList^,MaxTasks*SizeOf(tTaskRec),0);
{
  with TaskList^[0] do
  begin
    flags  :=ACF_ASSIGNED;
    StrDupW(name,'sample');
    handle :=0;
    action :=763391581;
    message:=WM_FIRSTTASK;
  end;
}
  end
  else
    SetAllTasks;
end;

procedure DeInit;
begin
  ClearTasks;
  if MessageWindow<>0 then
    DestroyWindow(MessageWindow);
end;

function AddOptionPage(var tmpl:pAnsiChar;var proc:pointer;var name:PAnsiChar):integer;
begin
  result:=0;
  tmpl:=PAnsiChar(IDD_TASKS);
  proc:=@DlgProcOpt;
  name:='Scheduler';
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