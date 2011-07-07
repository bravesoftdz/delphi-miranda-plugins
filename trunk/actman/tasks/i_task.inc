{}
const
  HWND_MESSAGE = HWND(-3);
const
  ACF_ASSIGNED = $80000000;  // Task assigned
  ACF_DISABLED = $10000000;  // Task disabled

  TCF_ABSOLUTE     = $00000001;
  TCF_IMMEDIATELY  = $00000002;
  TCF_NONZEROBREAK = $00000004;

const
  WM_RESETTASKS = WM_USER+1312;
  WM_FIRSTTASK  = WM_USER+1313;
  WM_LASTTASK   = WM_FIRSTTASK+1000;

type
  pTaskRec = ^tTaskRec;
  tTaskRec = record
    flags     :dword;
    name      :PWideChar; // name for task
    action    :dword;     // assigned action
    // maybe tSystemTime is better? but harder to save
    dayoffset :integer;   //!! offset, days
    starttime,            // task starttime
    interval  :TFileTime; // interval for repeat
    count     :integer;   // repeat count
  end;
  pTaskList = ^tTaskList;
  tTaskList  = array [0..1023] of tTaskRec;

var
  TaskList:pTaskList = nil;
  MaxTasks:integer = 0;
  settings:HWND = 0;
  MessageWindow:HWND = 0;
  hTaskInOut:THANDLE = 0;
  hTaskShutdown:THANDLE = 0;

procedure SetAllTasks;
begin
end;

procedure ClearTasks;
var
  i:integer;
begin
  for i:=0 to MaxTasks-1 do
  begin
    with TaskList[i] do
    begin
      if (flags and ACF_ASSIGNED)<>0 then
        mFreeMem(name);
    end;
  end;
  FreeMem(TaskList);
  MaxTasks:=0;
end;

function SchedulerWndProc(Dialog:HWnd;hMessage:UINT;wParam:WPARAM;lParam:LPARAM):lresult; stdcall;
var
  p:pTaskRec;
  ap:TAct_Param;
begin
  result:=0;
  case hMessage of
    WM_FIRSTTASK..WM_LASTTASK: begin
//      p:=GetTaskByMessage(hMessage);
      if p<>nil then
      begin
        ap.flags :=ACTP_WAIT;
        ap.id    :=p^.action;
        ap.wParam:=wParam;
        ap.lParam:=lParam;
        result:=CallService(MS_ACT_RUNPARAMS,0,TLPARAM(@ap));
      end;
    end;
  else
    result:=DefWindowProc(Dialog,hMessage,wParam,lParam);
  end;
end;

function CreateNewTask:integer;
var
  i:integer;
  tmp:pTaskList;
  st:tSystemTime;
begin
  result:=-1;
  // if list is not empty, search for hole
  if MaxTasks>0 then
  begin
    for i:=0 to MaxTasks-1 do
    begin
      if (TaskList[i].flags and ACF_ASSIGNED)=0 then
      begin
        FillChar(TaskList[i],SizeOf(tTaskRec),0);
        result:=i;
      end;
    end;
  end;
  if result<0 then
  begin
    // not found or empty list
    i:=(MaxTasks+16)*SizeOf(tTaskRec);
    GetMem  (tmp ,i);
    FillChar(tmp^,i,0);
    if MaxTasks>0 then
    begin
      move(TaskList^,tmp^,MaxTasks*SizeOf(tTaskRec));
      FreeMem(TaskList);
    end;
    TaskList:=tmp;
    result:=MaxTasks;
    inc(MaxTasks,16);
  end;
  with TaskList^[result] do
  begin
    flags:=flags or ACF_ASSIGNED or ACF_DISABLED;
    FillChar(st,SizeOf(st),0);
    st.wMonth :=1;
    st.wDay   :=1;
    st.wSecond:=1;
    SystemTimeToFileTime(st,interval);
//    interval.dwLowDateTime:=10000000; // 10 kk (100 ns)
  end;
end;
