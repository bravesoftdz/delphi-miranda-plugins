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

function ExportMenuItems(node:HXML;MenuItem:tUAMenuItem):HXML;
begin
  result:=AddChild(node,ioMenuItem,nil);
  with MenuItem do
  begin
  // popup
    if (szMenuPopup<>nil) and (szMenuPopup^<>#0) then
      AddAttr(result,ioMenuPopup,szMenuPopup);
  // name
    if (szMenuNameVars<>nil) and (szMenuNameVars^<>#0) then
      AddAttr(result,ioMenuName,szMenuNameVars);
  // show
    if (szMenuShowWhenVars<>nil) and (szMenuShowWhenVars^<>#0) then
      AddAttr(result,ioMenuShow,szMenuShowWhenVars);
  // separated
    AddAttrInt(result,ioMenuSeparated,ord((menu_opt AND UAF_MENUSEP)<>0));
  end;
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
      AddAttrInt(actnode,ioTwoState ,ORD((flags and UAF_2STATE   )<>0));
      AddAttrInt(actnode,ioSaveState,ORD((flags and UAF_SAVESTATE)<>0));
      sub:=AddChild(actnode,ioRegister,nil);
      AddAttrInt(sub,ioHotkey     ,ORD((flags and UAF_REGHOTKEY)<>0));
      AddAttrInt(sub,ioModern     ,ORD((flags and UAF_REGMTBB )<>0));
      AddAttrInt(sub,ioTabSRMM    ,ORD((flags and UAF_REGTABB )<>0));
      AddAttrInt(sub,ioMenuMain   ,ORD((flags and UAF_REGMMENU)<>0));
      AddAttrInt(sub,ioMenuContact,ORD((flags and UAF_REGCMENU)<>0));
      AddAttrInt(sub,ioMenuTray   ,ORD((flags and UAF_REGTMENU)<>0));
      // ----- Hotkey -----
      // nothing

      // ----- Modern CList toolbar -----
      // !!source - ANSI text
      if (flags and UAF_REGMTBB)<>0 then
      begin
        if (szMTBTooltip<>nil) and (szMTBTooltip^<>#0) then
          AddAttr(actnode,ioMTBTooltip,szMTBTooltip);
        if (szMTBTooltipPressed<>nil) and (szMTBTooltipPressed^<>#0) then
          AddAttr(actnode,ioMTBTooltipPressed,szMTBTooltipPressed);
      end;

      // ----- TabSRMM toolbar -----
      if (flags and UAF_REGTABB)<>0 then
      begin
        if (szTABTooltip<>nil) and (szTABTooltip^<>#0) then
          AddAttr(actnode,ioTABTooltip,szTABTooltip);
        if (szTABTooltipPressed<>nil) and (szTABTooltipPressed^<>#0) then
          AddAttr(actnode,ioTABTooltipPressed,szTABTooltipPressed);
      end;

      // ----- Main menu -----
      if (flags and UAF_REGMMENU)<>0 then
      begin
        sub:=ExportMenuItems(actnode,UAMenuItem[main_menu]);
        AddAttr(sub,ioType,'main');
      end;

      // ----- Contact menu -----
      if (flags and UAF_REGCMENU)<>0 then
      begin
        sub:=ExportMenuItems(actnode,UAMenuItem[contact_menu]);
        AddAttr(sub,ioType,'contact');
      end;

      // ----- Tray menu -----
      if (flags and UAF_REGTMENU)<>0 then
      begin
        sub:=ExportMenuItems(actnode,UAMenuItem[tray_menu]);
        AddAttr(sub,ioType,'tray');
      end;
      
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
