{}
var
  xmlparser:XML_API_W;

function Import(fname:PWideChar;aflags:dword):integer;
var
  i:integer;
  root,actnode:HXML;
  tmp,res:pWideChar;
  f:THANDLE;
  buf:array [0..511] of WideChar;
begin

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

  xmlparser.cbSize:=XML_API_SIZEOF_V1;//SizeOf(XML_API_W);
  CallService(MS_SYSTEM_GET_XI,0,lparam(@xmlparser));
  with xmlparser do
  begin
    root:=parseString(ChangeUnicode(res),@i,nil);


    DestroyNode(root);
  end;
  mFreeMem(res);
end;

procedure WriteUAction(actnode:HXML;id:dword);
var
  i:integer;
begin
  for i:=0 to HIGH(UActionList) do
  begin
    if UActionList[i].dwActID=id then
    begin

      // ----- Common -----
      2-state
      save state
      // ----- Hotkey -----
      // nothing

      // ----- Modern CList toolbar -----
      // tooltips

      // ----- TabSRMM toolbar -----
      // tooltips

      // ----- Main menu -----
      // popup
      // name
      // show
      // separated

      // ----- Contact menu -----
      // popup
      // name
      // show
      // separated

      // ----- Tray menu -----
      // popup
      // name
      // show
      // separated

      
      break;
    end;
  end;
end;

procedure Export({act:integer;}fname:pWideChar;aflags:dword);
var
  i:integer;
  f:THANDLE;
  root,actnode:HXML;
  res:pWideChar;
  act:integer;
  ptr,ptr1:pChain;
begin
  xmlparser.cbSize:=XML_API_SIZEOF_V1;//SizeOf(XML_API_W);
  CallService(MS_SYSTEM_GET_XI,0,lparam(@xmlparser));
  root:=0;
  with xmlparser do
  begin
    // we need append file, not rewrite
    i:=GetFSize(fname);
    if i<>0 then
    begin
      mGetMem (res ,i+SizeOf(WideChar));
      FillChar(res^,i+SizeOf(WideChar),0);
      f:=Reset(fname);
      BlockRead(f,res^,i);
      CloseHandle(f);
      root:=parseString(res,@i,nil);
      mFreeMem(res);
      i:=1;
    end;

    num:=CallService(MS_ACT_GETLIST,0,LPARAM(@ptr));
    if num>0 then
    begin
      ptr1:=ptr;
      inc(pbyte(ptr),4);
      for i:=0 to num-1 do
      begin
        if ((aflags and ACIO_SELECTED)=0) or
           ((ptr.flags and (ACF_EXPORT or ACF_ASSIGNED))=
                           (ACF_EXPORT or ACF_ASSIGNED)) then
        begin
//??          actnode:=addChild(root,ioAction,nil);
//??          AddAttr(actnode,ioName,GroupList[act].descr);

          WriteUAction(actnode,ptr.id);
        end;
      end;
      inc(ptr);
    end;
    CallService(MS_ACT_FREELIST,0,LPARAM(ptr1));

    res:=toString(root,@i);
    if i>0 then
    begin
      f:=Rewrite(fname);
      BlockWrite(f,res^,i*SizeOf(WideChar));
      CloseHandle(f);
    end;
    xmlparser.FreeMem(res);
    DestroyNode(root);
  end;
end;
