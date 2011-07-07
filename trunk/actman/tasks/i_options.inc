{}
const
  opt_tasks   :PAnsiChar = 'ACT_Tasks';
  opt_count   :PAnsiChar = 'count';

  opt_name    :PAnsiChar = 'name';
  opt_flags   :PAnsiChar = 'flags';
  opt_action  :PAnsiChar = 'action';
  opt_repeat  :PAnsiChar = 'repeat';

  opt_time_lo    :PAnsiChar = 'starttime_lo';
  opt_time_hi    :PAnsiChar = 'starttime_hi';
  opt_interval_lo:PAnsiChar = 'interval_lo';
  opt_interval_hi:PAnsiChar = 'interval_hi';

procedure SaveTasks;
var
  section:array [0..63] of AnsiChar;
  p:PAnsiChar;
  i,amount:integer;
begin
  amount:=0;
  for i:=0 to MaxTasks-1 do
  begin
    if (TaskList[i].flags and ACF_ASSIGNED)=0 then
      continue;

    p:=StrEnd(IntToStr(section,amount));
    with TaskList[i] do
    begin
      StrCopy(p,opt_flags ); DBWriteDWord  (0,opt_tasks,section,flags);
      StrCopy(p,opt_name  ); DBWriteUnicode(0,opt_tasks,section,name);
      StrCopy(p,opt_action); DBWriteDWord  (0,opt_tasks,section,action);
      StrCopy(p,opt_repeat); DBWriteWord   (0,opt_tasks,section,count);
      //systemtime to filetime if needs
      StrCopy(p,opt_time_lo    ); DBWriteDWord(0,opt_tasks,section,starttime.dwLowDateTime);
      StrCopy(p,opt_time_hi    ); DBWriteDWord(0,opt_tasks,section,starttime.dwHighDateTime);
      StrCopy(p,opt_interval_lo); DBWriteDWord(0,opt_tasks,section,interval .dwLowDateTime);
      StrCopy(p,opt_interval_hi); DBWriteDWord(0,opt_tasks,section,interval .dwHighDateTime);
    end;
    inc(amount);
  end;
  DBWriteByte(0,opt_tasks,opt_count,amount);
end;

function LoadTasks:integer;
var
  section:array [0..63] of AnsiChar;
  p:PAnsiChar;
  i:integer;
begin
  MaxTasks:=DBReadByte(0,opt_tasks,opt_count);
  result:=MaxTasks;
  if MaxTasks>0 then
  begin
    GetMem  (TaskList ,MaxTasks*SizeOf(tTaskRec));
    FillChar(TaskList^,MaxTasks*SizeOf(tTaskRec),0);
    for i:=0 to MaxTasks-1 do
    begin
      p:=StrEnd(IntToStr(section,i));
      with TaskList[i] do
      begin
        StrCopy(p,opt_flags ); flags :=DBReadDWord  (0,opt_tasks,section);
        StrCopy(p,opt_name  ); name  :=DBReadUnicode(0,opt_tasks,section);
        StrCopy(p,opt_action); action:=DBReadDWord  (0,opt_tasks,section);
        StrCopy(p,opt_repeat); count :=DBReadWord   (0,opt_tasks,section);

        StrCopy(p,opt_time_lo    ); starttime.dwLowDateTime :=DBReadDWord(0,opt_tasks,section);
        StrCopy(p,opt_time_hi    ); starttime.dwHighDateTime:=DBReadDWord(0,opt_tasks,section);
        StrCopy(p,opt_interval_lo); interval .dwLowDateTime :=DBReadDWord(0,opt_tasks,section);
        StrCopy(p,opt_interval_hi); interval .dwHighDateTime:=DBReadDWord(0,opt_tasks,section);
        // filetime to systemtime if needs
      end;
    end;
  end;
end;
