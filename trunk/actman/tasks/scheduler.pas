unit scheduler;

interface

procedure Init;
procedure DeInit;
function AddOptionPage(var tmpl:pAnsiChar;var proc:pointer;var name:PAnsiChar):integer;

implementation

uses
  windows, commctrl, messages,
  mirutils, common, dbsettings, io, m_api, wrapper,
  global;

{$R tasks.res}

{$include m_actman.inc}

var
  hevent: THANDLE;

{$include i_task.inc}
{$include i_tconst.inc}
{$include i_options.inc}
{$include i_opt_dlg.inc}
{$include i_service.inc}

// ------------ base interface functions -------------

var
  hendis,
  hcount,
  hdel: THANDLE;

procedure Init;
begin

  if LoadTasks=0 then
  begin
    MaxTasks:=8;
    GetMem  (TaskList ,MaxTasks*SizeOf(tTaskRec));
    FillChar(TaskList^,MaxTasks*SizeOf(tTaskRec),0);
  end
  else
    SetAllTasks;

  hcount:=PluginLink^.CreateServiceFunction(MS_ACT_TASKCOUNT ,@TaskCount);
  hendis:=PluginLink^.CreateServiceFunction(MS_ACT_TASKENABLE,@TaskEnable);
  hdel  :=PluginLink^.CreateServiceFunction(MS_ACT_TASKDELETE,@TaskDelete);
  hevent:=PluginLink^.CreateHookableEvent(ME_ACT_BELL);

end;

procedure DeInit;
begin
  StopAllTasks;
  PluginLink^.DestroyServiceFunction(hendis);
  PluginLink^.DestroyServiceFunction(hdel);
  PluginLink^.DestroyServiceFunction(hcount);
  ClearTasks;
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
  amLink.Next     :=ActionLink;
  amLink.Init     :=@Init;
  amLink.DeInit   :=@DeInit;
  amLink.AddOption:=@AddOptionPage;
  ActionLink      :=@amLink;
end;

initialization
  InitLink;
end.
