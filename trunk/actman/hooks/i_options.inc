{}
const
  opt_hooks :PAnsiChar = 'ACT_Hooks';
  opt_count :PAnsiChar = 'amount';
  opt_flags :PAnsiChar = 'flags';
  opt_descr :PAnsiChar = 'descr';
  opt_name  :PAnsiChar = 'name';
  opt_action:PAnsiChar = 'action';

  ioHook    :pWideChar = 'hook';
  ioName    :pWideChar = 'name';
  ioEvent   :pWideChar = 'event';
  ioDisabled:pWideChar = 'disabled';
  ioAction  :pWideChar = 'action';

procedure SaveHooks;
var
  section:array [0..63] of AnsiChar;
  p:PAnsiChar;
  i,amount:integer;
begin
  amount:=0;
  for i:=0 to MaxHooks-1 do
  begin
    if (HookList[i].flags and ACF_ASSIGNED)=0 then
      continue;

    p:=StrEnd(IntToStr(section,amount));
    with HookList[i] do
    begin
      StrCopy(p,opt_flags ); DBWriteDWord  (0,opt_hooks,section,flags);
      StrCopy(p,opt_descr ); DBWriteUnicode(0,opt_hooks,section,descr);
      StrCopy(p,opt_name  ); DBWriteString (0,opt_hooks,section,name);
      StrCopy(p,opt_action); DBWriteDWord  (0,opt_hooks,section,action);
    end;
    inc(amount);
  end;
  DBWriteByte(0,opt_hooks,opt_count,amount);
end;

function LoadHooks:integer;
var
  section:array [0..63] of AnsiChar;
  p:PAnsiChar;
  i:integer;
begin
  MaxHooks:=DBReadByte(0,opt_hooks,opt_count);
  result:=MaxHooks;
  if MaxHooks>0 then
  begin
    GetMem  (HookList ,MaxHooks*SizeOf(tHookRec));
    FillChar(HookList^,MaxHooks*SizeOf(tHookRec),0);
    for i:=0 to MaxHooks-1 do
    begin
      p:=StrEnd(IntToStr(section,i));
      with HookList[i] do
      begin
        StrCopy(p,opt_flags ); flags :=DBReadDWord  (0,opt_hooks,section);
        StrCopy(p,opt_descr ); descr :=DBReadUnicode(0,opt_hooks,section);
        StrCopy(p,opt_name  ); name  :=DBReadString (0,opt_hooks,section);
        StrCopy(p,opt_action); action:=DBReadDWord  (0,opt_hooks,section);
      end;
    end;
  end;
end;
