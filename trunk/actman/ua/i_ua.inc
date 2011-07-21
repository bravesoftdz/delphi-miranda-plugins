{}
procedure SetAllActionUsers(var ActionItem:tMyActionItem);
var
  buf:array [0..63] of AnsiChar;
begin
  if (ActionItem.flags and UAF_REGHOTKEY)<>0 then
    AddCoreHotkey(ActionItem)
  else
    DeleteCoreHotkey(ActionItem);

  if (ActionItem.flags and UAF_REGMTBB)<>0 then
    AddMTBButton(ActionItem)
  else
    DeleteMTBButton(ActionItem);

  if (ActionItem.flags and UAF_REGTABB)<>0 then
    AddTabBBButton(ActionItem)
  else
    DeleteTabBBButton(ActionItem);

  if (ActionItem.flags and UAF_REGMMENU)<>0 then
    AddMainMenuItem(ActionItem)
  else
    DeleteMainMenuItem(ActionItem);

  if (ActionItem.flags and UAF_REGCMENU)<>0 then
    AddContactMenuItem(ActionItem)
  else
    DeleteContactMenuItem(ActionItem);

  if (ActionItem.flags and UAF_REGTMENU)<>0 then
    AddTrayMenuItem(ActionItem)
  else
    DeleteTrayMenuItem(ActionItem);

  if ((ActionItem.flags and (UAF_REGMMENU or UAF_REGCMENU or UAF_REGTMENU))=0) and
      (ActionItem.hMenuService<>0) then
  begin
    PluginLink^.DestroyServiceFunction(ActionItem.hMenuService);
    ActionItem.hMenuService:=0;
  end;

  // First run (ok ok, if ppl ask for it....)
  StrCat(IntToStr(StrCopyE(buf,'Act'),ActionItem.dwActID),'_FirstRun');
  if DBReadByte(0,opt_UA,buf,0)<>0 then
  begin
    CAllService(MS_ACT_RUNBYID,ActionItem.dwActID,0);
    DBDeleteSetting(0,opt_UA,buf);
  end;
end;

procedure DeleteUAction(num:integer);
var
  ActionItem:pMyActionItem;
  buf:array [0..63] of AnsiChar;
begin
  DeleteUASettings(num);

  ActionItem:=@UActionList[num];

  DeleteIcolibIcon(ActionItem^);

  if (ActionItem.flags and UAF_REGHOTKEY)<>0 then
    DeleteCoreHotkey(ActionItem^);

  if (ActionItem.flags and UAF_REGMTBB)<>0 then
    DeleteMTBButton(ActionItem^);

  if (ActionItem.flags and UAF_REGTABB)<>0 then
    DeleteTabBBButton(ActionItem^);

  if (ActionItem.flags and UAF_REGMMENU)<>0 then
    DeleteMainMenuItem(ActionItem^);

  if (ActionItem.flags and UAF_REGCMENU)<>0 then
    DeleteContactMenuItem(ActionItem^);

  if (ActionItem.flags and UAF_REGTMENU)<>0 then
    DeleteTrayMenuItem(ActionItem^);

  if ((ActionItem.flags and (UAF_REGMMENU or UAF_REGCMENU or UAF_REGTMENU))=0) and
      (ActionItem.hMenuService<>0) then
  begin
    PluginLink^.DestroyServiceFunction(ActionItem.hMenuService);
    ActionItem.hMenuService:=0;
  end;

  StrCat(IntToStr(StrCopyE(buf,'Act'),ActionItem.dwActID),'_FirstRun');
  DBDeleteSetting(0,opt_UA,buf);

  // Free Memory
  mFreeMem(ActionItem.szNameID);
  mFreeMem(ActionItem.szActDescr);
  
  mFreeMem(ActionItem.szMTBTooltip);
  mFreeMem(ActionItem.szMTBTooltipPressed);

  mFreeMem(ActionItem.szTabBTooltip);
  mFreeMem(ActionItem.szTabBTooltipPressed);

  with ActionItem.UAMenuItem[main_menu] do
  begin
    mFreeMem(szMenuPopup);
    mFreeMem(szMenuNameVars);
    mFreeMem(szMenuShowWhenVars);
  end;

  with ActionItem.UAMenuItem[contact_menu] do
  begin
    mFreeMem(szMenuPopup);
    mFreeMem(szMenuNameVars);
    mFreeMem(szMenuShowWhenVars);
  end;

  with ActionItem.UAMenuItem[tray_menu] do
  begin
    mFreeMem(szMenuPopup);
    mFreeMem(szMenuNameVars);
    mFreeMem(szMenuShowWhenVars);
  end;

  // compact list
  if num<HIGH(UActionList) then
  begin
    move(UActionList[num+1],UActionList[num],(HIGH(UACtionList)-num)*SizeOf(tMyActionItem));
  end;
  SetLength(UActionList,Length(UActionList)-1);
end;

function AddUAction(idx:integer; ptr:pChain):integer;
var
  buf:array [0..127] of AnsiChar;
begin
  result:=-1;
  if idx<0 then idx:=Length(UActionList);
  if idx=Length(UActionList) then
    SetLength(UActionList,Length(UActionList)+1);

  FillChar(UActionList[idx],SizeOf(tMyActionItem),0);

  with UActionList[idx] do
  begin
    // get Action settings
    dwActID:=ptr^.id;
    if (ptr^.flags and ACCF_DISABLED)<>0 then
      flags:=UAF_DISABLED;
    StrDupW(szActDescr,ptr^.descr);
    wSortIndex:=idx;
    
    // prepare for work
    IntToStr(StrCopyE(buf,'Actions/Action_'),ptr^.id);
    StrDup(szNameID,@buf);
    AddIcolibIcon(UActionList[idx]);
  end;
end;

function CreateUActionList:integer;
var
  ptr,ptr1:pChain;
  i:integer;
begin
  result:=CallService(MS_ACT_GETLIST,0,LPARAM(@ptr));
  SetLength(UActionList,result);
  if result>0 then
  begin
    ptr1:=ptr;
    inc(pbyte(ptr),4);
    for i:=0 to result-1 do
    begin
      AddUAction(i,ptr);
      LoadUA(i); // just here coz at list changes for new we don't have settings
//      SetAllActionUsers(ActItem); // will need to repeat at changes :(
      inc(ptr);
    end;
    CallService(MS_ACT_FREELIST,0,LPARAM(ptr1));
  end;
end;

function ActListChange(wParam:WPARAM;lParam:LPARAM):integer; cdecl;
var
  ptr,ptr1:pChain;
  idx,i,j,count:integer;
  bFound:boolean;
begin
  result:=0;

  count:=CallService(MS_ACT_GETLIST,0,TLPARAM(@ptr));

  if count>0 then
  begin
    ptr1:=ptr;
    inc(pbyte(ptr),4);
    // maybe add ACTM_RELOAD (as NEW and DELETE) here too?
    if (wParam and (ACTM_NEW or ACTM_RENAME or ACTM_SORT or ACTM_DELETE))<>0 then
      for i:=0 to count-1 do
      begin
        // search corresponding element
        idx:=-1;
        for j:=0 to HIGH(UActionList) do
        begin
          if UActionList[j].dwActID=ptr^.id then
          begin
            idx:=j;
            break;
          end;
        end;
        // if we have no item in list for this action - then add new one
        if idx<0 then
          AddUAction(-1,ptr)
        else
        begin
          if (wParam and ACTM_RENAME)<>0 then
          begin
            // check for time economy - no need to change ALL items
            if StrCmpW(UActionList[idx].szActDescr,ptr^.descr)<>0 then
            begin
              mFreeMem(UActionList[idx].szActDescr);
              StrDupW (UActionList[idx].szActDescr,ptr^.descr);
            end;
          end;

          if (wParam and (ACTM_SORT or ACTM_DELETE or ACTM_NEW))<>0 then
            UActionList[idx].wSortIndex:=i;
        end;
        inc(ptr);
      end;
  end
  else
    ptr1:=nil;

  // now search deleted items
  if (wParam and ACTM_DELETE)<>0 then
  begin
    for j:=HIGH(UActionList) downto 0 do
    begin
      bFound:=false;
      if count>0 then
      begin
        ptr:=ptr1;
        inc(pbyte(ptr),4);
        for i:=0 to count-1 do
        begin
          if UActionList[j].dwActID=ptr^.id then
          begin
            bFound:=true;
            break;
          end;
          inc(ptr);
        end;
      end;
      if not bFound then
        DeleteUAction(j);
    end;
  end;

  if count>0 then
    CallService(MS_ACT_FREELIST,0,TLPARAM(ptr1));

  if settings<>0 then FillActionList(settings);
end;
