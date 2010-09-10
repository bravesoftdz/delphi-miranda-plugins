{}
var
  xmlparser:XML_API_W;
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

{
  ACIO_EXPORT   = $00000001; // export, else - import
  ACIO_APPEND   = $00000002; // append file on export
  ACIO_ASKEXIST = $00000004; // ask, if action exists on import
  ACIO_SELECTED = $00000008; // export selected actions only
}
const
  // Nodes
  ioRoot:PWideChar = 'ActMan_Export';

function Import(fname:pWideChar;aflags:dword):integer;
var
  root,hooknode:HXML;
  i,j:integer;
  res:pWideChar;
  tmp:pWideChar;
  ptr,ptr1:pChain;
  cnt:integer;
  hook:tHookRec;
  tmph:pHookList;
  f:THANDLE;
begin
  result:=0;
  if (fname=nil) or (fname^=#0) then
    exit;
  i:=GetFSize(fname);
  if i=0 then
    exit;
  mGetMem (res ,i+SizeOf(WideChar));
  FillChar(res^,i+SizeOf(WideChar),0);
  f:=Reset(fname);
  BlockRead(f,res^,i);
  CloseHandle(f);

  cnt:=CallService(MS_ACT_GETLIST,0,dword(@ptr1));

  xmlparser.cbSize:=SizeOf(XML_API_W);
  CallService(MS_SYSTEM_GET_XI,0,dword(@xmlparser));
  with xmlparser do
  begin
    root:=parseString(ChangeUnicode(res),@i,nil);
    j:=0;
    repeat
      FillChar(Hook,SizeOf(tHookRec),0);
      hooknode:=getNthChild(root,ioHook,j);
      if hooknode=0 then break;
      Hook.descr:=getAttrValue(hooknode,ioName);
      FastWideToAnsi(getAttrValue(hooknode,ioEvent),Hook.name);
      if StrToInt(getAttrValue(hooknode,ioDisabled))=1 then
        Hook.flags:=Hook.flags or ACF_DISABLED;

      pAnsiChar(ptr):=pAnsiChar(ptr1)+4;
      tmp:=getAttrValue(hooknode,ioAction);
      i:=0;
      while i<cnt do
      begin
        if StrCmpW(ptr^.descr,tmp)=0 then
        begin
          Hook.action:=ptr^.id;
          break;
        end;
        inc(ptr);
        inc(i);
      end;
      GetMem(tmph,(MaxHooks+1)*SizeOf(tHookRec));
      move(HookList^,tmph^,MaxHooks*SizeOf(tHookRec));
      FreeMem(HookList);
      HookList:=tmph;
      move(hook,HookList[MaxHooks],SizeOf(tHookRec));
      inc(MaxHooks);
      inc(j);
    until false;
  end;
  mFreeMem(res);
  CallService(MS_ACT_FREELIST,0,dword(ptr1));
end;

procedure Export(fname:pWideChar;aflags:dword);
var
  root,hooknode:HXML;
  hooks:integer;
  res:pWideChar;
  tmp:array [0..127] of WideChar;
  ptr,ptr1:pChain;
  i,cnt:integer;
  f:THANDLE;
begin
  xmlparser.cbSize:=SizeOf(XML_API_W);
  CallService(MS_SYSTEM_GET_XI,0,dword(@xmlparser));

  cnt:=CallService(MS_ACT_GETLIST,0,dword(@ptr1));

  with xmlparser do
  begin
    if GetFSize(fname)<>0 then
    begin
      mGetMem (res ,i+SizeOf(WideChar));
      FillChar(res^,i+SizeOf(WideChar),0);
      f:=Reset(fname);
      BlockRead(f,res^,i);
      CloseHandle(f);
      root:=parseString(res,@i,nil);
      mFreeMem(res);
    end
    else
      root:=CreateNode(ioRoot,nil,false);

    for hooks:=0 to MaxHooks-1 do
    begin
      with HookList[i] do
      begin
        if (flags and ACF_ASSIGNED)=0 then
          continue;
        hooknode:=addChild(root,ioHook,nil);
        AddAttr(hooknode,ioName,descr);
        if (flags and ACF_DISABLED)<>0 then
          AddAttrInt(hooknode,ioDisabled,1);
        AddAttr(hooknode,ioEvent,FastAnsiToWideBuf(name,tmp));

        i:=0;
        pAnsiChar(ptr):=pAnsiChar(ptr1)+4;
        while i<cnt do
        begin
          if ptr^.id=action then
          begin
            AddAttr(hooknode,ioAction,ptr^.descr);
            break;
          end;
          inc(ptr);
          inc(i);
        end;
      end;
    end;
  end;
  CallService(MS_ACT_FREELIST,0,dword(ptr1));
end;

function InOut(wParam:WPARAM;lParam:LPARAM):int; cdecl;
begin
  if (wParam and ACIO_EXPORT)=0 then
  begin
    result:=Import(pWideChar(lParam),wParam);
    if settings<>0 then  // redraw settings if opened
    begin
//!!      FillActionList(GetDlgItem(setting,IDC_ACTIONLIST));
      FillHookList  (GetDlgItem(settings,IDC_HOOKLIST));
    end;
  end
  else
  begin
    result:=1;
    if settings<>0 then ; // save settings if opened
    Export(pWideChar(lParam),wParam);
  end;
//  PluginLink^.NotifyEventHooks(hevinout,wParam,lParam);
end;
